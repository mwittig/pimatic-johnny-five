module.exports = (env) ->

  Promise = env.require 'bluebird'
  _ = env.require 'lodash'
  five = require('johnny-five')
  commons = require('pimatic-plugin-commons')(env)


  # Device class representing an Johnny Five digital input
  class JohnnyFivePresenceSensor extends env.devices.PresenceSensor

    # Create a new JohnnyFivePresenceSensor device
    # @param [Object] config    device configuration
    # @param [JohnnyFivePlugin] plugin   plugin instance
    # @param [Object] lastState state information stored in database
    constructor: (@config, @plugin, lastState) ->
      @id = config.id
      @name = config.name
      @debug = @plugin.config.debug || false
      @_invert = config.invert || false
      @_presence = @_invert
      @_base = commons.base @, config.class
      @board = plugin.boardManager.getBoard(config.boardId)
      super()

      @board.boardReady()
      .then (board)=>
        @pin = new five.Pin {
          pin: config.pin
          type: "digital"
          mode: 0
          board: board
        }
        @boardReady = true
        @pin.on("high", =>
          @_base.debug "#{@id} pin #{@config.pin} HIGH"
          @_setPresence(!@_invert)
        )
        @pin.on("low", =>
          @_base.debug "#{@id} pin #{@config.pin} LOW"
          @_setPresence(@_invert)
        )
      .catch (error) =>
        @_base.rejectWithError null, error


    getPresence: () ->
      return new Promise( (resolve, reject) =>
        @board.boardReady()
          .then =>
            resolve @_presence
          .catch (error) =>
            @_base.rejectWithError reject, error
      )