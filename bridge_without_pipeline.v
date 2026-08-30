`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/14/2026 07:12:34 PM
// Design Name: 
// Module Name: bridge_without_pipeline
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




module bridge_without_pipeline(

 
    input  wire  hclk,
    input  wire hresetn,

   

    input  wire  hselapb,
    input  wire hwrite,
    input  wire [1:0]  htrans,
    input  wire [31:0] haddr,
    input  wire [31:0] hwdata,

   

    input  wire [31:0] prdata,

  

    output reg    psel,
    output reg   penable,
    output reg   pwrite,
    output reg [31:0]  paddr,
    output reg [31:0]  pwdata,

  

    output reg   hresp,
    output reg hready,
    output reg [31:0]  hrdata
);


   
    parameter S_IDLE = 3'd0;
    parameter S_READ_SETUP = 3'd1;
    parameter S_READ_ACCESS= 3'd2;
    parameter S_WRITE_SETUP= 3'd3;
    parameter  S_WRITE_ACCESS=3'd4;

    reg [2:0] state;


    
    reg [31:0] addr_reg;
    reg [31:0] data_reg;
    reg  write_reg;


   
    // VALID AHB TRANSFER
    // NONSEQ = 10
    // SEQ    = 11
    
    wire valid;

    assign valid = hselapb &&
                   ((htrans == 2'b10) ||
                    (htrans == 2'b11));


  
    // SEQUENTIAL FSM
  

    always @(posedge hclk or negedge hresetn) begin

        if (!hresetn) begin

            state <= S_IDLE;

            addr_reg <= 32'd0;
            data_reg <= 32'd0;
            write_reg <= 1'b0;

        end

        else begin

            case (state)
            
                S_IDLE: begin

                    if (valid) begin

                      
                        addr_reg  <= haddr;
                        data_reg <= hwdata;
                        write_reg <= hwrite;

                        // Decide READ or WRITE
                        if (hwrite)
                            state <= S_WRITE_SETUP;
                        else
                            state <= S_READ_SETUP;

                    end

                end


                
                S_READ_SETUP: begin

                    state <= S_READ_ACCESS;

                end


                S_READ_ACCESS: begin

                    // Transfer completed
                    state <= S_IDLE;

                end


             

                S_WRITE_SETUP: begin

                    state <= S_WRITE_ACCESS;

                end


             

                S_WRITE_ACCESS: begin

                    // Transfer completed
                    state <= S_IDLE;

                end


                default: begin

                    state <= S_IDLE;

                end

            endcase

        end

    end


 
    always @(*) begin

        // Default values

        psel    = 1'b0;
        penable = 1'b0;
        pwrite  = 1'b0;

        paddr   = 32'd0;
        pwdata  = 32'd0;

        hready  = 1'b0;
        hresp  = 1'b0;
        hrdata  = 32'd0;


        case (state)


            S_IDLE: begin

                // Bridge ready for next AHB transfer
                hready = 1'b1;

            end

            S_READ_SETUP: begin

                psel    = 1'b1;
                penable = 1'b0;
                pwrite  = 1'b0;

                paddr   = addr_reg;

                hready  = 1'b0;

            end


           

            S_READ_ACCESS: begin

                psel    = 1'b1;
                penable = 1'b1;
                pwrite  = 1'b0;

                paddr   = addr_reg;

                // Return APB read data to AHB
                hrdata  = prdata;

                // Transfer complete
                hready  = 1'b1;

            end


           
            S_WRITE_SETUP: begin

                psel    = 1'b1;
                penable = 1'b0;
                pwrite  = 1'b1;

                paddr   = addr_reg;
                pwdata  = data_reg;

                hready  = 1'b0;

            end


            
            S_WRITE_ACCESS: begin

                psel    = 1'b1;
                penable = 1'b1;
                pwrite  = 1'b1;

                paddr   = addr_reg;
                pwdata  = data_reg;

                // Transfer complete
                hready  = 1'b1;

            end


            default: begin

                psel    = 1'b0;
                penable = 1'b0;
                hready  = 1'b1;

            end

        endcase

    end

endmodule
