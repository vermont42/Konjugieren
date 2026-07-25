# forms.json gate — the 15 remaining misses, categorised

Generated alongside `verbdata/authored/check_forms.py`. Raw per-verb verdicts: `forms-gate.json`.

**1,082 / 1,097 (98.6%) matched**, with `verbdata/authored/corrections.json` overlaid.
**No remaining miss is a sentence defect.** Every one is either the app's one-paradigm-per-verb
limitation, an orthographic variant the app does not generate, or a limit of the matcher itself.

## Fixed: the 4 genuine sentence defects (2026-07-25)

Corrected in `verbdata/authored/corrections.json`, which is overlaid on read rather than edited into
the authored shards, so the raw record of what each model produced stays intact.

| verb | was | now |
|---|---|---|
| `wegschmeißen` | *Wirf … weg* (that is **wegwerfen**) | *Schmeiß … weg*; the English comma splice fixed with a semicolon |
| `hochstellen` | *stellte … ein paar Stufen höher* (**höherstellen**) | *stellte die Heizung … hoch* |
| `heranhalten` | *hielt … nah an die Lampe* (plain *halten* + PP) | *hielt … an die Lampe **heran*** |
| `rechtdrehen` | *dreht … rechts* (the adverb) | *dreht … recht*; settled against kaikki, which attests *dreht recht* |

## Fixed earlier: 2 corpus defects

`zusammen+spinnen` was `fa="w"`, generating the non-word *zusammengespinnt*; now `fa="s" ag="beginnen"`.
`über*kochen` was glossed with the separable homograph's meaning; it now carries both readings.

## Dual-form verb — model used the other valid German form (9)

The app picks one form of a genuinely dual verb; the model picked the other. Both are attested German, so these are not sentence defects. **Josh decided 2026-07-25 that the corpus should carry both forms** (wrinkle 1 in `docs/verb-sources.md`), so these resolve when that model pass lands. `verglimmen` is additionally listed as **deferred** in `verbdata/wiktionary-defects.json`.

- **absaugen** _[5]_ — app conjugates *saugen* strong (*absog*, *abgesogen*); model used weak *saugte*
  > Der Zahnarzt saugte während der Behandlung ständig Speichel ab, damit ich schlucken konnte.
- **einsaugen** _[5]_ — same *saugen* strong/weak split
  > Der trockene Schwamm saugte das verschüttete Wasser innerhalb weniger Sekunden vollständig ein.
- **festsaugen** _[4-8]_ — same *saugen* strong/weak split
  > Der Tintenfisch saugte sich mit all seinen Armen an der Glasscheibe fest.
- **niederhauen** _[5]_ — app has *hauen* weak (*haute*); model used strong *hieb*
  > Der Räuber hieb den Wächter nieder und verschwand mit der Kasse in der Dunkelheit.
- **zusammenhauen** _[5]_ — app has *hauen* weak (*zusammengehaut*); model used *zusammengehauen*
  > Auf dem Heimweg vom Stadtfest wurde er von drei Betrunkenen übel zusammengehauen.
- **voraussenden** _[4-8]_ — app has *sendete*; model used *sandte*
  > Die Expedition sandte zwei Träger voraus, um im Tal ein Lager aufzuschlagen.
- **klieben** _[4-8]_ — app weak (*klieb*, *gekliebt*); model used strong *klob*
  > Der Bauer klob den ganzen Nachmittag Holz für den langen Winter.
- **krauchen** _[5]_ — app maps the participle to *gekrochen*; model used weak *krauchte*
  > Das Kind krauchte auf allen vieren unter den Tisch, um den Ball hervorzuholen.
- **verglimmen** _[5]_ — app has *verglimmte*; model used *verglomm* — the known deferred wrinkle
  > Die letzte Glut im Lagerfeuer verglomm, während über dem See der Morgen dämmerte.

## Clipped colloquial imperative (4)

German allows both *halte* and *halt* in the du-imperative; the app generates only the full form. The sentences are correct everyday German.

- **warmhalten** _[5]_ — *Halt* … warm (app has *halte*)
  > Halt bitte das Essen warm, ich komme erst gegen acht nach Hause.
- **danebenhalten** _[5]_ — *Halt* … daneben
  > Halt das Muster mal daneben, dann sehen wir, ob die beiden Weißtöne zusammenpassen.
- **runterhalten** _[5]_ — *Halt* … runter
  > Halt den Ast kurz runter, damit ich an die oberen Kirschen komme.
- **daherreden** _[5]_ — *Red* … daher (app has *rede*)
  > Red nicht so dummes Zeug daher, du warst doch damals gar nicht dabei!

## Gate matching limitation (2)

The sentence and the corpus are both fine; the matcher cannot see these.

- **aufstreben** _[4-8]_ — *aufstrebenden* — a declined adjectival participle; the harness emits only *aufstrebend*
  > In dem aufstrebenden Viertel eröffnen jede Woche neue Cafés und kleine Galerien.
- **wiederaufleben** _[5]_ — app's particle is the single token *wiederauf*; German writes *lebte … wieder auf* as two words
  > Dank einer neuen Förderung lebte das alte Handwerk in der Kleinstadt langsam wieder auf.
