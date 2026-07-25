# forms.json gate — the 21 misses, categorised

Generated alongside `verbdata/authored/check_forms.py`. Raw per-verb verdicts: `forms-gate.json`.

**1,076 / 1,097 (98.1%) matched.** Only **4** of the 21 misses are actual sentence defects, so 98.1%
is a floor on authoring quality, not an estimate of it. Read the categories before treating any miss
as an error.

## Genuine sentence defect — the sentence does not demonstrate its verb (4)

These four are real authoring errors and should be corrected or re-authored.

- **wegschmeißen** _[4-8]_ — uses *warf … weg* — that is **wegwerfen**; wegschmeißen wants *schmiss … weg*
  > Wirf die alten Zeitungen bitte nicht weg, ich brauche sie noch zum Basteln.
- **hochstellen** _[4-8]_ — uses *stellte … höher* — that is **höherstellen**; the particle *hoch* never appears
  > Weil ihm kalt war, stellte er die Heizung ein paar Stufen höher.
- **heranhalten** _[4-8]_ — uses *hielt … an* — the particle is **heran**, not *an*
  > Er hielt das Foto ganz nah an die Lampe, um die Gesichter besser zu erkennen.
- **rechtdrehen** _[4-8]_ — uses *dreht … rechts* — the particle is **recht**, not *rechts*
  > Laut Wetterbericht dreht der Wind am Nachmittag rechts und weht dann kräftig aus Westen.

## App corpus defect — the sentence is right, the corpus is wrong (ACTIONABLE) (2)

Both are worth fixing in `Verbs.xml`.

- **zusammenspinnen** _[5]_ — app has `zusammen+spinnen fa="w"`, generating *zusammengespinnt*. Its siblings `sp^i^nnen` and `herum+sp^i^nnen` are `fa="s" ag="beginnen"`. The model's *zusammengesponnen* is correct; the entry should match its siblings
  > Was er sich über seine angebliche Karriere zusammengesponnen hat, glaubt ihm längst niemand mehr.
- **überkochen** _[5]_ — app ships `über*kochen` (inseparable homograph = *overcook*, as the pilot established) but glosses it `tn="boil over"` — the **separable** homograph's meaning. The model wrote a correct separable sentence for the gloss it was handed. Fix is the pilot's own prescription: add a second separable reading via the `übersetzen`/`umgehen` dual machinery, not a flip
  > Wenn du den Deckel auf dem Topf lässt, kocht die Milch garantiert über.

## Dual-form verb — model used the other valid German form (9)

The app picks one form of a genuinely dual verb; the model picked the other. Both are attested German, so these are not sentence defects. `verglimmen` is already listed as **deferred** in `verbdata/wiktionary-defects.json` for exactly this reason.

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
