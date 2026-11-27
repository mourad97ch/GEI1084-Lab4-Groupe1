# Shift - S1 à S11

- `hatem_shift/` : exécution Vivado de H. Chaabane. Exécution 1 au commit c5fc234 (S1-S10 PASS, tb_mp1 20/20),
  exécution 2 sur la version intégrée (S1-S11 PASS, tb_mp1 27/27). Captures : `capture_shift_hatem.png` (S5)
  et `capture_shift_hatem_S11.png` (S11). Résumé : `Resultats_S1_S10.csv`, détails : `verification.txt`.
- `haroun_shift_review/` : revue indépendante de H. Azzabi (PR #6) au commit c5fc234 : avis, résultats,
  capture S10. Les preuves du défaut LSR #32 qu'il a trouvé sont dans `../DEBUG_CASE/`.
- Journaux par test sur la version intégrée : `../REGRESSION/aziz_integration/logs/S1.log` à `S11.log`.
- S11 est un test supplémentaire (cas limite) ; il ne remplace aucun des tests S1-S10 imposés.
