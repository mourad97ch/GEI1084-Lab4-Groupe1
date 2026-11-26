Commit testé: 22f207909ce65f8bd382cdf5815acf9c35502bcc
Branche: aziz/integration-final (base dev/phase4)
Outil observé: Vivado / XSim 2022.2
Date du rejeu: 2026-11-25

Bilan: les 32 cas demandés passent (zéro erreur par scénario): C1-C7, S1-S10, B1-B8 et R1-R7. Le rejeu distinct du programme historique Lab4 passe aussi: 20 cycles, zéro erreur. Un cas supplémentaire S11 vérifie LSR imm5=0 (encodage ARM de LSR #32): 3 cycles, zéro erreur, R3=0.

| ID | Résultat observé | Journal |
|---|---|---|
| C1 | PASS — 3 cycles, 0 erreur | logs/C1.log |
| C2 | PASS — 3 cycles, 0 erreur; soustraction positive | logs/C2.log |
| C3 | PASS — 3 cycles, 0 erreur; soustraction négative | logs/C3.log |
| C4 | PASS — 4 cycles, 0 erreur | logs/C4.log |
| C5 | PASS — 34 cycles, 0 erreur; 0x80000000 − 1, V=1 | logs/C5.log |
| C6 | PASS — 4 cycles, 0 erreur; CMP exécuté, RegState inchangé | logs/C6.log |
| C7 | PASS — 5 cycles, 0 erreur; instruction conditionnelle consomme les flags CMP | logs/C7.log |
| S1 | PASS — 2 cycles, 0 erreur | logs/S1.log |
| S2 | PASS — 2 cycles, 0 erreur | logs/S2.log |
| S3 | PASS — 3 cycles, 0 erreur | logs/S3.log |
| S4 | PASS — 3 cycles, 0 erreur | logs/S4.log |
| S5 | PASS — 4 cycles, 0 erreur | logs/S5.log |
| S6 | PASS — 6 cycles, 0 erreur | logs/S6.log |
| S7 | PASS — 4 cycles, 0 erreur | logs/S7.log |
| S8 | PASS — 4 cycles, 0 erreur | logs/S8.log |
| S9 | PASS — 6 cycles, 0 erreur | logs/S9.log |
| S10 | PASS — 4 cycles, 0 erreur | logs/S10.log |
| B1 | PASS — 3 cycles, 0 erreur | logs/B1.log |
| B2 | PASS — 3 cycles, 0 erreur | logs/B2.log |
| B3 | PASS — 10 cycles, 0 erreur | logs/B3.log |
| B4 | PASS — 3 cycles, 0 erreur | logs/B4.log |
| B5 | PASS — 5 cycles, 0 erreur | logs/B5.log |
| B6 | PASS — 7 cycles, 0 erreur | logs/B6.log |
| B7 | PASS — 3 cycles, 0 erreur | logs/B7.log |
| B8 | PASS — 4 cycles, 0 erreur | logs/B8.log |
| R1 | PASS — opération arithmétique registres, row 7 du rejeu Lab4 | logs/LAB4_catalog.log |
| R2 | PASS — opération logique registres, row 6 du rejeu Lab4 | logs/LAB4_catalog.log |
| R3 | PASS — immédiat, row 2 du rejeu Lab4 | logs/LAB4_catalog.log |
| R4 | PASS — LDR, row 15 du rejeu Lab4 | logs/LAB4_catalog.log |
| R5 | PASS — STR, row 14 du rejeu Lab4 | logs/LAB4_catalog.log |
| R6 | PASS — exécution conditionnelle LT, row 12 du rejeu Lab4 | logs/LAB4_catalog.log |
| R7 | PASS — branchement B ordinaire, cas B1 | logs/B1.log |

Régression Lab4 séparée: 20 cycles, zéro erreur — logs/LAB4_catalog.log.
Rejeu du banc de projet tb_mp1: 27 instructions, zéro erreur — logs/tb_mp1_27.log.
Le script phase4/prepare_aziz_integration.tcl reproduit les simulations et produit results.csv ainsi que les journaux.
