# Comparaison E7 du Groupe 1

Cette synthèse prépare la décision du groupe. La notation et la sélection restent à consigner après validation des cinq fiches individuelles.

| Membre | Sujet | Preuve ou point de départ | État |
|---|---|---|---|
| Mourad Chrami | Vérifier PC et R14 lors d’un BL conditionnel | B6 sur 7ab6fb8, sept cycles sans erreur | PDF préparé, à confirmer comme travail individuel |
| Abdoulrazack Abib Ahmed | Vérifier les effets de CMP | C5 à C7 sur 7ab6fb8 | PDF classé, validation confirmée par Mourad |
| Hatem Chaabane | Tester les encodages limites du Shifter | LSL avec champ nul et S11 pour LSR #32 | PDF classé, validation confirmée par Mourad |
| Haroun Azzabi | Isoler un défaut du Shifter par un banc minimal | PR #6, reproduction du défaut avant correction | PDF reçu et classé |
| Mohamed Aziz Amiri | Reproduire une régression à partir d’un commit | PR #9, 32 cas sans erreur sur 22f2079 | PDF reçu et classé |

La fiche d’Haroun documente le défaut observé avant correction. Après intégration, S11 a vérifié le comportement corrigé sur 7ab6fb8. La piste d’Hatem porte sur la couverture des encodages limites, tandis que celle d’Haroun porte sur la méthode d’isolement du défaut.

## Matrice à remplir ensemble

Noter de 1 à 5, avec 5 pour le résultat le plus favorable. Calculer la moyenne pondérée sur 5.

| Critère | Poids | Mourad | Abdoulrazack | Hatem | Haroun | Aziz |
|---|---:|---|---|---|---|---|
| Pertinence | 20 % | | | | | |
| Bénéfice attendu | 20 % | | | | | |
| Faisabilité | 20 % | | | | | |
| Qualité des preuves | 15 % | | | | | |
| Complexité d’intégration | 10 % | | | | | |
| Coût et risque | 10 % | | | | | |
| Extensibilité | 5 % | | | | | |
| Total pondéré | 100 % | | | | | |

Consigner la date, l’idée retenue, les critères qui ont départagé les pistes, les responsabilités et la mesure de réussite. Reporter ensuite le choix dans le rapport et la présentation.

