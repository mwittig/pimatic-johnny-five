module.exports = (env) ->

  Promise = env.require 'bluebird'
  _ = env.require 'lodash'
  five = require('johnny-five')
  Oled = require('oled-js')
  font = require('oled-font-5x7')
  commons = require('pimatic-plugin-commons')(env)


  # Device class representing a Johnny Five OLED display
  class JohnnyFiveOledDisplay extends env.devices.Device
    attributes: {}

    # Create a new JohnnyFiveOledDisplay device
    # @param [Object] config    device configuration
    # @param [JohnnyFivePlugin] plugin   plugin instance
    # @param [Object] lastState state information stored in database
    constructor: (@config, @plugin, lastState) ->
      @id = @config.id
      @name = @config.name
      @rows = @config.rows || 2
      @cols = @config.cols || 16
      @debug = @plugin.config.debug || false
      @_base = commons.base @, @config.class

      oledOptions =
        width: 128
        height: 64
      if @config.address? and @config.address isnt ""
        oledOptions.address = @config.address
#      if @config.slavePin? and @config.slavePin isnt ""
#        oledOptions.slavePin = @config.slavePin
      @_base.debug "Oled config", oledOptions
      @board = @plugin.boardManager.getBoard(@config.boardId)
      super()

      @board.boardReady()
      .then( =>
        @board.wait 3000, =>
          @oled = new Oled(@board, five, oledOptions);
          @oled.clearDisplay()
          @oled.update();
#        @oled.clearDisplay()
#
          @oled.setCursor(0, 0);
          @oled.writeString(font, 1, '1234567890', 0, false, 2);
          @oled.update();

      )
      .catch ((error) =>
        @_base.rejectWithError null, error
      )


    destroy: () ->
      super()