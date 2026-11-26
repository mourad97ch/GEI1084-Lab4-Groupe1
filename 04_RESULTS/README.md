# 04_RESULTS - Index des preuves

Chaque sous-dossier regroupe les journaux XSim, captures et résumés d'une fonction.
Les identifiants de tests (C1-C7, S1-S11, B1-B8, R1-R7) sont ceux de `03_TESTBENCH`.

| Dossier | Contenu | Auteur de l'exécution |
|---|---|---|
| `CMP/` | index des journaux C1-C7 (voir `CMP/README.md`) | M. A. Amiri, H. Azzabi |
| `SHIFT/hatem_shift/` | S1-S11 + tb_mp1, journal Vivado, captures S5 et S11, `Resultats_S1_S10.csv` | H. Chaabane |
| `SHIFT/haroun_shift_review/` | revue indépendante du Shifter (PR #6) et reproduction du défaut LSR #32 | H. Azzabi |
| `BL/mourad_bl/` | B1-B8, capture BL, journal Vivado | M. Chrami |
| `REGRESSION/aziz_integration/` | rejeu intégré C, S, B, R1-R7, tb_mp1 27 (PR #9) | M. A. Amiri |
| `REGRESSION/haroun_integration/` | vérification finale indépendante (PR #11), banc minimal LSR #32 | H. Azzabi |
| `REGRESSION/haroun_phase4/` | vérification indépendante de la base phase 4 (PR #2) | H. Azzabi |
| `REGRESSION/lab4_baseline/` | validation du Lab 4 d'origine | M. Chrami |
| `REGRESSION/rejeu_xsim/` | rejeu complet sur la structure de remise (`run_regression_xsim.ps1`) : 36/36 PASS | H. Chaabane |
| `DEBUG_CASE/` | diagnostic d'un défaut réel : LSR avec imm5 = 0 | voir le dossier |
