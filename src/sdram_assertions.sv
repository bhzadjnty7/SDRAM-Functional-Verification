module sdram_assertions(
    input tb_HCLK,
    input tb_HRESET,
    input tb_HWRITE,
    input tb_HSEL,
    input [31:0] tb_HWDATA,
    input [31:0] tb_HADDR,
    input tb_HREADY,
    input [31:0] tb_HRDATA
);
    //assertions
    //assertion 1: hready should become zero after write request
    property p_ready_low_on_wreq;
       @(posedge tb_HCLK) disable iff (tb_HRESET)
       ($rose(tb_HSEL) && $rose(tb_HWRITE) && (tb_HREADY)) |-> $fell(tb_HREADY);
    endproperty
    assert property (p_ready_low_on_wreq)
        else $error("error on hready for write request");
    
    //asserion 2: hready should become zero after read request
     property p_ready_low_on_rreq;
       @(posedge tb_HCLK) disable iff (tb_HRESET)
       ($rose(tb_HSEL) && $fell(tb_HWRITE) && (tb_HREADY)) |-> $fell(tb_HREADY);
    endproperty
    assert property (p_ready_low_on_rreq)
        else $error("error on hready for read requset");

    // Assertion 3: HREADY remains low for 5 cycles (50ns) during operation
    property p_hready_low_for_5_cycles;
        @(posedge tb_HCLK) disable iff (tb_HRESET)
        $fell(tb_HREADY) |=> $stable(tb_HREADY)[*5];
    endproperty
    assert property (p_hready_low_for_5_cycles)
        else $error("HREADY should remain low for 5 cycles during operation");

    // Assertion 4: HREADY goes high on reset
    property p_hready_high_on_reset;
        @(posedge tb_HCLK)
        $rose(tb_HRESET) |=> $rose(tb_HREADY);
    endproperty
    assert property (p_hready_high_on_reset)
        else $error("HREADY should go high on reset");

    // Assertion 5: HREADY goes high on reset
    property p_hready_high_on_reset2;
        @(posedge tb_HCLK)
        $rose(tb_HRESET) |-> $rose(tb_HREADY);
    endproperty
    assert property (p_hready_high_on_reset)
        else $error("HREADY should go high on reset2");
endmodule
