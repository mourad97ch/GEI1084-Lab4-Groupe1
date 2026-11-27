# Régression

| R | Fonction | Preuve |
|---|---|---|
| R1 | arithmétique registre (ligne 7 du programme Lab 4) | `aziz_integration/logs/LAB4_catalog.log` |
| R2 | logique registre (ligne 6) | idem |
| R3 | immédiat (ligne 2) ; aussi couvert par S10 | idem |
| R4 | LDR (ligne 15) | idem |
| R5 | STR (ligne 14) | idem |
| R6 | conditionnelle non-BL, ADDLT (ligne 12) | idem |
| R7 | B ordinaire = scénario B1 | `aziz_integration/logs/B1.log` |

| Dossier | Contenu |
|---|---|
| `aziz_integration/` | rejeu intégré de M. A. Amiri (PR #9) : `results.csv` + un journal XSim par test dans `logs/` (C1-C7, S1-S11, B1-B8, LAB4, tb_mp1 27/27) |
| `haroun_integration/` | vérification finale indépendante de H. Azzabi (PR #11) : `resultats.csv`, `tableau_groupe.csv`, captures S11 et bilan 27/27 |
| `haroun_phase4/` | vérification indépendante de la base phase 4 (PR #2) : comparaisons, captures |
| `lab4_baseline/` | validation du Lab 4 d'origine (20 tests, 0 erreur) : `validation_mourad.png` |
| `rejeu_xsim/` | rejeu complet sur la structure de remise : `results.csv` (36/36 PASS). Les journaux sont régénérés par `03_TESTBENCH/regression/run_regression_xsim.ps1` et ne sont pas versionnés. |
