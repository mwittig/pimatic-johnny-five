module.exports = (env) ->

  Promise = env.require 'bluebird'
  _ = env.require 'lodash'
  five = require('johnny-five')
  commons = require('pimatic-plugin-commons')(env)


  # Device class representing an Johnny Five servo
  class JohnnyFiveServo extends env.devices.ButtonsDevice

    # Create a new JohnnyFiveServo device
    # @param [Object] config    device configuration
    # @param [JohnnyFivePlugin] plugin   plugin instance
    # @param [Object] lastState state information stored in database
    constructor: (@config, @plugin, lastState) ->
      @id = @config.id
      @name = @config.name
      for b in @config.buttons
        b.text = b.id unless b.text?
      @debug = @plugin.config.debug || false
      super(@config)
      @_base = commons.base @, @config.class
      @boardHandle = @plugin.boardManager.getBoard(@config.boardId)
      #console.log("----------------------", lastState)

      @boardHandle.boardReady()
        .then (board)=>
          @_base.debug "initializing digital output pin #{@config.pin}"
          @servo = new five.Servo {
            pin: @config.pin
            controller: @config.controller
            address: parseInt @config.address
            type: @config.type
            range: @config.range
            board: board
          }
        .catch (error) =>
          @_base.rejectWithError null, error


    destroy: () ->
      super()

    buttonPressed: (buttonId) ->
      for b in @config.buttons
        if b.id is buttonId
          @_lastPressedButton = b.id
          @emit 'button', b.id
          @servo[b.id]()
          return Promise.resolve()

      throw new Error("No button with the id #{buttonId} found")
