package FIFO_coverage_pkg;
    import uvm_pkg::*;
    import FIFO_seq_item_pkg::*;
    `include "uvm_macros.svh"

    class FIFO_coverage extends uvm_component;
        `uvm_component_utils(FIFO_coverage)

        uvm_analysis_export #(FIFO_seq_item) cov_export;
        uvm_tlm_analysis_fifo #(FIFO_seq_item) cov_fifo;
        FIFO_seq_item seq_item_cov;


        covergroup FIFO_cvr_gp;

            cp_wr_en: coverpoint seq_item_cov.wr_en;
            cp_rd_en: coverpoint seq_item_cov.rd_en;
            cp_ack: coverpoint seq_item_cov.wr_ack;
            cp_overflow: coverpoint seq_item_cov.overflow;
            cp_full: coverpoint seq_item_cov.full;
            cp_empty: coverpoint seq_item_cov.empty;
            cp_almostfull: coverpoint seq_item_cov.almostfull;
            cp_almostempty: coverpoint seq_item_cov.almostempty; 
            cp_underflow: coverpoint seq_item_cov.underflow;
            wr_ack_C: cross cp_wr_en, cp_rd_en, cp_ack{
                illegal_bins zero_zero_one = binsof(cp_wr_en) intersect {0} && binsof(cp_ack) intersect {1}; 
            } // cross coverage for wr_ack, note that a wr_ack can't be done if the wr_en is zero, so it takes an illegal bin
            overflow_C: cross cp_wr_en, cp_rd_en, cp_overflow {
                illegal_bins zero_w_one = binsof(cp_wr_en) intersect {0} && binsof(cp_overflow) intersect {1}; 
            } // cross coverage for overflow, note that an overflow can't be done if there is wr_en is low , so it takes an illegal bin
            full_C: cross cp_wr_en, cp_rd_en, cp_full {
                illegal_bins one_r_one = binsof(cp_rd_en) intersect {1} && binsof(cp_full) intersect {1}; 
            } // cross coverage for full flag , note that a full signal can't be raised if there is read process, so it takes an illegal bin
            empty_C: cross cp_wr_en, cp_rd_en, cp_empty; // cross coverage for empty
            almostfull_C: cross cp_wr_en, cp_rd_en, cp_almostfull; // cross coverage for almostfull signal
            almostempty_C: cross cp_wr_en, cp_rd_en, cp_almostempty; // cross coverage for almostempty signal
            underflow_C: cross cp_wr_en, cp_rd_en, cp_underflow {
                illegal_bins zero_r_one = binsof(cp_rd_en) intersect {0} && binsof(cp_underflow) intersect {1};
            } // cross coverage for underflow signal, note that an underflow can't be done if rd_en is low , so it takes an illegal bin
        endgroup

       function new(string name = "FIFO_coverage", uvm_component parent = null);
            super.new(name, parent);
            FIFO_cvr_gp = new();
            FIFO_cvr_gp.start();
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            cov_export = new("cov_export", this);
            cov_fifo = new("cov_fifo", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);

            //connect the analysis exports
            cov_export.connect(cov_fifo.analysis_export);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                cov_fifo.get(seq_item_cov);
                FIFO_cvr_gp.sample();
            end
        endtask
    endclass
endpackage