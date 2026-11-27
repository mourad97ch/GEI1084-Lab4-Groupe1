# Regression complete en ligne de commande XSim (sans projet Vivado).
# Meme couverture que run_regression.tcl : C1-C7, S1-S11, B1-B8, Lab 4 (R1-R6),
# R7 (= B1), tb_mp1, plus le banc d'origine du Lab 4 (02_HDL/baseline_lab4).
#
# Usage (PowerShell, depuis la racine du depot) :
#   powershell -ExecutionPolicy Bypass -File 03_TESTBENCH/regression/run_regression_xsim.ps1
# Option : -Vivado "C:\Xilinx\Vivado\2022.2"   (dossier d'installation)
# Sorties : 04_RESULTS/REGRESSION/rejeu_xsim/results.csv et logs/<ID>.log
param([string]$Vivado = "C:\Xilinx\Vivado\2022.2")

$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$out  = Join-Path $root "04_RESULTS\REGRESSION\rejeu_xsim"
$work = Join-Path $env:TEMP "GEI1084_MP1_xsim"
$env:PATH = "$Vivado\bin;$env:PATH"

function Reset-Dir($d) { if (Test-Path $d) { Remove-Item -Recurse -Force $d }; New-Item -ItemType Directory $d | Out-Null }
Reset-Dir $work; New-Item -ItemType Directory -Force (Join-Path $out "logs") | Out-Null

# ---- Design final MP1 ------------------------------------------------------
$mp1 = Join-Path $work "mp1"; Reset-Dir $mp1
Copy-Item "$root\02_HDL\final_design\*.vhd", "$root\03_TESTBENCH\testbench\*.vhd" $mp1
Copy-Item "$root\03_TESTBENCH\instructions\*.hex", "$root\03_TESTBENCH\instructions\*.txt" $mp1
Copy-Item "$root\03_TESTBENCH\expected_results\*.trace", "$root\03_TESTBENCH\expected_results\*.txt" $mp1
Push-Location $mp1
# Ordre de compilation : dependances d'abord.
$order = 'adder','alu_arithmetic','alu_select','alu_flags','alu32','alu_decoder','main_decoder',
         'pc_logic','condcheck','condlogic','reg_enable','register_file','extend','shifter',
         'data_memory','datapath','arm_mp1','instruction_rom','mp1_system',
         'tb_mp1','tb_shift_catalog','tb_cmp_catalog','tb_bl_catalog','tb_bl'
& xvhdl.bat -2008 ($order | ForEach-Object { "$_.vhd" }) *> compile.log
if (Select-String compile.log -Pattern 'ERROR' -Quiet) { Pop-Location; throw "Compilation MP1 en erreur : voir $mp1\compile.log" }

$rows = @()
function Invoke-Catalog($tb, $id, $prog, $trace) {
    # Les generics passent par un fichier d'arguments (xelab.bat coupe les '=').
    "-debug off $tb -s snap_$id -generic_top PROGRAM_FILE=$prog -generic_top EXPECTED_FILE=$trace -generic_top TEST_ID=$id" |
        Out-File -Encoding ascii "args_$id.txt"
    & xelab.bat -f "args_$id.txt" *> "elab_$id.log"
    $log = Join-Path $out "logs\$id.log"
    & xsim.bat "snap_$id" -R *> $log
    $txt = Get-Content $log -Raw
    if ($txt -match "$id cycles=(\d+) errors=(\d+)") {
        $st = if ([int]$Matches[2] -eq 0) { "PASS" } else { "FAIL" }
        return @{ ID = $id; Status = $st; Observed = "$($Matches[1]) cycles; $($Matches[2]) errors"; Log = "logs/$id.log" }
    }
    return @{ ID = $id; Status = "FAIL"; Observed = "no summary"; Log = "logs/$id.log" }
}

