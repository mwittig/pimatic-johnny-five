module.exports = (env) ->

  Promise = env.require 'bluebird'
  _ = env.require 'lodash'
  five = require('johnny-five')
  commons = require('pimatic-plugin-commons')(env)


  # Device class representing an Johnny Five digital input
  class JohnnyFiveButton extends env.devices.ContactSensor

    # Create a new JohnnyFiveButton device
    # @param [Object] config    device configuration
    # @param [JohnnyFivePlugin] plugin   plugin instance
    # @param [Object] lastState state information stored in database
    constructor: (@config, @plugin, lastState) ->
      @id = config.id
      @name = config.name
      @debug = true
      @_contact = false
      @_base = commons.base @, config.class
      @board = plugin.boardManager.getBoard(config.boardId)
      super()

      @_base.setAttribute("contact", if config.pullUp then true else false)
      @board.boardReady()
        .then( (board)=>
          try
            @button = new five.Button {
              pin: config.pin
              pullup: config.pullUp || false
              invert: config.invert || false
              holdtime: config.holdTime || 500
              controller: config.controller || undefined
              board: board
            }
          catch error
            throw error

          @button.on("hold", =>
            @_base.debug "#{@id} pin #{@config.pin} HOLD"
            @_base.setAttribute("contact", true)
          )
          @button.on("press", =>
            @_base.debug "#{@id} pin #{@config.pin} PRESS"
          )
          @button.on("release", =>
            @_base.debug "#{@id} pin #{@config.pin} RELEASE"
            @_base.setAttribute("contact", false)
          )
        )
        .catch (error) =>
          @_base.rejectWithError null, error


    getContact: () ->
      return Promise.resolve @_contact