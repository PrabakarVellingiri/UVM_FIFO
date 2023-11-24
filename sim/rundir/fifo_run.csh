#! /bin/csh -f
##=============================================================================
##  CONFIDENTIAL and Copyright (C) 2014 Test and Verification Solutions Ltd
##=============================================================================
#  Contents a:
#  tvs_run_script.csh 
#
#  Brief description:
#  This is the tvs_run_script.csh script, which is used to run a single test case 
#  or regression either in the cadence or questa sim. For further details run,
#  ./tvs_run_script.csh -help
#
#  Known exceptions to rules:
#    
##============================================================================
#  Author        : Natarajan.A
#  Created on    : 
#  File Id       : $Id: tvs_run_script.csh
##============================================================================== 

#################################################################################
#setenv UVM_HOME ~/uvm-1.1b
#setenv UVM_HOME /tools/questasim10.1d/verilog_src/uvm-1.1b
setenv UVM_HOME /tools/questa10_6c/questasim/verilog_src/questa_uvm_pkg-1.2/src
#################################################################################

set tcl_opt        = ""
set func_cover     = 0
set tool           = "-cadence" 
set regression     = "" 
set dump_option    = "-dump_questa"
set dump_cadence   = ""
set dump_questa    = ""
set cmd_option     = "-cmdp"
set testcase_name  = ""
set verbosity      = "UVM_HIGH"
set user_define    = "VC_DUMMY"
set top_tb_name    = "top"
set cmdp_opt       = ""
set gui_opt        = ""
set ET             = "Error_Test.inf"
set PT             = "Pass_Test.inf"
set pass_count     = 0
set fail_count     = 0
set testcase_count = 0
set compile=0
set func_opt       = ""
set tmp            = ""
#------------------------------------------------------#
# USER SELECT SWITCH                                   #
#------------------------------------------------------#
  while ($#argv )
    if( "$1" == "-t") then
      shift
      set testcase_name = "$1"
    else if( "$1" == "-cadence") then
      set tool = "$1"
    else if( "$1" == "-compile") then
      set compile = 1
    else if( "$1" == "-reg") then
      set regression = "$1"
    else if( "$1" == "-questa") then
      set tool = "$1"
    else if( "$1" == "-dump_cadence") then
      set dump_option = "$1"
    else if( "$1" == "-dump_questa") then
      set dump_option = "$1"
    else if( "$1" == "-guip") then
      set cmd_option = "$1"
    else if( "$1" == "-func_cov") then
      set func_cover = 1
    else if( "$1" == "-cmdp") then
      set compile = 1 
      set cmd_option = "$1"
    else if( "$1" == "-v") then
      shift
      set verbosity = "$1"
    else if( "$1" == "-define" ) then
      shift
      set user_define = "$1";
      echo $user_define;
    else if("$1" == "-h" || "$1" == "-help") then
      goto SHOW_OPTIONS
    else if( "$1" == "-clean" || "$1" == "-cl") then
      goto CLEANUP_DATABASE
    endif
    shift
  end #(while)
  
#-------------------------------------------------------------------------#
#   tool == Questa                                                        #
#-------------------------------------------------------------------------#
  
  if("$tool" == "-questa") then
    if("$cmd_option" == "-cmdp") then
      set cmdp_opt = "-c"
      set tcl_opt = "run -all"
    endif
    if("$dump_option" == "-dump_questa") then
      set dump_questa="add wave -r /*;"
    endif
    if("$cmd_option" == "-guip") then
      set tcl_opt = ""
    endif
    if("$func_cover" == 1) then
      if !(-e ./coverage/testcase_ucdb/reports) then
        mkdir -p ./coverage/testcase_ucdb/reports
        mkdir -p ./coverage/testcase_ucdb/report_html
      endif
      if ! (-e ./coverage/merged_ucdb/reports) then
        mkdir -p ./coverage/merged_ucdb/reports
        mkdir -p ./coverage/merged_ucdb/report_html
      endif
      if("$cmd_option" == "-cmdp") then
        set func_opt = "-c"
      set tcl_opt = "run -all"
      else if("$cmd_option" == "-guip") then
        set func_opt = ""
      endif
      set cmdp_opt = "$func_opt -coverage -voptargs="+cover=bcfst" -cvg63"
      set tcl_opt = "do coverage.do;coverage save -codeAll -cvg -onexit $testcase_name.ucdb;set SolveArrayResizeMax 0; run -all; exit;"
    endif
  endif #("$tool" == "-questa")

#-------------------------------------------------------------------------#
#   tool == Cadence                                                       #
#-------------------------------------------------------------------------#

  if("$tool" == "-cadence") then
    if("$cmd_option" == "-guip") then
      set gui_opt = "-access rwc -gui"
    endif
    if( -e ./INCA_libs) then
      rm -rf ./INCA_libs
    endif
    if ("$dump_option" == "-dump_cadence") then
      set dump_cadence="+define+CADENCE_DUMP +access+rw"
    endif
  endif #( "#tool" == "-cadence")
  
#-------------------------------------------------------------------------#
#   Go To Regression                                                      #
#-------------------------------------------------------------------------#
  
  if("$regression" == "-reg") then
    goto REG
  endif
  
###########################################################################################################################
####################################### SINGLE TEST CASE SCRIPT STARTED ###################################################
###########################################################################################################################

 
  echo " "
  echo "==================================================================================================================="
  echo "                                            TESTCASE:  $testcase_name.svh " 
  echo "==================================================================================================================="
  echo ""
  if ("$tool" == "-questa" ) then
    if !( -e ./logs/$testcase_name) then
      mkdir -p ./logs/$testcase_name
    endif
    if("$cmd_option" == "-guip") then
      vlib work
      vlog -sv -novopt \
      +define+$user_define+define+QUESTA +incdir+$UVM_HOME/src $UVM_HOME/src/uvm_pkg.sv #$UVM_HOME/src/dpi/uvm_dpi.cc \
      -f ../compile/compile_list.fl | tee $testcase_name.log
      vsim -novopt -gui $top_tb_name \
      +UVM_TESTNAME=$testcase_name \
      +UVM_VERBOSITY=$verbosity  \
      -do "add wave *;set SolveArrayResizeMax 0;log -r *;" \
      -sv_seed \
      -l ./logs/$testcase_name/$testcase_name.log     
    endif   
    if("$func_cover" == 1) then
      vlib work
      vlog -sv -novopt +define+QUESTA_SIM +define+$user_define  +define+QUESTA \
      +incdir+$UVM_HOME $UVM_HOME/questa_uvm_pkg.sv \
      -f ../compile/compile_list.fl | tee -a $testcase_name.log 
      vsim -c $top_tb_name \
      +UVM_TESTNAME=$testcase_name \
      +UVM_VERBOSITY=$verbosity  \
      -novopt -coverage \
      -voptargs="+cover=bcfst" -cvg63 \
      -do "$dump_questa ;coverage save -codeAll -cvg -onexit $testcase_name.ucdb;set SolveArrayResizeMax 0; run -all; exit" \
      -sv_seed random \
      | tee -a ./logs/$testcase_name.log 
      
      mv $testcase_name.ucdb ./coverage/testcase_ucdb
      vcover report -details ./coverage/testcase_ucdb/$testcase_name.ucdb > ./coverage/testcase_ucdb/reports/$testcase_name.rpt_det
      vcover report -cvg -details ./coverage/testcase_ucdb/$testcase_name.ucdb > ./coverage/testcase_ucdb/reports/$testcase_name.fun_det
      vcover report -html -htmldir ./coverage/testcase_ucdb/report_html ./coverage/testcase_ucdb/$testcase_name.ucdb
    else
    if("$cmd_option" == "-cmdp") then
      vlib work
      vlog -sv -novopt +define+define+$user_define +define+QUESTA \
      +incdir+$UVM_HOME $UVM_HOME/questa_uvm_pkg.sv \
      -f ../compile/compile_list.fl | tee ./logs/$testcase_name.log
      vsim -novopt -c  $top_tb_name \
          +UVM_TESTNAME=$testcase_name \
          +UVM_VERBOSITY=$verbosity  \
          -do "$dump_questa ;set SolveArrayResizeMax 0;run -a; quit -f" -sv_seed random | tee -a ./logs/$testcase_name.log 
    endif 
    endif # if ("$tool" == "-questa" )ends here
  
  ### ("tool" == "-cadence") starts here
  else if("$tool" == "-cadence" ) then
    if !( -e ./logs/$testcase_name) then
      mkdir -p ./logs/$testcase_name
    endif
    if("$func_cover" == 1) then
        irun -uvm -sv -seed random \
        -f ../compile/compile_list.fl \
        +UVM_TESTNAME=$testcase_name \
        +UVM_VERBOSITY=$verbosity  \
        +define+CADENCE +define+$user_define \
        +nccoverage+u  \
        +tcl+run.tcl \
        $dump_cadence | tee -a ./logs/$testcase_name.log  
       imc -exec cover_reg_report_gen
    else
      if("$cmd_option" == "-cmdp") then
        irun -uvm -TIMESCALE 1ns/1ns -sv -seed random \
        -f ../compile/compile_list.fl \
        +UVM_TESTNAME=$testcase_name \
        +UVM_VERBOSITY=$verbosity  \
        +define+CADENCE +define+$user_define  \
#        +tcl+run.tcl \
        $dump_cadence | tee -a ./logs/$testcase_name.log  
      endif
      if("$cmd_option" == "-guip") then
        irun -uvm -access +r+w+c -64bit -TIMESCALE 1ns/1ns -v93 -messages  \
        -f ../compile/compile_list.fl \
        +UVM_TESTNAME=$testcase_name \
        +UVM_VERBOSITY=$verbosity  \
        +define+CADENCE +define+$user_define \
        -gui -l ./logs/$testcase_name.log
      endif
    endif
  endif
  
################################################################################################################
###################################### Individual log folder for each testcase #################################
################################################################################################################
  
  mv ./logs/$testcase_name.log ./logs/$testcase_name/$testcase_name.log
#  rm ./*.log
  
################################################################################################################
###################################### Individual dump for each testcase #######################################
################################################################################################################
  
  if("$dump_option" == "-dump_cadence" ) then
    if ("$func_cover" == 1 | "$cmd_option" == "-cmdp") then
      mv tvs_i3c_dump.trn  ./logs/$testcase_name/$testcase_name.trn
      mv tvs_i3c_dump.dsn  ./logs/$testcase_name/$testcase_name.dsn
      rm -rf ./logs/$testcase_name.log
    endif
  endif
  if ("$dump_option" == "-dump_questa") then
   if ("$cmd_option" == "-func_cov" | "$cmd_option" == "-cmdp") then
    mv *.wlf ./logs/$testcase_name/$testcase_name.wlf
   endif
  endif

####################################################################################
####################  ERROR FILTERATION FOR PASS/FAIL LOG  #########################
####################################################################################
 
  echo " "
  echo "============================================================================================================"
  echo "                                         TESTCASE ENDS: $testcase_name.svh  " 
  echo "============================================================================================================"
  
  if (`grep -c "\<Fatal\>" ./logs/$testcase_name/$testcase_name.log`) then
    set result_status  = "TEST FAILED DURING COMPILATION/SIMULATION Fatal"
    set result = "TEST_FAILED"
    
  else if (`grep -c "UVM_WARNING @" ./logs/$testcase_name/$testcase_name.log`) then  
    set result_status  = "TEST FAILED DUE TO UVM_WARNING DURING SIMULATION "
    set result = "TEST_FAILED"
    
  else if (`grep -c "UVM_ERROR *.* @" ./logs/$testcase_name/$testcase_name.log`) then  
    set result_status  = "TEST FAILED DUE TO UVM_ERROR DURING SIMULATION "
    set result = "TEST_FAILED"
    
  else if (`grep -c "\<Error\>" ./logs/$testcase_name/$testcase_name.log`) then
    set result_status  = "TEST FAILED DUE TO COMPILATION/SIMULATION ERROR"
    set result = "TEST_FAILED"
    
  else if (`grep -c "UVM_FATAL @" ./logs/$testcase_name/$testcase_name.log`) then  
    set result_status  = " TEST FAILED DUE TO UVM_FATAL "
    set result = "TEST_FAILED"
    
  else if (`grep -c "ncvlog: \*E" ./logs/$testcase_name/$testcase_name.log`) then
    set result_status  = "TEST FAILED DUE TO COMPILATION ERRORS"
    set result = "TEST_FAILED" 
    
  else if (`grep -c "ncsim: \*E" ./logs/$testcase_name/$testcase_name.log`) then
    set result_status  = "TEST FAILED DUE TO ERRORS AT SIMULATION"
    set result = "TEST_FAILED" 
    
  else if (`grep -c "ncelab: \*E" ./logs/$testcase_name/$testcase_name.log`) then
    set result_status  = "TEST FAILED DUE TO ELABORATION ERRORS"
    set result = "TEST_FAILED"
    
  else
    set result_status  = " "
    set result = "TEST_PASSED"

  endif
  endif
 
 
echo "================================================TEST_CASE_STATUS============================================ " | tee -a ./logs/$testcase_name/$testcase_name.log
    echo " " | tee -a ./logs/$testcase_name/$testcase_name.log
    echo "                            FIFO_UVM  TEST-NAME:          $testcase_name " | tee -a ./logs/$testcase_name/$testcase_name.log
  if ($result == "TEST_FAILED") then
    echo "                            FIFO_UVM  RESULT_STATUS:      $result_status " | tee -a ./logs/$testcase_name/$testcase_name.log
    echo "                            FIFO_UVM  RESULT:             $result        " | tee -a ./logs/$testcase_name/$testcase_name.log
  else
    echo "                            FIFO_UVM  RESULT:             $result        " | tee -a ./logs/$testcase_name/$testcase_name.log
  endif
    echo " " | tee -a ./logs/$testcase_name/$testcase_name.log
echo "============================================================================================================ " | tee -a ./logs/$testcase_name/$testcase_name.log

  exit(0)
  
  COVERAGE:
  exit(0);

###################################################################################################################
####################################### SINGLE TEST CASE SCRIPT ENDS ##############################################
###################################################################################################################
  
  
REG:
###################################################################################################
###<---------------------------------REGRESSION SCRIPT----------------------------------------->###
###################################################################################################
  
  set FILENAME = ./FIFO_TEST_LIST

  if(-f $ET ) then
   rm -rf $ET 
  endif
  
  if(-f $PT ) then
   rm -rf $PT 
  endif
#  if ("$tool" == "-questa") then
#    vlib work
#    vlog -sv -novopt +define+QUESTA_SIM +define+define+$user_define+define+QUESTA \
#      +incdir+$UVM_HOME/src $UVM_HOME/src/uvm_pkg.sv $UVM_HOME/src/dpi/uvm_dpi.cc \
#      -f ../compile/compile_list.fl | tee -a ./logs/$testcase_name.log 
#
##    vlog +define+ -incr -sv -novopt +cover=f +define+FCOVER1 +define+$user_define  \
##    +incdir+$UVM_HOME/src $UVM_HOME/src/uvm_pkg.sv \
##    -f ../compile/compile_list.fl | tee -a ./logs/$testcase_name.log
#   endif
   
   if("$func_cover" == 1 && "$tool" == "-questa") then
     set cmdp_opt = -c
     set tcl_opt = "do coverage.do;coverage save -codeAll -cvg -onexit $testcase_name.ucdb; set SolveArrayResizeMax 0;run -all; exit;"
   endif
  
  ########################## Input File Taken From Here Through Foreach Loop #########################
  
  foreach tmp ( "`cat $FILENAME`" ) 
    set testcase_name = `echo "$tmp" | awk '{print $1}'`
    set user_define = `echo "$tmp" | awk '{print $3}'`
    
    if("$user_define" == "") then
      echo "print no defines"
    else
      set user_define = "+define+$user_define" 
    endif 
    
    echo " "
    echo "====================================== "
    echo "TESTCASE:"  $testcase_name 
    echo "====================================== "
    
    set testcase_count = `expr $testcase_count + 1`
    
    if( -e ./INCA_libs) then
      rm -rf ./INCA_libs
    endif
    
    if ! (-e ./logs/$testcase_name) then
      mkdir -p ./logs/$testcase_name
    endif
    
################################    SIMULATION STARTS HERE #########################################
    if("$tool" == "-questa") then
    vlib work
    vlog -sv -novopt +define+QUESTA_SIM $user_define +define+QUESTA \
      +incdir+$UVM_HOME $UVM_HOME/questa_uvm_pkg.sv \
      -f ../compile/compile_list.fl | tee -a ./logs/$testcase_name/$testcase_name.log 

       vsim -c $top_tb_name \
      +UVM_TESTNAME=$testcase_name \
      +UVM_VERBOSITY=$verbosity  \
      -novopt -coverage \
      -voptargs="+cover=bcfst" -cvg63 \
      -do "$dump_questa; coverage save -codeAll -cvg -onexit $testcase_name.ucdb;set SolveArrayResizeMax 0; run -all; exit" \
      | tee -a ./logs/$testcase_name/$testcase_name.log

      mv $testcase_name.ucdb ./coverage/testcase_ucdb/$testcase_name$user_define.ucdb

    endif
    if("$tool" == "-cadence") then
    irun -uvm -TIMESCALE 1ns/1ps -v93 -messages -sv -seed random $user_define -linedebug \
    -f ../compile/compile_list.fl \
        +UVM_TESTNAME=$testcase_name \
        +UVM_VERBOSITY=$verbosity  \
        +nccoverage+u $user_define \
        +tcl+run.tcl \
        $dump_cadence | tee -a ./logs/$testcase_name.log  
    endif
    
    if ("$tool" == "-questa" ) then
      if("$func_cover" == 1) then
        vcover merge ./coverage/merged_ucdb/merged_ucdb.ucdb  ./coverage/testcase_ucdb/*.ucdb
        vcover report -details ./coverage/merged_ucdb/merged_ucdb.ucdb > ./coverage/merged_ucdb/reports/merged_ucdb.rpt
        vcover report -html -htmldir ./coverage/merged_ucdb/report_html -verbose -threshL 50 -threshH 90 ./coverage/merged_ucdb/merged_ucdb.ucdb
      endif
    endif
    ####################################################################################
    ############################   SIMULATION ENDS HERE ################################
    ####################################################################################
    ##################  INDIVIDUAL LOG FOLDER FOR EACH TESTCASE  #######################
    ####################################################################################
    mv ./logs/$testcase_name.log ./logs/$testcase_name/$testcase_name.log
    
    if("$dump_option" == "-dump_cadence" ) then
      mv tvs_i3c_dump.trn  ./logs/$testcase_name/$testcase_name.trn
      mv tvs_i3c_dump.dsn  ./logs/$testcase_name/$testcase_name.dsn
    endif
    if ("$dump_option" == "-dump_questa") then
      if ("$cmd_option" == "-func_cov" | "$cmd_option" == "-cmdp") then
        mv *.wlf   ./logs/$testcase_name/$testcase_name.wlf
      endif
    endif

    ####################################################################################
    ####################  ERROR FILTERATION FOR PASS/FAIL LOG  #########################
    ####################################################################################
    
    if (`grep -c "\<Fatal\>" ./logs/$testcase_name/$testcase_name.log`) then
      set result_status  = "Fatal:TEST FAILED DURING COMPILATION/SIMULATION"
      set result = "TEST_FAILED"
      if(-f $ET ) then
        echo $testcase_name >>$ET 
      else
        echo $testcase_name >$ET
      endif
    else if (`grep -c "\<FATAL\>" ./logs/$testcase_name/$testcase_name.log`) then
      set result_status  = "FATAL:TEST FAILED DURING COMPILATION/SIMULATION"
      set result = "TEST_FAILED"
      if(-f $ET ) then
        echo $testcase_name >>$ET 
      else
        echo $testcase_name >$ET
      endif   
    else if (`grep -c "UVM_FATAL \@" ./logs/$testcase_name/$testcase_name.log`) then
      set result_status  = "UVM_FATAL:TEST FAILED DURING COMPILATION/SIMULATION"
      set result = "TEST_FAILED"
      if(-f $ET ) then
        echo $testcase_name >>$ET 
      else
        echo $testcase_name >$ET
      endif    
    else if (`grep -c "\<ERROR\>" ./logs/$testcase_name/$testcase_name.log`) then
      set result_status  = "ERROR:TEST FAILED DURING COMPILATION/SIMULATION"
      set result = "TEST_FAILED"
      if(-f $ET ) then
        echo $testcase_name >>$ET 
      else
        echo $testcase_name >$ET
      endif   
    else if (`grep -c "UVM_ERROR \@" ./logs/$testcase_name/$testcase_name.log`) then
      set result_status  = "UVM_ERROR:TEST FAILED DURING COMPILATION/SIMULATION"
      set result = "TEST_FAILED"
      if(-f $ET ) then
        echo $testcase_name >>$ET 
      else
        echo $testcase_name >$ET
      endif    
    else if (`grep -c "\<Error\>" ./logs/$testcase_name/$testcase_name.log`) then
      set result_status  = "Error:TEST FAILED DURING COMPILATION/SIMULATION"
      set result = "TEST_FAILED"
      if(-f $ET ) then
        echo $testcase_name >>$ET 
      else
        echo $testcase_name >$ET
      endif   
    else if (`grep -c "\<warning\>" ./logs/$testcase_name/$testcase_name.log`) then
      set result_status  = "TEST FAILED DUE TO WARNING"
      set result = "TEST_FAILED"
      if(-f $ET ) then
        echo $testcase_name >>$ET 
      else
        echo $testcase_name >$ET
      endif
    else if (`grep -c "\<MISMATCH\>" ./logs/$testcase_name/$testcase_name.log`) then
      set result_status  = "TEST FOUND WITH MISMATCH"
      set result = "TEST_FAILED"
      if(-f $ET ) then
        echo $testcase_name >>$ET 
      else
        echo $testcase_name >$ET
      endif
    else if (`grep -c "ncvlog: \*E" ./logs/$testcase_name/$testcase_name.log`) then
      set result_status  = "TEST FAILED DUE TO COMPILATION ERRORS"
      set result = "TEST_FAILED" 
      if(-f $ET ) then
        echo $testcase_name >>$ET 
      else
        echo $testcase_name >$ET
      endif
    else if (`grep -c "ncsim: \*E" ./logs/$testcase_name/$testcase_name.log`) then
      set result_status  = "TEST FAILED DUE TO ERRORS AT SIMULATION"
      set result = "TEST_FAILED" 
      if(-f $ET ) then
        echo $testcase_name >>$ET 
      else
        echo $testcase_name >$ET
      endif
    else if (`grep -c "ncelab: \*E" ./logs/$testcase_name/$testcase_name.log`) then
      set result_status  = "TEST FAILED DUE TO ELABORATION ERRORS"
      set result = "TEST_FAILED"
      if(-f $ET ) then
        echo $testcase_name >>$ET 
      else
        echo $testcase_name >$ET
      endif
    else
      set result_status  = " "
      set result = "TEST_PASSED"
      if(-f $PT ) then
        echo $testcase_name >>$PT 
      else
        echo $testcase_name >$PT
      endif
    endif    
    
    echo " " | tee -a ./logs/$testcase_name/$testcase_name.log 
    echo " =============================================== " | tee -a ./logs/$testcase_name/$testcase_name.log 
    echo " ----------------- TEST_RESULT------------------ " | tee -a ./logs/$testcase_name/$testcase_name.log 
    echo " =============================================== " | tee -a ./logs/$testcase_name/$testcase_name.log 
    echo " TEST-NAME: $testcase_name " | tee -a ./logs/$testcase_name/$testcase_name.log
    
    if ($result == "TEST_FAILED") then
      echo " RESULT_STATUS: $result_status " | tee -a ./logs/$testcase_name/$testcase_name.log
      echo " RESULT: $result " | tee -a ./logs/$testcase_name/$testcase_name.log
    else
      echo " RESULT: $result " | tee -a ./logs/$testcase_name/$testcase_name.log
    endif
    echo " =============================================== " | tee -a ./logs/$testcase_name/$testcase_name.log
    
    if($result == "TEST_PASSED") then
      set pass_count = `expr $pass_count + 1`
    else if($result == "TEST_FAILED") then
      set fail_count = `expr $fail_count + 1`
    endif
    
    echo " "
    echo "=========================================================================="
    echo "                     TESTCASE ENDS: $testcase_name.sv                     " 
    echo "=========================================================================="
  end #(Foreach loop Ends Here)
  
  ####################################################################################
  ####################  FUNCTIONAL COVERAGE ENABLE FOR REGRESSION ####################
  ####################################################################################
  
  if("$tool" == "-cadence") then
    if("$func_cover" == 1 ) then
      imc -exec cover_reg_report_gen
    endif
  endif
   
  goto REG_INFO 
exit(0);

REG_INFO:
  echo " " | tee -a ./regression_statistics.info
  echo " =============================================== " | tee -a ./regression_statistics.info
  echo " 	      REGRESSION STATISTICS  		 " | tee -a ./regression_statistics.info
  echo " =============================================== " | tee -a ./regression_statistics.info
  echo " TESTCASES RUN    :" $testcase_count | tee -a ./regression_statistics.info
  echo " TESTCASES PASSED :" $pass_count     | tee -a ./regression_statistics.info
  echo " TESTCASES FAILED :" $fail_count     | tee -a ./regression_statistics.info
  echo " =============================================== " | tee -a ./regression_statistics.info
  
  echo " =============================================== " | tee -a ./regression_statistics.info
  echo " 		    PASS TEST 			 " | tee -a ./regression_statistics.info
  echo " =============================================== " | tee -a ./regression_statistics.info
  if (-f $PT) then
    cat $PT 	     | tee -a ./regression_statistics.info	
    else 
    echo " No Test Passed in Regression" | tee -a ./regression_statistics.info
  endif
  echo " =============================================== " | tee -a ./regression_statistics.info

  echo " =============================================== " | tee -a ./regression_statistics.info
  echo " 		    FAIL TEST 			 " | tee -a ./regression_statistics.info
  echo " =============================================== " | tee -a ./regression_statistics.info
  if (-f $ET) then
    cat $ET 	     | tee -a ./regression_statistics.info	
  else
    echo " No Test Failed in Regression" | tee -a ./regression_statistics.info
  endif
  echo " =============================================== " | tee -a ./regression_statistics.info
exit(0);

SHOW_OPTIONS:

echo ""
  echo "Usage: tvs_run_script.csh [-t <testcase>  : User has to specify the respective test case ]"
  echo "                          [-cadence       : Enables Running in Cadence Simulator]" 
  echo "                          [-questa        : Enables Running in Questa  Simulator]"
  echo "                          [-dump_cadence  : Enables Dumping for waveform viewing in Cadence Simulator]" 
  echo "                          [-dump_questa   : Enables Dumping for waveform viewing in Questa  Simulator]"
  echo "                          [-func_cov      : Enables Simulation in command Mode Prompt with Functional Coverage]"
  echo "                          [-cmdp          : Enables Simulation in Command Mode Prompt]"
  echo "                          [-guip          : Enables Simulation in GUI Mode Prompt]"
  echo "                          [-cl[ean]       : Cleans  the Directory database location]"
  echo "                          [-v <verbosity> : Enables the Reporting Mechanism]"
  echo "                               | UVM_NONE : Prints only the UVM_WARNING Informations - For Error Checking"
  echo "                               | UVM_LOW  : Prints only the UVM_WARNING and UVM_INFO Informations - For Error Checking"
  echo "                               | UVM_HIGH : Prints the UVM_INFO, UVM_WARNING, UVM_ERROR, UVM_FATAL Informations - For Debugging"
  echo ""
  echo "        tvs_run_script.csh -h[elp] For Printing this Message"
  echo ""
exit(0)

CLEANUP_DATABASE:

echo ""
echo "Cleaning up the Database.......";
rm -rf  ./work ./transcript ./coverage ./cov_work ./INCA_libs ./merge_report
rm -rf  ./logs
find . -name "*.diag"         -exec rm -rf {} \; 
find . -name "*.log"          -exec rm -rf {} \; 
find . -name "*.wlf"          -exec rm -rf {} \; 
find . -name "*.dbg"          -exec rm -rf {} \; 
find . -name "*.dsn"          -exec rm -rf {} \; 
find . -name "*.trn"          -exec rm -rf {} \; 
find . -name "*.key"          -exec rm -rf {} \; 
find . -name "*.inf*"         -exec rm -rf {} \; 
find . -name "*.swo"          -exec rm -rf {} \; 
find . -name "*.swp"          -exec rm -rf {} \; 
find . -name "*.cfg"          -exec rm -rf {} \; 
find . -name "*.so"           -exec rm -rf {} \; 
find . -name "*.awc"          -exec rm -rf {} \; 
find . -name "*.asdb"         -exec rm -rf {} \; 
find . -type f -name "*.vstf" -exec rm {} \; 

exit(0)


