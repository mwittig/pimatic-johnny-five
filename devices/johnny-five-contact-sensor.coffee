module.exports = (env) ->

  Promise = env.require 'bluebird'
  _ = env.require 'lodash'
  five = require('johnny-five')
  commons = require('pimatic-plugin-commons')(env)
  

  # Device class representing an Johnny Five digital input
  class JohnnyFiveContactSensor extends env.devices.ContactSensor

    # Create a new JohnnyFiveContactSensor device
    # @param [Object] config    device configuration
    # @param [JohnnyFivePlugin] plugin   plugin instance
    # @param [Object] lastState state information stored in database
    constructor: (@config, @plugin, lastState) ->
      @id = config.id
      @name = config.name
      @debug = true
      @_invert = config.invert || false
      @_contact = @_invert
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
          @_setContact(!@_invert)
        )
        @pin.on("low", =>
          @_base.debug "#{@id} pin #{@config.pin} LOW"
          @_setContact(@_invert)
        )
      .catch (error) =>
        @_base.rejectWithError null, error


    getContact: () ->
      return new Promise( (resolve, reject) =>
        @board.boardReady()
        .then =>
          try
            @pin.query((state) =>
              resolve if state.state is 1 then !@_invert else @_invert
            )
          catch e
            @_base.rejectWithError reject, e
        .catch (error) =>
          @_base.rejectWithError reject, error
      )