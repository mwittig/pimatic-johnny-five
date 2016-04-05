module.exports = (env) ->

  Promise = env.require 'bluebird'
  _ = env.require 'lodash'
  five = require('johnny-five')
  commons = require('pimatic-plugin-commons')(env)


  # Device class representing an Johnny Five temperature and humidity sensor
  class JohnnyFiveTemperatureHumidity extends env.devices.TemperatureSensor

    attributes:
      temperature:
        description: "the measured temperature"
        type: "number"
        unit: '°C'
        acronym: 'T'
      humidity:
        description: "the measured relative humidity"
        type: "number"
        unit: '%'
        acronym: 'RH'

    # Create a new JohnnyFiveTemperatureHumidity device
    # @param [Object] config    device configuration
    # @param [JohnnyFivePlugin] plugin   plugin instance
    # @param [Object] lastState state information stored in database
    constructor: (@config, @plugin, lastState) ->
      @id = @config.id
      @name = @config.name
      @debug = @plugin.config.debug || false
      @_base = commons.base @, @config.class
      @_temperature = lastState?.temperature?.value or null
      @_humidity = lastState?.humidity?.value or null
      @_temperatureOffset = @config.temperatureOffset || 0
      @_humidityOffset = @config.humidityOffset || 0
      @_temperatureKey = "celsius"
      if @config.units is "imperial"
        @attributes["temperature"].unit = '°F'
        @_temperatureKey = "fahrenheit"
      else if @config.units is "standard"
        @attributes["temperature"].unit = 'K'
        @_temperatureKey = "kelvin"
      @boardHandle = @plugin.boardManager.getBoard(@config.boardId)
      super()

      @boardHandle.boardReady()
        .then( (board)=>
          try
            address = if address then parseInt(address) else undefined
            @multi = new five.Multi {
              pin: @config.pin || undefined
              address: address
              freq: 1000 * (@config.interval || 10)
              controller: @config.controller || 'ANALOG'
              board: board
            }
          catch error
            throw error

          @multi.on("data", =>
            temperature = if @multi.thermometer? then @multi.thermometer[@_temperatureKey] else null
            humidity = if @multi.hygrometer.relativeHumidity? then @multi.hygrometer.relativeHumidity else null
            @_base.debug "temperature (raw): #{temperature} #{@_temperatureKey} (offset) #{@_temperatureOffset}"
            @_base.debug "humidity (raw): #{humidity} (offset) #{@_humidityOffset}"
            @_setTemperature temperature + @_temperatureOffset
            @_base.setAttribute "humidity", humidity + @_humidityOffset
          )
        )
        .catch (error) =>
          @_base.rejectWithError null, error

    getTemperature: ->
      @boardHandle.boardReady()
        .then =>
          Promise.resolve(@_temperature)

    getHumidity: ->
      @boardHandle.boardReady()
        .then =>
          Promise.resolve(@_humidity)