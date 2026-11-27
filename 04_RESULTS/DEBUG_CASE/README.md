# Diagnostic d'un défaut réel : LSR avec imm5 = 0 (LSR #32)

| Étape | Contenu | Preuve |
|---|---|---|
| 1. Symptôme | Au commit c5fc234, le Shifter rend l'opérande inchangé pour `LSR` avec imm5 = 00000 : A = 0x80000001 ressort 0x80000001 au lieu de 0x00000000. S1-S10 passaient tous. | `../SHIFT/haroun_shift_review/journal_lsr32.txt` (ligne `observed=80000001 ARM_LSR32_expected=00000000`) |
| 2. Hypothèse | Le codage ARM imm5 = 0 n'est pas traité à part pour LSR. | `../SHIFT/haroun_shift_review/avis_revue.txt`, PR #6 |
| 3. Preuve diagnostique | Banc minimal sur le shifter seul : A = 0x80000001, sh = 01, shamt = 00000, bit4 = 0. | `../SHIFT/haroun_shift_review/tb_lsr32_review.vhd` |
| 4. Cause racine | `shift_right(unsigned(A), 0)` = A ; or en ARM, LSR avec imm5 = 0 encode un décalage de 32. | `02_HDL/final_design/shifter.vhd` (branche `"01"`) |
| 5. Correction | Si sh = 01 et shamt = 0, la sortie vaut 0 (commit 647cab6, M. A. Amiri). | historique Git, commit 647cab6 |
| 6. Retest | Même banc minimal : `observed=00000000` ; test processeur S11 : R2 = 0xFFFFFFFF, `ADD R3, R0, R2, LSR #32` -> R3 = 0, 3 cycles, 0 erreur. | `../REGRESSION/haroun_integration/integration/LSR32_MINIMAL.log`, `../SHIFT/hatem_shift/logs/S11.log`, `../SHIFT/hatem_shift/capture_shift_hatem_S11.png` |
| 7. Régression associée | S1-S11, C1-C7, B1-B8, Lab 4 et tb_mp1 27/27 : 0 erreur. | `../REGRESSION/aziz_integration/`, `../REGRESSION/haroun_integration/`, `../REGRESSION/rejeu_xsim/` |

Personnes impliquées : H. Chaabane (Shifter), H. Azzabi (détection en revue, PR #6, et revérification, PR #11),
M. A. Amiri (correction lors de l'intégration, PR #9).
