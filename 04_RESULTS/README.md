# 04_RESULTS - Index des preuves

Chaque sous-dossier regroupe les captures, résumés CSV et notes de vérification d'une fonction.
Les identifiants de tests (C1-C7, S1-S11, B1-B8, R1-R7) sont ceux de `03_TESTBENCH`.

| Dossier | Contenu | Auteur de l'exécution |
|---|---|---|
| `CMP/` | index C1-C7, capture console de validation CMP | A. Abib Ahmed, M. A. Amiri |
| `SHIFT/hatem_shift/` | S1-S11 + tb_mp1, captures S5 et S11, `Resultats_S1_S10.csv` | H. Chaabane |
| `SHIFT/haroun_shift_review/` | revue indépendante du Shifter (PR #6) | H. Azzabi |
| `BL/mourad_bl/` | B1-B8, capture BL, `Resultats_B1_B8.csv` | M. Chrami |
| `REGRESSION/aziz_integration/` | rejeu intégré C, S, B, R1-R7, tb_mp1 27 (PR #9) ; **un journal XSim par test** dans `logs/` | M. A. Amiri |
| `REGRESSION/haroun_integration/` | vérification finale indépendante (PR #11) | H. Azzabi |
| `REGRESSION/haroun_phase4/` | vérification indépendante de la base phase 4 (PR #2) | H. Azzabi |
| `REGRESSION/lab4_baseline/` | validation du Lab 4 d'origine | M. Chrami |
| `REGRESSION/rejeu_xsim/` | rejeu complet sur la structure de remise : 36/36 PASS | H. Chaabane |
| `DEBUG_CASE/` | diagnostic d'un défaut réel : LSR avec imm5 = 0 (symptôme, banc minimal, retest) | voir le dossier |

## Journaux bruts

Pour garder la remise lisible, seuls les journaux utiles à la conclusion PASS/FAIL sont conservés : un journal
par test (`REGRESSION/aziz_integration/logs/`) et ceux du cas de debug. Les autres journaux de travail
(exécutions répétées, VCD, fichiers d'audit) ont été retirés au commit 281cda7. Ils restent consultables dans
l'historique Git, par exemple `git show 3463f8a:04_RESULTS/REGRESSION/haroun_integration/integration/C1.log`.
Les CSV des membres (`Resultats_*.csv`, `resultats.csv`, `tableau_groupe.csv`) sont conservés tels quels ;
leurs colonnes de chemin désignent ces journaux d'origine.

Tous les résultats sont des résultats de simulation (Vivado/XSim 2022.2) ; aucun essai sur FPGA.
