# Release History

* 20160427, V0.8.9
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