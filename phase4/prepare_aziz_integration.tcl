# Reproduce the Aziz integration verification in Vivado/XSim 2022.2.
# From repository root: vivado -mode batch -source phase4/prepare_aziz_integration.tcl
set base [file dirname [file normalize [info script]]]
set out [file normalize [file join $base .. preuves aziz_integration]]
file mkdir [file join $out logs]

create_project Aziz_Integration [file join $::env(TEMP) Aziz_Integration] -part xc7z007sclg225-1 -force
set_property target_language VHDL [current_project]
add_files -norecurse [glob -directory [file join $base src] *.vhd]
add_files -fileset sim_1 -norecurse [glob -directory [file join $base sim] *]
set_property file_type {VHDL 2008} [get_files *.vhd]
update_compile_order -fileset sources_1

set simlog [file join $::env(TEMP) Aziz_Integration Aziz_Integration.sim sim_1 behav xsim simulate.log]
proc run_one {top generics runtime simlog dest} {
    set_property top $top [get_filesets sim_1]
    set_property generic $generics [get_filesets sim_1]
    set_property xsim.simulate.runtime $runtime [get_filesets sim_1]
    update_compile_order -fileset sim_1
    launch_simulation
    close_sim
    file copy -force $simlog $dest
    set f [open $dest r]; set txt [read $f]; close $f
    return $txt
}

set csv [open [file join $out results.csv] w]
puts $csv "ID,Status,Observed,Journal"

# CMP corrected catalog C1-C7 supplied for this integration.
foreach id {C1 C2 C3 C4 C5 C6 C7} {
    set txt [run_one tb_cmp_catalog "PROGRAM_FILE=CMP_$id.hex EXPECTED_FILE=CMP_$id.trace TEST_ID=$id" 400ns $simlog [file join $out logs $id.log]]
    set status FAIL; set observed "no summary"
    if {[regexp "$id cycles=(\\d+) errors=(\\d+)" $txt -> n err]} {
        set observed "$n cycles; $err errors"
        if {$err == 0} {set status PASS}
    }
    puts $csv "$id,$status,$observed,logs/$id.log"
}

# Shifter catalog S1-S10, plus S11 for ARM's LSR imm5=0 boundary rule.
foreach id {S1 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11} {
    set txt [run_one tb_shift_catalog "PROGRAM_FILE=$id.hex EXPECTED_FILE=$id.trace TEST_ID=$id" 300ns $simlog [file join $out logs $id.log]]
    set status FAIL; set observed "no summary"
    if {[regexp "$id cycles=(\\d+) errors=(\\d+)" $txt -> n err]} {
        set observed "$n cycles; $err errors"
        if {$err == 0} {set status PASS}
    }
    puts $csv "$id,$status,$observed,logs/$id.log"
}

# BL catalog B1-B8.
foreach id {B1 B2 B3 B4 B5 B6 B7 B8} {
    set txt [run_one tb_bl_catalog "PROGRAM_FILE=$id.hex EXPECTED_FILE=$id.trace TEST_ID=$id" 300ns $simlog [file join $out logs $id.log]]
    set status FAIL; set observed "no summary"
    if {[regexp "$id cycles=(\\d+) errors=(\\d+)" $txt -> n err]} {
        set observed "$n cycles; $err errors"
        if {$err == 0} {set status PASS}
    }
    puts $csv "$id,$status,$observed,logs/$id.log"
}

# R1-R6 are rows inside the complete original Lab4 architectural regression.
# R7 reuses B1's ordinary-B vector and separately labels its result.
set txt [run_one tb_cmp_catalog "PROGRAM_FILE=CMP_LAB4.hex EXPECTED_FILE=CMP_LAB4.trace TEST_ID=LAB4" 250ns $simlog [file join $out logs LAB4_catalog.log]]
set status FAIL; set observed "no summary"
if {[regexp {LAB4 cycles=(\d+) errors=(\d+)} $txt -> n err]} {
    set observed "$n cycles; $err errors"
    if {$n == 20 && $err == 0} {set status PASS}
}
puts $csv "LAB4_ORIGINAL_20,$status,$observed,logs/LAB4_catalog.log"
set rids {R1 R2 R3 R4 R5 R6}
set rdesc {"arithmetic register row 7" "logical register row 6" "immediate row 2" "LDR row 15" "STR row 14" "conditional LT row 12"}
foreach id $rids detail $rdesc {puts $csv "$id,$status,$detail,logs/LAB4_catalog.log"}
set b1status FAIL
set f [open [file join $out logs B1.log] r]; set txt [read $f]; close $f
if {[regexp {B1 cycles=(\d+) errors=0} $txt]} {set b1status PASS}
puts $csv "R7,$b1status,ordinary B,logs/B1.log"

# Replay the original project tb_mp1 as a separate 27-row run; its first
# twenty vectors are the historical Lab4 program, followed by CMP cases.
set txt [run_one tb_mp1 {} 310ns $simlog [file join $out logs tb_mp1_27.log]]
set status FAIL; set observed "no summary"
if {[regexp {Tests: (\d+); errors: (\d+)} $txt -> n err]} {
    set observed "$n instructions; $err errors"
    if {$n >= 27 && $err == 0} {set status PASS}
}
puts $csv "tb_mp1_27,$status,$observed,logs/tb_mp1_27.log"
close $csv
close_project
