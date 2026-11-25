set repo [file normalize [file join [file dirname [info script]] .. ..]]
set work [file normalize [file join $repo .. reproduction_haroun_shift]]
file mkdir $work

set phase [file join $repo phase4]
set proof [file join $work resultats]
file mkdir $proof
file mkdir [file join $proof logs]
cd $work
puts "HAROUN_SHIFT_COMMIT=[exec git -C $repo rev-parse HEAD]"
puts "HAROUN_SHIFT_VIVADO=[version -short]"
create_project Haroun_Shift [file join $work vivado] -part xc7z007sclg225-1
set_property target_language VHDL [current_project]
add_files -norecurse [glob -directory [file join $phase src] *.vhd]
add_files -fileset sim_1 -norecurse [glob -directory [file join $phase sim] *]
set_property file_type {VHDL 2008} [get_files *.vhd]
set_property top mp1_system [get_filesets sources_1]
set_property xsim.simulate.runtime 0ns [get_filesets sim_1]
set rundir [file join $work vivado Haroun_Shift.sim sim_1 behav xsim]
file mkdir $rundir
foreach f [glob -directory [file join $phase sim] *.hex *.trace *.txt] {file copy $f [file join $rundir [file tail $f]]}
set csv [open [file join $proof resultats.csv] w]
puts $csv {Test,Cycles,Error_count,Done,Status}
foreach id {S1 S2 S3 S4 S5 S6 S7 S8 S9 S10 REG} {
 if {$id eq "REG"} {set top tb_mp1; set gen {};set runtime 230ns;set expected 20} else {
 set top tb_shift_catalog
 set gen "PROGRAM_FILE=$id.hex EXPECTED_FILE=$id.trace TEST_ID=$id"
 set runtime 300ns
 set f [open [file join $phase sim $id.trace] r];set expected [llength [split [string trim [read $f]] \n]];close $f
 }
 set_property top $top [get_filesets sim_1]
 set_property generic $gen [get_filesets sim_1]
 update_compile_order -fileset sources_1
 update_compile_order -fileset sim_1
 launch_simulation -mode behavioral
 log_wave -r /
 open_vcd [file join $proof $id.vcd]
 log_vcd /$top/*
 run $runtime
 close_vcd
 set n [get_value /$top/Test_number]
 set err [get_value /$top/Error_count]
 set done [get_value /$top/Done]
 set pass [expr {$n == $expected && $err == 0 && [string equal -nocase $done true]}]
 set status [expr {$pass ? "PASS" : "FAIL"}]
 puts "HAROUN_SHIFT_RESULT $id cycles=$n errors=$err Done=$done expected_cycles=$expected STATUS=$status"
 puts $csv "$id,$n,$err,$done,$status"
 flush $csv
 create_wave_config Haroun_$id
 foreach sig {Test_number Error_count Done CLK Reset PC Instr ALUResult WriteData RegState ALUFlags Flags CondEx RegWrite FlagWrite MemWrite PCSrc} {add_wave /$top/$sig}
 save_wave_config [file join $work $id.wcfg]
 close_sim
 file copy [file join $rundir simulate.log] [file join $proof logs $id.log]
}
close $csv
close_project
puts HAROUN_SHIFT_EXECUTION_COMPLETE
