module.exports = (env) ->

  Promise = env.require 'bluebird'
  _ = env.require 'lodash'
  five = require('johnny-five')
  commons = require('pimatic-plugin-commons')(env)


  # Device class representing an Johnny Five digital PWM output
  class JohnnyFivePwmOutput extends env.devices.DimmerActuator

    # Create a new JohnnyFivePwmOutput device
    # @param [Object] config    device configuration
    # @param [JohnnyFivePlugin] plugin   plugin instance
    # @param [Object] lastState state information stored in database
    constructor: (@config, @plugin, lastState) ->
      @id = config.id
      @name = config.name
      @debug = true
      @_dimlevel = 0
      @_state = off
      @_base = commons.base @, config.class
      @board = plugin.boardManager.getBoard(config.boardId)
      super()

      @board.boardReady()
      .then( (board)=>
        @pin = new five.Led {
          pin: config.pin
          board: board
        }
        @changeDimlevelTo(lastState?.dimlevel?.value or 0)
          .catch (error) =>
            @_base.rejectWithError null, error
      )
      .catch ((error) =>
        @_base.rejectWithError null, error
      )


    _queryLevel: () ->
      return new Promise( (resolve, reject) =>
        @board.boardReady()
          .then =>
            try
              resolve @pin.value * 100 / 255
            catch e
              @_base.rejectWithError reject, e
          .catch (error) =>
            @_base.rejectWithError reject, error
      )


    changeDimlevelTo: (newLevelPerCent) ->
      @_base.debug "dimlevel change requested to (per cent): #{newLevelPerCent}"
      return new Promise( (resolve, reject) =>
        @board.boardReady()
          .then =>
            try
              @pin.brightness newLevelPerCent * 255 / 100
            catch e
              @_base.rejectWithError reject, e
            @_queryLevel()
            .then (level) =>
              @_setDimlevel level
              resolve level
          .catch (error) =>
            @_base.rejectWithError reject, error
      )

    getState: () ->
      @_queryLevel()
        .then (level) =>
          return Promise.resolve level > 0
        .catch (error) =>
          return @_base.rejectWithError Promise.reject, error

    getDimlevel: () ->
      @_queryLevel()
        .then (level) =>
          return Promise.resolve level
        .catch (error) =>
          return @_base.rejectWithError Promise.reject, error