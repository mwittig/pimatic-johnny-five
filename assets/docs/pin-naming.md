# Pin Naming

Note, if the device configuration is edited with a text editor pin assignments always need to be provided as string 
 (in quotes). If the device editor of the pimatic frontend is used, no quotes are required as the editor will 
 automatically transform the input to a string value based on the device schema. 

## Raspberry Boards (raspi-io)

Pin numbers can be specified using one of the following:
* by function name, e.g. "GPIO7"
* by header pin number, which is specified in the form "P[header]-[pin]", e.g. 'P1-40'
* by Wiring Pi virtual pin number, e.g. "29"

For Raspberry B+/2/3 the pinout and naming schemes are as shown in table below. Function names given in brackets 
 cannot be used for for pin assignments. As part of the 
 [raspi-io Wiki, more details](https://github.com/nebrius/raspi-io/wiki/Pin-Information) can be found for the various 
 types of Raspberry Pi boards.

| WiringPi| Pin Name |  Header Pin | Header Pin   | Pin Name | WiringPi |
|:--------|:---------|:------------|-------------:|:---------|:---------|
| –  | (+3,3V)  |   P1-1       |  P1-2      | (+5V)     | –  |
| 8  | GPIO2    |   P1-3       |  P1-4      | (+5V)     | -  |
| 9  | GPIO3    |   P1-5       |  P1-6      | (GND)     | -  |
| 7  | GPIO4    |   P1-7       |  P1-8      | GPIO14    | 15 |
| -  | (GND)    |   P1-9       |  P1-10     | GPIO15    | 16 |
| 0  | GPIO17   |   P1-11      |  P1-12     | GPIO18    | 1  |
| 2  | GPIO27   |   P1-13      |  P1-14     | (GND)     | -  |
| 3  | GPIO22   |   P1-15      |  P1-16     | GPIO23    | 4  |
| -  | (+3,3V)  |   P1-17      |  P1-18     | GPIO24    | 5  |
| 12 | GPIO10   |   P1-19      |  P1-20     | (GND)     | -  |
| 13 | GPIO9    |   P1-21      |  P1-22     | GPIO25    | 6  |
| 14 | GPIO11   |   P1-23      |  P1-24     | GPIO8     | 10 |
| -  | (GND)    |   P1-25      |  P1-26     | GPIO7     | 11 |
| 30 | (SDA.0)  |   P1-27      |  P1-28     | (SCL.0)   | 31 |
| 21 | GPIO5    |   P1-29      |  P1-30     | (GND)     | -  |
| 22 | GPIO6    |   P1-31      |  P1-32     | GPIO12    | 26 |
| 23 | GPIO13   |   P1-33      |  P1-34     | (GND)     | -  |
| 24 | GPIO19   |   P1-35      |  P1-36     | GPIO16    | 27 |
| 25 | GPIO26   |   P1-37      |  P1-38     | GPIO20    | 28 |
| -  | (GND)    |   P1-39      |  P1-40     | GPIO21    | 29 |

## Particle Boards (particle-io)

For the assignment of analog or digital pins simply use the pin names as printed on the PCB.  

## Arduino Boards (arduino)

For pin assignments use the logical pin numbers. For digital pins the logical number is also used as part
 of the pin name which is usually printed on the PCB. For example, for pin "D13" use "13". For analog pins you may 
 also use the pin name. For example, you can use "A0" instead of the pin number "14" for Arduino Nano. 
 
## Expander Boards (expander)

For pin assignments use the logical pin numbers. For example, for MCP23017 which has 2x8 I/O ports use pin numbers 0 to 
 7 for GPA0 to GPA7 and numbers 8 to 15 for GPB0 to GPB7.

