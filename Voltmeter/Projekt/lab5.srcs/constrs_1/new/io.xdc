set_property PACKAGE_PIN Y9 [get_ports {clk}];  # "GCLK"
set_property PACKAGE_PIN P16 [get_ports {rst}];  # "BTNC"
set_property PACKAGE_PIN Y10  [get_ports {tx}];  # "JA3"
set_property PACKAGE_PIN AA9  [get_ports {rx}];  # "JA4"


set_property PACKAGE_PIN W8 [get_ports {sclk}];  # "JB4"
#set_property PACKAGE_PIN V10 [get_ports {clr}];  # "JB3"
set_property PACKAGE_PIN W11 [get_ports {miso}];  # "JB2"
set_property PACKAGE_PIN W12 [get_ports {ss}];  # "JB1"


set_property PACKAGE_PIN R16 [get_ports {start}];  # "BTND"

set_property PACKAGE_PIN T22 [get_ports {leds[0]}];  # "leds[0"
set_property PACKAGE_PIN T21 [get_ports {leds[1]}];  # "leds[1"
set_property PACKAGE_PIN U22 [get_ports {leds[2]}];  # "leds[2"
set_property PACKAGE_PIN U21 [get_ports {leds[3]}];  # "leds[3"
set_property PACKAGE_PIN V22 [get_ports {leds[4]}];  # "leds[4"
set_property PACKAGE_PIN W22 [get_ports {leds[5]}];  # "leds[5"
set_property PACKAGE_PIN U19 [get_ports {leds[6]}];  # "leds[6"
set_property PACKAGE_PIN U14 [get_ports {leds[7]}];  # "leds[7"

set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]];

set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 34]];

set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 13]];