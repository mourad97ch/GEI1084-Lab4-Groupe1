set base [file dirname [file normalize [info script]]]
create_project MP1_Developpement [file join $base vivado] -part xc7z007sclg225-1
set_property target_language VHDL [current_project]
add_files -norecurse [glob -directory [file join $base src] *.vhd]
add_files -fileset sim_1 -norecurse [glob -directory [file join $base sim] *]
set_property file_type {VHDL 2008} [get_files *.vhd]
set_property top mp1_system [get_filesets sources_1]
set_property top tb_mp1 [get_filesets sim_1]
set_property xsim.simulate.runtime 310ns [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
launch_simulation
close_sim
close_project
exit
