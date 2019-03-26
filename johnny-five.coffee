# Johnny Five plugin
module.exports = (env) ->

  BoardManager = require('./board-manager')(env)
  deviceTypes = {}
  for device in [
#    'johnny-five-lcd-display'
    'johnny-five-oled-display'
    'johnny-five-switch'
    'johnny-five-contact-sensor'
    'johnny-five-presence-sensor'
    'johnny-five-button'
    'johnny-five-relay'
    'johnny-five-pwm-output'
    'johnny-five-temperature'
    'johnny-five-temperature-humidity'
    'johnny-five-temperature-pressure'
    'johnny-five-rgb-led'
    'johnny-five-servo'
  ]
    # convert kebap-case to camel-case notation with first character capitalized
    className = device.replace /(^[a-z])|(\-[a-z])/g, ($1) -> $1.toUpperCase().replace('-','')
    deviceTypes[className] = require('./devices/' + device)(env)

  actionProviders = {}
  for provider in [
    'johnny-five-rgb-color-action'
  ]
    # convert kebap-case to camel-case notation with first character capitalized
    className = provider.replace(/(^[a-z])|(\-[a-z])/g, ($1) -> $1.toUpperCase().replace('-','')) + 'Provider'
    actionProviders[className] = require('./actions/' + provider)(env)

  # ###JohnnyFivePlugin class
  class JohnnyFivePlugin extends env.plugins.Plugin

    init: (app, @framework, @config) =>
      @boardManager = new BoardManager(@config, @)

      # register devices
      deviceConfigDef = require("./device-config-schema")

      for className, classType of deviceTypes
        env.logger.debug "Registering device class #{className}"
        @framework.deviceManager.registerDeviceClass(className, {
          configDef: deviceConfigDef[className],
          createCallback: @callbackHandler(className, classType)
        })

      for className, classType of actionProviders
        env.logger.debug "Registering action provider #{className}"
        @framework.ruleManager.addActionProvider(new classType @framework)

    callbackHandler: (className, classType) ->
      # this closure is required to keep the className and classType context as part of the iteration
      return (config, lastState) =>
        return new classType(config, @, lastState)


  # ###Finally
  # Create a instance of my plugin
  # and return it to the framework.
  return new JohnnyFivePlugin