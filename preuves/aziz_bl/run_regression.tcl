set script_dir [file dirname [file normalize [info script]]]
set repo [file normalize [file join $script_dir .. ..]]
set project_dir [file join $repo vivado_aziz_batch]
create_project -force Aziz_BL_Batch $project_dir -part xc7z007sclg225-1
set_property target_language VHDL [current_project]
add_files -norecurse [glob -directory [file join $repo phase4 src] *.vhd]
add_files -fileset sim_1 -norecurse [glob -directory [file join $repo phase4 sim] *]
set_property file_type {VHDL 2008} [get_files *.vhd]
set_property top mp1_system [get_filesets sources_1]
set_property xsim.simulate.runtime 110ns [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
puts "CASE tb_bl BEGIN"
set_property top tb_bl [get_filesets sim_1]
launch_simulation
close_sim
puts "CASE tb_bl END"
set_property xsim.simulate.runtime 230ns [get_filesets sim_1]
set_property top tb_bl_catalog [get_filesets sim_1]
foreach id {B1 B2 B3 B4 B5 B6 B7 B8} {
  set_property generic "PROGRAM_FILE=$id.hex EXPECTED_FILE=$id.trace TEST_ID=$id" [get_filesets sim_1]
  puts "CASE $id BEGIN"
  launch_simulation
  close_sim
  puts "CASE $id END"
}
set_property top tb_mp1 [get_filesets sim_1]
set_property generic {PROGRAM_FILE=Instructions.txt EXPECTED_FILE=ExpectedData.txt} [get_filesets sim_1]
puts "CASE tb_mp1 BEGIN"
launch_simulation
close_sim
puts "CASE tb_mp1 END"
close_project
exit
