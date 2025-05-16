
     package FIFO_scoreboard_pkg;
    import uvm_pkg::*;
    import FIFO_seq_item_pkg::*;
    `include "uvm_macros.svh"
    parameter FIFO_WIDTH = 16;
    parameter FIFO_DEPTH = 8;
    
    class FIFO_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(FIFO_scoreboard)
        
        uvm_analysis_export #(FIFO_seq_item) sb_export;
        uvm_tlm_analysis_fifo #(FIFO_seq_item) sb_fifo;
        FIFO_seq_item seq_item_sb;
        localparam max_fifo_addr = $clog2(FIFO_DEPTH);

        logic [FIFO_WIDTH-1:0] data_out_ref;
        bit [FIFO_WIDTH - 1 : 0] fifo_mem [FIFO_DEPTH-1:0];

        bit [max_fifo_addr - 1 : 0] write_ptr, read_ptr;
        bit [max_fifo_addr : 0] count;
         int error_count = 0;
        int correct_count = 0;

        function new (string name = "FIFO_scoreboard", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sb_export = new("sb_export", this);
            sb_fifo = new("sb_fifo", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            sb_export.connect(sb_fifo.analysis_export);
        endfunction
        task ref_model();
            if (!seq_item_sb.rst_n) begin
                read_ptr = 0;
                write_ptr = 0;
                count = 0;
            end
            else begin
                if (seq_item_sb.rd_en && count != 0) begin
                    data_out_ref = fifo_mem[read_ptr];
                    read_ptr++;
                end
                if (seq_item_sb.wr_en && count != FIFO_DEPTH) begin
                    fifo_mem[write_ptr] = seq_item_sb.data_in;
                    write_ptr++;
                end
                 if (({seq_item_sb.wr_en, seq_item_sb.rd_en} == 2'b11) && count == 0)
                    count = count + 1;
                else if (({seq_item_sb.wr_en, seq_item_sb.rd_en} == 2'b11) && count == FIFO_DEPTH)
                    count = count - 1;
                else if (({seq_item_sb.wr_en, seq_item_sb.rd_en} == 2'b10) && count!= FIFO_DEPTH)
                    count = count + 1;
                else if (({seq_item_sb.wr_en, seq_item_sb.rd_en} == 2'b01) && count != 0 )
                    count = count - 1;
                end 
        endtask

        task check_data();
             ref_model(); 

         if (seq_item_sb.data_out !== data_out_ref) begin
       `uvm_error("check_data", $sformatf("Error: data_out mismatch! Expected: %0h, Got: %0h", data_out_ref, seq_item_sb.data_out))
                error_count++;
            end else begin
                `uvm_info("check_data", $sformatf("Correct: data_out matches at time %0t!", $time), UVM_HIGH)
                correct_count++;
            end
        endtask

   task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                sb_fifo.get(seq_item_sb);
                
                // Call the check_data task to check each transaction
                check_data();
            end
        endtask
        
        function void report_phase(uvm_phase phase);
            super.report_phase(phase);
            `uvm_info("report_phase", $sformatf("Total successful transactions: %0d", correct_count), UVM_MEDIUM)
            `uvm_info("report_phase", $sformatf("Total failed transactions: %0d", error_count), UVM_MEDIUM)            
        endfunction
    endclass
endpackage