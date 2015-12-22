module.exports = (env) ->

  Promise = env.require 'bluebird'
  _ = env.require 'lodash'
  five = require('johnny-five')
  commons = require('pimatic-plugin-commons')(env)


  # Device class representing an Johnny Five digital output
  class JohnnyFiveSwitch extends env.devices.SwitchActuator

    # Create a new JohnnyFiveSwitch device
    # @param [Object] config    device configuration
    # @param [JohnnyFivePlugin] plugin   plugin instance
    # @param [Object] lastState state information stored in database
    constructor: (@config, @plugin, lastState) ->
      @id = config.id
      @name = config.name
      @debug = @plugin.config.debug || false
      @_base = commons.base @, config.class
      @_state = off
      @board = plugin.boardManager.getBoard(config.boardId)
      super()

      @board.boardReady()
        .then (board)=>
          @_base.debug "initializing digital output pin #{config.pin}"
          @pin = new five.Pin {
            pin: config.pin
            type: "digital"
            mode: 1
            board: board
          }
          @changeStateTo lastState?.state?.value or off
        .catch (error) =>
          @_base.rejectWithError null, error


    _queryState: () ->
      return new Promise( (resolve, reject) =>
        @board.boardReady()
          .then =>
            try
              if (@board.remote)
                resolve @_state
              else
                @pin.query((state) =>
                  @_base.debug "Queried state is:", state.value
                  resolve if state.value is 1 then true else false
                )
            catch e
              @_base.rejectWithError reject, e
          .catch (error) =>
            @_base.rejectWithError reject, error
      )

    changeStateTo: (newState) ->
      @_base.debug "state change requested to: #{newState}"
      return new Promise (resolve, reject) =>
        @board.boardReady()
          .then =>
            stateVal = if newState then 1 else 0
            try
              @pin.write stateVal
            catch e
              @_base.rejectWithError reject, e

            if @board.remote
              @_setState newState
              resolve()
            else
              @_queryState()
                .then (state) =>
                  @_setState state
                  resolve()
          .catch (error) =>
            @_base.rejectWithError reject, error


    getState: () ->
      return Promise.resolve @_state
