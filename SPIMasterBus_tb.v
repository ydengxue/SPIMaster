/*****************************************************************************************************
* Description:                 Spi master module test bench
*
* Author:                      Dengxue Yan
*
* Email:                       Dengxue.Yan@wustl.edu
*
* Rev History:
*       <Author>        <Date>        <Hardware>     <Version>        <Description>
*     Dengxue Yan   2016-08-27 17:00       --           1.00             Create
*****************************************************************************************************/
`timescale 100ns / 1ps
module SPIMasterBus_tb;

    reg clk;
    reg reset;
    reg [7:0] data_tx = 8'h00;
    reg cs = 1'b0;
    reg nwr = 1'b1;
    
    wire [7:0] data_rx;
    wire spi_busy;
    
    wire spi_cs;
    wire spi_clk;
    wire spi_mosi;
    reg  spi_miso = 1'b0;
    
    
    SPIMasterBus DUT(
    .reset(reset), 
    .clk(clk),
    
    // MCU Hardware Interface
    .nwr(nwr), 
    .data_tx(data_tx), 
    .data_rx(data_rx), 
    .spi_busy(spi_busy),
    
    // SPI Hardware Interface
    .spi_cs(spi_cs), 
    .spi_clk(spi_clk), 
    .spi_mosi(spi_mosi), 
    .spi_miso(spi_miso) 
    );
    
    initial
    begin

        $dumpfile("SPIMasterBus.vcd"); 
        $dumpvars(0, SPIMasterBus_tb); 
            
        #0 
        clk=0;
        reset=1; // reset
        nwr=1;
        data_tx = 8'h00;
        cs = 1'b0;
        nwr = 1'b1;

        #41     
        reset=0;

        #10     
        data_tx=8'hAA;
        nwr=0;

        #20
        nwr=1;

        #10
        spi_miso=0;// Bit7

        #20
        spi_miso=1;// Bit6

        #20
        spi_miso=0;// Bit5

        #20
        spi_miso=1;// Bit4

        #20
        spi_miso=1;// Bit3

        #20
        spi_miso=0;// Bit2

        #20
        spi_miso=1;// Bit1

        #20
        spi_miso=0;// Bit0

        // These are disturbance signals, 
        #20
        spi_miso=1;

        #20
        spi_miso=0;

        #20

        #10
        $finish;
    end
    always
        #10 clk= !clk;
    
endmodule
