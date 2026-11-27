# Comparaison E7 du Groupe 1

Cette synthèse prépare la décision du groupe. La notation et la sélection ci-dessous ont été confirmées par le groupe le 26 novembre 2026.

| Membre | Sujet | Preuve ou point de départ | État |
|---|---|---|---|
| Mourad Chrami | Vérifier PC et R14 lors d’un BL conditionnel | B6 sur 7ab6fb8, sept cycles sans erreur | PDF préparé, à confirmer comme travail individuel |
| Abdoulrazack Abib Ahmed | Vérifier les effets de CMP | C5 à C7 sur 7ab6fb8 | PDF classé, validation confirmée par Mourad |
| Hatem Chaabane | Tester les encodages limites du Shifter | LSL avec champ nul et S11 pour LSR #32 | PDF classé, validation confirmée par Mourad |
| Haroun Azzabi | Isoler un défaut du Shifter par un banc minimal | PR #6, reproduction du défaut avant correction | PDF reçu et classé |
| Mohamed Aziz Amiri | Reproduire une régression à partir d’un commit | PR #9, 32 cas sans erreur sur 22f2079 | PDF reçu et classé |

La fiche d’Haroun documente le défaut observé avant correction. Après intégration, S11 a vérifié le comportement corrigé sur 7ab6fb8. La piste d’Hatem porte sur la couverture des encodages limites, tandis que celle d’Haroun porte sur la méthode d’isolement du défaut.

## Matrice de décision du groupe

| Critère | Poids | Mourad — BL | Abdoulrazack — CMP | Hatem — Shifter | Haroun — Diagnostic | Aziz — Régression |
|---|---:|---:|---:|---:|---:|---:|
| Pertinence | 20 % | 5 | 5 | 5 | 5 | 5 |
| Bénéfice attendu | 20 % | 4 | 4 | 4 | 4 | 5 |
| Faisabilité | 20 % | 5 | 5 | 5 | 5 | 5 |
| Qualité des preuves | 15 % | 5 | 4 | 5 | 5 | 5 |
| Complexité d’intégration | 10 % | 5 | 5 | 4 | 5 | 4 |
| Coût et risque | 10 % | 5 | 5 | 5 | 5 | 5 |
| Extensibilité | 5 % | 4 | 4 | 4 | 3 | 5 |
| **Total pondéré sur 5** | **100 %** | **4,75** | **4,60** | **4,65** | **4,70** | **4,90** |

Une note de 5 en complexité ou en coût et risque correspond à un effort ou à un risque faible. Le total est la somme des notes multipliées par leurs poids. Pour P4, le calcul donne `5 × 90 % + 4 × 10 % = 4,90`.

**Date de la décision** — 26 novembre 2026 (notes confirmées par le groupe ; choix présenté à l'oral le même jour).

**Idée retenue** — P4, la régression reproductible par commit, proposée par Mohamed Aziz Amiri.

**Justification** — Le bénéfice et l’extensibilité départagent les pistes. P4 relie chaque cas du catalogue à la version exacte du processeur, à son résultat et à son journal XSim. Elle couvre CMP, Shifter, BL et la régression du Lab4. Les autres pistes renforcent des contrôles précis. Le score de P4 en complexité tient compte du script, des fichiers de test et de la configuration Vivado à maintenir.

**Responsabilités proposées** — Aziz maintient le script de rejeu et le tableau des résultats. Haroun vérifie que chaque ID renvoie à la bonne preuve. Mourad reporte le choix et le bilan dans le rapport et la présentation.

**Mesure de réussite** — À partir d’un commit identifié, rejouer la suite et obtenir 32 cas du catalogue traçables et réussis, avec zéro erreur sur les 20 instructions du Lab4. Ce résultat a été observé en simulation Vivado/XSim sur `7ab6fb8`.
