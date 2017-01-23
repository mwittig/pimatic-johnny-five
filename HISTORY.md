# Release History

* 20170123, V0.9.11
    * Bug fixture: added missing require statement for new action
    
* 20170123, V0.9.10
    * Added support for software PWM for raspi-io
    * Added support for excluding pins from use with raspi-io. This might be useful if other GPIO drivers are used
      like pimatic-dht-sensors
    * Added RGBLedDevice to provide control for common cathode/common cathode LEDs and PCA9685,
      an I2C-bus controlled 16-channel LED controller
    * Revised README and docs
    
* 20170117, V0.9.9
    * Improved device schema for temperature unit properties to editable with device editor
    * Added debug mode property to enable plugin debugging mode
    
* 20170116, V0.9.8
    * Improved error handling for the expander board, i.e. handle i2c errors due to misconfiguration
    * Improved board configuration handling

* 20170115, V0.9.7
    * Fixed initialization bug for expander board when used with raspi-io, issue #54
    * Dependency updates
    
* 20161105, V0.9.6
    * Fixed handling of i2c address property, issue #47
    * Remove data listener on destruction of temperature device
    * Added helper to release pins for analog sensors on destruction
    
* 20161105, V0.9.5
    * fix for invalid I2C address problem, issue 46
    * Revised README
    
* 20161027, V0.9.4
    * Dependency updates
    * Added JohnnyFiveTemperaturePressure device type, thanks @kanedo
    
* 20160512, V0.9.3
    * Dependency updates
    * Removed beta tag

* 20160506, V0.9.2 (beta)
    * Dependency updates
    * Added badges and travis build descriptor
    
* 20160503, V0.9.1 (beta)
    * Dependency updates
    
* 20160427, V0.9.0 (beta)
    * Added ESP-8266 board support (experimental)
    * Pimatic 0.9 compatibility changes
    * Dependency updates
    * Moved release history to separate file
    * Added license info to README
    
* 20160305, V0.8.8
    * Dependency updates. Now includes support for Raspberry Pi 3
    * Fixed some typos

* 20160210, V0.8.7
    * Fixed initialization for "particle-io" boards, issue #3 - thanks @hoodpablo
    * Updated README, fixed switch example

* 20160123, V0.8.6
    * Updated dependency on "raspi-io" to include support for enabling pull up resistors by writing HIGH to the pin while in INPUT mode
    * Tweaked johnny-five to allow for longer board initialization timeouts to provide for slow initialization of some Arduinos
    * Added note to README about installation issue

* 20160121, V0.8.5
    * Added support for Expander boards
    * Improved support for setup of remote boards
    * Improved robustness and error handling

* 20160112, V0.8.4
    * Fixed dependency on etherport fork, thanks to @rubenoost7

* 20151229, V0.8.3
    * Added board config option to set baudrate
    * Fixed error in getBoard() function

* 20151228, V0.8.2
    * Fix: Added missing board-manager.coffee to files property

* 20151228, V0.8.1
    * Added experimental support for Photon boards
    * Updated dependency on pimatic-plugin-commons
    * Updated README

* 20151222, V0.8.0
    * First release