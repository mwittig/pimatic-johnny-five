module.exports = (env) ->

  Promise = env.require 'bluebird'
  _ = env.require 'lodash'
  five = require('johnny-five')
  commons = require('pimatic-plugin-commons')(env)


  # Device class representing an Johnny Five temperature and pressure sensor
  class JohnnyFiveTemperaturePressure extends env.devices.TemperatureSensor

    attributes:
      temperature:
        description: "the measured temperature"
        type: "number"
        unit: '°C'
        acronym: 'T'
      pressure:
        description: "the measured pressure"
        type: "number"
        unit: 'hPa'
        acronym: 'P'

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
      @_pressure = lastState?.pressure?.value or null
      @_temperatureOffset = @config.temperatureOffset || 0
      @_pressureOffset = @config.pressureOffset || 0
      @_elevation = @config.elevation || 0
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
            @multi = new five.Multi {
              pin: @config.pin || undefined
              address: if not _.isEmpty @config.address then parseInt @config.address else undefined
              freq: 1000 * (@config.interval || 10)
              controller: @config.controller || 'MS5611'
              board: board,
              elevation: @_elevation
            }
          catch error
            throw error

          @multi.on("data", =>
            temperature = if @multi.thermometer? then @multi.thermometer[@_temperatureKey] else null
            pressure = if @multi.barometer.pressure? then @multi.barometer.pressure else null
            @_base.debug "temperature (raw): #{temperature} #{@_temperatureKey} (offset) #{@_temperatureOffset}"
            @_base.debug "pressure (raw): #{pressure} (offset) #{@_pressureOffset}"
            @_setTemperature temperature + @_temperatureOffset
            @_base.setAttribute "pressure", pressure * 10 + @_pressureOffset
          )
        )
        .catch (error) =>
          @_base.rejectWithError null, error


    destroy: () ->
      @multi.removeAllListeners 'data' if @multi?
      @boardHandle.releasePin @config.pin, @config.controller || 'ANALOG'
      delete @multi
      super()


    getTemperature: ->
      @boardHandle.boardReady()
        .then =>
          Promise.resolve(@_temperature)

    getPressure: ->
      @boardHandle.boardReady()
        .then =>
          Promise.resolve(@_pressure)