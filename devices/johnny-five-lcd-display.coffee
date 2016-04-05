module.exports = (env) ->

  Promise = env.require 'bluebird'
  commons = require('pimatic-plugin-commons')(env)


  # Device class representing a Johnny Five LCD display
  class JohnnyFiveLcdDisplay extends env.devices.Device

    # Create a new JohnnyFiveLcdDisplay device
    # @param [Object] config    device configuration
    # @param [JohnnyFivePlugin] plugin   plugin instance
    # @param [Object] lastState state information stored in database
    constructor: (@config, plugin, lastState) ->
      @id = @config.id
      @name = @config.name
      @debug = @plugin.config.debug || false
      @_base = commons.base @, @config.class
      super()

