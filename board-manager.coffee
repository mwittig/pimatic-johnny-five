# Class UniPiUpdateManager
module.exports = (env) ->

  Promise = env.require 'bluebird'
  _ = env.require 'lodash'
  events = require 'events'
  util = require 'util'
  five = require('johnny-five')
  commons = require('pimatic-plugin-commons')(env)

  class ExpanderBoardMapper
    constructor: (@opts) ->
      @boardIsReady = false
      @debug = @opts.debug || false
      @id = @opts.id
      @_base = commons.base @, "ExpanderBoard"
      if not @opts.controller?
        throw new Error "Missing controller property for expander board"

      @boardInit = new Promise((resolve, reject) =>
        @_boardReadyListener = @_boardReadyHandler(resolve, reject)
        @_boardNotReadyListener = @_boardNotReadyHandler(resolve, reject)
        if @opts.board.isReady
          @_boardReadyListener()
        else
          @opts.board.once "ready", @_boardReadyListener
          @opts.board.once "error", @_boardNotReadyListener
      )

    _boardReadyHandler: (resolve, reject) ->
      return () =>
        @boardIsReady = true
        expanderOptions =
          controller: @opts.controller
        if @opts.address?
          expanderOptions.address = @opts.address
        @virtual = new five.Board.Virtual({
          io:  new five.Expander(expanderOptions),
          board: @opts.board
        })
        @opts.board.removeListener "error", @_boardNotReadyListener if @_boardNotReadyListener?
        @virtual.remote = false
        @_base.debug "Board Ready"
        resolve @virtual

    _boardNotReadyHandler: (resolve, reject) ->
      return (error) =>
        @opts.board.removeListener "ready", @_boardReadyListener if @_boardReadyListener?
        @_base.rejectWithError(reject, error)

    boardReady: () ->
      return new Promise( (resolve, reject) =>
        Promise.settle([@boardInit])
        .then () =>
          if @boardIsReady
            resolve @virtual
          else
            @_base.rejectWithError(reject, new Error "Board not ready")
        .catch (error) =>
          @_base.rejectWithError(reject, error)
      )


  class BoardWrapper extends five.Board
    constructor: (opts) ->
      super(opts)
      @boardIsReady = false
      @debug = opts.debug || false
      @_base = commons.base @, "Board"

      @boardInit = new Promise((resolve, reject) =>
        @_boardReadyListener = @_boardReadyHandler(resolve, reject)
        @_boardNotReadyListener = @_boardNotReadyHandler(resolve, reject)
        if @isReady
          @_boardReadyListener()
        else
          @once "ready", @_boardReadyListener
          @once "error", @_boardNotReadyListener
        @on "message", (event) =>
          @_base.debug "Message received:", event.message
        @on "error", (error) =>
          @_base.error "Board not ready:", error.message.replace("\n", "")
        @on "ready", =>
          @_base.debug "Board Ready"
      )

    _boardReadyHandler: (resolve, reject) ->
      return () =>
        @boardIsReady = true
        @removeListener "error", @_boardNotReadyListener if @_boardNotReadyListener?
        resolve @board

    _boardNotReadyHandler: (resolve, reject) ->
      return (error) =>
        @removeListener "ready", @_boardReadyListener if @_boardReadyListener?
        @_base.rejectWithError(reject, error)

    boardReady: () ->
      return new Promise( (resolve, reject) =>
        Promise.settle([@boardInit])
        .then () =>
          if @boardIsReady
            resolve @
          else
            @_base.rejectWithError(reject, new Error "Board not ready")
        .catch (error) =>
          @_base.rejectWithError(reject, error)
      )

  class BoardManager extends events.EventEmitter

    constructor: (@config, plugin) ->
      @boards = {}
      @debug = plugin.config.debug || false
      @_base = commons.base @, "BoardManager"
      super()

      boardConfigs = @config.boards
      if boardConfigs? and boardConfigs.length isnt 0
        for boardConfig in @config.boards
          if boardConfig.id?
            try
              @boards[boardConfig.id] = @createBoard(_.assign {debug: @debug, repl: false, timeout: 40000}, boardConfig)
              @_base.debug "Created board #{boardConfig.id}"
            catch e
              @_base.error "Creation of board #{boardConfig.id} raised exception:" + e
          else
            @_base.error "Invalid plugin configuration. Missing board id"
      else
        @_base.error "Invalid plugin configuration. No boards configured"


    createBoard: (options) ->
      switch options.boardType || 'arduino'
        when 'arduino' then (
          if options.port? and options.baudrate?
            fiveModule = require.cache[require.resolve 'johnny-five']
            SerialPort = fiveModule.require('serialport').SerialPort;
            options.port = new SerialPort(options.port, {baudrate: options.baudrate})
          @board = new BoardWrapper options
        )
        when 'raspi-io' then (
          raspi = require 'raspi-io'
          @board = new BoardWrapper(_.assign(options, {io: new raspi()}))
        )
        when 'particle-io' then (
          Particle = require 'particle-io'
          @board = new BoardWrapper(_.assign(options, {io: new Particle({
            token: options.token, deviceId: options.deviceId })}))
        )
        when 'etherport' then (
          EtherPort = require 'etherport'
          @board = new BoardWrapper(_.assign(options, {port: new EtherPort({
            port: options.port, reset: options.port || false})}))
        )
        when 'etherport-client', 'esp8266' then (
          EtherPortClient = require('etherport-client').EtherPortClient
          @board = new BoardWrapper(_.assign(options, {
            port: new EtherPortClient({
              port: options.port,
              host: options.address
            })
          }))
        )
        when 'expander' then (
          parentBoard =  @getBoard options.port
          @board = new ExpanderBoardMapper(_.assign(options, {board: parentBoard}))
        )
        else
          throw new Error "Unsupported boardType #{options.boardType}"

      return @board

    getBoard: (id) ->
      if @boards[id]
        board=@boards[id]
      if board?
        return board
      else
        error = new Error "Board not found"
        @_base.error error
        throw error