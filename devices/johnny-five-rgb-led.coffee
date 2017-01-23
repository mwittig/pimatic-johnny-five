module.exports = (env) ->

  types = env.require('decl-api').types
  Promise = env.require 'bluebird'
  _ = env.require 'lodash'
  five = require('johnny-five')
  commons = require('pimatic-plugin-commons')(env)


  # Device class representing an Johnny Five digital PWM output
  class JohnnyFiveRgbLed extends env.devices.DimmerActuator

    @attributes =
      color:
        description: 'RGB hex string fo the LED color value'
        type: types.string
        unit: 'hex color'
        acronym: 'RGB'
    @actions =
      setColor:
        description: 'set a light color'
        params:
          colorCode:
            type: types.string

    # Create a new JohnnyFiveRgbLed device
        # @param [Object] config    device configuration
        # @param [JohnnyFivePlugin] plugin   plugin instance
        # @param [Object] lastState state information stored in database
    constructor: (@config, @plugin, lastState) ->
      @id = @config.id
      @name = @config.name
      @debug = @plugin.config.debug || false
      @_dimlevel = 0
      @_state = off
      @_base = commons.base @, @config.class
      @boardHandle = @plugin.boardManager.getBoard(@config.boardId)
      @attributes = _.merge {}, @attributes, JohnnyFiveRgbLed.attributes
      @actions = _.merge {}, @actions, JohnnyFiveRgbLed.actions
      super()


      @boardHandle.boardReady()
      .then( (board)=>
        @pin = new five.Led.RGB {
          pins: @config.pins
          isAnode: @config.isAnode
          board: board
        }
        @changeDimlevelTo(lastState?.dimlevel?.value or 0)
        .catch (error) =>
          @_base.rejectWithError null, error
      )
      .catch ((error) =>
        @_base.rejectWithError null, error
      )

    destroy: () ->
      super()

    _queryLevel: () ->
      return new Promise( (resolve, reject) =>
        @boardHandle.boardReady()
        .then =>
          try
            resolve if @pin.isOn then @pin.intensity() else 0
          catch e
            @_base.rejectWithError reject, e
        .catch (error) =>
          @_base.rejectWithError reject, error
      )

    _componentToHex: (c) ->
      hex = c.toString 16
      if hex.length is 1 then '0' + hex else hex


    _rgbToHex: (r, g, b) ->
      '#' + @_componentToHex(r) + @_componentToHex(g) + @_componentToHex(b)
  
    _queryColor: () ->
      return new Promise( (resolve, reject) =>
        @boardHandle.boardReady()
        .then =>
          try
            color = @pin.color()
            resolve @_rgbToHex color.red, color.green, color.blue
          catch e
            @_base.rejectWithError reject, e
        .catch (error) =>
          @_base.rejectWithError reject, error
      )

    changeDimlevelTo: (newLevelPerCent) ->
      @_base.debug "dimlevel change requested to (per cent): #{newLevelPerCent}"
      return new Promise( (resolve, reject) =>
        @boardHandle.boardReady()
        .then =>
          try
            @pin.intensity newLevelPerCent
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

    getColor: () ->
      @_queryColor()
      .then (color) =>
        return Promise.resolve color
      .catch (error) =>
        return @_base.rejectWithError Promise.reject, error

    setColor: (color) ->
      @_base.debug "color change requested to: color"
      return new Promise( (resolve, reject) =>
        @boardHandle.boardReady()
        .then =>
          try
            @pin.color color
          catch e
            @_base.rejectWithError reject, e
          @_queryColor()
          .then (c) =>
            @_base.setAttribute 'color', c
            resolve c
        .catch (error) =>
          @_base.rejectWithError reject, error
      )
