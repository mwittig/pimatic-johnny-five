module.exports = {
  title: "pimatic-johnny-five device config schemas"
  JohnnyFivePwmOutput: {
    title: "Johnny Five PWM Output"
    description: "Johnny Five PWM Output"
    type: "object"
    properties:
      boardId:
        description: "Id of the board to be used"
        type: "string"
      pin:
        description: "The pin address"
        type: "string"
  }
  JohnnyFiveSwitch: {
    title: "Johnny Five Switch"
    description: "Johnny Five Switch"
    type: "object"
    properties:
      boardId:
        description: "Id of the board to be used"
        type: "string"
      pin:
        description: "The pin address"
        type: "string"
  }
  JohnnyFiveContactSensor: {
    title: "Johnny Five Contact Sensor"
    description: "Johnny Five Contact Sensor for a digital input"
    type: "object"
    extensions: ["xConfirm", "xLink", "xClosedLabel", "xOpenedLabel"]
    properties:
      boardId:
        description: "Id of the board to be used"
        type: "string"
      pin:
        description: "The pin address"
        type: "string"
      invert:
        description: "If true, invert the contact states, i.e. 'on' state on LOW. "
        type: "boolean"
        default: false
  }
  JohnnyFivePresenceSensor: {
    title: "Johnny Five Presence Sensor"
    description: "Johnny Five Presence Sensor for a digital input"
    type: "object"
    extensions: ["xLink", "xPresentLabel", "xAbsentLabel"]
    properties:
      boardId:
        description: "Id of the board to be used"
        type: "string"
      pin:
        description: "The pin address"
        type: "string"
      invert:
        description: "If true, invert the presence states, i.e. 'present' state on LOW. "
        type: "boolean"
        default: false
  }
  JohnnyFiveButton: {
    title: "Johnny Five Button"
    description: "Johnny Five Digital Input"
    type: "object"
    extensions: ["xLink", "xClosedLabel", "xOpenedLabel"]
    properties:
      boardId:
        description: "Id of the board to be used"
        type: "string"
      pin:
        description: "The pin address"
        type: "string"
      pullUp:
        description: "If true, activate the internal pull-up. As a result, a high signal will be read if push-button is open"
        type: "boolean"
        default: false
      invert:
        description: "If true, invert the button state."
        type: "boolean"
        default: false
      holdTime:
        description: "Time in milliseconds that the button must be held until triggering an event"
        type: "number"
        default: 500
      controller:
        description: "Controller interface type if an EVshield is used. Supports EVS_EV3 and EVS_NXT shields"
        type: "string"
        default: ""
  }
  JohnnyFiveRelay: {
    title: "Johnny Five Relay"
    description: "Johnny Five Relay"
    type: "object"
    properties:
      boardId:
        description: "Id of the board to be used"
        type: "string"
      pin:
        description: "The pin address"
        type: "string"
      type:
        description: "Whether the relay is wired to be 'normally open' (NO), or 'normally closed' if pin output is LOW"
        enum: ["NO", "NC"]
        default: "NO"
  }
  JohnnyFiveTemperature: {
    title: "Johnny Five Temperature"
    description: "Johnny Five Temperature"
    type: "object"
    extensions: ["xLink", "xAttributeOptions"]
    properties:
      boardId:
        description: "Id of the board to be used"
        type: "string"
      controller:
        description: "Controller interface type to be used, one of TINKERKIT, LM35, TMP36, DS18B20, MPU6050, GROVE, BMP180, MPL115A2, MPL3115A2, HTU21D, SI7020"
        type: "string"
        default: "TINKERKIT"
      pin:
        description: "The pin address. Required if controller is ANALOG, optional otherwise"
        type: "string"
        default: ""
      address:
        description: """
          The I2C address. If controller is an I2C device and address is not provided the device-specfic
          default address applies.
        """
        type: "string"
        default: ""
      interval:
        description: "The time interval in seconds at which the sensor will be read"
        type: "number"
        default: 10
      units:
        description: "Defines whether \"metric\", \"imperial\", or \"standard\" units shall be used"
        format: "enum"
        enum: ["metric", "imperial", "standard"]
        default: "metric"
      offset:
        description: "A positive or negative offset value to adjust a deviation of the temperature sensor"
        type: "number"
        default: 0
  }
  JohnnyFiveTemperatureHumidity: {
    title: "Johnny Five Temperature & Humidity"
    description: "Johnny Five Temperature & Humidity"
    type: "object"
    extensions: ["xLink", "xAttributeOptions"]
    properties:
      boardId:
        description: "Id of the board to be used"
        type: "string"
      controller:
        description: "Controller interface type to be used, one of ANALOG, LM35, TMP36, DS18B20, MPU6050, GROVE, BMP180, MPL115A2, MPL3115A2, HTU21D"
        type: "string"
        default: "ANALOG"
      pin:
        description: "The pin address. Required if controller is ANALOG, optional otherwise"
        type: "string"
        default: ""
      address:
        description: """
          The I2C address. If controller is an I2C device and address is not provided the device-specfic
          default address applies.
        """
        type: "string"
        default: ""
      interval:
        description: "The time interval in seconds at which the sensor will be read"
        type: "number"
        default: 10
      units:
        description: "Defines whether \"metric\", \"imperial\", or \"standard\" units shall be used"
        format: "enum"
        enum: ["metric", "imperial", "standard"]
        default: "metric"
      temperatureOffset:
        description: "A positive or negative offset value to adjust a deviation of the temperature sensor"
        type: "number"
        default: 0
      humidityOffset:
        description: "A positive or negative offset value to adjust a deviation of the humidity sensor"
        type: "number"
        default: 0
  }
  JohnnyFiveTemperaturePressure: {
    title: "Johnny Five Temperature & Pressure"
    description: "Johnny Five Temperature & Pressure"
    type: "object"
    extensions: ["xLink", "xAttributeOptions"]
    properties:
      boardId:
        description: "Id of the board to be used"
        type: "string"
      controller:
        description: "Controller interface type to be used, one of MS5611"
        type: "string"
        default: "MS5611"
      pin:
        description: "The pin address. Required if controller is ANALOG, optional otherwise"
        type: "string"
        default: ""
      address:
        description: """
          The I2C address. If controller is an I2C device and address is not provided the device-specfic
          default address applies.
        """
        type: "string"
        default: ""
      interval:
        description: "The time interval in seconds at which the sensor will be read"
        type: "number"
        default: 10
      units:
        description: "Defines whether \"metric\", \"imperial\", or \"standard\" units shall be used"
        format: "enum"
        enum: ["metric", "imperial", "standard"]
        default: "metric"
      temperatureOffset:
        description: "A positive or negative offset value to adjust a deviation of the temperature sensor"
        type: "number"
        default: 0
      pressureOffset:
        description: "A positive or negative offset value to adjust a deviation of the humidity sensor"
        type: "number"
        default: 0
      elevation:
        description: "The elevation of the current location in meters"
        type: "number"
        default: 0
  }
  JohnnyFiveRgbLed: {
    title: "Johnny Five RGB LED"
    description: "Johnny Five RGB LED"
    type: "object"
    properties:
      boardId:
        description: "Id of the board to be used"
        type: "string"
      controller:
        description: "Controller interface type. One of DEFAULT, PCA9685, BLINKM"
        type: "string"
        default: "DEFAULT"
      pins:
        description: "The pins assigned to the RGB LED"
        type: "object"
        properties:
          red:
            description: "The pin for red"
            type: "string"
          green:
            description: "The green for green"
            type: "string"
          blue:
            description: "The pin for blue"
            type: "string"
      isAnode:
        description: "If set to true the LED is a common anode LED. Defaults to false, indicating a common cathode LED"
        type: "boolean"
        default: "false"
  }
  JohnnyFiveOledDisplay: {
    title: "JohnnyFive LED"
    description: "JohnnyFive LED"
    type: "object"
    properties:
      boardId:
        description: "Id of the board to be used"
        type: "string"
      address:
        description: "The I2C address. If omitted SPI mode is assumed"
        type: "string"
        default: ""
      slavePin:
        description: "The slave select pin used in SPI mode"
        type: "string"
        default: "12"
  }
  JohnnyFiveLcdDisplay: {
    title: "JohnnyFive LED"
    description: "JohnnyFive LED"
    type: "object"
    properties:
      boardId:
        description: "Id of the board to be used"
        type: "string"
      controller:
        description: "The I2C controller. If omitted the parallel interface will be used."
        type: "string"
        default: ""
      address:
        description: "The I2C address. If omitted the default address will be used in I2C mode"
        type: "string"
        default: ""
      pins:
        description: "The comma separated list of pins used for the parallel interface."
        type: "string"
        default: ""
      backlight:
        description: "The pin driving the backlight for the parallel interface."
        type: "string"
        default:  ""
      rows:
        description: "The number of rows on the device"
        type: "number"
        default:  2
      cols:
        description: "The number of columns on the device"
        type: "number"
        default:  16
  }
  JohnnyFiveServo: {
    title: "JohnnyFive Servo"
    description: "JohnnyFive Servo"
    type: "object"
    properties:
      boardId:
        description: "Id of the board to be used"
        type: "string"
      controller:
        description: "Controller interface type: DEFAULT, PCA9685"
        type: "string"
        default: "DEFAULT"
      address:
        description: "The I2C address if controller is PCA9685. If omitted the default address will be used in I2C mode"
        type: "string"
        default: ""
      pin:
        description: "The pin address"
        type: "string"
      type:
        description: "The type of servo, one of standard or continuous"
        type: "string"
        default:  "standard"
      range:
        description: "The range of motion in degrees"
        type: "array"
        default: [
          0,
          180
        ]
        format: "table"
        items:
          type: "number"
      buttons:
        description: "The inputs to select from"
        type: "array"
        default: [
          {
            id: "min"
          }
          {
            id: "max"
          }
          {
            id: "center"
          }
          {
            id: "stop"
          }
        ]
        format: "table"
        items:
          type: "object"
          properties:
            id:
              enum: [
                "min", "max", "center", "home", "sweep", "stop", "cw", "ccw"
              ]
              description: "The input ids switchable by the AVR"
            text:
              type: "string"
              description: """
                The button text to be displayed. The id will be displayed if not set
              """
              required: false
            confirm:
              description: "Ask the user to confirm the input select"
              type: "boolean"
              default: false
  }
}