foreach ($i in 1..7)  { $rows += Invoke-Catalog tb_cmp_catalog   "C$i" "CMP_C$i.hex" "CMP_C$i.trace" }
foreach ($i in 1..11) { $rows += Invoke-Catalog tb_shift_catalog "S$i" "S$i.hex"     "S$i.trace" }
foreach ($i in 1..8)  { $rows += Invoke-Catalog tb_bl_catalog    "B$i" "B$i.hex"     "B$i.trace" }
$lab4 = Invoke-Catalog tb_cmp_catalog "LAB4" "CMP_LAB4.hex" "CMP_LAB4.trace"
$rows += $lab4
# R1-R6 sont des lignes du programme Lab 4 complet ; R7 reutilise B1 (B ordinaire).
$rdesc = [ordered]@{ R1 = "registre arithmetique, ligne 7"; R2 = "registre logique, ligne 6"; R3 = "immediat, ligne 2";
                     R4 = "LDR, ligne 15"; R5 = "STR, ligne 14"; R6 = "conditionnelle LT, ligne 12" }
foreach ($k in $rdesc.Keys) { $rows += @{ ID = $k; Status = $lab4.Status; Observed = $rdesc[$k]; Log = "logs/LAB4.log" } }
$b1 = $rows | Where-Object { $_.ID -eq "B1" }
$rows += @{ ID = "R7"; Status = $b1.Status; Observed = "B ordinaire (scenario B1)"; Log = "logs/B1.log" }

# tb_mp1 : 20 vecteurs historiques du Lab 4 + 7 vecteurs CMP.
& xelab.bat -debug off tb_mp1 -s snap_mp1 *> elab_mp1.log
$log = Join-Path $out "logs\tb_mp1.log"; & xsim.bat snap_mp1 -R *> $log
$txt = Get-Content $log -Raw
if ($txt -match "Tests: (\d+); errors: (\d+)") {
    $rows += @{ ID = "tb_mp1"; Status = $(if ([int]$Matches[2] -eq 0) { "PASS" } else { "FAIL" }); Observed = "$($Matches[1]) tests; $($Matches[2]) errors"; Log = "logs/tb_mp1.log" }
} else { $rows += @{ ID = "tb_mp1"; Status = "FAIL"; Observed = "no summary"; Log = "logs/tb_mp1.log" } }
Pop-Location

# ---- Banc d'origine du Lab 4 (continuite) ---------------------------------
$l4 = Join-Path $work "lab4"; Reset-Dir $l4
Copy-Item "$root\02_HDL\baseline_lab4\src\*.vhd", "$root\02_HDL\baseline_lab4\sim\*" $l4
Push-Location $l4
$order4 = 'adder','alu_arithmetic','alu_select','alu_flags','alu32','alu_decoder','main_decoder',
          'pc_logic','condcheck','condlogic','reg_enable','register_file','extend',
          'data_memory','datapath','instruction_memory','arm_lab4','tb_arm_lab4'
& xvhdl.bat -2008 ($order4 | ForEach-Object { "$_.vhd" }) *> compile.log
& xelab.bat -debug off tb_arm_lab4 -s snap_lab4 *> elab.log
$log = Join-Path $out "logs\BASELINE_LAB4.log"; & xsim.bat snap_lab4 -R *> $log
$txt = Get-Content $log -Raw
if ($txt -match "Tests: (\d+); errors: (\d+)") {
    $rows += @{ ID = "BASELINE_LAB4"; Status = $(if ([int]$Matches[2] -eq 0) { "PASS" } else { "FAIL" }); Observed = "$($Matches[1]) tests; $($Matches[2]) errors"; Log = "logs/BASELINE_LAB4.log" }
} else { $rows += @{ ID = "BASELINE_LAB4"; Status = "FAIL"; Observed = "no summary"; Log = "logs/BASELINE_LAB4.log" } }
Pop-Location

# ---- Resume ----------------------------------------------------------------
$csv = @("ID,Status,Observed,Log") + ($rows | ForEach-Object { "$($_.ID),$($_.Status),$($_.Observed),$($_.Log)" })
Set-Content -Path (Join-Path $out "results.csv") -Value $csv -Encoding ascii
$rows | ForEach-Object { "{0,-14} {1,-5} {2}" -f $_.ID, $_.Status, $_.Observed }
$fail = @($rows | Where-Object { $_.Status -ne "PASS" }).Count
"Total : $($rows.Count) lignes, $fail FAIL"
if ($fail -gt 0) { exit 1 }
