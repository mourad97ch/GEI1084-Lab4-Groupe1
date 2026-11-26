# Shift (S1-S10) + regression tb_mp1 dans Vivado/XSim 2022.2.
# Usage (console Tcl de Vivado ou en batch) :
#   vivado -mode batch -source phase4/prepare_shift.tcl
# Chaque journal XSim est copie dans preuves/hatem_shift/logs/ et un
# resume est ecrit dans preuves/hatem_shift/Resultats_S1_S10.csv.
set base [file dirname [file normalize [info script]]]
set out  [file normalize [file join $base .. preuves hatem_shift]]
file mkdir [file join $out logs]

create_project MP1_Shift [file join $base vivado_shift] -part xc7z007sclg225-1 -force
set_property target_language VHDL [current_project]
add_files -norecurse [glob -directory [file join $base src] *.vhd]
add_files -fileset sim_1 -norecurse [glob -directory [file join $base sim] *]
set_property file_type {VHDL 2008} [get_files *.vhd]
set_property top mp1_system [get_filesets sources_1]
update_compile_order -fileset sources_1

set simlog [file join $base vivado_shift MP1_Shift.sim sim_1 behav xsim simulate.log]

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

# Objectif de chaque scenario (catalogue officiel).
set purpose {
    S1  "LSL #0 : identite (R2 = 0xA5)"
    S2  "LSL #1 (R4 = 6)"
    S3  "LSL multi-bits #4 et #28 (R5 = 0x30, R6 = 0x30000000)"
    S4  "LSR ordinaire #1 et #5 (R7 = 0x10, R8 = 1)"
    S5  "LSR avec MSB = 1 : zeros a gauche (R9 = 0x7FFFFFFF, R11 = 1)"
    S6  "Decalage jusqu'a zero (0x80000000 LSL #1 = 0, 1 LSR #1 = 0)"
    S7  "AND avec operande decale (R3 = 0x0F, R4 = 0)"
    S8  "ORR avec operande decale (R3 = 0xF01, R4 = 0xF1)"
    S9  "Regression registre non decale (SUB/ADD/AND/ORR)"
    S10 "Regression chemin immediat + STR WriteData non decale (R1 = 0xA5)"
}

set csv [open [file join $out Resultats_S1_S10.csv] w]
puts $csv "ID,Function,Expected,Observed,Status,EvidencePath"
foreach {id desc} $purpose {
    set log [file join $out logs $id.log]
    set txt [run_one tb_shift_catalog \
        "PROGRAM_FILE=$id.hex EXPECTED_FILE=$id.trace TEST_ID=$id" \
        300ns $simlog $log]
    set obs "no result"
    set status FAIL
    if {[regexp "$id cycles=(\\d+) errors=(\\d+)" $txt -> cyc err]} {
        set obs "$cyc cycles, $err erreurs"
        if {$err == 0} { set status PASS }
    }
    puts $csv "$id,\"$desc\",Trace architecturale complete ($id.trace),$obs,$status,preuves/hatem_shift/logs/$id.log"
    puts "=== $id : $status ($obs)"
}

# Regression Lab 4 (20 instructions + controle LT) avec le shifter en place.
set txt [run_one tb_mp1 {} 230ns $simlog [file join $out logs tb_mp1.log]]
set status FAIL
if {[regexp {Tests: (\d+); errors: (\d+)} $txt -> n err] && $err == 0} { set status PASS }
puts $csv "REG,\"Regression Lab 4 tb_mp1\",20 tests sans erreur,[expr {[info exists n] ? "$n tests, $err erreurs" : "no result"}],$status,preuves/hatem_shift/logs/tb_mp1.log"
puts "=== tb_mp1 : $status"
close $csv
close_project
