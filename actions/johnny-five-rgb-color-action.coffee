module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  _ = env.require 'lodash'
  M = env.matcher
  colors = require 'colornames'
  colorNames = colors.all().filter((v) -> v.css is true).map((v) -> v.name)

  class JohnnyFiveRgbColorActionHandler extends env.actions.ActionHandler
    constructor: (@provider, @device, @color, @variable) ->
      @_variableManager = @provider.framework.variableManager
      super()

    setup: ->
      @dependOnDevice(@device)
      super()

    executeAction: (simulate) =>
      if @variable?
        @_variableManager.evaluateStringExpression([@variable])
        .then (value) =>
          if value.match(/(#[a-fA-F\d]{6})(.*)/)? or colors(value)?
            @setColor value, simulate
          else
            Promise.reject new Error __("variable value #{value} is not a valid color")
      else
        @setColor @color, simulate

    setColor: (color, simulate) =>
      if simulate
        return Promise.resolve(__("would log set color #{color}"))
      else
        @device.setColor color
        return Promise.resolve(__("set color #{color}"))

  class JohnnyFiveRgbColorActionProvider extends env.actions.ActionProvider
    constructor: (@framework) ->
      super()

    parseAction: (input, context) =>
      j5ColorDevices = _(@framework.deviceManager.devices).values().filter(
        (device) => device.config.class is 'JohnnyFiveRgbLed'
      ).value()

      # Try to match the input string with: set ->
      m = M(input, context).match(['j5 set color '])

      device = null
      color = null
      match = null
      variable = null

      # device name -> color
      m.matchDevice j5ColorDevices, (m, d) ->
        # Already had a match with another device?
        if device? and device.id isnt d.id
          context?.addError(""""#{input.trim()}" is ambiguous.""")
          return

        device = d

        m.match [' to '], (m) ->
          m.or [
            # rgb hex like #00FF00
            (m) -> m.match [/(#[a-fA-F\d]{6})(.*)/], (m, s) ->
              color = s.trim()
              match = m.getFullMatch()

            # color name like red
            (m) -> m.match colorNames, (m, s) ->
              color = colors(s)
              match = m.getFullMatch()

             # a variable holding the color value
            (m) -> m.matchVariable (m, s) ->
              variable = s
              match = m.getFullMatch()
          ]

      if match?
        assert device?
        # either variable or color should be set
        assert variable? ^ color?
        assert typeof match is "string"
        return {
          token: match
          nextInput: input.substring(match.length)
          actionHandler: new JohnnyFiveRgbColorActionHandler(@, device, color, variable)
        }
      else
        return null

  return JohnnyFiveRgbColorActionProvider
