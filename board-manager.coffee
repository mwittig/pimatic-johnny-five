# Class UniPiUpdateManager
module.exports = (env) ->

  Promise = env.require 'bluebird'
  _ = env.require 'lodash'
  net = require 'net'
  events = require 'events'
  url = require 'url'
  util = require 'util'
  five = require('johnny-five')
  commons = require('pimatic-plugin-commons')(env)

  class BoardWrapper extends five.Board
    constructor: (opts) ->
      @boardIsReady = false
      @debug = opts.debug || false
      super(opts)
      @_base = commons.base @, "Board"

      @boardInit = new Promise((resolve, reject) =>
        @once "ready", @_boardReadyHandler(resolve, reject)
        @once "error", @_boardNotReadyHandler(resolve, reject)
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
        @removeListener "error", @_boardNotReadyHandler(resolve, reject)
        resolve @board

    _boardNotReadyHandler: (resolve, reject) ->
      return (error) =>
        @removeListener "ready", @_boardReadyHandler(resolve, reject)
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
          @board = new BoardWrapper(_.assign({}, options, {repl: false}))
        )
        when 'raspi-io' then (
          raspi = require 'raspi-io'
          @board = new BoardWrapper(_.assign({}, options, {io: new raspi(), repl: false}))
        )
        when 'etherport' then (
          etherport = require 'etherport'
          firmata = require('firmata')
          @board = new BoardWrapper
            id: options.id
            io: new firmata.Board(new etherport({port: options.port}))
            remote: true
            repl: false
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
        _base.error error
        throw error