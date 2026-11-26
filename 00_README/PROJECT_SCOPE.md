# Portée du projet (Team01)

## Base du Lab 4 (conservée)

Processeur ARM monocycle du laboratoire 4 : chemin de données, banc de registres, ALU (ADD, SUB, AND,
ORR), indicateurs NZCV, exécution conditionnelle (condlogic / condcheck), LDR/STR, B ordinaire.
Source : `02_HDL/baseline_lab4/`. Sa régression (R1-R7, banc d'origine 20/20) est rejouée sur le design final.

## Extensions obligatoires (requises et prises en charge)

| Extension | Comportement pris en charge | Tests |
|---|---|---|
| CMP | SUB réutilisé, NZCV mis à jour (FlagW = 11), aucune écriture de registre, respect de CondEx | C1-C7 |
| Immediate Shifted Register | `Rm, LSL #0..31` et `Rm, LSR #1..31` ; `LSR` avec imm5 = 0 = LSR #32 (résultat 0) ; seul l'opérande registre (RD2) est décalé ; ExtImm et WriteData non décalés | S1-S10 (+ S11) |
| BL | PC <- PC+8 + 4 x SignExt(imm24) et R14 <- PC+4 dans le même cycle, seulement si CondEx = 1 | B1-B8 |
| Intégration | un seul processeur `mp1_system` réunit les trois extensions et la base du Lab 4 | R1-R7, `tb_mp1` |

## Exclusions explicites (non prises en charge)

ASR, ROR, RRX ; décalage spécifié par registre (bit 4 = 1 : opérande transmis sans décalage) ;
carry ou flag produit par le shifter ; BX, BLX, Thumb/interworking ; exceptions ; pipeline ;
retour automatique par LR ; ISA ARM complète ; déplacement mémoire négatif ou registre.

## Extensions optionnelles réellement implémentées

- Test supplémentaire **S11** (cas limite ARM `LSR #32`), ajouté après la revue indépendante du Shifter.
- Outil d'étude `05_ARCHITECTURE/traceur/traceur-arm-monocycle.html` (visualisation du chemin de
  données par instruction ; n'intervient pas dans la vérification).
- Aucune extension HDL optionnelle : `02_HDL/optional_extensions/` est vide.
