# Rapport de présentation — intégration finale de la phase 4

**Présenté par :** Mohamed Aziz Amiri (`medazizamiri5`)  
**Branche :** `aziz/integration-final`, créée depuis `dev/phase4`  
**Pull request :** [PR #9 — Intégration CMP, Shifter et BL](https://github.com/mourad97ch/GEI1084-Lab4-Groupe1/pull/9)  
**Révision testée :** `22f207909ce65f8bd382cdf5815acf9c35502bcc`  
**Outil :** Vivado / XSim 2022.2

## 1. Résumé de ma contribution

Mon rôle a été de réunir CMP, Shifter et BL sur une branche d’intégration séparée de `main`, de vérifier leurs interfaces communes dans `arm_mp1.vhd` et `datapath.vhd`, puis de rejouer le catalogue et la régression. J’ai conservé le RTL CMP de Zack et ajouté le jeu de tests CMP corrigés fourni pour cette intégration. J’ai corrigé dans le Shifter le cas ARM `LSR` avec `imm5=0`, ajouté un scénario dédié et enregistré les scripts, résultats et journaux de simulation.

Les branches de fonctionnalité des autres membres n’ont pas été modifiées. La PR #9 est ouverte vers `dev/phase4` pour revue; elle n’est pas fusionnée.

## 2. Comment les blocs sont réunis

Le processeur est organisé en chemin de contrôle et chemin de données. `arm_mp1.vhd` décode l’instruction, établit les commandes et connecte ces commandes au `datapath.vhd`. Les blocs intégrés partagent notamment les signaux d’instruction, les registres, le résultat ALU, les drapeaux NZCV et les commandes d’écriture.

```text
Instruction
    │
    ├── main_decoder ── commandes (ALUSrc, RegWrite, MemWrite, Branch…)
    ├── alu_decoder ──── opération ALU et FlagWrite
    └── champs registres / immédiat
             │
Banque de registres ── RD1 ───────────────────────┐
                       RD2 ── Shifter ──┐         │
Immédiat étendu ───────────────────────┴─ mux ───┴─ ALU
                                                     │
                                        résultat / mémoire / writeback
```

`RegState` expose les registres R0 à R14 dans un bus de 480 bits : 15 registres × 32 bits. Le registre Rn occupe la tranche `RegState(32*n+31 downto 32*n)`; LR/R14 est donc dans les bits 479 à 448. Cette sortie rend possible la comparaison complète de l’état des registres dans les traces.

## 3. CMP : comparaison sans écriture du résultat

Une instruction CMP effectue une soustraction pour produire les drapeaux, mais ne stocke pas le résultat dans un registre. Dans le RTL conservé de Zack, le décodeur principal reconnaît l’opcode CMP et désactive `RegW`. Le décodeur ALU sélectionne SUB et demande la mise à jour des drapeaux NZCV. Le bloc de condition applique ensuite l’écriture des drapeaux conformément aux commandes et à la condition de l’instruction.

J’ai ajouté `tb_cmp_catalog.vhd` et les fichiers C1–C7 fournis (`CMP_C*.hex` et `CMP_C*.trace`). Le banc compare cycle par cycle PC, instruction, résultat ALU, WriteData, drapeaux avant/après, commandes de contrôle et état complet `RegState`.

| Cas | Ce qu’il vérifie | Résultat XSim |
|---|---|---|
| C1 | Égalité et drapeaux correspondants | PASS — 3 cycles, 0 erreur |
| C2 | Soustraction positive, `9 − 4 = 5` | PASS — 3 cycles, 0 erreur |
| C3 | Soustraction négative, `4 − 9 = −5` | PASS — 3 cycles, 0 erreur |
| C4 | Comparaisons dans les deux sens : différence négative puis positive | PASS — 4 cycles, 0 erreur |
| C5 | `0x80000000 − 1`; le drapeau V vaut 1 | PASS — 34 cycles, 0 erreur |
| C6 | CMP est exécuté (`CondEx=1`) et aucun registre n’est modifié | PASS — 4 cycles, 0 erreur |
| C7 | Une instruction conditionnelle consomme les drapeaux CMP | PASS — 5 cycles, 0 erreur |

La longue durée de C5 vient de la séquence de préparation qui construit `0x80000000`; le cas de comparaison lui-même est vérifié dans la trace complète.

## 4. Shifter : chemin registre et cas limite LSR #32

Le Shifter est placé entre la sortie RD2 de la banque de registres et l’entrée registre du mux `ALUSrc`. Lorsque l’opérande est un registre, le champ `Instr(11:7)` fournit `imm5`, `Instr(6:5)` sélectionne LSL ou LSR et `Instr(4)` indique si le décalage est par constante. Lorsque `ALUSrc=1`, l’immédiat étendu passe directement au mux : le Shifter ne le transforme pas. `WriteData` continue de prendre RD2 non décalé, ce qui préserve les données d’un STR.

Les scénarios S1–S10 vérifient LSL #0/#1 et les grands décalages, LSR logique avec bit de signe à 1, l’entrée de zéros, l’utilisation du résultat décalé par AND/ORR, les opérations registre non décalées et le chemin immédiat/STR/LDR.

La revue indépendante de Haroun avait signalé que `imm5=00000` en LSR devait coder un décalage de 32, alors que le code existant rendait l’opérande inchangé. J’ai corrigé ce cas sur la branche d’intégration : si le type est LSR et `imm5=0`, la sortie est zéro. Le nouveau test S11 prépare `R2=0xFFFFFFFF`, exécute `LSR R3,R2,#32` et vérifie `R3=0` : **3 cycles, 0 erreur**. Ce test supplémentaire n’est pas compté parmi les dix scénarios S1–S10 demandés.

Le périmètre vérifié du Shifter reste LSL et LSR par constante. ASR, ROR et les décalages par registre ne sont pas couverts par ces scénarios.

## 5. BL : appel, LR et retour

Pour l’appel avec lien, `arm_mp1.vhd` détecte une instruction branch-and-link avec `link_s`. Cette commande active l’écriture registre et le datapath choisit R14 comme destination; la valeur de writeback est `PCPlus4`. Le chemin PC reçoit la cible de branchement lorsque `PCSrc` est actif. Ainsi, un BL exécuté avec PC=4 place `8` dans LR, soit PC+4.

Un branchement B ordinaire n’a pas le bit Link : il peut modifier le PC sans écrire LR. Pour les branches conditionnelles, `CondEx` détermine si l’effet est appliqué. Les tests vérifient le BL pris, le BL non pris, la conservation de LR pendant B, le retour via LR et la continuation après le retour.

J’ai également rejoué les résultats BL de Mourad sur la branche `feature/bl`, au commit testé `080daf3e27d49d2980a594b65e7b8defc8c05055`. `tb_bl` a exécuté ses huit instructions avec zéro erreur et `Done=TRUE`. J’ai ajouté au même banc le cas BL avec EQ vraie; il vérifie `NZCV=0110`, la prise de branche, `LR=PC+4`, le retour via LR et la reprise après le retour, également sans erreur. J’ai conservé et poussé mes propres preuves sous `preuves/aziz_bl` sur la branche [`aziz/bl-verification`](https://github.com/mourad97ch/GEI1084-Lab4-Groupe1/tree/aziz/bl-verification/preuves/aziz_bl). La revue de la [PR #3](https://github.com/mourad97ch/GEI1084-Lab4-Groupe1/pull/3#pullrequestreview-6067127024) a ensuite été publiée comme **Approve**. Ces preuves correspondent au commit BL indiqué; dans la révision intégrée, B1–B8 ont été rejoués séparément contre leurs traces architecturales.

| Cas | Résultat XSim |
|---|---|
| B1 | PASS — 3 cycles, 0 erreur |
| B2 | PASS — 3 cycles, 0 erreur |
| B3 | PASS — 10 cycles, 0 erreur |
| B4 | PASS — 3 cycles, 0 erreur |
| B5 | PASS — 5 cycles, 0 erreur |
| B6 | PASS — 7 cycles, 0 erreur |
| B7 | PASS — 3 cycles, 0 erreur |
| B8 | PASS — 4 cycles, 0 erreur |

## 6. Régression Lab4 et total du catalogue

Le total convenu est **7 CMP + 10 Shift + 8 BL + 7 régressions = 32 cas**. R1–R6 sont les opérations correspondantes dans la trace complète de 20 instructions du Lab4; R7 est le branchement B ordinaire déjà isolé en B1. Cette association est consignée par ID dans `results.csv` et le détail des lignes vérifiées est ci-dessous.

| ID | Instruction couverte dans la trace Lab4 | Résultat |
|---|---|---|
| R1 | Arithmétique entre registres, ligne 7 | PASS |
| R2 | Logique entre registres, ligne 6 | PASS |
| R3 | Opérande immédiat, ligne 2 | PASS |
| R4 | LDR, ligne 15 | PASS |
| R5 | STR, ligne 14 | PASS |
| R6 | Exécution conditionnelle LT, ligne 12 | PASS |
| R7 | Branchement B ordinaire, scénario B1 | PASS |

Le banc `tb_cmp_catalog` a également rejoué les 20 instructions originales du Lab4 : **20 cycles, 0 erreur**. En complément, le banc de projet `tb_mp1` intégré a parcouru 27 instructions, y compris les cas CMP présents dans ce programme : **27 tests, 0 erreur**. Pour la mémoire, la trace vérifie les commandes STR/LDR, l’adresse et la valeur observée au chargement; elle ne lit pas directement chaque cellule interne de la RAM.

## 7. Tableau récapitulatif des 32 cas

| Groupe | IDs | Bilan |
|---|---|---|
| CMP | C1–C7 | 7/7 PASS, zéro erreur |
| Shifter | S1–S10 | 10/10 PASS, zéro erreur |
| BL | B1–B8 | 8/8 PASS, zéro erreur |
| Régression | R1–R7 | 7/7 PASS, zéro erreur |
| Rejeu Lab4 original séparé | — | 20 cycles, zéro erreur |
| Test additionnel LSR #32 | S11 | 3 cycles, zéro erreur |

## 8. Reproduction et pièces justificatives

Depuis la racine du dépôt, le script `phase4/prepare_aziz_integration.tcl` crée un projet temporaire Vivado, compile les sources et rejoue les cas. Il écrit les résultats et journaux sous `preuves/aziz_integration/`. Le CSV `results.csv` donne les résultats par ID; `logs/C1.log` à `logs/C7.log`, `logs/S1.log` à `logs/S11.log`, `logs/B1.log` à `logs/B8.log`, `logs/LAB4_catalog.log` et `logs/tb_mp1_27.log` contiennent les résumés XSim observés. `vivado_batch.log` conserve la sortie batch globale.

Les attendus des tests fournis n’ont pas été changés pour obtenir ces résultats. La simulation valide le comportement décrit par les vecteurs et traces; aucune conclusion de synthèse, de fréquence ou de test sur FPGA n’est formulée ici.

## Présentation orale courte

> « Ma partie a été l’intégration et la vérification finale de CMP, du Shifter et de BL sur une branche séparée de `dev/phase4`. J’ai conservé le RTL CMP de Zack et ajouté les tests CMP corrigés transmis pour cette intégration. Pour BL, j’ai rejoué les huit instructions de `tb_bl`, puis le cas EQ vraie dans le même banc; les résultats et mes preuves ont été publiés sur GitHub et ma revue de la PR #3 a été approuvée. J’ai aussi corrigé le cas ARM où LSR avec `imm5=0` signifie un décalage de 32 et doit produire zéro, puis j’ai ajouté S11 pour le vérifier. Le catalogue donne 32 cas sans erreur, et la régression distincte des 20 instructions Lab4 passe aussi. Le rapport, les journaux et le script de rejeu sont joints à la PR #9, qui attend une revue et n’a pas été fusionnée. »


