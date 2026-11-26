# GEI1084 Mini-projet 1 - Team01 (Groupe 1)

## 1. Objectif du projet

Faire évoluer le processeur ARM monocycle validé au laboratoire 4, sans le remplacer, en lui ajoutant
trois fonctions : **CMP**, **Immediate Shifted Register (LSL/LSR)** et **Branch with Link (BL)**.
Une régression structurée montre ensuite que les fonctions du Lab 4 restent valides.

## 2. Sous-ensemble d'instructions pris en charge

| Famille | Instructions |
|---|---|
| Traitement de données | ADD, SUB, AND, ORR (immédiat 8 bits ou registre), avec ou sans S |
| Comparaison | CMP (SUB réutilisé, NZCV mis à jour, aucun registre écrit) |
| Opérande registre décalé | `Rm, LSL #shamt` et `Rm, LSR #shamt` pour ADD, SUB, AND, ORR, CMP (shamt = Instr[11:7], sh = Instr[6:5], bit 4 = 0). `LSR` avec imm5 = 0 encode LSR #32 (résultat 0), comme en ARM |
| Mémoire | LDR, STR, déplacement immédiat positif |
| Branchement | B, BL (R14 <- PC+4, cible PC+8 + 4 x SignExt(imm24)) |
| Exécution conditionnelle | les 15 conditions ARM sur toutes les instructions ci-dessus |

## 3. Limitations explicites

- Hors portée (guide, section 1.4) : ASR, ROR, RRX, décalage spécifié par registre, carry du shifter,
  BX, BLX, Thumb, exceptions, pipeline, retour automatique par LR.
- Le décodage de CMP ne vérifie pas le bit S (constat de l'équipe, rapport section 10).
- Les traces de test ne lisent pas directement les cellules de la mémoire de données ; une écriture
  mémoire est vérifiée par MemWrite, l'adresse (ALUResult) et WriteData.
- Résultats de simulation RTL seulement : aucune synthèse, contrainte de temps ni essai sur FPGA.

## 4. Structure du dépôt

| Dossier | Contenu |
|---|---|
| `00_README/` | ce fichier, portée, index de remise, déclaration IAg |
| `01_REPORT/` | rapport final (PDF + source Word) |
| `02_HDL/baseline_lab4/` | processeur du Lab 4 d'origine (`src/`, banc `sim/`, archive `Laboratoire_4.zip`) |
| `02_HDL/final_design/` | processeur MP1 intégré (CMP + Shift + BL), top `mp1_system` |
| `03_TESTBENCH/testbench/` | bancs : `tb_cmp_catalog`, `tb_shift_catalog`, `tb_bl_catalog`, `tb_bl`, `tb_mp1` |
| `03_TESTBENCH/instructions/` | programmes `.hex` (un par test) et `Instructions.txt` / `Program.hex` |
| `03_TESTBENCH/expected_results/` | traces attendues `.trace`, `ExpectedData.txt`, `ExpectedResults.csv`, générateur des traces Shift |
| `03_TESTBENCH/regression/` | scripts de régression et `RegressionSummary.csv` |
| `04_RESULTS/` | journaux et captures par fonction (CMP, SHIFT, BL, REGRESSION, DEBUG_CASE) |
| `05_ARCHITECTURE/` | schémas Lab 4, CMP, Shift, BL, intégré ; `traceur/` = outil d'étude interactif |
| `06_ENGINEERING_PRACTICE/` | livrables E2 à E7 |
| `07_PRESENTATION/` | présentation (PDF + source PowerPoint) |
| `08_GRADING_EVIDENCE/` | carte des preuves (Evidence Map) |

## 5. Outils, versions et standard

- AMD Vivado / XSim **2022.2** (Windows), part `xc7z007sclg225-1`.
- VHDL-**2008** pour tous les fichiers `.vhd`.
- PowerShell 5.1 pour le script de régression en ligne de commande.

## 6. Compilation (build)

Le design est compilé par les scripts de régression ci-dessous. Pour un projet Vivado manuel :
ajouter `02_HDL/final_design/*.vhd` comme sources (top `mp1_system`), puis, dans le jeu de simulation,
`03_TESTBENCH/testbench/*.vhd`, `03_TESTBENCH/instructions/*` et `03_TESTBENCH/expected_results/*.trace`
et `ExpectedData.txt`. Régler tous les `.vhd` en VHDL 2008.

## 7. Simulation d'un test

Bancs catalogue (C, S, B) : choisir le top de simulation et ses generics, par exemple pour S5 :

| Top | Generics |
|---|---|
| `tb_shift_catalog` | `PROGRAM_FILE=S5.hex EXPECTED_FILE=S5.trace TEST_ID=S5` |
| `tb_cmp_catalog` | `PROGRAM_FILE=CMP_C5.hex EXPECTED_FILE=CMP_C5.trace TEST_ID=C5` |
| `tb_bl_catalog` | `PROGRAM_FILE=B6.hex EXPECTED_FILE=B6.trace TEST_ID=B6` |
| `tb_mp1` | aucun (lit `Instructions.txt` et `ExpectedData.txt`, 27 vecteurs) |

Durée : 400 ns pour les tests C, 300 ns pour S et B, 250 ns pour LAB4, 310 ns pour `tb_mp1`.
À chaque cycle, le banc compare PC, Instr, ALUResult, WriteData, flags, RegWrite, MemWrite, PCSrc,
FlagWrite, CondEx, le PC suivant et R0-R14 à la trace attendue.

## 8. Régression complète

Depuis la racine du dépôt, au choix :

```
vivado -mode batch -source 03_TESTBENCH/regression/run_regression.tcl
```
Sorties : `04_RESULTS/REGRESSION/rejeu/results.csv` et `logs/`.

```
powershell -ExecutionPolicy Bypass -File 03_TESTBENCH/regression/run_regression_xsim.ps1
```
(XSim en ligne de commande, sans projet ; option `-Vivado <dossier d'installation>`.)
Sorties : `04_RESULTS/REGRESSION/rejeu_xsim/results.csv` et `logs/`. Ce script rejoue aussi le banc
d'origine du Lab 4 (`02_HDL/baseline_lab4`).

## 9. Critère de réussite

- chaque catalogue C1-C7, S1-S11, B1-B8 et LAB4 affiche `<ID> cycles=<n> errors=0` ;
- `tb_mp1` affiche `Tests: 27; errors: 0` et le banc d'origine `Tests: 20; errors: 0` ;
- le résumé `results.csv` ne contient que des `PASS`.

Dernier rejeu sur cette structure : 36 lignes sur 36 PASS (`04_RESULTS/REGRESSION/rejeu_xsim/results.csv`).

## 10. Références et provenance

- Guide étudiant GEI1084 MP1, automne 2026 (UQTR).
- D. M. Harris et S. L. Harris, *Digital Design and Computer Architecture, ARM Edition*, ch. 5 et 7.
- ARM Architecture Reference Manual (codage des décalages immédiats, LSR #32).
- Provenance et licence : `06_ENGINEERING_PRACTICE/E4_Provenance_License/THIRD_PARTY_AND_PROVENANCE.md`.

## Mode de remise

Remettre à la fois l'archive complète `GEI1084_MP1_Team01.zip` et l'URL Git. Les deux doivent
correspondre au même commit/tag final consigné dans `SUBMISSION_INDEX.md`.
