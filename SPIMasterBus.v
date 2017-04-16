/*****************************************************************************************************
* Description:                 Spi master module
*
* Author:                      Dengxue Yan
*
* Rev History:
*       <Author>        <Date>        <Hardware>     <Version>        <Description>
*     Dengxue Yan   2016-08-27 17:00       --           1.00             Create
*****************************************************************************************************/
`timescale 1us / 1ps

module SPIMasterBus(
    reset, 
    clk, 
    nwr, 
    data_tx, 
    data_rx, 
    spi_busy,
    spi_cs, 
    spi_clk, 
    spi_mosi, 
    spi_miso// SPI Hardware Interface
    );

    input reset;
    input clk;
    input nwr;
    
    input [7:0] data_tx;
    
    output [7:0] data_rx;
    reg [7:0] data_rx = 8'h00;
    
    output spi_busy;
    
    output spi_cs;
    
    output spi_clk;
    
    output spi_mosi;
    reg spi_mosi = 1'b0;
    
    input spi_miso;
    
    reg [1:0] nwr_buff = 2'b11;
    reg [2:0] spi_st = 3'b000;
    reg [7:0] data_tx_shadow = 8'h00;
    reg [6:0] data_tx_temp = 7'h00;
    reg [6:0] data_rx_temp = 7'h00;
    reg spi_cs_local_hold = 1'b0;
    reg spi_clk_enable = 1'b0;
    
    always @(negedge clk)
    begin
        nwr_buff <= {nwr_buff[0], nwr};
    end
    assign nwr_falling_edge = (nwr_buff[1]) && (!nwr_buff[0]);
    
    assign spi_io_busy = (spi_clk_enable | spi_cs_local_hold);
    assign spi_busy = (nwr_falling_edge | spi_io_busy);
    assign spi_cs = (!spi_busy);
    assign spi_clk = spi_clk_enable ? clk : 1'b1;
    always @ (posedge clk)
    begin
        if (reset)
        begin
            spi_st <= 3'h0;
            data_rx <= 8'h00;
            data_rx_temp <= 7'h00;
            spi_clk_enable <= 1'b0;
        end
        else
        begin
            if (!spi_io_busy) 
            begin
                if (nwr_falling_edge)// SPI RX and TX start
                begin
                    spi_st <= 3'h7;
                    spi_clk_enable <= 1'b1;
                    data_tx_shadow <= data_tx;
                end
            end
            else
            begin
                if (3'h0 == spi_st)
                begin
                    data_rx <= {data_rx_temp[6:0], spi_miso};
                    spi_clk_enable <= 1'b0;
                end
                else
                begin
                    spi_st <= spi_st - 1'b1;
                    data_rx_temp <= {data_rx_temp[5:0], spi_miso};
                end
            end
        end
    end
    
     
    always @ (negedge clk)
    begin
        if (reset)
        begin
            data_tx_temp <= 7'h00;
            spi_cs_local_hold <= 1'b0;
        end
        else
        begin
            if (spi_clk_enable)
            begin
                spi_cs_local_hold <= 1'b1;
                if (3'h7 == spi_st)
                begin
                    {spi_mosi, data_tx_temp[6:0]} <= data_tx_shadow;
                end
                else
                begin
                    {spi_mosi, data_tx_temp[6:1]} <= data_tx_temp[6:0];
                end
            end
            else
            begin
                if (spi_cs_local_hold)
                begin
                    spi_cs_local_hold <= 1'b0;
                end
            end
        end
    end

endmodule
