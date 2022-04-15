import defines::*;
import mem_defines::*;

module ref_hier(
	input reg clk,
	input reg rst,
	input kill
);

reg [7:0] mem_ref[0:65535];
integer i;
integer f;

initial
begin
	// Load TCM memory
	$display("REF: initializing simulation memory, this may take a while...");
	for (i=0;i<65535;i=i+1)
		mem_ref[i] = 0;

	f = $fopen("instr.bin","rb");
	i = $fread(mem_ref, f);
	
	for (i=0;i<MAX_PHY_ADDR;i=i+1)
		mem_inst_ref.write(i, mem_ref[i]);
end

data_t			debug_pc;
instr_t			debug_instr;
always_comb begin : debug_wire_assign
	debug_pc = core_ref.pc_q;
	debug_instr = instr_t'(core_ref.mem_i_inst_i);
end
logic[XLEN-1:0] boot_pc [0:0];

logic			mem_i_rd_w;
logic			mem_i_flush_w;
logic			mem_i_invalidate_w;
logic	[ 31:0]	mem_i_pc_w;
logic	[ 31:0]	mem_d_addr_w;
logic	[ 31:0]	mem_d_data_wr_w;
logic			mem_d_rd_w;
logic	[  3:0]	mem_d_wr_w;
logic			mem_d_cacheable_w;
logic	[ 10:0]	mem_d_req_tag_w;
logic			mem_d_invalidate_w;
logic			mem_d_writeback_w;
logic			mem_d_flush_w;
logic			mem_i_accept_w;
logic			mem_i_valid_w;
logic			mem_i_error_w;
logic	[ 31:0]	mem_i_inst_w;
logic	[ 31:0]	mem_d_data_rd_w;
logic			mem_d_accept_w;
logic			mem_d_ack_w;
logic			mem_d_error_w;
logic	[ 10:0]	mem_d_resp_tag_w;

riscv_core core_ref (
	// Inputs
	 .clk_i(clk)
	,.rst_i(rst)
	,.kill(kill)
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
	,.reset_vector_i(boot_pc[0])
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

// synopsys translate_off
	initial begin
		if (BOOT_TYPE == BINARY_BOOT) begin
			$readmemh("boot.cfg", boot_pc);
			$display("REF: boot mode: binary");
			$display("REF: booting from pc = %h", boot_pc[0]);
		end else if (BOOT_TYPE == RARS_BOOT) begin
			boot_pc[0] = 32'b0;
			$display("REF: boot mode: RARS");
			$display("REF: booting from pc = %h", 0);
		end
	end
// synopsys translate_on

endmodule: ref_hier
