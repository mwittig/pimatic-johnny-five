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

}