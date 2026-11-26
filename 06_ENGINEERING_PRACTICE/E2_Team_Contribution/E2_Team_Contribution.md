# E2 - Contribution au travail d'équipe et intégration (Team01)

Faits tirés du dépôt https://github.com/mourad97ch/GEI1084-Lab4-Groupe1 (PR, commits, journaux).
Les parties qui demandent le jugement de chaque membre sont marquées **À COMPLÉTER**.

## E2.1 - Plan de contribution (prévu en début de projet)

| Tâche | Responsable principal | Support | Reviewer prévu | Dépendance d'intégration |
|---|---|---|---|---|
| CMP | A. Abib Ahmed (Zack) | M. A. Amiri (tests corrigés à l'intégration) | M. Chrami | ALU decoder, main decoder, condlogic |
| Shift | H. Chaabane | — | H. Azzabi | datapath (RD2 -> mux ALUSrc) |
| BL | M. Chrami | — | A. Abib Ahmed (prévu) ; revue faite par M. A. Amiri | datapath (A3, WD3), extend, arm_mp1 |
| Intégration | M. A. Amiri | M. Chrami (fusions) | H. Chaabane (prévu) | les trois extensions |
| Vérification / régression | H. Azzabi | tous | M. A. Amiri (prévu) | bancs catalogue, traces |
| Dépôt / reproductibilité | M. Chrami | H. Chaabane (structure de remise, scripts) | A. Abib Ahmed (prévu) | — |
| Pratique d'ingénierie (E2-E7) | E2 : H. Azzabi ; E3 : A. Abib Ahmed ; E4 : M. Chrami ; E5 : H. Chaabane ; E6 : M. A. Amiri ; E7 : chacun | — | — | — |

## E2.2 - Contributions techniques visibles dans le dépôt

| Membre | Artefacts produits / modifiés | Validation / diagnostic | Preuves |
|---|---|---|---|
| M. Chrami | base réutilisable phase 4 (`mp1_system`, `RegState`, ROM), BL (`arm_mp1`, `datapath`, `extend`), tests B1-B8 | B1-B8 PASS, Lab 4 20/20 | PR #1, PR #3, `04_RESULTS/BL/mourad_bl/` |
| A. Abib Ahmed | CMP (`alu_decoder`, `main_decoder`, `arm_mp1`), tests CMP | validation CMP | PR #8 |
| H. Chaabane | `shifter.vhd` + câblage `datapath.vhd`, S1-S10, modèle de référence `gen_shift_tests.py`, banc `tb_shift_catalog`, traceur, structure de remise | S1-S11 PASS, mutations (ASR, shifter court-circuité, mal placé) détectées | PR #4, #5, #10, #12, `04_RESULTS/SHIFT/hatem_shift/` |
| H. Azzabi | revues indépendantes Lab 4, phase 4, Shifter, intégration ; banc minimal LSR #32 | détection du défaut LSR #32, revérification après correction | PR #2, #6, #11, `04_RESULTS/REGRESSION/haroun_*`, `04_RESULTS/SHIFT/haroun_shift_review/` |
| M. A. Amiri | intégration CMP + Shift + BL, tests CMP corrigés, correctif LSR #32 (647cab6), S11, script de rejeu | 32 cas + Lab 4 + tb_mp1 27/27 | PR #9, `04_RESULTS/REGRESSION/aziz_integration/` |

Décision technique personnelle de chaque membre (au moins une) : **À COMPLÉTER par chaque membre.**
Exemple documenté pour H. Chaabane : shifter placé avant le mux ALUSrc (et non après) pour que ExtImm et
WriteData ne soient jamais décalés ; LSR en `unsigned` pour un remplissage par zéros.

## E2.3 - Problème d'intégration réel

Problème -> composants -> étudiants -> résolution -> revalidation :

- **Problème** : LSR avec imm5 = 0 rendait l'opérande inchangé au lieu de 0 (LSR #32 en ARM).
- **Composants** : `shifter.vhd`, modèle de référence `gen_shift_tests.py`.
- **Étudiants** : H. Chaabane (auteur du Shifter), H. Azzabi (détection en revue, PR #6), M. A. Amiri (correction à l'intégration).
- **Résolution** : commit 647cab6 (sortie 0 si sh = 01 et shamt = 0) + test S11.
- **Revalidation** : banc minimal (0x80000001 -> 0x00000000), S1-S11, C1-C7, B1-B8, Lab 4, tb_mp1 27/27 (PR #9, #10, #11).
  Détail : `04_RESULTS/DEBUG_CASE/README.md`.

## E2.4 - Revues techniques par un pair

| Fonction | Développeur | Reviewer | Date | Éléments contrôlés | Constats | Corrections | Statut |
|---|---|---|---|---|---|---|---|
| Base phase 4 | M. Chrami | H. Azzabi | 25 nov. 2026 | 20 tests Lab 4, contrôle LT | aucun défaut | — | approuvée (PR #1), preuves PR #2 |
| CMP | A. Abib Ahmed | M. Chrami | 25 nov. 2026 | décodage, couverture des tests (PR #8) | changements demandés (C2/C3 inversés, C5-C7 à compléter) | tests corrigés à l'intégration (54190ca) | « changes requested » affiché sur PR #8 ; vérifié ensuite par H. Azzabi (PR #11) |
| Shift | H. Chaabane | H. Azzabi | 25 nov. 2026 | RD2 -> shifter -> ALUSrc, immédiat, WriteData, S1-S10, Lab 4 | réserve LSR #32 | 647cab6 + S11 | réserve levée par la revérification (PR #11) |
| BL | M. Chrami | M. A. Amiri | 25 nov. 2026 | tb_bl, cas EQ vrai, B1-B8, Lab 4 | aucun défaut bloquant | banc étendu | approuvée (PR #3) |
| Intégration | M. A. Amiri | H. Azzabi | 25 nov. 2026 | C1-C7, S1-S11, B1-B8, Lab 4, tb_mp1 27, banc minimal LSR #32, 42 exécutions | aucun défaut | — | vérification finale (PR #11) |

## E2.5 - Traçabilité par étudiant

| Étudiant | Contribution principale | Support | Intégration | Revue | Validation / debug | Preuve |
|---|---|---|---|---|---|---|
| M. Chrami | base phase 4, BL | dépôt, fusions | fusion PR #1, #3, #8, #9 | revue CMP (PR #8) | B1-B8 | PR #1, #3 |
| A. Abib Ahmed | CMP | — | — | — | tests CMP | PR #8 |
| H. Chaabane | Shifter, S1-S10 | traceur, structure de remise | PR #5, #10, #12 | **À COMPLÉTER** (revue de l'intégration prévue) | S1-S11, mutations | PR #10 |
| H. Azzabi | vérification indépendante | — | — | PR #2, #6, #11 | défaut LSR #32 | PR #6, #11 |
| M. A. Amiri | intégration | correctif LSR #32 | PR #9 | revue BL (PR #3) | 32 cas + Lab 4 | PR #9 |

Rappel du guide : nombre de commits ≠ niveau de contribution. Chaque ligne doit être confirmée par le membre concerné.
