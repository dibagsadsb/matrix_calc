

# ---------- 时钟 ----------
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -name clk -period 10.000 [get_ports clk]

# ---------- 按键 ----------
set_property PACKAGE_PIN R15 [get_ports button_confirm]
set_property IOSTANDARD LVCMOS33 [get_ports button_confirm]
set_property PULLUP true [get_ports button_confirm]

# ---------- 拨码开关 ----------
set_property PACKAGE_PIN R1 [get_ports dip_switch[0]]
set_property PACKAGE_PIN N4 [get_ports dip_switch[1]]
set_property PACKAGE_PIN M4 [get_ports dip_switch[2]]
set_property PACKAGE_PIN R2 [get_ports dip_switch[3]]
set_property IOSTANDARD LVCMOS33 [get_ports dip_switch[*]]

# ---------- LED ----------
set_property PACKAGE_PIN K2 [get_ports leds[0]]
set_property PACKAGE_PIN J2 [get_ports leds[1]]
set_property PACKAGE_PIN J3 [get_ports leds[2]]
set_property PACKAGE_PIN H4 [get_ports leds[3]]
set_property PACKAGE_PIN J4 [get_ports leds[4]]
set_property PACKAGE_PIN G3 [get_ports leds[5]]
set_property PACKAGE_PIN G4 [get_ports leds[6]]
set_property PACKAGE_PIN F6 [get_ports leds[7]]
set_property IOSTANDARD LVCMOS33 [get_ports leds[*]]

# ---------- 七段数码管 ----------
set_property PACKAGE_PIN B4 [get_ports seg_display[6]]  # a
set_property PACKAGE_PIN A4 [get_ports seg_display[5]]  # b
set_property PACKAGE_PIN A3 [get_ports seg_display[4]]  # c
set_property PACKAGE_PIN B1 [get_ports seg_display[3]]  # d
set_property PACKAGE_PIN A1 [get_ports seg_display[2]]  # e
set_property PACKAGE_PIN B3 [get_ports seg_display[1]]  # f
set_property PACKAGE_PIN B2 [get_ports seg_display[0]]  # g
set_property IOSTANDARD LVCMOS33 [get_ports seg_display[*]]

# ---------- UART ----------
set_property PACKAGE_PIN U4 [get_ports uart_rx]
set_property PACKAGE_PIN V5 [get_ports uart_tx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx]