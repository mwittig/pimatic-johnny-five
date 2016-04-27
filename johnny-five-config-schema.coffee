# #pimatic-johnny-five plugin config options
module.exports = {
  title: "pimatic-johnny-five plugin config options"
  type: "object"
  properties:
    boards:
      description: "Boards"
      type: "array"
      default: []
      format: "table"
      items:
        type: "object"
        properties:
          id:
            type: "string"
            description: "A unique identifier used a reference to the boards"
          boardType:
            type: "string"
            description: "Board type, one of arduino, raspi-io, etherport"
            default: "arduino"
          port:
            description: "Path or name of device port"
            type: "string"
            default: ""
          baudrate:
            description: "The baudrate to use for serial communication"
            type: "number"
            required: false
          token:
            description: "Particle token. Only required for particle-io board type"
            type: "string"
            required: false
          deviceId:
            description: "Particle device id. Only required for particle-io board type"
            type: "string"
            required: false
          controller:
            description: "Expander controller type. Only required for expander board type"
            type: "string"
            required: false
          address:
            description: "Expander I2C address or IP address/hostname. Only used for expander and etherport-client board type"
            type: "string"
            required: false
}