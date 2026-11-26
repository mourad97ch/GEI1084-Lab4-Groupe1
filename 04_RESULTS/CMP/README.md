# CMP - C1 à C7

Les tests CMP ont été exécutés sur la version intégrée ; leurs journaux sont dans les dossiers de régression.

| ID | Objectif | Journal (intégration) | Rejeu sur la structure de remise |
|---|---|---|---|
| C1 | égalité, Z = 1 | `../REGRESSION/aziz_integration/logs/C1.log` | `../REGRESSION/rejeu_xsim/logs/C1.log` |
| C2 | soustraction positive | `../REGRESSION/aziz_integration/logs/C2.log` | `../REGRESSION/rejeu_xsim/logs/C2.log` |
| C3 | soustraction négative | `../REGRESSION/aziz_integration/logs/C3.log` | `../REGRESSION/rejeu_xsim/logs/C3.log` |
| C4 | carry / borrow | `../REGRESSION/aziz_integration/logs/C4.log` | `../REGRESSION/rejeu_xsim/logs/C4.log` |
| C5 | overflow signé (0x80000000 - 1) | `../REGRESSION/aziz_integration/logs/C5.log` | `../REGRESSION/rejeu_xsim/logs/C5.log` |
| C6 | aucun registre écrit | `../REGRESSION/aziz_integration/logs/C6.log` | `../REGRESSION/rejeu_xsim/logs/C6.log` |
| C7 | flags CMP -> instruction conditionnelle | `../REGRESSION/aziz_integration/logs/C7.log` | `../REGRESSION/rejeu_xsim/logs/C7.log` |

Vérification indépendante : `../REGRESSION/haroun_integration/` (PR #11).
Forme d'onde CMP de la version intégrée : **à ajouter** (aucune capture CMP intégrée dans le dépôt).
