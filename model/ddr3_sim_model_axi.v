`timescale 1ps/100fs

// DDR3 simulation wrapper logic based on example designed generated for KC705
// Parameters are pre-defined for KC705, and if you don't know functions of
// parameters, then do not touch, otherwise simulation accuracy is not
// guaranteed.
module ddr3_sim_model (
	input[13:0]	ddr3_sdram_addr,
  	input[2:0]	ddr3_sdram_ba,
  	input 		ddr3_sdram_cas_n,
  	input[0:0]	ddr3_sdram_ck_n,
  	input[0:0]	ddr3_sdram_ck_p,
  	input[0:0]	ddr3_sdram_cke,
  	input[0:0]	ddr3_sdram_cs_n,
  	input[7:0]	ddr3_sdram_dm,
  	inout[63:0]	ddr3_sdram_dq,
  	inout[7:0]	ddr3_sdram_dqs_n,
  	inout[7:0]	ddr3_sdram_dqs_p,
  	input[0:0]	ddr3_sdram_odt,
  	input 		ddr3_sdram_ras_n,
  	input 		ddr3_sdram_reset_n,
  	input 		ddr3_sdram_we_n
);

//**************************************************************************//
// Memory Models instantiations
//**************************************************************************//
genvar i;
generate
for (i = 0; i < 8; i = i + 1) begin: gen_mem
	ddr3_model u_comp_ddr3 (
	   .rst_n(ddr3_sdram_reset_n),
	   .ck(ddr3_sdram_ck_p[(i*8)/72]),
	   .ck_n(ddr3_sdram_ck_n[(i*8)/72]),
	   .cke(ddr3_sdram_cke[((i*8)/72)]),
	   .cs_n(ddr3_sdram_cs_n[((i*8)/72)]),
	   .ras_n(ddr3_sdram_ras_n),
	   .cas_n(ddr3_sdram_cas_n),
	   .we_n(ddr3_sdram_we_n),
	   .dm_tdqs(ddr3_sdram_dm),
	   .ba(ddr3_sdram_ba),
	   .addr(ddr3_sdram_addr),
	   .dq(ddr3_sdram_dq[8*(i+1)-1:8*(i)]),
	   .dqs(ddr3_sdram_dqs_p[i]),
	   .dqs_n(ddr3_sdram_dqs_n[i]),
	   .tdqs_n(),
	   .odt(ddr3_sdram_odt[((i*8)/72)])
   );
end
endgenerate

endmodule
