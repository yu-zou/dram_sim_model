`timescale 1ps/100fs

// DDR3 simulation wrapper logic based on example designed generated for KC705
// Parameters are pre-defined for KC705, and if you don't know functions of
// parameters, then do not touch, otherwise simulation accuracy is not
// guaranteed.
module ddr3_sim_model #(
	//***************************************************************************
	// The following parameters refer to width of various ports
	//***************************************************************************
	parameter COL_WIDTH			= 10,// # of memory Column Address bits.
	parameter CS_WIDTH			= 1,// # of unique CS outputs to memory.
	parameter DM_WIDTH      	= 8,// # of DM (data mask)
	parameter DQ_WIDTH      	= 64,// # of DQ (data)
	parameter DQS_WIDTH     	= 8,
	parameter DQS_CNT_WIDTH 	= 3,// = ceil(log2(DQS_WIDTH))
	parameter ECC           	= "OFF",
	parameter RANKS         	= 1,// # of Ranks.
	parameter ODT_WIDTH     	= 1,// # of ODT outputs to memory.
	parameter ROW_WIDTH     	= 14,// # of memory Row Address bits.
	parameter ADDR_WIDTH    	= 28// # = RANK_WIDTH + BANK_WIDTH
									//     + ROW_WIDTH + COL_WIDTH;
									// Chip Select is always tied to low for
									// single rank devices
)(
	// Inouts
	inout[DQ_WIDTH-1:0]		ddr3_dq_fpga,
	inout[DQS_WIDTH-1:0]	ddr3_dqs_n_fpga,
	inout[DQS_WIDTH-1:0]	ddr3_dqs_p_fpga,

	// Inputs
	input[ROW_WIDTH-1:0]	ddr3_addr_fpga,
	input[3-1:0]			ddr3_ba_fpga,
	input					ddr3_ras_n_fpga,
	input					ddr3_cas_n_fpga,
	input					ddr3_we_n_fpga,
	input					ddr3_reset_n,
	input[1-1:0]			ddr3_ck_p_fpga,
	input[1-1:0]			ddr3_ck_n_fpga,
	input[1-1:0]			ddr3_cke_fpga,
	input[(CS_WIDTH*1)-1:0]	ddr3_cs_n,
	input[DM_WIDTH-1:0]		ddr3_dm_fpga,
	input[ODT_WIDTH-1:0]	ddr3_odt_fpga,

	input	init_calib_complete
);

//***************************************************************************
// The following parameters are mode register settings
//***************************************************************************
localparam CA_MIRROR	= "OFF";// C/A mirror opt for DDR3 dual rank


//**************************************************************************//
// Local parameters Declarations
//**************************************************************************//
localparam real TPROP_DQS			= 0.00;// Delay for DQS signal during Write Operation
localparam real TPROP_DQS_RD		= 0.00;// Delay for DQS signal during Read Operation
localparam real TPROP_PCB_CTRL     	= 0.00;// Delay for Address and Ctrl signals
localparam real TPROP_PCB_DATA     	= 0.00;// Delay for data signal during Write operation
localparam real TPROP_PCB_DATA_RD  	= 0.00;// Delay for data signal during Read operation

localparam MEMORY_WIDTH = 8;
localparam NUM_COMP     = DQ_WIDTH/MEMORY_WIDTH;
localparam ECC_TEST 	= "OFF" ;
localparam ERR_INSERT 	= (ECC_TEST == "ON") ? "OFF" : ECC ;

reg[(CS_WIDTH*1)-1:0]	ddr3_cs_n_sdram_tmp;
reg[DM_WIDTH-1:0]		ddr3_dm_sdram_tmp;
reg[ODT_WIDTH-1:0]		ddr3_odt_sdram_tmp;
wire[DQ_WIDTH-1:0]		ddr3_dq_sdram;
reg[ROW_WIDTH-1:0]		ddr3_addr_sdram[0:1];
reg[3-1:0]				ddr3_ba_sdram[0:1];
reg						ddr3_ras_n_sdram;
reg						ddr3_cas_n_sdram;
reg						ddr3_we_n_sdram;
wire[(CS_WIDTH*1)-1:0] 	ddr3_cs_n_sdram;
wire[ODT_WIDTH-1:0]		ddr3_odt_sdram;
reg[1-1:0]				ddr3_cke_sdram;
wire[DM_WIDTH-1:0]		ddr3_dm_sdram;
wire[DQS_WIDTH-1:0]		ddr3_dqs_p_sdram;
wire[DQS_WIDTH-1:0]		ddr3_dqs_n_sdram;
reg[1-1:0]				ddr3_ck_p_sdram;
reg[1-1:0]				ddr3_ck_n_sdram;

always @ (*) begin
	ddr3_ck_p_sdram		<=  #(TPROP_PCB_CTRL) ddr3_ck_p_fpga;
    ddr3_ck_n_sdram     <=  #(TPROP_PCB_CTRL) ddr3_ck_n_fpga;
    ddr3_addr_sdram[0]  <=  #(TPROP_PCB_CTRL) ddr3_addr_fpga;
    ddr3_addr_sdram[1]  <=  #(TPROP_PCB_CTRL) (CA_MIRROR == "ON") ?
										{ddr3_addr_fpga[ROW_WIDTH-1:9],
						   				ddr3_addr_fpga[7], ddr3_addr_fpga[8],
						   				ddr3_addr_fpga[5], ddr3_addr_fpga[6],
						   				ddr3_addr_fpga[3], ddr3_addr_fpga[4],
						   				ddr3_addr_fpga[2:0]} : ddr3_addr_fpga;
    ddr3_ba_sdram[0]    <=  #(TPROP_PCB_CTRL) ddr3_ba_fpga;
    ddr3_ba_sdram[1]    <=  #(TPROP_PCB_CTRL) (CA_MIRROR == "ON") ?
						   				{ddr3_ba_fpga[3-1:2],
						   				ddr3_ba_fpga[0],
						   				ddr3_ba_fpga[1]} :
						   				ddr3_ba_fpga;
    ddr3_ras_n_sdram    <=  #(TPROP_PCB_CTRL) ddr3_ras_n_fpga;
    ddr3_cas_n_sdram    <=  #(TPROP_PCB_CTRL) ddr3_cas_n_fpga;
    ddr3_we_n_sdram     <=  #(TPROP_PCB_CTRL) ddr3_we_n_fpga;
    ddr3_cke_sdram      <=  #(TPROP_PCB_CTRL) ddr3_cke_fpga;
end

always @ ( * )
    ddr3_cs_n_sdram_tmp <= #(TPROP_PCB_CTRL) ddr3_cs_n_fpga;
assign ddr3_cs_n_sdram = ddr3_cs_n_sdram_tmp;

always @ ( * )
	ddr3_dm_sdram_tmp <= #(TPROP_PCB_DATA) ddr3_dm_fpga;//DM signal generation
assign ddr3_dm_sdram = ddr3_dm_sdram_tmp;
    

always @ ( * )
	ddr3_odt_sdram_tmp <= #(TPROP_PCB_CTRL) ddr3_odt_fpga;
assign ddr3_odt_sdram = ddr3_odt_sdram_tmp;

// Controlling the bi-directional BUS
genvar dqwd;
generate
for (dqwd = 1; dqwd < DQ_WIDTH; dqwd = dqwd+1) begin : dq_delay
	WireDelay # (
		.Delay_g(TPROP_PCB_DATA),
		.Delay_rd(TPROP_PCB_DATA_RD),
		.ERR_INSERT("OFF")
	) u_delay_dq (
		.A(ddr3_dq_fpga[dqwd]),
		.B(ddr3_dq_sdram[dqwd]),
		.reset(sys_rst_n),
		.phy_init_done(init_calib_complete)
   );
end

WireDelay # (
	.Delay_g(TPROP_PCB_DATA),
	.Delay_rd(TPROP_PCB_DATA_RD),
	.ERR_INSERT("OFF")
) u_delay_dq_0 (
	.A(ddr3_dq_fpga[0]),
	.B(ddr3_dq_sdram[0]),
	.reset(sys_rst_n),
	.phy_init_done(init_calib_complete)
);

endgenerate

genvar dqswd;
generate
for (dqswd = 0; dqswd < DQS_WIDTH; dqswd = dqswd+1) begin : dqs_delay
	WireDelay # (
		.Delay_g(TPROP_DQS),
		.Delay_rd(TPROP_DQS_RD),
		.ERR_INSERT("OFF")
	) u_delay_dqs_p (
		.A(ddr3_dqs_p_fpga[dqswd]),
		.B(ddr3_dqs_p_sdram[dqswd]),
		.reset(sys_rst_n),
		.phy_init_done(init_calib_complete)
	);

	WireDelay # (
		.Delay_g(TPROP_DQS),
		.Delay_rd(TPROP_DQS_RD),
		.ERR_INSERT("OFF")
	) u_delay_dqs_n (
		.A(ddr3_dqs_n_fpga[dqswd]),
		.B(ddr3_dqs_n_sdram[dqswd]),
		.reset(sys_rst_n),
		.phy_init_done(init_calib_complete)
	);
end
endgenerate

//**************************************************************************//
// Memory Models instantiations
//**************************************************************************//
genvar r,i;
generate
for (r = 0; r < CS_WIDTH; r = r + 1) begin: mem_rnk
	for (i = 0; i < NUM_COMP; i = i + 1) begin: gen_mem
		ddr3_model u_comp_ddr3 (
		   .rst_n(ddr3_reset_n),
		   .ck(ddr3_ck_p_sdram[(i*MEMORY_WIDTH)/72]),
		   .ck_n(ddr3_ck_n_sdram[(i*MEMORY_WIDTH)/72]),
		   .cke(ddr3_cke_sdram[((i*MEMORY_WIDTH)/72)+(1*r)]),
		   .cs_n(ddr3_cs_n_sdram[((i*MEMORY_WIDTH)/72)+(1*r)]),
		   .ras_n(ddr3_ras_n_sdram),
		   .cas_n(ddr3_cas_n_sdram),
		   .we_n(ddr3_we_n_sdram),
		   .dm_tdqs(ddr3_dm_sdram[i]),
		   .ba(ddr3_ba_sdram[r]),
		   .addr(ddr3_addr_sdram[r]),
		   .dq(ddr3_dq_sdram[MEMORY_WIDTH*(i+1)-1:MEMORY_WIDTH*(i)]),
		   .dqs(ddr3_dqs_p_sdram[i]),
		   .dqs_n(ddr3_dqs_n_sdram[i]),
		   .tdqs_n(),
		   .odt(ddr3_odt_sdram[((i*MEMORY_WIDTH)/72)+(1*r)])
	   );
   end
end
endgenerate

endmodule
