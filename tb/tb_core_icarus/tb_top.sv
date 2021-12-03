module tb_top;

reg clk;
reg rst;

reg [7:0] mem_ref[0:65535];
integer i;
integer f;


function logic[31:0] swap_endian;
	input logic[31:0] data;
	return	{{data[7:0]},
			{data[15:8]},
			{data[23:16]},
			{data[31:24]}};
endfunction

initial
begin
    // Reset
    clk = 0;
    rst = 1;
    repeat (5) @(posedge clk);
    rst = 0;

    // Load TCM memory
    for (i=0;i<65535;i=i+1)
        mem_ref[i] = 0;

    f = $fopen("instr.bin","r");
    i = $fread(mem_ref, f);
    for (i=0;i<65535;i=i+1)
        mem_inst_ref.write(i, mem_ref[i]);
end

initial
begin
    forever
    begin 
        clk = #5 ~clk;
    end
end

logic          mem_i_rd_w;
logic          mem_i_flush_w;
logic          mem_i_invalidate_w;
logic [ 31:0]  mem_i_pc_w;
logic [ 31:0]  mem_d_addr_w;
logic [ 31:0]  mem_d_data_wr_w;
logic          mem_d_rd_w;
logic [  3:0]  mem_d_wr_w;
logic          mem_d_cacheable_w;
logic [ 10:0]  mem_d_req_tag_w;
logic          mem_d_invalidate_w;
logic          mem_d_writeback_w;
logic          mem_d_flush_w;
logic          mem_i_accept_w;
logic          mem_i_valid_w;
logic          mem_i_error_w;
logic [ 31:0]  mem_i_inst_w;
logic [ 31:0]  mem_d_data_rd_w;
logic          mem_d_accept_w;
logic          mem_d_ack_w;
logic          mem_d_error_w;
logic [ 10:0]  mem_d_resp_tag_w;

riscv_core proc_ref (
    // Inputs
     .clk_i(clk)
    ,.rst_i(rst)
    ,.mem_d_data_rd_i(mem_d_data_rd_w)
    ,.mem_d_accept_i(mem_d_accept_w)
    ,.mem_d_ack_i(mem_d_ack_w)
    ,.mem_d_error_i(mem_d_error_w)
    ,.mem_d_resp_tag_i(mem_d_resp_tag_w)
    ,.mem_i_accept_i(mem_i_accept_w)
    ,.mem_i_valid_i(mem_i_valid_w)
    ,.mem_i_error_i(mem_i_error_w)
    ,.mem_i_inst_i(mem_i_inst_w)
    ,.intr_i(1'b0)
    ,.reset_vector_i(32'h00000000)
    ,.cpu_id_i('b0)

    // Outputs
    ,.mem_d_addr_o(mem_d_addr_w)
    ,.mem_d_data_wr_o(mem_d_data_wr_w)
    ,.mem_d_rd_o(mem_d_rd_w)
    ,.mem_d_wr_o(mem_d_wr_w)
    ,.mem_d_cacheable_o(mem_d_cacheable_w)
    ,.mem_d_req_tag_o(mem_d_req_tag_w)
    ,.mem_d_invalidate_o(mem_d_invalidate_w)
    ,.mem_d_writeback_o(mem_d_writeback_w)
    ,.mem_d_flush_o(mem_d_flush_w)
    ,.mem_i_rd_o(mem_i_rd_w)
    ,.mem_i_flush_o(mem_i_flush_w)
    ,.mem_i_invalidate_o(mem_i_invalidate_w)
    ,.mem_i_pc_o(mem_i_pc_w)
);

tcm_mem mem_inst_ref (
    // Inputs
     .clk_i(clk)
    ,.rst_i(rst)
    ,.mem_i_rd_i(mem_i_rd_w)
    ,.mem_i_flush_i(mem_i_flush_w)
    ,.mem_i_invalidate_i(mem_i_invalidate_w)
    ,.mem_i_pc_i(mem_i_pc_w)
    ,.mem_d_addr_i(mem_d_addr_w)
    ,.mem_d_data_wr_i(mem_d_data_wr_w)
    ,.mem_d_rd_i(mem_d_rd_w)
    ,.mem_d_wr_i(mem_d_wr_w)
    ,.mem_d_cacheable_i(mem_d_cacheable_w)
    ,.mem_d_req_tag_i(mem_d_req_tag_w)
    ,.mem_d_invalidate_i(mem_d_invalidate_w)
    ,.mem_d_writeback_i(mem_d_writeback_w)
    ,.mem_d_flush_i(mem_d_flush_w)

    // Outputs
    ,.mem_i_accept_o(mem_i_accept_w)
    ,.mem_i_valid_o(mem_i_valid_w)
    ,.mem_i_error_o(mem_i_error_w)
    ,.mem_i_inst_o(mem_i_inst_w)
    ,.mem_d_data_rd_o(mem_d_data_rd_w)
    ,.mem_d_accept_o(mem_d_accept_w)
    ,.mem_d_ack_o(mem_d_ack_w)
    ,.mem_d_error_o(mem_d_error_w)
    ,.mem_d_resp_tag_o(mem_d_resp_tag_w)
);

// reg debug wire
logic reg_wren_ref;
logic[4:0] reg_wr_addr;
logic[31:0] rd_data_ref;
assign reg_wren_ref = proc_ref.rd_writeen_w;
assign reg_wr_addr = proc_ref.rd_q;
assign rd_data_ref = proc_ref.rd_val_w;

always_ff @(negedge clk) begin : ref_log
	if (reg_wren_ref) begin
		$display("Write reg: %d, value: %h", reg_wr_addr, rd_data_ref);
	end
end

endmodule