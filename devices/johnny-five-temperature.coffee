module.exports = (env) ->

  Promise = env.require 'bluebird'
  _ = env.require 'lodash'
  five = require('johnny-five')
  commons = require('pimatic-plugin-commons')(env)


  # Device class representing an Johnny Five temperature sensor
  class JohnnyFiveTemperature extends env.devices.TemperatureSensor

    # Create a new JohnnyFiveTemperature device
    # @param [Object] config    device configuration
    # @param [JohnnyFivePlugin] plugin   plugin instance
    # @param [Object] lastState state information stored in database
    constructor: (@config, @plugin, lastState) ->
      @id = config.id
      @name = config.name
      @debug = @plugin.debug || false
      @_base = commons.base @, config.class
      @_temperature = lastState?.temperature?.value or null
      @_offset = config.offset || 0
      @_temperatureKey = "celsius"
      if config.units is "imperial"
        @attributes["temperature"].unit = '°F'
        @_temperatureKey = "fahrenheit"
      else if config.units is "standard"
        @attributes["temperature"].unit = 'K'
        @_temperatureKey = "kelvin"
      @board = plugin.boardManager.getBoard(config.boardId)
      super()

      @board.boardReady()
        .then( (board)=>
          address = if address then parseInt(address) else undefined
          try
            @thermometer = new five.Thermometer {
              pin: config.pin || undefined
              address: address
              freq: 1000 * (config.interval || 10)
              controller: config.controller || 'ANALOG'
              board: board
            }
          catch error
            throw error

          @thermometer.on("data", =>
            @_base.debug "temperature (raw): #{@thermometer[@_temperatureKey]} #{@_temperatureKey} (offset) #{@_offset}"
            @_setTemperature @thermometer[@_temperatureKey] + @_offset
          )
        )
        .catch (error) =>
          @_base.rejectWithError null, error

    

    getTemperature: ->
      @board.boardReady()
        .then =>
          Promise.resolve(@_temperature)