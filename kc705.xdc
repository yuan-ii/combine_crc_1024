set_property PACKAGE_PIN AD12 [get_ports sysclk_p]
set_property PACKAGE_PIN AD11 [get_ports sysclk_n]
set_property IOSTANDARD LVDS [get_ports {sysclk_p sysclk_n}]
create_clock -period 5.000 -name sysclk [get_ports sysclk_p]

set_property PACKAGE_PIN AG5 [get_ports rst_btn]
set_property IOSTANDARD LVCMOS15 [get_ports rst_btn]

set_property PACKAGE_PIN AA12 [get_ports mode_btn]
set_property IOSTANDARD LVCMOS15 [get_ports mode_btn]

set_property PACKAGE_PIN AB8  [get_ports {led[0]}]
set_property PACKAGE_PIN AA8  [get_ports {led[1]}]
set_property PACKAGE_PIN AC9  [get_ports {led[2]}]
set_property PACKAGE_PIN AB9  [get_ports {led[3]}]
set_property PACKAGE_PIN AE26 [get_ports {led[4]}]
set_property PACKAGE_PIN G19  [get_ports {led[5]}]
set_property PACKAGE_PIN E18  [get_ports {led[6]}]
set_property PACKAGE_PIN F16  [get_ports {led[7]}]

set_property IOSTANDARD LVCMOS15 [get_ports {led[*]}]

set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 2.5 [current_design]