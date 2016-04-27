module.exports = (env) ->

  Promise = env.require 'bluebird'
  _ = env.require 'lodash'
  five = require('johnny-five')
  commons = require('pimatic-plugin-commons')(env)

  # Device class representing an Johnny Five digital output
  class JohnnyFiveRelay extends env.devices.SwitchActuator

    # Create a new JohnnyFiveRelay device
    # @param [Object] config    device configuration
    # @param [JohnnyFivePlugin] plugin   plugin instance
    # @param [Object] lastState state information stored in database
    constructor: (@config, @plugin, lastState) ->
      @id = @config.id
      @name = @config.name
      @debug = @plugin.config.debug || false
      @_base = commons.base @, @config.class
      @_state = lastState?.state?.value or off
      @boardHandle = @plugin.boardManager.getBoard(@config.boardId)
      super()

      @boardHandle.boardReady()
      .then( (board)=>
        @relay = new five.Relay {
          pin: @config.pin
          type: "NC"
          board: board
        }
        @changeStateTo(@_state)
      )
      .catch ((error) =>
        @_base.rejectWithError null, error
      )


    destroy: () ->
      super()


    _queryState: () ->
      return new Promise( (resolve, reject) =>
        @boardHandle.boardReady()
          .then =>
            try
              resolve @relay.isOn
            catch e
              @_base.rejectWithError reject, e
          .catch (error) =>
            @_base.rejectWithError reject, error
      )


    changeStateTo: (newState) ->
      @_base.debug "state change requested to: #{newState}"
      return new Promise( (resolve, reject) =>
        @boardHandle.boardReady()
          .then =>
            if newState
              @relay.on()
            else
              @relay.off()
            @_setState newState
            resolve newState
          .catch (error) =>
            @_base.rejectWithError reject, error
      )


    getState: () ->
      return @_queryState()
        .then (state) =>
          return Promise.resolve state
        .catch (error) =>
          return @_base.rejectWithError Promise.reject
