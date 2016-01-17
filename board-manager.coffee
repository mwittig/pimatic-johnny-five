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
        if @opts.board.isReady
          @_boardReadyHandler(resolve, reject)()
        else
          @_boardReadyListener = @_boardReadyHandler(resolve, reject)
          @_boardNotReadyListener = @_boardNotReadyHandler(resolve, reject)
          @opts.board.once "ready", @_boardReadyListener
          @opts.board.once "error", @_boardNotReadyListener
      )

    _boardReadyHandler: (resolve, reject) ->
      return () =>
        @boardIsReady = true
        expanderOptions =
          controller: @opts.controller
          address: @opts.address
        @virtual = new five.Board({
          io:  new five.Expander(expanderOptions),
          board: @opts.board
          repl: false,
          debug: false,
          sigint: false
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
              config = _.assign {}, boardConfig
              config.debug = @debug
              @boards[config.id] = @createBoard(config)
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
            SerialPort = require('serialport').SerialPort
            options.port = new SerialPort(options.port, {baudrate: options.baudrate})
          @board = new BoardWrapper(_.assign({}, options, {repl: false}))
        )
        when 'raspi-io' then (
          raspi = require 'raspi-io'
          @board = new BoardWrapper(_.assign({}, options, {io: new raspi(), repl: false}))
        )
        when 'spark-io' then (
          spark = require 'spark-io'
          @board = new BoardWrapper(_.assign({}, options, {io: new spark(), repl: false}))
        )
        when 'etherport' then (
          etherport = require 'etherport'
          firmata = require('firmata')
          @board = new BoardWrapper
            id: options.id
            io: new firmata.Board(new etherport({port: options.port}))
            remote: false
            repl: false
        )
        when 'expander' then (
          parentBoard =  @getBoard options.port
          @board = new ExpanderBoardMapper(_.assign({}, options, {board: parentBoard}))
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