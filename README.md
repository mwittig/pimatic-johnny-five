
# pimatic-johnny-five

![Logo](https://github.com/mwittig/pimatic-johnny-five/raw/master/assets/images/johnny-five-icon.png)

Pimatic Plugin for [Johnny Five](http://johnny-five.io), a Robotics and IoT programming framework. Thanks to
Johnny Five, you can easily integrate a wide range of sensors and actuators attached to an Arduino board or your
Raspberry Pi. On Arduino, the universal Firmata library is used which implements a protocol for the communication with
host computer. Thus, there is no need to modify the Arduino sketch when new sensors or actuators are connected to your
Arduino. Johnny Five also supports a variety of [I2C](https://en.wikipedia.org/wiki/I%C2%B2C) and
[1-Wire](https://en.wikipedia.org/wiki/1-Wire) devices.

## Status of implementation

This version supports the following devices
* ContactSensor and PresenceSensor (digital input)
* Dimmer (digital output with PWM)
* Switch (digital output)
* Relay Switch (relay boards attached to digital output)
* Temperature Sensor (analog, I2C and 1-Wire)
* Temperature & Humidity Sensor (analog, I2C - sorry, no 1-Wire support, to date)

The OLED and LCD display devices are incomplete and, thus, should not be used. 
They won't do anything useful anyway.

Board-support has been mainly tested with "arduino". More testing for "raspi-io" will follow. The "etherport" 
support is highly experimental at the moment.

## Getting Started

This section is still work in progress.

### Platform Support

The plugin currently supports Arduino, Raspberry Pi boards, and tethering. More boards can be 
added on request. The Johnny Five project provides a detailed 
[list of supported platforms](https://johnny-five.io/platform-support/) with 
detailed information on supported features and how to set up the board. 

## Plugin Configuration

You can load the plugin by editing your `config.json` to include the following
in the `plugins` section. You need to configure the boards you wish to use to control
your devices. Generally, a board is a control system as part of pimatic to drive the 
hardware boards you use, e.g., your Raspberry Pi, an Arduino board attached via USB,
or a remote board connected via etherport. The following configuration 
is an example for pimatic on windows with an Arduino Nano connected via USB on COM4:

    {
        "plugin": "johnny-five",
        "boards": [
           {
               "id": "1",
               "boardType": "arduino",
               "port": "COM4",
           }
        ]
    }

The plugin has the following configuration properties:

| Property  | Default  | Type    | Description                                 |
|:----------|:---------|:--------|:--------------------------------------------|
| debug     | false    | Boolean | Provide additional debug output if true     |
| boards    | -        | Array   | An Array of board configuration objects     |

The configuration for a board is an object comprising the following properties.

| Property  | Default   | Type    | Description                                 |
|:----------|:----------|:--------|:--------------------------------------------|
| id        | -         | String  | Unique identifier used as a reference by a device configuration |
| boardType | "arduino" | String  | The type of board, one of "arduino", "raspi-io", "etherport"    |
| port      | -         | String  | Path or name of device port                 |


## Device Configuration

Devices must be added manually to the device section of your pimatic config.

### Switch Device

`JohnnyFiveSwitch` is based on the PowerSwitch device class. You need to provide
the address of the output `pin`. The device is mapped to a [JF "digital output" Pin](http://johnny-five.io/api/pin/).

    {
          "id": "jf-do-1",
          "class": "JohnnyFiveDigitalOutput",
          "name": "Digital Output (pin 13)"
          "pin": 13,
          "boardId": "1"
    }

It has the following configuration properties:

| Property  | Default  | Type    | Description                                 |
|:----------|:---------|:--------|:--------------------------------------------|
| pin       |          | String  | Pin address of the digital output           |
| boardId   | -        | String  | Id of the board to be used                  |

The Digital Output Device exhibits the following attributes:

| Property      | Unit  | Type    | Acronym | Description                            |
|:--------------|:------|:--------|:--------|:---------------------------------------|
| state         | -     | Boolean | -       | Switch State, true is on, false is off |

The following predicates and actions are supported:
* {device} is turned on|off
* switch {device} on|off
* toggle {device}

### Presence Sensor

`JohnnyFivePresenceSensor` is a digital input device based on the `PresenceSensor` device class. You need
to provide the address of the input `pin` and the `boardId`.

    {
          "id": "jf-cs-1",
          "class": "JohnnyFiveContactSensor",
          "name": "Digital Input (pin 4)"
          "pin": "4",
          "boardId": "1"
    }

It has the following configuration properties:

| Property  | Default  | Type    | Description                                 |
|:----------|:---------|:--------|:--------------------------------------------|
| pin       | -        | String  | Pin address of the digital output           |
| boardId   | -        | String  | Id of the board to be used                  |
| invert    | false    | Boolean | If true, invert the presence sensor state   |

The presence sensor exhibits the following attributes:
                    
| Property      | Unit  | Type    | Acronym | Description                            |
|:--------------|:------|:--------|:--------|:---------------------------------------|
| presence      | -     | Boolean | -       | Presence State, true is present, false is absent | 

The following predicates are supported:
* {device} is present|absent


### Contact Sensor

`JohnnyFiveContactSensor` is a digital input device based on the `ContactSensor` device class. You need
to provide the address of the input `pin`.

    {
          "id": "jf-cs-1",
          "class": "JohnnyFiveContactSensor",
          "name": "Digital Input (pin 4)"
          "pin": "4",
          "boardId": "1"
    }

It has the following configuration properties:

| Property  | Default  | Type    | Description                                 |
|:----------|:---------|:--------|:--------------------------------------------|
| pin       |          | String  | Pin address of the digital output           |
| boardId   | -        | String  | Id of the board to be used                  |
| invert    | false    | Boolean | If true, invert the contact sensor state    |

The presence sensor exhibits the following attributes:
                    
| Property      | Unit  | Type    | Acronym | Description                            |
|:--------------|:------|:--------|:--------|:---------------------------------------|
| contact       | -     | Boolean | -       | Contact State, true is opened, false is closed | 


The following predicates are supported:
* {device} is opened|closed

### Button Device

The Button Device is a digital input device based on the ContactSensor device class. You need
to provide the address of the input `pin`.

    {
          "id": "jf-b-1",
          "class": "JohnnyFiveButton",
          "name": "Button (pin 2)"
          "pin": "2",
          "boardId": "1"
    }

The Button Device has the following configuration properties:

| Property   | Default  | Type    | Description                                                                   |
|:-----------|:---------|:--------|:------------------------------------------------------------------------------|
| pin        | -        | String  | Pin address of the digital output                                             |
| boardId    | -        | String  | Id of the board to be used                                                    |
| pullUp     | false    | Boolean | If true, activate the internal pull-up. As a result, a high signal will be read if push-button is open |
| invert     | false    | Boolean | If true, invert the button state                                              |
| holdTime   | 500      | Number  | Time in milliseconds that the button must be held until triggering an event   |
| controller | ""       | String  | Controller interface type if an EVshield is used. Supports 'EVS_EV3' and 'EVS_NXT' shields |

For wiring examples, see:
* [Button](http://johnny-five.io/examples/button/)
* [Button - Pull-up](http://johnny-five.io/examples/button-pullup/)
* [Button - EVShield NXT](http://johnny-five.io/examples/button-EVS_NXT/)

The following predicates are supported:
* {device} is opened|closed

### Relay

The Relay Device represents a single digital Relay attached to the physical board. You need
to provide the address of the output `pin` controlling the relay. The Relay Device supports two wiring options:

* "NO", Normally Open: When provided with any voltage supply, the output is on. The default mode is LOW or "off", 
  requiring a HIGH signal to turn the relay off. 
* "NC", Normally Closed: When provided with any voltage supply, the output is off. The default mode is LOW or “off”, 
  requiring a HIGH signal to turn the relay on.


    {
        "id": "jf-r-1",
        "name": "Johnny Five Relay",
        "class": "JohnnyFiveRelay",
        "boardId": "1",
        "pin": "12",
        "type": "NO"
    }
    
For wiring examples, see:
* [Relay "NO" and "NC" wiring](http://johnny-five.io/examples/relay/)

    
The Relay Device has the following configuration properties:

| Property   | Default  | Type    | Description                                                                   |
|:-----------|:---------|:--------|:------------------------------------------------------------------------------|
| pin        | -        | String  | Pin address of the digital output                                             |
| boardId    | -        | String  | Id of the board to be used                                                    |
| type       | "NO"     | String  | Whether the relay is wired to be normally open ("NO"), or normally closed ("NC") if pin output is LOW |

### Temperature Sensor

The Temperature Sensor is an input device based on the TemperatureSensor device class. It currently 
supports 4,7k NTC thermistors ("TINKERKIT"), various I2C sensors, and the DS18B20 1Wire sensor. 
Depending on type of sensor different properties are required.

    {
        "id": "jf-t-1",
        "name": "Johnny Five Temperature",
        "class": "JohnnyFiveTemperature",
        "boardId": "1",
        "controller": "SI7020",
        "address": "0x40",
        "temperatureOffset": -1
    },
    {
        "id": "jf-t-2",
        "name": "Johnny Five Temperature 2",
        "class": "JohnnyFiveTemperature",
        "boardId": "1",
        "pin": "A0",
        "controller": "TINKERKIT",
        "offset": -2.75,
        "units": "metric"
    }

The Temperature Sensor has the following configuration properties:

| Property   | Default     | Type     | Description                                                                   |
|:-----------|:------------|:---------|:------------------------------------------------------------------------------|
| controller | "TINKERKIT" | String   | Controller interface type to be used, one of TINKERKIT, LM35, TMP36, DS18B20, MPU6050, GROVE, BMP180, MPL115A2, MPL3115A2, HTU21D, SI7020 |                                         |
| pin        | ""          | String   | The pin address. Required if controller is TINKERKIT, optional otherwise |                                         |
| boardId    | -           | String   | Id of the board to be used                                                    |
| interval   | 10          | Number   | The time interval in seconds at which the sensor will be read |
| units      | "metric"    | String   | Defines whether metric, imperial, or standard units shall be used                                              |
| offset     | 0           | Number   | A positive or negative offset value to adjust a deviation of the temperature sensor |
| controller | ""          | String   | Controller interface type if an EVshield is used. Supports 'EVS_EV3' and 'EVS_NXT' shields |

For wiring examples, see:
* [Temperature TINKERKIT](http://johnny-five.io/examples/tinkerkit-thermistor/)
    * If you don't have the tinkerkit shield, here's a 
    [wiring sketch](https://github.com/mwittig/pimatic-johnny-five/raw/master/assets/sketches/arduino-temperature-4k7-thermistor.png) 
    for the thermistor. 
* [Temperature MPU6050](http://johnny-five.io/examples/temperature-mpu6050/)

## Credits

The 'johnny-five-icon' files have been created with [Inkscape](https://inkscape.org) using artwork
by [Mike Sgier](http://msgierillustration.com/) published as part of the Johnny Five project.

Copyright (c) 2012, 2013, 2014 Rick Waldron <waldron.rick@gmail.com>
Copyright (c) 2014, 2015 The Johnny-Five Authors

MIT-License: https://github.com/rwaldron/johnny-five/blob/master/LICENSE-MIT
