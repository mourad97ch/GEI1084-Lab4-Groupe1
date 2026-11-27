# CMP - C1 à C7

| ID | Objectif | Journal XSim (version intégrée, PR #9) |
|---|---|---|
| C1 | égalité, Z = 1 | `../REGRESSION/aziz_integration/logs/C1.log` |
| C2 | soustraction positive | `../REGRESSION/aziz_integration/logs/C2.log` |
| C3 | soustraction négative | `../REGRESSION/aziz_integration/logs/C3.log` |
| C4 | carry / borrow | `../REGRESSION/aziz_integration/logs/C4.log` |
| C5 | overflow signé (0x80000000 - 1) | `../REGRESSION/aziz_integration/logs/C5.log` |
| C6 | aucun registre écrit | `../REGRESSION/aziz_integration/logs/C6.log` |
| C7 | flags CMP -> instruction conditionnelle | `../REGRESSION/aziz_integration/logs/C7.log` |

- `capture_cmp_c1_c7_zack.png` : console du banc `tb_mp1` (vecteurs CMP C1-C7 PASS, 27 tests, 0 erreur),
  validation CMP de A. Abib Ahmed (commit 8a1298c).
- Programmes et traces attendues : `03_TESTBENCH/instructions/CMP_C*.hex`, `03_TESTBENCH/expected_results/CMP_C*.trace`.
- Vérification indépendante : `../REGRESSION/haroun_integration/` (PR #11).
