`ifndef ASSERT_MACROS
 `define ASSERT_MACROS

 `define assert_clk_xrst(arg) \
    assert property (@(posedge lc3if.clk) disable iff (lc3if.rst) arg)
 `define assert_clk(arg) \
    assert property (@(posedge lc3if.clk) arg)

`endif
