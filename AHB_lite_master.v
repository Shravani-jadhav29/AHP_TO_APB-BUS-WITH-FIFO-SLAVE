`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/28/2026 07:52:27 PM
// Design Name: 
// Module Name: AHB_lite_master
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module AHB_lite_master(



    input  wire   HCLK,
    input  wire   HRESETn,

  
    input  wire  start,
    input  wire  write_enable,
    input  wire [31:0] address,
    input  wire [31:0] write_data,

  

    output reg [31:0] HADDR,
    output reg [31:0] HWDATA,
    output reg  HWRITE,
    output reg [1:0]  HTRANS,
    output reg [2:0]  HSIZE,
    output reg   HSEL,

   
    input wire [31:0] HRDATA,
    input wire  HREADY,
    input wire  HRESP,

   
    output reg [31:0] read_data,
    output reg  done

);

    
    parameter  HTRANS_IDLE   = 2'b00;
    parameter  HTRANS_NONSEQ = 2'b10;

    

   parameter S_IDLE = 3'd0;
    parameter S_ADDR = 3'd1;
    parameter  S_TRANSFER = 3'd2;
    parameter  S_DONE     = 3'd3;

    reg [2:0] state;


    always @(posedge HCLK or negedge HRESETn) begin

        if (!HRESETn) begin

            state <= S_IDLE;

            HADDR  <= 32'h00000000;
            HWDATA <= 32'h00000000;
            HWRITE <= 1'b0;
            HTRANS <= HTRANS_IDLE;
            HSIZE  <= 3'b010;
            HSEL <= 1'b0;

            read_data <= 32'h00000000;
            done <= 1'b0;

        end

        else begin

            // done is only one clock pulse
            done <= 1'b0;

            case (state)

           
                S_IDLE: begin

                    HSEL <= 1'b0;
                    HTRANS <= HTRANS_IDLE;

                    if (start) begin

                        HADDR <= address;

                       

                        HWDATA <= write_data;

                        
                        // READ / WRITE
                        // 1 = WRITE
                        // 0 = READ
                       

                        HWRITE <= write_enable;

                        

                        HSIZE <= 3'b010;

                       

                        HSEL <= 1'b1;
                        HTRANS <= HTRANS_NONSEQ;

                        state <= S_ADDR;

                    end

                end


            
                S_ADDR: begin

                    HSEL <= 1'b1;
                    HTRANS <= HTRANS_NONSEQ;

                    state <= S_TRANSFER;

                end


               

                S_TRANSFER: begin

                    // Keep AHB transfer active

                    HSEL   <= 1'b1;
                    HTRANS <= HTRANS_NONSEQ;

                    // Wait until bridge/slave is ready

                    if (HREADY) begin

                    

                        if (!HWRITE) begin

                            read_data <= HRDATA;

                        end

                      

                        done <= 1'b1;

                        state <= S_DONE;

                    end

                end


              
                S_DONE: begin

                    // Return AHB bus to IDLE

                    HSEL   <= 1'b0;
                    HTRANS <= HTRANS_IDLE;

                    state <= S_IDLE;

                end


              

                default: begin

                    state <= S_IDLE;

                    HADDR <= 32'h00000000;
                    HWDATA <= 32'h00000000;
                    HWRITE <= 1'b0;
                    HTRANS <= HTRANS_IDLE;
                    HSEL <= 1'b0;

                end

            endcase

        end

    end

endmodule
