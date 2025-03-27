Attention:
	1. if you reconfig the ip parameters,which reload the ddr_memory_interface.ipc and re-generator. 
	   please attention bits width of the top.v and tb.v file. for example, in the tb.v:
	   	ddr_dq, ddr_dqs, ddr_addr......

	   int the top.v file:
		ddr_addr, ddr_ba,ddr_dqm,ddr_dq,ddr_dqs,ddr_dqs_n,app_wdf_mask,
		app_wdf_data,app_raw_not_ecc,app_addr,app_rd_data,app_ecc_multiple_err,mc_ras_n,
		mc_cas_n,mc_we_n,mc_address,mc_bank,mc_cs_n,mc_cke,mc_wrdata,mc_wrdata_mask,phy_rd_data

	2. for simulation, please in the../../project/src/top.v file,open below:
	   `define SIM
	   for board test, please in the../../project/src/top.v file,close below:
	   `define SIM
 	3. if appear below Error:
            # ** Error (suppressible): (vsim-12023) ../../tb/tb.v(91): Cannot execute undefined system task/function '$fsdbDumpfile'
	    # ** Error (suppressible): (vsim-12023) ../../tb/tb.v(92): Cannot execute undefined system task/function '$fsdbDumpvars'

        please ignore this error,because $fsdbDumpfile,$fsdbDumpvars function used in the vcs simulation

1.Run Command
    method 1: do cmd.do , in the Transcript windows of the Modesim Tool
    method 2: vsim -do cmd.do , in the Terminal of the Linux 

2.Files Introduction

    prim_sim.v                  :
                                simulation library
    cmd.do                      :
                                modesim  do(command) file
    compile.f                   :
                                modesim compile design file

