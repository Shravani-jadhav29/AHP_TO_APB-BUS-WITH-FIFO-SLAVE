`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: nexys_a7_top
//
// SIMPLE VERSION -- same idea as your ahb_write/ahb_read testbench tasks,
// just rebuilt as real hardware instead of simulation code.
//
// Your testbench task did this:
//   1) @(posedge hclk) -- drive haddr/hwdata/hselapb/htrans
//   2) @(posedge hclk) -- hold the same values one more cycle
//   3) @(posedge hclk) -- drop everything back to 0
//
// This module does the exact same 3 steps, just triggered by a button press
// instead of by a testbench calling a task:
//
//   STATE IDLE   -> waiting. On button press, drive the AHB signals (step 1)
//   STATE SETUP  -> just hold everything the same for one more cycle (step 2)
//   STATE ENABLE -> grab whatever hrdata says, then clear everything (step 3)
//
// Controls:
//   SW[7:0]  = address you want to talk to   (0x20 = the FIFO)
//   SW[15:8] = data byte to write
//   BTNC     = press to WRITE
//   BTNU     = press to READ
//   7-seg display + LED[7:0] = show the last byte read back


module nexys_a7_top (



     input  wire        CLK100MHZ,
    input  wire        CPU_RESETN,

    input  wire        BTNC,
    input  wire        BTNU,

    input  wire [15:0] SW,

    output wire [15:0] LED,
    output wire [3:0]  AN,
    output wire [6:0]  SEG,
    output wire        DP


);

   

    wire HCLK;
    wire HRESETn;

    assign HCLK    = CLK100MHZ;
    assign HRESETn = CPU_RESETN;


   

    wire btn_write_db;
    wire btn_read_db;

    debounce debounce_write (
        .clk    (HCLK),
        .rst    (~HRESETn),
        .btn    (BTNC),
        .btn_db (btn_write_db)
    );

    debounce debounce_read (
        .clk    (HCLK),
        .rst    (~HRESETn),
        .btn    (BTNU),
        .btn_db (btn_read_db)
    );


   

    wire write_pulse;
    wire read_pulse;

    edge_detector edge_write (
        .clk       (HCLK),
        .rst       (~HRESETn),
        .signal_in (btn_write_db),
        .pulse     (write_pulse)
    );

    edge_detector edge_read (
        .clk       (HCLK),
        .rst       (~HRESETn),
        .signal_in (btn_read_db),
        .pulse     (read_pulse)
    );


  
    wire  start;
    wire write_enable;
    wire [31:0] address;
    wire [31:0] write_data;

    assign start = write_pulse | read_pulse;

    assign write_enable = write_pulse;

    // SW[7:0] = AHB address
    assign address = {24'h000000, SW[7:0]};

    // SW[15:8] = AHB write data
    assign write_data = {24'h000000, SW[15:8]};


   
    wire [31:0] HADDR;
    wire [31:0] HWDATA;

    wire  HWRITE;
    wire [1:0]  HTRANS;
    wire [2:0]  HSIZE;
    wire  HSEL;

    wire [31:0] HRDATA;
    wire HREADY;
    wire  HRESP;


    
    wire [31:0] read_data;
    wire    done;


    

    AHB_lite_master master (

        .HCLK  (HCLK),
        .HRESETn (HRESETn),

        .start (start),
        .write_enable (write_enable),
        .address (address),
        .write_data (write_data),

        .HADDR (HADDR),
        .HWDATA (HWDATA),
        .HWRITE  (HWRITE),
        .HTRANS (HTRANS),
        .HSIZE  (HSIZE),
        .HSEL         (HSEL),

        .HRDATA (HRDATA),
        .HREADY  (HREADY),
        .HRESP  (HRESP),

        .read_data (read_data),
        .done   (done)
    );


   

    wire  PSEL;
    wire PENABLE;
    wire  PWRITE;

    wire [31:0] PADDR;
    wire [31:0] PWDATA;

    wire [31:0] PRDATA;


    
    

    bridge_without_pipeline bridge (

        .hclk      (HCLK),
        .hresetn   (HRESETn),

        .hselapb   (HSEL),
        .hwrite    (HWRITE),
        .htrans    (HTRANS),
        .haddr     (HADDR),
        .hwdata    (HWDATA),

        .prdata    (PRDATA),

        .psel      (PSEL),
        .penable   (PENABLE),
        .pwrite    (PWRITE),
        .paddr     (PADDR),
        .pwdata    (PWDATA),

        .hresp     (HRESP),
        .hready    (HREADY),
        .hrdata    (HRDATA)
    );


   

    wire uart_sel;
    wire gpio_sel;
    wire fifo_sel;
    wire pwm_sel;

    apb_decoder decoder (

        .psel     (PSEL),
        .paddr     (PADDR[7:0]),

        .uart_sel (uart_sel),
        .gpio_sel (gpio_sel),
        .fifo_sel (fifo_sel),
        .pwm_sel  (pwm_sel)
    );


    
    wire        fifo_wr_en;
    wire        fifo_rd_en;

    wire [7:0]  fifo_data_in;
    wire [7:0]  fifo_data_out;

    wire        fifo_full;
    wire        fifo_empty;


    

    apb_slave fifo_apb (

        .clk      (HCLK),
        .rst      (~HRESETn),

        .psel     (fifo_sel),
        .penable  (PENABLE),
        .pwrite   (PWRITE),

        .pwdata   (PWDATA),
        .prdata   (PRDATA),

        .pready   (),
        .pslverr  (),

        .wr_en    (fifo_wr_en),
        .rd_en    (fifo_rd_en),

        .data_in  (fifo_data_in),
        .data_out (fifo_data_out),

        .full     (fifo_full),
        .empty    (fifo_empty)
    );


   
    FIFO fifo (

        .clk      (HCLK),
        .rst      (~HRESETn),

        .wr_en    (fifo_wr_en),
        .rd_en    (fifo_rd_en),

        .data_in  (fifo_data_in),
        .data_out (fifo_data_out),

        .full     (fifo_full),
        .empty    (fifo_empty)
    );


   
display_mux DISP (

    .clk  (HCLK),
   
    .data (read_data[7:0]),
    .an   (AN),
    .seg  (SEG)

);

    
    // LED[7:0]
    // Read data from AHB master
   

    assign LED[7:0] = read_data[7:0];


   

    assign LED[8] = HRESP;


   
    // LED[9]
    // HREADY
   

    assign LED[9] = HREADY;


    
    // LED[10]
    // FIFO WRITE ENABLE
   

    assign LED[10] = fifo_wr_en;


    
    // LED[11]
    // FIFO READ ENABLE
  

    assign LED[11] = fifo_rd_en;


    
    // LED[12]
    // APB SELECT
    

    assign LED[12] = PSEL;


    
    // LED[13]
    // APB ENABLE
    

    assign LED[13] = PENABLE;



    // LED[14]
    // APB WRITE
   

    assign LED[14] = PWRITE;


   
    // LED[15]
    // FIFO NOT EMPTY


    assign LED[15] = ~fifo_empty;


endmodule
