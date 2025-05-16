module FIFO_SVA(FIFO_if.DUT FIFOif);
always_comb begin
    if(!FIFOif.rst_n) begin
    
    	count_aa: assert final(dut.count == 0);
        wr_ptr_aa: assert final(dut.wr_ptr == 0);
        rd_ptr_aa: assert final(dut.rd_ptr == 0);
        full_aa: assert final(FIFOif.full == 0);
        empty_aa: assert final(FIFOif.empty == 1);
        underflow_aa: assert final(FIFOif.underflow == 0);
        almostfull_aa: assert final(FIFOif.almostfull == 0);
        almostempty_aa: assert final(FIFOif.almostempty == 0);
        wr_ack_aa: assert final(FIFOif.wr_ack == 0);
        overflow_aa: assert final(FIFOif.overflow == 0);
      
	end
	if((dut.count == 0))
      
        empty_a: assert final (FIFOif.empty == 1);
      
	if((dut.count == FIFOif.FIFO_DEPTH))
      
        full_a: assert final(FIFOif.full == 1);
      
	if((dut.count == FIFOif.FIFO_DEPTH - 1))
    
        almostfull_a: assert final(FIFOif.almostfull == 1);
	if(dut.count == 1)
        almostempty_a: assert final(FIFOif.almostempty == 1);

end


property wr_ack_p;
	@(posedge FIFOif.clk) disable iff (FIFOif.rst_n == 0) 
	  FIFOif.wr_en && ( dut.count < FIFOif.FIFO_DEPTH) |=> FIFOif.wr_ack ;
endproperty

property overflow_p;
	@(posedge FIFOif.clk) disable iff (FIFOif.rst_n == 0) 
	((dut.count == FIFOif.FIFO_DEPTH) && FIFOif.wr_en) |=> (FIFOif.overflow == 1);
endproperty

property underflow_p;
	@(posedge FIFOif.clk) disable iff (FIFOif.rst_n == 0) 
	(FIFOif.empty) && (FIFOif.rd_en) |=> FIFOif.underflow;
endproperty 

property write_count;
        @(posedge FIFOif.clk) disable iff (!FIFOif.rst_n) 
        (!FIFOif.rd_en && FIFOif.wr_en &&  dut.count != FIFOif.FIFO_DEPTH) |=> (dut.count == ($past(dut.count) + 1'b1 ));
 endproperty
 property read_count;
        @(posedge FIFOif.clk) disable iff (!FIFOif.rst_n) 
        (FIFOif.rd_en && !FIFOif.wr_en &&  dut.count != 0) |=> ( dut.count == ($past(dut.count) - 1'b1 ));
 endproperty
  property read_write_count;
        @(posedge FIFOif.clk) disable iff(!FIFOif.rst_n) 
        (FIFOif.rd_en && FIFOif.wr_en && dut.count != 0 && dut.count != FIFOif.FIFO_DEPTH) |=> ($past(dut.count) == dut.count);
   endproperty
 property read_write_count_empty;
        @(posedge FIFOif.clk) disable iff(!FIFOif.rst_n) 
        (FIFOif.rd_en && FIFOif.wr_en && FIFOif.empty) |=> ($past(dut.count) + 1'b1 == dut.count);
    endproperty
property read_write_count_full;
        @(posedge FIFOif.clk) disable iff(!FIFOif.rst_n) 
        (FIFOif.rd_en && FIFOif.wr_en && FIFOif.full) |=> ($past(dut.count) - 1'b1 == dut.count);
    endproperty
 property write_ptr_p;
        @(posedge FIFOif.clk) disable iff (!FIFOif.rst_n) 
        (FIFOif.wr_en && dut.count != FIFOif.FIFO_DEPTH) |=> (dut.wr_ptr == $past(dut.wr_ptr) + 1'b1 );
    endproperty
property read_ptr_p;
        @(posedge FIFOif.clk) disable iff (!FIFOif.rst_n) 
        (FIFOif.rd_en && dut.count != 0) |=> (dut.rd_ptr == $past(dut.rd_ptr) + 1'b1 );
    endproperty
`ifdef SIM
    ack_a: assert property(wr_ack_p);
    overflow_a: assert property (overflow_p);
    underflow_a: assert property (underflow_p);
    wr_ptr_a: assert property (write_ptr_p);
    rd_ptr_a: assert property (read_ptr_p);
    count_write_priority_a: assert property (read_write_count);
    count_read_priority_empty_a: assert property (read_write_count_empty);
	count_read_priority_full_a: assert property (read_write_count_full);
    count_w_a: assert property (write_count);
    count_r_a: assert property (read_count);
  `endif

    ack_a_cv: cover property(wr_ack_p);
    overflow_a_cv: cover property(overflow_p);
    underflow_a_cv: cover property(underflow_p);
    wr_ptr_a_cv: cover property(write_ptr_p);
    rd_ptr_a_cv: cover property(read_ptr_p);
    count_write_priority_a_cv: cover property(read_write_count);
    count_read_priority_empty_a_cv: cover property(read_write_count_empty);
	count_read_priority_full_a_cv: cover property(read_write_count_full);
    count_w_a_cv: cover property(write_count);
    count_r_a_cv: cover property(read_count);
endmodule