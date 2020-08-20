`timescale 1ps/100fs

import axi_vip_pkg::*;
import design_1_axi_vip_0_0_pkg::*;//This name should be the same as the name written down

module example_sim_top ();

// Important: don't remove this line, even though it's not passed to any sub module
// Vivado will automatically detect this parameter
parameter SIM_BYPASS_INIT_CAL = "FAST";

// ID value for WRITE/READ_BURST transaction
xil_axi_uint mtestID;
// ADDR value for WRITE/READ_BURST transaction
xil_axi_ulong mtestADDR;
// Burst Length value for WRITE/READ_BURST transaction
xil_axi_len_t mtestBurstLength;
// SIZE value for WRITE/READ_BURST transaction
xil_axi_size_t mtestDataSize;
// Burst Type value for WRITE/READ_BURST transaction
xil_axi_burst_t mtestBurstType;
// LOCK value for WRITE/READ_BURST transaction
xil_axi_lock_t mtestLOCK;
// Cache Type value for WRITE/READ_BURST transaction
xil_axi_cache_t mtestCacheType = 3;
// Protection Type value for WRITE/READ_BURST transaction
xil_axi_prot_t mtestProtectionType = 3'b000;
// Region value for WRITE/READ_BURST transaction
xil_axi_region_t mtestRegion = 4'b000;
// QOS value for WRITE/READ_BURST transaction
xil_axi_qos_t mtestQOS = 4'b000;
// Data beat value for WRITE/READ_BURST transaction
xil_axi_data_beat dbeat;
// User beat value for WRITE/READ_BURST transaction
xil_axi_user_beat usrbeat;
// Wuser value for WRITE/READ_BURST transaction
xil_axi_data_beat[255:0] mtestWUSER;
// Awuser value for WRITE/READ_BURST transaction
xil_axi_data_beat mtestAWUSER = 'h0;
// Aruser value for WRITE/READ_BURST transaction
xil_axi_data_beat mtestARUSER = 0;
// Ruser value for WRITE/READ_BURST transaction
xil_axi_data_beat[255:0] mtestRUSER;
// Buser value for WRITE/READ_BURST transaction
xil_axi_uint mtestBUSER = 0;
// Bresp value for WRITE/READ_BURST transaction
xil_axi_resp_t mtestBresp;
// Rresp value for WRITE/READ_BURST transaction
xil_axi_resp_t[255:0] mtestRresp;
// write transaction created by master VIP 
axi_transaction wr_transaction; 
// read transaction created by master VIP 
axi_transaction rd_transaction; 
// transaction used for constraint randomization purpose
axi_transaction wr_rand;
// transaction used for constraint randomization purpose
axi_transaction rd_rand;
//----------------------------------------------------------------------------------------------
// A burst can not cross 4KB address boundry for AXI4
// maximum data bits = 4*1024*8 =32768
// Write Data Value for WRITE_BURST transaction
// Read Data Value for READ_BURST transaction
//----------------------------------------------------------------------------------------------
bit[511:0] mtestWData = 0;
bit[511:0] mtestRData;
//----------------------------------------------------------------------------------------------
// verbosity level which specifies how much debug information to produce
// 0       - No information will be printed out.
// 400      - All information will be printed out.
// master VIP agent verbosity level
//----------------------------------------------------------------------------------------------
xil_axi_uint mst_agent_verbosity = 0;

// Declare agent
design_1_axi_vip_0_0_mst_t master_agent;//This should be the same as the name written down

wire[13:0]	ddr3_sdram_addr;
wire[2:0]	ddr3_sdram_ba;
wire 		ddr3_sdram_cas_n;
wire[0:0]	ddr3_sdram_ck_n;
wire[0:0]	ddr3_sdram_ck_p;
wire[0:0]	ddr3_sdram_cke;
wire[0:0]	ddr3_sdram_cs_n;
wire[7:0]	ddr3_sdram_dm;
wire[63:0]	ddr3_sdram_dq;
wire[7:0]	ddr3_sdram_dqs_n;
wire[7:0]	ddr3_sdram_dqs_p;
wire[0:0]	ddr3_sdram_odt;
wire 		ddr3_sdram_ras_n;
wire 		ddr3_sdram_reset_n;
wire 		ddr3_sdram_we_n;

ddr3_sim_model sim_model (
	.ddr3_sdram_addr(ddr3_sdram_addr),
  	.ddr3_sdram_ba(ddr3_sdram_ba),
  	.ddr3_sdram_cas_n(ddr3_sdram_cas_n),
  	.ddr3_sdram_ck_n(ddr3_sdram_ck_n),
  	.ddr3_sdram_ck_p(ddr3_sdram_ck_p),
  	.ddr3_sdram_cke(ddr3_sdram_cke),
  	.ddr3_sdram_cs_n(ddr3_sdram_cs_n),
  	.ddr3_sdram_dm(ddr3_sdram_dm),
  	.ddr3_sdram_dq(ddr3_sdram_dq),
  	.ddr3_sdram_dqs_n(ddr3_sdram_dqs_n),
  	.ddr3_sdram_dqs_p(ddr3_sdram_dqs_p),
  	.ddr3_sdram_odt(ddr3_sdram_odt),
  	.ddr3_sdram_ras_n(ddr3_sdram_ras_n),
  	.ddr3_sdram_reset_n(ddr3_sdram_reset_n),
  	.ddr3_sdram_we_n(ddr3_sdram_we_n)
);

wire init_calib_complete;

reg reset = 1;

localparam CLKIN_PERIOD = 5000;//5000ps = 200MHz

reg clk = 1;
always #(CLKIN_PERIOD/2.0) clk = ~clk;
wire sys_diff_clock_clk_n = ~clk;
wire sys_diff_clock_clk_p = clk;

design_1_wrapper DUT (
	.ddr3_sdram_addr(ddr3_sdram_addr),
    .ddr3_sdram_ba(ddr3_sdram_ba),
    .ddr3_sdram_cas_n(ddr3_sdram_cas_n),
    .ddr3_sdram_ck_n(ddr3_sdram_ck_n),
    .ddr3_sdram_ck_p(ddr3_sdram_ck_p),
    .ddr3_sdram_cke(ddr3_sdram_cke),
    .ddr3_sdram_cs_n(ddr3_sdram_cs_n),
    .ddr3_sdram_dm(ddr3_sdram_dm),
    .ddr3_sdram_dq(ddr3_sdram_dq),
    .ddr3_sdram_dqs_n(ddr3_sdram_dqs_n),
    .ddr3_sdram_dqs_p(ddr3_sdram_dqs_p),
    .ddr3_sdram_odt(ddr3_sdram_odt),
    .ddr3_sdram_ras_n(ddr3_sdram_ras_n),
    .ddr3_sdram_reset_n(ddr3_sdram_reset_n),
    .ddr3_sdram_we_n(ddr3_sdram_we_n),
    
	.init_calib_complete_0(init_calib_complete),
    
	.reset(reset),
    .sys_diff_clock_clk_n(sys_diff_clock_clk_n),
    .sys_diff_clock_clk_p(sys_diff_clock_clk_p)
);

initial begin
	// Create an agent
	master_agent = new("master vip agent", DUT.design_1_i.axi_vip_0.inst.IF);

	// Set tag for agents for easy debug
	master_agent.set_agent_tag("Master VIP");

	// Set print out verbosity level
	master_agent.set_verbosity(mst_agent_verbosity);

	// Start the agent
	master_agent.start_master();

	#100ns
	reset = 0;

	wait(init_calib_complete == 1'b1);
	#10ns;
	$display("DDR3 initialization is done");
	$stop;
	
	@(posedge clk);
	mtestID = 0;
	mtestADDR = 32'h8000_0000;//The address assigned in Vivado
	mtestBurstLength = 0;
	mtestDataSize = xil_axi_size_t'(xil_clog2(512/8));
	mtestBurstType = XIL_AXI_BURST_TYPE_INCR;
	mtestLOCK = XIL_AXI_ALOCK_NOLOCK;
	mtestProtectionType = 0;
	mtestRegion = 0;
	mtestQOS = 0;
	mtestWUSER = 0;
	mtestWData[0 +: 512] = 512'hdeadbeaf;
	master_agent.AXI4_WRITE_BURST(
		mtestID,
        mtestADDR,
        mtestBurstLength,
        mtestDataSize,
        mtestBurstType,
        mtestLOCK,
        mtestCacheType,
        mtestProtectionType,
        mtestRegion,
        mtestQOS,
        mtestAWUSER,
        mtestWData,
        mtestWUSER,
        mtestBresp
	);
	$display("Master issued 512-bit write");
	$display("mtestWData: %s", mtestWData[0 +: 512]);

	$stop;
	@(posedge clk);
	mtestID = 0;
	mtestADDR = 32'h8000_0000;
	mtestBurstLength = 0;
	mtestDataSize = xil_axi_size_t'(xil_clog2(512/8));
	mtestBurstType = XIL_AXI_BURST_TYPE_INCR;
	mtestLOCK = XIL_AXI_ALOCK_NOLOCK;
	mtestProtectionType = 0;
	mtestRegion = 0;
	mtestQOS = 0;
	mtestWUSER = 0;
	master_agent.AXI4_READ_BURST(
		mtestID,
		mtestADDR,
		mtestBurstLength,
		mtestDataSize,
		mtestBurstType,
		mtestLOCK,
		mtestCacheType,
		mtestProtectionType,
		mtestRegion,
		mtestQOS,
		mtestARUSER,
		mtestRData,
		mtestRresp,
		mtestRUSER
	);
	$display("Master issued 512-bit read");
	$display("mtestRData: %s", mtestRData[0 +: 512]);
	assert(mtestRData[0 +: 512] == 512'hdeadbeaf) else $stop;

	#10ns
	$display("Test done");
	$finish;
end

endmodule
