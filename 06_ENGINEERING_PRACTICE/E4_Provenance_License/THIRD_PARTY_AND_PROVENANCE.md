# Third-party and provenance record / Provenance des artefacts (Team01)

Responsable E4 : M. Chrami. Les colonnes « Origine », « Créé par l'équipe ? » et « Modifié ? » sont tirées de
l'historique Git ; les colonnes de droits et d'action reprennent le tableau 7 du rapport final (section 9.3).

| Artefact | Origine | Créé par l'équipe ? | Modifié ? | Statut de redistribution | L'équipe peut-elle le licencier ? | Action requise |
|---|---|---|---|---|---|---|
| HDL baseline Lab 4 (`02_HDL/baseline_lab4/`) | laboratoire 4 du cours GEI1084 (archive `Laboratoire_4.zip`) : base de l'équipe et supports du cours | en partie (supports du cours) | non (conservé tel quel) | à vérifier | selon les droits | séparer la base et les ajouts |
| Modifications CMP (`alu_decoder`, `main_decoder`, `arm_mp1`) | équipe (A. Abib Ahmed, PR #8) | oui | oui | selon les droits | selon les droits | citer la PR |
| HDL Shift (`shifter.vhd`, câblage `datapath.vhd`) | équipe (H. Chaabane, feature/shift ; correctif M. A. Amiri, 647cab6, PR #9) | oui | oui | selon les droits | selon les droits | citer la correction |
| Modifications BL (`arm_mp1`, `datapath`, `extend`) | équipe (M. Chrami, PR #3) | oui | oui | selon les droits | selon les droits | citer la PR |
| Ajouts testbench (`03_TESTBENCH/`) | équipe (branches et PR #9) ; `tb_mp1` dérivé du banc du Lab 4 | oui | oui | selon les sources | selon les droits | référencer les tests |
| Diagrammes (`05_ARCHITECTURE/`) | équipe, dessinés d'après le VHDL ; architecture monocycle de Harris & Harris, ch. 7 | oui (dessins) | oui | vérifier les sources | selon les droits | citer le manuel si repris |
| Code externe éventuel | aucun code externe identifié dans le dépôt | — | — | autorisation requise | à établir | exclure si droits inconnus |
| README / rapport / présentation | équipe (dossier de remise) | voir la déclaration IAg | — | selon les sources | selon les droits | vérifier les attributions |
| Contenu assisté par IA | à déclarer par l'équipe dans `00_README/AI_USE_DECLARATION.md` (le rapport mentionne : correction des textes du rapport, présentation) | — | — | — | — | déclaration IAg |

## Stratégie de diffusion (rapport, section 9.3)

Privilégier un dépôt à accès restreint au groupe et au correcteur si les droits de diffusion sont incertains.
Un sous-ensemble public ne comprend que les éléments dont les droits sont établis. Pour le HDL d'un tiers sans
licence claire, demander une autorisation ou réimplémenter le bloc, puis consigner l'origine et les droits.
Au 25 novembre 2026, le dépôt de l'équipe était public et contenait `Laboratoire_4.zip` : les droits de
diffusion de cette archive restent à vérifier.
