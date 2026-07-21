## Real Digital Boolean board (XC7S50CSGA324): PMODA PmodKYPD + BLE TX
set_property -dict {PACKAGE_PIN F14 IOSTANDARD LVCMOS33} [get_ports {clk}]
create_clock -period 10.000 -name clk [get_ports {clk}]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

## PmodKYPD on PMODA: columns driven by FPGA, rows read by FPGA
set_property -dict {PACKAGE_PIN A14 IOSTANDARD LVCMOS33} [get_ports {col[0]}]
set_property -dict {PACKAGE_PIN B14 IOSTANDARD LVCMOS33} [get_ports {col[1]}]
set_property -dict {PACKAGE_PIN A13 IOSTANDARD LVCMOS33} [get_ports {col[2]}]
set_property -dict {PACKAGE_PIN B13 IOSTANDARD LVCMOS33} [get_ports {col[3]}]
set_property -dict {PACKAGE_PIN C14 IOSTANDARD LVCMOS33 PULLUP TRUE} [get_ports {row[0]}]
set_property -dict {PACKAGE_PIN C13 IOSTANDARD LVCMOS33 PULLUP TRUE} [get_ports {row[1]}]
set_property -dict {PACKAGE_PIN D12 IOSTANDARD LVCMOS33 PULLUP TRUE} [get_ports {row[2]}]
set_property -dict {PACKAGE_PIN E12 IOSTANDARD LVCMOS33 PULLUP TRUE} [get_ports {row[3]}]

## BLE UART direction is important:
## F5 is BLE_UART_RX (input of the BLE module), so FPGA sends on this pin.
## G5 is BLE_UART_TX (output of the BLE module) and must NOT be driven.
set_property -dict {PACKAGE_PIN F5 IOSTANDARD LVCMOS33} [get_ports {ble_uart_rx}]

## LEDs 0 through 15
set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN F1 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN F2 IOSTANDARD LVCMOS33} [get_ports {led[3]}]
set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33} [get_ports {led[4]}]
set_property -dict {PACKAGE_PIN E2 IOSTANDARD LVCMOS33} [get_ports {led[5]}]
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports {led[6]}]
set_property -dict {PACKAGE_PIN E5 IOSTANDARD LVCMOS33} [get_ports {led[7]}]
set_property -dict {PACKAGE_PIN E6 IOSTANDARD LVCMOS33} [get_ports {led[8]}]
set_property -dict {PACKAGE_PIN C3 IOSTANDARD LVCMOS33} [get_ports {led[9]}]
set_property -dict {PACKAGE_PIN B2 IOSTANDARD LVCMOS33} [get_ports {led[10]}]
set_property -dict {PACKAGE_PIN A2 IOSTANDARD LVCMOS33} [get_ports {led[11]}]
set_property -dict {PACKAGE_PIN B3 IOSTANDARD LVCMOS33} [get_ports {led[12]}]
set_property -dict {PACKAGE_PIN A3 IOSTANDARD LVCMOS33} [get_ports {led[13]}]
set_property -dict {PACKAGE_PIN B4 IOSTANDARD LVCMOS33} [get_ports {led[14]}]
set_property -dict {PACKAGE_PIN A4 IOSTANDARD LVCMOS33} [get_ports {led[15]}]
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets -hier -filter {NAME =~ *ro_chain*}]
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets -hier -filter {NAME =~ *ro_chain*}]