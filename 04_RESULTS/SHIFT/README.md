# Shift - S1 à S11

- `hatem_shift/` : exécution Vivado de H. Chaabane. Exécution 1 au commit c5fc234 (S1-S10 PASS, tb_mp1 20/20),
  exécution 2 sur la version intégrée (S1-S11 PASS, tb_mp1 27/27). Captures : `capture_shift_hatem.png` (S5)
  et `capture_shift_hatem_S11.png` (S11). Détails : `hatem_shift/verification.txt`.
- `haroun_shift_review/` : revue indépendante de H. Azzabi (PR #6) au commit c5fc234, dont la reproduction du
  défaut LSR #32 (`tb_lsr32_review.vhd`, `journal_lsr32.txt`).
- Rejeu sur la structure de remise : `../REGRESSION/rejeu_xsim/logs/S1.log` à `S11.log`.
- S11 est un test supplémentaire (cas limite) ; il ne remplace aucun des tests S1-S10 imposés.
