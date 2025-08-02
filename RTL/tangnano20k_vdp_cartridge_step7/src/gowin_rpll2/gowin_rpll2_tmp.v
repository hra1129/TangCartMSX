//Copyright (C)2014-2025 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.11.02 (64-bit)
//Part Number: GW2AR-LV18QN88C8/I7
//Device: GW2AR-18
//Device Version: C
//Created Time: Sat Aug  2 07:16:03 2025

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    Gowin_rPLL2 your_instance_name(
        .clkout(clkout), //output clkout
        .lock(lock), //output lock
        .clkoutp(clkoutp), //output clkoutp
        .clkin(clkin) //input clkin
    );

//--------Copy end-------------------
