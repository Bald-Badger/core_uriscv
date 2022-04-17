import defines::*;
import mem_defines::*;

module tcm_mem_ram # (
	parameter   ADDR_WIDTH = $clog2(MAX_PHY_ADDR+1)
) (
	// Inputs
	 input						clk0_i
	,input						rst0_i
	,input	[ ADDR_WIDTH - 1:0]	addr0_i
	,input	[ 31:0]				data0_i
	,input	[  3:0]				wr0_i
	,input						clk1_i
	,input						rst1_i
	,input	[ ADDR_WIDTH - 1:0]	addr1_i
	,input	[ 31:0]				data1_i
	,input	[  3:0]				wr1_i

	// Outputs
	,output	[ 31:0]				data0_o
	,output	[ 31:0]				data1_o
);



//-----------------------------------------------------------------
// Dual Port RAM 64KB
// Mode: Read First
//-----------------------------------------------------------------
/* verilator lint_off MULTIDRIVEN */
// 32MB ram on fpga
reg [31:0]   ram [0 : (MAX_PHY_ADDR + 1)/BYTES] /*verilator public*/;
/* verilator lint_on MULTIDRIVEN */


// synthesis translate_off
integer i;
integer fp, s;
initial begin
		case (BOOT_TYPE)
		BINARY_BOOT: begin
			fp = $fopen("test.elf","rb");
			if (fp == 0) begin
				$error("failed to open boot file\n");
				$stop();
			end
			s = $fread(ram, fp);
			$fclose(fp);

			// RISCV binary should load to VA (in this case also PA) 0x10000
			// moving data to its offset position and earsing them
			for (i = 0; i < 20'h10000/4; i++) begin
				ram[20'h0x10000/4 + i] = swap_endian(ram [i]);
				ram[i] = 0;
			end
		end
		
		RARS_BOOT: begin
			$readmemh("instr.mc", ram);
		end

		default: begin
			$display("unkown boot type!");
			$stop();
		end
	endcase
end
// synthesis translate_on

reg [31:0] ram_read0_q;
reg [31:0] ram_read1_q;


// Synchronous write
always @ (posedge clk0_i)
begin
	if (wr0_i[0])
		ram[addr0_i][7:0] <= data0_i[7:0];
	if (wr0_i[1])
		ram[addr0_i][15:8] <= data0_i[15:8];
	if (wr0_i[2])
		ram[addr0_i][23:16] <= data0_i[23:16];
	if (wr0_i[3])
		ram[addr0_i][31:24] <= data0_i[31:24];

	ram_read0_q <= ram[addr0_i];
end

always @ (posedge clk1_i)
begin
	if (wr1_i[0])
		ram[addr1_i][7:0] <= data1_i[7:0];
	if (wr1_i[1])
		ram[addr1_i][15:8] <= data1_i[15:8];
	if (wr1_i[2])
		ram[addr1_i][23:16] <= data1_i[23:16];
	if (wr1_i[3])
		ram[addr1_i][31:24] <= data1_i[31:24];

	ram_read1_q <= ram[addr1_i];
end

assign data0_o = ram_read0_q;
assign data1_o = ram_read1_q;



endmodule
