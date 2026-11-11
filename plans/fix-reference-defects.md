# Plan: Fix the Defects Found While Checking the Browse and Verb Screens

**For:** a fresh Claude Code session, or several. **Kind of work:** corrections to verb data,
second readings for verbs whose senses take different auxiliaries, one fix in the conjugator, two
small fixes in app code, replacement of five example sentences, and corrections to three
documents. **Written:** 2026-11-10. **Revised** the same day, when Josh made the four decisions
below.

## Status (2026-11-10, during the third session)

**Parts 0 to 5 and 7 are done. Part 6's rulings are done: the audit's worklist is empty and `--check` passes. What remains of Part 6 is "Stop the cause" (the importer change) and the review list below; then the plan's Closing.** Read this section before the rest: several
numbers below were true when the plan was written and are not now. The journal entries in
`docs/blog_notes.md` headed "Defect plan, Part N" are the detailed record.

| Part | Commit | What landed |
|---|---|---|
| 0 | `3bc1763` | Baselines reproduced. Roadmap step 9 (tranche 3) held for Part 6. |
| 3 | `abbcfa9` | Shortcut picker ranks the exact infinitive first; search matches every reading's gloss. Done before Part 1, as required. |
| 1 | `90ddaa8` | 38 verbs ruled (the 37, plus zurücktreten): 12 gained a second reading, 21 flipped, 6 re-glossed, 2 kept. `verbdata/auxiliary-rulings.tsv` created. Also fixed `VerbView` keeping the previous verb's reading after a deeplink. |
| 2 | `70b99e3` | Overrides keep their prefix. gelten's group simplified. At-odds 7 → 5. 5c done here too. |
| 4 | `e4f9610` | Eight example sentences replaced (the five, plus three from Part 1). Scan 2: 35 → 29. |
| 5 | `89de103` | Privacy policy and `feature-architecture.md` corrected. The policy waits for Josh to deploy it and set both date lines. |
| 7 | `d49f505` | backen, hauen, salzen mixed on participle-override groups (73 → 76), 18 verbs re-encoded. krauchen weak. abhauen to sein. Seven entries added to `wiktionary-defects.json`; at-odds held at 5. Scan 2: 29 → 27. |
| after 7 | `fb1f60b` | Ablaut article drops its stale counts ("sixty-six patterns", geben's "nineteen"). |
| after 7 | `6da7c1d` | Eight groups that were in `AblautGroups.xml` but never in the Families tab now listed and described; geben's description corrected. Two `BrowseableFamilyTests` keep the list and the XML in step. |
| after 7 | `29d2695` | anhängen split into weak "attach, append" and strong "adhere to, be devoted to". A Part 6 ruling, made early. |
| 6 (step 1, fahren) | `5120262` | `verbdata/audit_auxiliaries.py` with `--check` and `--unruled`; the prototype removed. fahren's 15 listed derivatives ruled (8 two readings, 6 flips, 1 keep), plus umfahren by hand. |
| 6 (ziehen) | `adaf738` | 14 listed ziehen derivatives plus zuziehen by hand: durchziehen the first verb with three readings, 7 more with two, 1 flip, 2 re-glosses, 4 keeps. zuziehen's and durchziehen's etymologies rewritten. |
| 6 (treten) | `18b6880` | 5 listed treten derivatives: 3 two readings (übertreten split by separability), 1 flip, 1 re-gloss. No question for Josh; review found nothing. |
| 6 (brechen) | `f4f6fef` | 12 listed brechen derivatives: durchbrechen three readings, 4 more with two (aufbrechen now leads with "set off"), 4 flips, umbrechen re-glossed and kept, 2 keeps. Two etymologies corrected. |
| 6 (treiben) | `fa78a79` | 9 listed treiben derivatives, the first batch run under the away-mode prompt: 3 two readings (a "drift" sense with sein beside "drive"), 1 re-gloss, 4 keeps, zertreiben deferred for want of any source. Two etymologies corrected. Review found nothing. |
| 6 (laufen) | `412a1f9` | 8 listed laufen derivatives: durchlaufen and umlaufen three readings each, 3 more with two (unterlaufen's "a mistake slips in" with sein), 2 flips to sein with re-gloss, 1 keep. durchlaufen's verb-level `in` made inseparable. umlaufen's etymology rewritten. One review finding, adjudicated and not applied. |
| 6 (schießen, streben) | `8903915` | 7 schießen and 7 streben derivatives in one batch: einschießen two readings, zustreben and emporstreben to sein, 2 re-glosses, 9 keeps, two of them deferred (überschießen, zusammenstreben). Several keeps rest on the labelled-sense defaults. Review found nothing. |
| 6 (brennen, schlagen, wachsen) | `2ba0cc0` | 13 verbs: durchschlagen and überschlagen three readings, abbrennen and ausschlagen two, anbrennen, entbrennen, durchbrennen to sein, 6 keeps. Two etymologies corrected. Three review findings adjudicated: two glosses narrowed, one kept. |
| 6 (step 5, stehen and liegen) | `623c518` | 39 verbs: erstehen and unterliegen gain a sein reading, umeinanderstehen re-glossed and deferred, 36 keeps, most of them regional variation. erstehen's etymology corrected. Review found nothing. |
| 6 (small families 1) | `48ca069` | 31 verbs: 6 gain a second reading (überspringen by separability), 7 flip, among them abschieben to haben and ausscheiden's first reading to sein, 18 keeps, two of them deferred. Review found nothing. |
| 6 (small families 2) | see journal | The last 50 verbs: 18 gain a second reading (durchdringen inseparable first), 6 flip, 4 re-glosses, 22 keeps, two of them deferred. durchdringen's etymology boilerplate removed. One review finding, rejected by Fable. |

**Where Part 6 stands.**

- **The worklist is empty.** `python3 verbdata/audit_auxiliaries.py --check` passes: 252 verbs
  ruled, 0 awaiting a ruling, 0 other problems. Any later edit to a ruled reading must keep it
  passing. The next Part 6 work is "Stop the cause", which the away-mode prompt excluded.
- **The rulings file has 332 readings of 252 verbs**, and 118 verbs have more than one reading,
  6 of them three (durchziehen, durchbrechen, durchlaufen, umlaufen, durchschlagen, überschlagen). Suite: 224 tests.
- **Josh's rulings of 2026-11-10, in the fahren batch**, which later batches should follow:
  - **A domain label qualified by *häufig* does not fail criterion 2** (hochfahren, "boot up",
    *häufig Technik*). This narrows the anspringen precedent but does not overturn it: a plain
    "Technik" or "salopp" label (anspringen, durchdrehen, abhauen) is still unruled. Ask.
  - **A separable homograph whose own auxiliary splits gets one reading, not two** (überfahren:
    separable "cross (by boat), ferry across" with sein, parallel to übersetzen; the transitive
    haben use is left unmodelled). Ask if a case looks different.
  - **A separability split the audit cannot see may be added by hand** (umfahren, "knock over",
    both readings haben). It was approved for umfahren only. Raise similar finds with Josh rather
    than sweeping for them. zuziehen (a wrong auxiliary kaikki could not flag) was the second.
  - **A third reading is allowed when DWDS gives three verbs under one spelling** (durchziehen:
    separable with haben and with sein, inseparable with haben). Approved for durchziehen and
    durchbrechen; ask again for any other verb, as the plan says.
  - **A labelled primary sense keeps its single reading** (umbrechen, typesetting, labelled in
    both dictionaries). Josh kept it as shipped rather than add an unlabelled second reading.
- **Derivatives do not always sit on their base's ablaut group.** brechen's are on sprechen's.
  Carry each verb's own `fa` and `ag` into a new reading rather than assuming the base's.
- **An etymology whose closing paragraph describes "this reading" can go stale when a reading
  is added** (zuziehen, durchziehen). Check the verb's entry in `Etymologies.json` after ruling it.
- **Batch method that worked for fahren:** two web-fetch agents on DWDS (Wiktionary as fallback),
  rule, edit `Verbs.xml` with anchored replacements, then a review shard in the multi-reading
  format holding every touched reading, including single-reading flips, with the base's other
  derivatives' glosses supplied beside it to catch cross-verb collisions. Sonnet reviews, Fable
  adjudicates. A reading with its own `in` deserves a pinned participle and Imperativ test (see
  `separabilityHomographReadings`), because the parameterized test asserts only the auxiliary.

**Calls made without Josh, confirmed.** Filled by the session run under the away-mode prompt at
the end of this plan: one line per verb, giving the call made, the alternative, and why. **Josh
confirmed every entry below on 2026-11-10, reversing none.** They are settled rulings now, and a
later session should not reopen them. The "worth a second look" and "see the review list" notes
in `verbdata/auxiliary-rulings.tsv` point here and are settled by the same confirmation.

- **zertreiben** (treiben): kept haben and recorded as deferred, under the missing-sources
  default. DWDS has no entry, and Wiktionary and Duden return 404. Alternative: none until a
  source is found. The example sentence is transitive, which haben fits.
- **antreiben** (treiben): kept single. DWDS gives sein only for a bullet under sense 4,
  *herantreiben* (*der Kahn treibt an*, drift ashore). Alternative: a second reading "drift
  ashore" with sein. Judged marginal, a sub-sense of a sub-sense.
- **abtreiben** (treiben): two readings, with the abortion sense kept first as "abort (a
  pregnancy), drive off" and "drift off course" with sein second. "drive off" joins the gloss
  because the Luther sentence uses it. Alternatives: lead with "drive off", or keep the shipped
  "have an abortion" and leave the sentence's sense unglossed. The reviewer remarked, without a
  finding, that the comma joins two senses; zuziehen's "pull shut, incur (an illness)" is the
  precedent.
- **eintreiben** (treiben): re-glossed "drive in, collect (debts)", beyond the auxiliary
  question, because collecting debts is the commonest modern sense and the etymology names it.
  Alternative: keep "drive in", which the Luther sentence illustrates.
- **durchlaufen** (laufen): three readings under the durchziehen-shape default, with the
  inseparable "go through, traverse" first and the verb's own `in` changed to `durch*l^au^fen`,
  because it is the commonest sense and the Kafka sentence (*K. durchlief beide Seitenschiffe*)
  uses it. The verb had shipped separable with the inseparable sense's gloss. Alternative: keep
  the separable verb first, as durchziehen and durchbrechen do.
- **umlaufen** (laufen): three readings under the same default: separable "circulate, go
  around" (sein), inseparable "circle, run around (something)" (haben), and separable "knock
  over (by running)" (haben). Alternative: two readings, dropping "knock over", which DWDS lists
  first and unlabelled but which is rare on a verb ranked 2,655.
- **ablaufen** (laufen): added "wear down (shoes)" with haben, DWDS sense 8, unlabelled.
  Alternative: keep single, as a minor sense beside "expire". Separately, the review proposed
  replacing the shipped "expire, proceed" because the comma joins two senses, and Fable amended it
  to "go, proceed (of events)" to keep the Grimm sentence covered. Not applied, because the
  amendment drops expiry, the commonest sense. Alternative: apply it, or replace the sentence with
  an expiry one and accept "expire, run out".
- **einlaufen** (laufen): re-glossed reading 0 from "run in" to "come in, arrive", because
  British "run in" is the haben sense of breaking in an engine. Shrinking in the wash (sein) is
  not in either gloss. Alternative: "come in, shrink".
- **aufschießen** (schießen): kept the shipped "shoot open" (haben) under the labelled-primary
  default, although DWDS lacks that sense entirely and its main sense, "shoot up, spring up" (*die
  Pilze sind aufgeschossen*), takes sein unlabelled. kaikki labels "shoot open" colloquial, and
  the authored example sentence uses it. Alternative: add "shoot up, spring up" with sein as the
  first reading. This is the call in this batch most worth reversing.
- **vorschießen** (schießen): kept single and re-glossed "advance (money)". DWDS's group label
  *umgangssprachlich* covers both the money sense and "dash forward" (sein), so the sein sense
  fails criterion 2. Alternative: a second reading "dash forward".
- **losschießen** (schießen): kept single "open fire". "Dash off" (sein) is labelled
  *umgangssprachlich* in DWDS. Alternative: a second reading.
- **niederschießen** (schießen): kept single. Wiktionary's "swoop down" (sein) is unlabelled,
  but DWDS gives it no definition, and the verb is rare. Alternative: a second reading.
- **überschießen** (schießen): kept and deferred under the missing-sources default. DWDS gives
  "ist übergeschossen" only for boiling over (*landschaftlich*) and overshooting, and no source
  covers the shipped "shoot something over something". The football example sentence (*schoss er
  weit über*) is intransitive, so the gloss deserves a look whatever the auxiliary.
- **zusammenstreben** (streben): kept and deferred. No source has an entry.
- **auseinanderstreben** (streben): kept single "diverge" (Duden: hat). Duden's "move apart"
  takes ist and is unlabelled, and was ruled marginal for a verb this rare. Alternative: a second
  reading.
- **durchschlagen** (schlagen): three readings under the durchziehen-shape default:
  "fight one's way through, get by" (haben), "come through, take effect" (sein), and inseparable
  "pierce, penetrate" (haben). The Bundestag example sentence illustrates the sein reading but its
  speaker said *hat durchgeschlagen*. Alternative: two readings, dropping the inseparable verb.
- **überschlagen** (schlagen): three readings under the same default, inseparable "estimate
  roughly" first, then separable "spill over, jump across" (sein) and "cross (one's legs)"
  (haben). Alternative: keep the single inseparable reading; the separable haben sense lives
  mostly in the participle (*mit übergeschlagenen Beinen*).
- **ausschlagen** (schlagen): added "turn out (well or badly)" with sein, DWDS sense 11, labelled
  *gehoben*, under the gehoben precedent. Alternative: keep single. Fable kept the gloss against
  a proposed "swing, deflect", since the pendulum sense takes either auxiliary.
- **anbrennen** (brennen): flipped to sein and kept single. DWDS's transitive "light (a candle)"
  takes haben and is unlabelled, but anzünden is the usual verb. Alternative: a second reading.
- **wachsen** (wachsen): kept single "grow". The homograph "wax (skis)" is weak and takes haben,
  the anhängen shape. Alternative: add it as a weak second reading.
- **erstehen** (stehen): added "arise, rise again" with sein (DWDS ¹erstehen, *gehoben*) beside
  "buy, acquire" (²erstehen, *umgangssprachlich*), as plan step 5 names it. Both senses are
  labelled, so neither the gehoben precedent nor the labelled-primary default settles it alone.
  Alternative: keep the single "buy" reading under the umbrechen default.
- **abstehen** (stehen): kept single. DWDS 2, *von etw. abstehen* (desist), takes sein and is
  *gehoben*, so it passes criterion 2, but was ruled too rare for criterion 3. Alternative: a
  second reading.
- **umeinanderstehen** (stehen): re-glossed from the cross-reference "synonym of herumstehen" to
  "stand around", and kept haben as deferred. DWDS returns 404, and no other source was tried.
- **anstehen**, **dafürstehen** (stehen): kept, but each example sentence illustrates something
  other than the gloss. anstehen's (*weil sie mir nicht ganz anstand*) is "befit", and
  dafürstehen's (*Die Linke steht auch dafür*) is "für etwas stehen" written apart. Both are
  example-pipeline questions, not auxiliary ones.
- **bekommen** (small families): kept single, as the July pass did, although DWDS II *jmdm.
  bekommt etw. gut* (*wie ist dir der Abend bekommen?*) takes sein and is unlabelled.
  Alternative: a second reading "agree with (of food)".
- **übersteigen** (small families): kept the inseparable "exceed" alone. Separable *übersteigen*
  (*ist übergestiegen*, climb over) is unlabelled but rare. Alternative: a second reading.
- **nachschieben** (small families): flipped to haben with its gloss kept. Its Bundestag sentence
  (*hat sie nachgeschoben*) is the labelled sense "add afterwards". Alternative: re-gloss it.
- **hinrücken**, **rückdrehen** (small families): kept and deferred for want of a source.
- **Family splits not made** (small families): schleifen (strong "grind" beside weak "drag"),
  bleichen and ausbleichen (weak "bleach" beside strong "fade", *ist geblichen*), schwellen and
  aufschwellen (strong "swell" beside weak "make swell"). Each is the anhängen shape, which the
  away-mode defaults do not cover, so each was kept single. bleichen lost "fade" from its gloss,
  and ausbleichen flipped to haben to match its weak family and transitive sentence. Alternative:
  add the other verb as a reading with its own family, as anhängen did.
- **entzweireißen** (small families): two readings, "rip in two (something)" with haben and "tear
  in two (come apart)" with sein, departing from entzweibrechen's single sein reading, because
  Wiktionary and the verb's etymology treat the transitive use as ordinary. Alternative: follow
  entzweibrechen.
- **durchdringen** (small families): the inseparable "penetrate, permeate" (haben) now leads and
  the verb's own `in` is inseparable, as with durchlaufen; separable "get through, prevail" (sein)
  follows. Alternative: separable first, as shipped.
- **durchschwimmen**, **durchfließen** (small families): kept single. durchschwimmen's
  separable sense is labelled *umgangssprachlich* (labelled-primary default), and DWDS lists
  durchfließen only as the inseparable verb, so the shipped separable one is deferred.
  Alternative: a second, inseparable reading for each.
- **ausreißen**, **verrauchen** (small families): kept single, each with an unlabelled but minor
  second sense (*der Griff ist ausgerissen*, sein; *Zigaretten verrauchen*, haben).
- **mitfolgen** (small families): kept and deferred. No source has an entry.

**State to start Part 6 from (end of the second session; partly superseded above).**

- **The counts have moved.** The audit prototype reports 89 agreeing and 142 needing a ruling
  (rerun at the end of the second session, unchanged by Part 7). The prototype skips every verb
  with two readings, so the 12 verbs that gained one in Part 1 left its rows; the Part 1
  re-glosses moved a few more between verdicts. zurücktreten and abhauen are ruled and still
  listed, because the prototype does not read the rulings file. Take Part 6's scope from a fresh
  run, minus the verbs already in the rulings file. The `--check` mode Part 6 asks for is what
  removes that bookkeeping.
- **57 verbs have two readings** (44 before Part 1, 56 after it; anhängen is the 57th). The
  suite is 224 tests in 33 suites, and the ablaut inventory is 76 groups. The at-odds count is 5
  (helfen, schaffen, vergleichen, verstoßen, zusammenspinnen).
- **The rulings file has 53 readings of 40 verbs.** Its columns are `verb, reading, gloss, auxiliary, in,
  outcome, source, date, note`. Outcomes used: `two readings`, `flip`, `flip and re-gloss`,
  `re-gloss`, `keep`. Each new row goes into the file *and* into
  `ConjugatorTests.auxiliaryRulings`, the table behind the parameterized `ruledAuxiliary` test.
  That table is `nonisolated` because the `@Test(arguments:)` macro evaluates it off the main
  actor.
- **Part 6 gained two verbs:** übergehen (step 6) and schaffen (step 6a, a missing "create"
  reading with a different family).
- **Part 7 ruled one of Part 6's verbs:** abhauen, flipped to sein (row 51 of the rulings file).
  The hauen derivatives are now mixed, on the hauen group, so a second reading for any of them
  keeps `fa="m" ag="hauen"`. festbacken's auxiliary (DWDS: hat/ist) was left for Part 6. The
  same holds for the backen and salzen derivatives: aufbacken, festbacken, nachbacken,
  nachsalzen, and versalzen are mixed, on their base's group.
- **anhängen was ruled after Part 7 (rows 52 and 53)**, and it sets two precedents Part 6 will
  meet again:
  - **A split by family is a ruling like a split by auxiliary.** Both anhängen readings take
    haben, so the rulings rows carry the reason in the note. This is step 6a's shape (schaffen)
    and hängen's. Expect more among the derivatives of hängen and of other verbs that are two
    verbs spelled alike. The audit script cannot find these, because it compares auxiliaries.
    anhängen surfaced only when the hängen group's members became visible in the Families tab.
  - **A sense DWDS labels *gehoben* passes criterion 2.** The criterion's exclusions are
    archaic, dated, regional, colloquial, and technical, and anbrechen (Part 1) had already
    treated *gehoben* as standard. Josh has not ruled on this either way, so name it when it
    recurs. The criterion-2 refusals for labelled senses (anspringen "Technik", durchdrehen and
    abhauen "salopp") still await his ruling, so ask before extending them.
- **A verb whose readings differ in family shows `shippedEncodingFailed` in the classifier.**
  The classifier tests only the first reading, against a kaikki table that may describe only one
  of the two verbs. The at-odds summary excludes multi-reading verbs for that reason, so the
  count does not move. Do not read the flag as a defect on such a verb.
- **Each new group needs an `AblautGroupInfo.exemplars` entry and a catalog description**, or
  `everyAblautGroupIsListedAndDescribed` fails. A group used only by a second reading would also
  fail `everyListedAblautGroupHasAVerb`, because the tab counts verbs by their first reading.

**Method that worked in Part 1, worth repeating.**

- **Evidence.** Four web-fetch agents in parallel, about nine verbs each, fetching
  `https://www.dwds.de/wb/<verb>`, told to quote each sense's "Perfektbildung mit Hilfsverb …"
  line verbatim and its usage labels, falling back to `https://de.wiktionary.org/wiki/<verb>` where
  DWDS states no per-sense auxiliary. DWDS often gives only "ist/hat" in the header; that alone
  does not settle a sense.
- **Glosses.** Write the pair while ruling. Then build a shard in `prompts/gloss_review.md`'s
  multi-reading format and review it on a different model from the author (Sonnet was used),
  then adjudicate the findings under `prompts/gloss_adjudication.md` on a third (Fable was used).
  The audit script itself is a useful ambiguity check: ausreiten's "ride out" matched kaikki's
  haben sense, because English uses it for exercising a horse.
- **The bar for a second reading.** "A learner who knows the other sense from elsewhere would be
  misled by a single reading" (anfahren: er hat den Fußgänger angefahren). Taken literally,
  criterion 3 admits nearly every DWDS sense, so judgment is unavoidable. Record it in the note.
- **Criterion 2 was applied as written:** a shipped sense that DWDS labels "Technik" or "salopp"
  (anspringen, durchdrehen) could not carry a second reading. Josh has not yet ruled on whether
  that is too strict, so ask before extending the precedent.
- **Simulator check.** Deeplinks open a verb directly: `xcrun simctl openurl booted
  "konjugieren://verb/<verb>"`, then read the `describe_ui.sh` output for `"er (ist|hat) …"`, and
  `tap_label.sh "<second gloss>"` to switch readings.

**State to start Part 7 from.**

- **Part 2 is done**, so a derivative now shares its base's override group: ab + gehauen, and
  ver + hauen with the ge- removed (`takesGe` decides). `overridesBehindEachKindOfPrefix` in
  `ConjugatorTests` shows how to test a prefix path no shipping verb reaches.
- **Do not take expected values from kaikki's tables without checking.** English Wiktionary
  auto-generates weak tables for pages with no strong template. kaikki gave entgelten
  "entgeltete", which is the defect `verbdata/wiktionary-defects.json` records. German
  Wiktionary's Flexion page is the arbiter.
- **Scan 2 will tell you whether Part 7 worked, but only in part.** zusammenhauen
  ("zusammengehauen") and krauchen ("krauchte") are among its 29 misses, and both should leave the
  list: the first by the new participle, and the second if krauchen is ruled weak. hauen and
  niederhauen will stay. Their sentences use the strong Präteritum *hieb*, and the mixed family
  gives *haute*, so they belong to the dual-paradigm gap, not to this fix.
- **The new ablaut-group count** must be updated in the four cache files that
  `scripts/check_docs.py` names; it is 73 today.

## Goal

Make the reference say only true things. Every defect found during the research behind
[`docs/browse-and-verb-ideas.md`](../docs/browse-and-verb-ideas.md) is to be fixed, or ruled on
and recorded, before any idea in that document is built.

## Why This Comes First

People open the app to look a verb up, and one of the questions they bring is "haben or sein?".
The shipping app answers it wrongly for common verbs. All of the following were read off the
verb page in the simulator on 2026-11-10, on the current `main`:

| Verb | Frequency rank | The page says | German says |
|---|---:|---|---|
| stattfinden | 182 | er ist stattgefunden | er hat stattgefunden |
| reisen | 413 | er hat gereist | er ist gereist |
| bedürfen | 542 | ich darf, du darfst, er darf | ich bedarf, du bedarfst, er bedarf |
| backen | 560 | gebackt | gebacken |
| entgehen | 806 | er hat entgangen | er ist entgangen |
| nachgehen | 1,031 | er hat nachgegangen | er ist nachgegangen |
| umziehen, "move" | 1,098 | er hat umgezogen | er ist umgezogen |
| zurücktreten, "step back" | 1,108 | er hat zurückgetreten | er ist zurückgetreten |
| aufstehen, "get up" | 1,112 | er hat aufgestanden | er ist aufgestanden |
| abfahren, "depart, leave" | 1,436 | er hat abgefahren | er ist abgefahren |

A learner who catches one of these has reason to doubt every table in the app.

## What Has Changed Since the Ideas Document

The ideas document lists five defects. Preparing this plan widened the first of them a great
deal. Every shipped auxiliary was compared with the kaikki snapshot in `verbdata/`, using the
script beside this plan, `fix-reference-defects-audit.py`, since promoted to [`verbdata/audit_auxiliaries.py`](../verbdata/audit_auxiliaries.py). Its
counts on 2026-11-10:

| Verdict | Verbs | Meaning |
|---|---:|---|
| Contradicts, at the level of the verb | 6 | kaikki names one auxiliary and the app ships the other |
| Contradicts, at the level of the sense | 31 | The kaikki sense that matches the shipped gloss carries an auxiliary note, and the note names the other auxiliary |
| Agrees | 71 | The matching sense's note, or its transitive or reflexive tag, names the shipped auxiliary |
| Needs a ruling | 141 | kaikki marks the verb as taking both, and no sense matched or the matching sense carries no note |
| Regional | 3 | liegen, sitzen, stehen. Handled by the Region setting and not part of this plan. |

So 37 verbs are contradicted outright and 141 more cannot be settled from kaikki alone. From a
reading of the 141, a good share of them are wrong in the same way as the 37 (weiterfahren,
fortfahren "drive away", vorfahren, zusammenstoßen "collide", zurücktreten). That is a reading
and not a count.

Two more findings came out of the same preparation:

- **backen ships the Perfektpartizip gebackt**, confirmed in the simulator. This is the same
  class as hauen and gehaut, and the roadmap knows the class as "wrinkle 4" without naming either
  verb.
- **The cause of the lost prefixes is one mechanism**, described in Part 2, and it affects
  exactly three verbs today.

## Decisions

All four were made by Josh on 2026-11-10.

| # | Decision | Answer |
|---:|---|---|
| 1 | When a verb's two senses take different auxiliaries, should this work add a second `<reading>`, or only make the one shipped reading true? | **Add the second reading**, wherever both senses are current German. A verb that is only made true can still mislead: a learner who finds umziehen with sein alone may write ich bin mich umgezogen. The section "Second Readings" below says when a second reading is warranted and how to write one. |
| 2 | How should a verb with a weak Präteritum and a strong Perfektpartizip be expressed (backen, hauen)? The roadmap offers "a new family or a full-override ablaut group". | **The ablaut group.** Part 2 makes it workable for prefixed derivatives, and Part 7 says what it involves. |
| 3 | What should the privacy policy say about the signals it omits? | **Correct it so that it describes the signals the app sends.** The session edits the text in the repository, and Josh deploys it. See Part 5. |
| 4 | Should the fixes ship in a release of their own? | **No. One release, together with other work, and not soon.** Josh cannot cut a release from his present MacBook and plans to replace it in 2027. The same holds for Conjuguer and Conjugar, and `CLAUDE.md` records the constraint. |

**What decision 4 means for this work.**

- The corrections accumulate on `main`. People using version 1.4 go on seeing the errors until
  the next release, and nothing in this plan can change that.
- No part has to be kept small enough to ship alone. The order of the parts stays as it is, for
  a different reason: Part 1 sets the pattern that Part 6 repeats 200 times.
- The privacy policy is the exception. Its corrected text describes version 1.4 as it ships
  today, so it can be deployed as soon as it is written.
- Other work will land on `main` before the release, and the import of tranche 3 is the one that
  matters here: it would repeat the cause of Part 1. Part 0 records that in the roadmap.
- Do not draft release notes. [`docs/release_notes.txt`](../docs/release_notes.txt) holds
  published text, and the next release will cover more than this plan. The journal entries are
  the record the notes will be written from, so each should state plainly what a user would see
  changed.

## Read First

1. [`docs/browse-and-verb-ideas.md`](../docs/browse-and-verb-ideas.md), the section "Defects
   Found Along the Way" and the appendix.
2. [`prompts/dual_auxiliary.md`](../prompts/dual_auxiliary.md): "Status", "It is not really an
   auxiliary problem", "The model", and "Interim policy". It defines the `<reading>` model and
   records that the classification pipeline cannot check an auxiliary at all.
3. [`docs/roadmap.md`](../docs/roadmap.md): "Still open" and "Known gaps that are nobody's step
   yet".
4. [`docs/verb-classification.md`](../docs/verb-classification.md): how to run the pipeline, and
   what "at odds with Wiktionary" means.
5. [`docs/adding-verbs.md`](../docs/adding-verbs.md): the XML format, the `^` region convention,
   and the `*` suffix that makes an ablaut entry a full override.
6. [`docs/verb-sources.md`](../docs/verb-sources.md), wrinkles 1 and 4.
7. `CLAUDE.md` on the three ways a test run reports success while doing nothing, and
   [`KonjugierenTests/CLAUDE.md`](../KonjugierenTests/CLAUDE.md) on the mixed-case convention.
8. For Part 4 only: [`docs/example-sentence-pipeline.md`](../docs/example-sentence-pipeline.md),
   [`prompts/uses_etymologies.md`](../prompts/uses_etymologies.md), and the `integrate` skill.

## Ground Rules

- **Evidence before edits.** Every change to a verb cites a source outside the app. kaikki is
  the first source and is sometimes wrong, which is why `verbdata/wiktionary-defects.json`
  exists. German Wiktionary is edited independently and is this repository's arbiter. Duden and
  DWDS state the auxiliary sense by sense ("Perfektbildung mit hat" or "mit ist") and are the
  best sources for Parts 1 and 6.
- **Never take an expected value from the conjugator's output.** `prompts/dual_auxiliary.md`
  explains how that launders a defect into a pinned test.
- **`Verbs.xml` is edited as text**, with anchored replacements that are asserted to match
  exactly once. Do not parse and rewrite it. `git diff --stat` should show only the lines that
  were meant to change. The build validates the file against its DTD.
- **The classification pipeline does not see auxiliaries.** Its at-odds count is a regression
  check for Parts 2 and 7 and says nothing about Parts 1 and 6. Tests are the only guard there.
- **Read the current gloss from `Verbs.xml`.** The glosses in
  `verbdata/tranche2-dual-auxiliary.txt` are the glosses at import, and 220 glosses have been
  corrected since.
- **Commit to `main`, one commit per part.** No branches. Append a journal entry to
  `docs/blog_notes.md` as each part lands.
- **The simulator on this Mac is set to the Swiss variety**, so ß displays as ss. The Region
  setting changes the auxiliary only for liegen, sitzen, and stehen.
- **Adding tests changes the test counts** that `scripts/check_docs.py` asserts in the cache
  files. Run it after each part and update the counts it names.

## Second Readings

This section governs Parts 1 and 6. The model is the one `prompts/dual_auxiliary.md` defines and
44 verbs already use:

```xml
<verb in="um+z^ieh^en" ...>
  <reading tn="move (house)" fa="s" ag="ziehen" ay="s" />
  <reading tn="change clothes" fa="s" ag="ziehen" />
</verb>
```

The glosses in that sketch are illustrations. Write the real ones from the dictionary.

**When a second reading is warranted.** All three must hold:

1. The verb has two senses that differ in auxiliary, or in family, or in the separability of the
   prefix.
2. Both senses are current standard German. A dictionary that marks a sense as archaic, dated,
   regional, colloquial, or technical is saying that it is not.
3. Both are senses a learner would meet. A sense that Duden or DWDS lists among the verb's main
   senses qualifies.

**When the verb stays single.** Three kinds, and the rulings file must say which applies, so
that a later session does not reopen the question:

- **No split in meaning.** kaikki marks some verbs as taking both auxiliaries although ordinary
  usage has one. The July pass left anfangen, anstreben, auftauchen, bekommen, belaufen, streben,
  vorliegen, and wandern single for this reason.
- **Regional variation.** Derivatives of stehen, sitzen, and liegen take haben in the German
  standard and sein in the south, for the same meaning. That is the Region setting's subject and
  not a reading. See Part 6, step 4.
- **A marginal second sense.** aufstehen's haben sense is the colloquial "stand open". It does
  not earn equal billing with "get up".

**How many readings.** Split by auxiliary, family, or prefix, and not by sense. Senses that share
all three share a reading and a gloss, as anziehen's first reading does with "attract, dress".
ausziehen has three senses and wants two readings: moving out, which takes sein, and taking off
or pulling out, which take haben. No verb has shipped with three readings. If one seems to need
three, stop and ask Josh.

**Which reading comes first.** The first reading is primary. It supplies the gloss in the verb
list and is what the quiz and the widget use. Choose the more common sense. For a causative pair
that is usually the transitive reading with haben, and for a verb of motion the intransitive
reading with sein, as the interim policy in `prompts/dual_auxiliary.md` says. When that does not
settle it, prefer the sense that the verb's example sentence uses.

**The glosses.** The two glosses must tell the readings apart without grammatical labels, as the
shipped pairs do: "drive (a vehicle)" beside "travel, go", and "break off, cancel" beside "break
off, snap (come apart)". Three lessons from the July audit, recorded at the top of
[`prompts/multi_reading_glosses.md`](../prompts/multi_reading_glosses.md), apply directly:

- Review each pair together. The defect that audit found was a swap, with each reading carrying
  the other's meaning, and a reviewer who reads one gloss at a time cannot see that.
- Separability belongs to the reading. übersetzen is `über*setzen` in one reading and
  `über+setzen` in the other, and a reading's `in` must strip to the same infinitive as its
  verb's.
- Use a dictionary that gives the paradigm sense by sense. DWDS does. A concordance that pools a
  verb's readings cannot say which sense takes which auxiliary.

Write the second reading while the verb is being ruled on, when both senses are already open in
the dictionary. Then put every new pair through the review in
[`prompts/gloss_review.md`](../prompts/gloss_review.md), and through the second opinion in
[`prompts/gloss_adjudication.md`](../prompts/gloss_adjudication.md), in batches. That audit found
6 defects in 88 glosses of verbs like these, so the review is not optional.

**What does not change.** The frequency, the icon, the etymology, and the example sentence
belong to the verb and not to the reading. Note in the rulings file which reading the example
sentence illustrates. Do not replace a sentence only because it illustrates the second reading.

## Part 0: Baselines and Tools

1. Run the whole test suite and record the count.
2. Run the classification pipeline as `docs/verb-classification.md` describes, and record the
   number of shipping verbs at odds with Wiktionary. The last recorded summary says 7.
3. Run `python3 scripts/check_docs.py`.
4. Run `python3 plans/fix-reference-defects-audit.py` with its output sent to a scratch file,
   and confirm the counts in the table above. If they differ, the corpus or the snapshot has
   changed, and the new numbers are the ones to work from.
5. Regenerate `corpus/working/forms.json`. The copy on disk dates from 2026-07-25. Use the
   struct name in the filter:

   ```bash
   TEST_RUNNER_KONJUGIEREN_FORMS_OUT="$PWD/corpus/working/forms.json" \
   xcodebuild -project Konjugieren.xcodeproj -scheme Konjugieren \
     -destination 'platform=iOS Simulator,name=iPhone 17' -parallel-testing-enabled NO test \
     -only-testing:KonjugierenTests/CorpusFormsDumpTests
   ```

   Confirm that the file's modification time changed. The run command printed in the header of
   `CorpusFormsDumpTests.swift` uses the suite's display name, `CorpusFormsDump`, which by the
   rule in `CLAUDE.md` matches nothing and still reports success. Part 5 corrects that comment.
6. Run the two scans in the appendix and keep their output. They are the before picture for
   Parts 2 and 4.
7. Add a line to step 9 of the sequence in `docs/roadmap.md`: tranche 3 waits for the change to
   the importer in Part 6 of this plan. Without it, an import run in the months before the
   release would write mismatched auxiliaries and glosses into new verbs.

## Part 1: Auxiliaries That kaikki Contradicts Outright

**What is wrong.** 37 verbs, listed by the audit script with the verdict `CONTRADICTS`. The six
at the level of the verb:

| Verb | Rank | Ships | Gloss | Note |
|---|---:|---|---|---|
| stattfinden | 182 | sein | take place | Wrong in the simulator. In the corpus since commit `f3ae3ad`. |
| angehen | 385 | haben | concern, approach | Needs a ruling. Usage differs by sense and by region. |
| reisen | 413 | haben | travel | Wrong in the simulator. In the corpus since commit `f3ae3ad`. |
| entgehen | 806 | haben | escape, elude | Wrong in the simulator. In the corpus since commit `f3ae3ad`. |
| nachgehen | 1,031 | haben | follow, pursue | Wrong in the simulator. |
| zerschellen | 2,399 | sein | be dashed to pieces | Probably right as shipped, and kaikki wrong. Needs a ruling. |

The 31 at the level of the sense, in order of frequency: umziehen, aufstehen, schmelzen,
ausziehen, anfahren, abbiegen, abfahren, zerreißen, verstreichen, ausrücken, umkehren, einbiegen,
anbrechen, wegfahren, anspringen, herziehen, durchdrehen, herumfahren, abfliegen, ausbrennen,
triefen, stieben, ausreiten, abstreichen, durchklingen, wegtreten, ausschleichen, durchkriechen,
zureiten, aufrauchen, verstinken. All ship haben except abstreichen, which ships sein with the
gloss "wipe off, scrape off".

**Cause.** Three of the six date from the hand-entered batch of verbs 601 to 1,000. For the 31,
the tranche-2 importer took the first auxiliary that kaikki lists for the verb and, separately,
a gloss from one of its senses. The file it wrote is headed "kaikki primary auxiliary" and
"translation as shipped", and nothing tied the two together. aufstehen got haben, which belongs
to "stand open", and the gloss "get up", which takes sein.

**Fix.** Confirm each of the 37 against German Wiktionary, Duden, or DWDS. Then one of four
outcomes per verb:

- **Two readings.** Both senses pass the test in "Second Readings". Write both, each with its
  own gloss and auxiliary. umziehen, ausziehen, zerreißen, and schmelzen are the likely cases
  among the 37, and schmelzen is the verb `prompts/dual_auxiliary.md` uses to illustrate the
  model.
- **Flip.** The verb stays single, and the sense its gloss names takes the other auxiliary.
  Change `ay`. An absent `ay` means haben, and `ay="s"` means sein. reisen and stattfinden are
  plain flips.
- **Re-gloss.** The verb stays single, the shipped auxiliary belongs to its main sense, and the
  gloss names a different one. Correct the gloss so that it names the sense that takes the
  auxiliary.
- **Keep.** kaikki is wrong. Record why, with the source.

Several of the 31 have glosses that look defective in themselves (aufrauchen "rise, appear").
Correct those as a re-gloss.

Record each ruling in a new file, `verbdata/auxiliary-rulings.tsv`, with one row per reading and
columns for the verb, the reading's position, its gloss, its auxiliary, its `in` where that
differs from the verb's, the outcome, the source, and the date. A verb that stays single gets
one row and the reason. The reasoning then sits beside the data, as it does in
`wiktionary-defects.json`.

Land Part 3b before this part or with it. Until then a second reading's gloss cannot be found by
searching.

**Guard.** Two tests in `ConjugatorTests`:

- Expectations on `.perfektIndikativ(.thirdSingular)` for stattfinden, reisen, entgehen,
  nachgehen, umziehen, aufstehen, and abfahren, written from the dictionary and not from the
  engine. The existing Perfekt tests show the mixed-case shape (`hAt gemacht`, `BIN gegANGen`),
  and each participle's casing should agree with the pinned test of its base verb.
- For umziehen and one other verb that gains a reading here, the same expectation for each
  reading, with `readingIndex`, as the tests for hängen do.
- A parameterized test over every reading ruled in this part and in Part 6, by verb and
  position, that asserts only the reading's auxiliary. It pins the rulings without hundreds of
  hand-written mixed-case strings.

**Done when.** The audit script reports no `CONTRADICTS` row that is not recorded as a "keep" in
the rulings file, the new pairs of glosses have passed review, the tests pass, and the ten verbs
in the table under "Why This Comes First" read correctly in the simulator. For a verb that
gained a reading, select each reading on its page and read the Perfekt Indikativ of both.

## Part 2: A Prefix Lost Under a Full Override

**What is wrong.** Confirmed in the simulator:

| Verb | The page says | German says |
|---|---|---|
| bedürfen | ich darf, du darfst, er darf | bedarf, bedarfst, bedarf |
| vermögen | ich mag, du magst, er mag | vermag, vermagst, vermag |
| entgelten | du galtest, ihr galtet | entgaltest, entgaltet |

**Cause.** An entry in `AblautGroups.xml` that ends in `*` is a full override: the whole
conjugation, spelled out. `Conjugator.applyAblaut` returns it with a flag, and each caller then
returns it as the complete answer (`conjugateSimpleTense`, the Perfektpartizip case, and three
places in `conjugateImperativ`). The reading's prefix is never put back. The groups with
overrides are dürfen, essen, gelten, können, mögen, müssen, sein, sollen, tun, werden, wissen,
and wollen. Only three prefixed verbs sit on any of them today, which is why only three are
wrong. The roadmap records the same limitation for haben, whose group was rewritten in July
because "an override bakes in the literal word, so no prefixed derivative could reuse it".

**Fix.** Make a full override aware of prefixes: when the reading has any, the conjugation is
the reading's prefix run followed by the override. Points to get right:

- **The participle.** essen and tun override the Perfektpartizip with the ge- already in it
  (`gegEssen*`, `getAn*`). After a separable prefix the result is correct as it stands
  (auf + gegessen). After an inseparable prefix the ge- must go (ver + tan, not ver + getan).
  `Reading.prefixes.takesGe` already answers which case applies.
- **The Imperativ.** `withSeparablePrefix` drops the first characters of the conjugation on the
  assumption that they are the prefix. With an override they are not, today. After the fix they
  are, so check that path with a test and not by reasoning.
- **Casing.** The prefix is lowercase and the override keeps its own letters: `bedarF`, `vermAG`.
  The pinned tests for dürfen and mögen (`darF`, `mAG`) show the casing to match.
- **The harness comment.** `CorpusFormsDumpTests.strandingParticle` carries a comment that
  describes the old behavior as a fact about overrides. Correct it.

The two overrides in the gelten group (`gAltest*`, `gAltet*`) may no longer be needed at all,
since the conjugator now adds the epenthetic e to a strong Präteritum stem that ends in t, as it
does for fandest. If the group verifies as `I,a2s,a3s|A,bA|Ö,dA|O,pp`, simplify it, as was done
for haben. Do this in addition to the code fix, not in place of it: dürfen and mögen have no
ending in the first and third person singular and cannot be expressed without an override.

**Guard.** `ConjugatorTests` expectations for all six conjugations of the Präsens Indikativ of
bedürfen and vermögen, and of the Präteritum Indikativ of entgelten, taken from Wiktionary.

**Done when.** The first scan in the appendix reports no verb beyond the false positives it
describes, the tests pass, and the at-odds count has not risen. It may fall.

**A by-product to record and not to act on.** Derivatives of tun, werden, and essen could not be
imported while overrides dropped prefixes. Some of the verbs in `verbdata/tranche2-deferred.txt`
may now verify. Note that in the roadmap. Importing them is not part of this plan.

## Part 3: Two Small Bugs in App Code

**3a. The shortcut picker hides the verb that was asked for.**
`VerbEntityQuery.entities(matching:)` filters the alphabetical list by substring and keeps the
first 25. For kommen, machen, stehen, stellen, halten, setzen, and ziehen, which are 7 of the 50
most frequent verbs, the verb is not among its own 25 results. Fix the order: an exact match on
the infinitive first, then infinitives that begin with the text, then the rest, each by
frequency, and only then the limit of 25. Guard with a test that asks for each of the seven and
expects it first.

**3b. The glosses of second readings are never searched.** `VerbBrowseView` and `VerbEntityQuery`
both match against `verb.translation`, which is the first reading's gloss. With the search scope
set to include translations, "travel" does not find fahren, whose second reading is "travel, go".
44 verbs are affected today, and Parts 1 and 6 will add many more. Match against every reading's
gloss. Put the predicate where a test can reach it.

Not in this part, although they sit in the same few lines: ranking the exact match first in the
verb list, folding umlauts, and the default search scope. Those are ideas A1 to A3 of the ideas
document and belong to its first release.

## Part 4: Example Sentences That Quote Another Verb

**What is wrong.** Five example sentences contain no conjugation of the verb they illustrate:

| Verb | What the sentence contains | Source |
|---|---|---|
| abstimmen | the noun Abstimmung | Grundgesetz |
| fertigen | verfertigt, from verfertigen | Goethe, *Werther* |
| greifen | ergriff, from ergreifen | Mann, *Der Tod in Venedig* |
| nutzen | nützen | Nietzsche, *Zarathustra* |
| schalten | ausschalten | Kafka, *Der Proceß* |

**Added by Part 1, 2026-11-10.** Three more sentences illustrate a sense the dictionaries do
not recognize, because each was authored to fit a kaikki gloss that Part 1 corrected. They are
not misses in the second scan, since each contains a conjugation of its verb, so the scan will
not find them. Replace them with the five:

| Verb | Gloss now | What the sentence shows | Source |
|---|---|---|---|
| ausschleichen | taper off (a medication) | "schlich er sich leise aus", an unattested "sneak off" | Opus 4.8 |
| aufrauchen | finish smoking | smoke rising, kaikki's archaic sense | Opus 4.8 |
| verstinken | stink up | kaikki's obsolete "stink until the smell is gone" | Opus 5 |

**Fix.** Replace each, in German and in English, by the process the pipeline documents describe.
Before discarding a displaced sentence, check whether the verb it does illustrate (ergreifen,
ausschalten) is in the corpus with a weaker example, and move the sentence there if so.

**The rest of the 35.** The second scan in the appendix finds 35 sentences in which the map
does not find the sentence's verb. Only these five are defects of the sentence. The appendix of
the ideas document sorts the others:

- Twelve use a standard conjugation that the app's table lacks. Most are the dual-paradigm gap
  that the roadmap records as decided and unscheduled (wandte, sandte, schuf, saugte). Leave the
  sentences alone and add any verb the roadmap's list lacks. hauen and krauchen are Part 7.
- Seven have a participle with an adjective ending, four a short imperative, and four an older
  spelling. The sentences are correct. These are limits of the map, and they matter to the
  reverse-lookup idea and not to this plan.
- übergehen ships the gloss "skip, ignore" with sein, and its sentence uses the separable verb
  ("geht ... ins Urteil über"). The inseparable verb takes haben. These are two verbs spelled
  alike, the same shape as übersetzen, and it should gain a reading whose `in` is `über+gehen`.
  The audit script does not flag it, because kaikki lists sein for both of its records, which is
  wrong for the inseparable one. Rule on it by hand in Part 6. Its sentence then illustrates the
  second reading and can stay.
- bedürfen's sentence is right and exposed Part 2.

**Done when.** The second scan reports no sentence that quotes a different verb, and each
remaining miss belongs to a class named above.

## Part 5: Documents That State Something False

**5a. The privacy policy.** [`docs/privacy_policy.txt`](../docs/privacy_policy.txt) lists what
analytics record (screens, quiz events, quiz difficulty, the question reached) and ends the list
with "That is all". `Analytics.swift` also sends `startGame`, `loseGame`, `completeWave`,
`tapPlayGame`, `tapRateOrReview`, `tapShowOnboarding`, `tapViewLeaderboard`,
`tapSendTutorMessage`, `tapExplainError`, and `tapDeleteChatHistory`. None carries a parameter,
so none carries text, a verb, or a score. The policy's promises hold, and only its list is
incomplete.

Per decision 3, correct the list in the English text and in the German one:

- Describe what is sent in the policy's own plain terms: game events (starting a game, finishing
  a wave, losing), and taps on a handful of buttons (play, rate or review, show onboarding, view
  leaderboard, send a tutor message, explain an error, delete chat history). State that a tap is
  recorded as having happened and that nothing typed or shown is sent with it. That matters most
  for the tutor: sending a message is recorded, and the message is not.
- Add the tutor screen to the list of screens, since `viewTutorView` is sent.
- Derive the list from `Analytics.swift` and from the call sites, not from this plan, and keep
  "That is all" true.
- Describe only what version 1.4 sends. The signals proposed in the ideas document do not exist
  yet and belong in the policy when they ship.
- Check that `Konjugieren/PrivacyInfo.xcprivacy` still matches. Nothing here changes what is
  collected, so it should need no edit.
- Follow `docs/english_writing_style.md` in both languages.

Leave the two date lines alone ("Effective Date" near the top, and "Datum des Inkrafttretens" in
the German half). The policy promises a new effective date with each change, and that date is
the day Josh deploys it. Tell him so when the text is ready.

**5b. `docs/feature-architecture.md` on the Control Center controls.** It says that both
controls use `OpenURLIntent`. They use `OpenRandomVerbIntent` and `OpenQuizIntent` from
`Shared/`, and [`docs/control-center-controls.md`](../docs/control-center-controls.md) explains
that `OpenURLIntent` does not work from a widget extension. `docs/pedagogy.md` records two more
errors in the same file (the conjugationgroups per quiz difficulty, and the claim that the game
involves conjugating). Correct all three in one commit.

**5c. The run command in `CorpusFormsDumpTests.swift`.** See Part 0, step 5.

**5d. The ideas document.** As each part lands, mark the matching item in its "Defects Found
Along the Way" section as fixed, with the commit.

## Part 6: The Remaining Auxiliary Rulings

**What is wrong.** 141 verbs that kaikki marks as taking both auxiliaries, that ship one
reading, and that kaikki's sense notes do not settle. Many are right as shipped and many are
not.

The 71 that agree are true as shipped, and under decision 1 that no longer ends the matter: a
verb whose shipped reading is right may still want a second one. So all 212 are in scope, and
the 37 of Part 1 were only the first of them. The work on the 71 is lighter, since it is only
the question in "Second Readings". Spot-check ten of the 71 for their shipped reading as well,
because the gloss matching in the audit script is approximate.

**Method.**

1. Promote the script beside this plan to `verbdata/audit_auxiliaries.py`. Give it a `--check`
   mode that reads `verbdata/auxiliary-rulings.tsv` and fails when any reading in `Verbs.xml`
   disagrees with its ruling, or when a verb that needs a ruling has none. The prototype skips
   every verb with two readings, on the ground that the July audit covered them. That stops
   being true the moment this work adds one, so the promoted script must check each reading of
   each ruled verb.
2. Rule by base verb. The derivatives of fahren, ziehen, treten, brechen, treiben, schießen,
   and laufen make up most of the list and follow their bases: the intransitive sense of motion
   takes sein (wegfahren, mitfahren, weiterfahren), and the transitive sense takes haben
   (hinfahren "give a ride"). fahren, ziehen, and treten already ship two readings, which shows
   the split to follow.
3. Apply the four outcomes of Part 1. Expect "two readings" to be the commonest outcome among
   the derivatives of verbs that already have two, and "stays single" to be the commonest among
   the derivatives of stehen, sitzen, and liegen.
4. Review the new pairs of glosses batch by batch, as "Second Readings" describes, before the
   batch is committed.
5. Treat derivatives of stehen, sitzen, and liegen with care. Most take haben in the German
   standard and sein in the south, exactly like their bases, and should keep haben. Whether they
   should also carry the regional marking of their bases is a separate question and not part of
   this plan. A few take sein everywhere because they name a change and not a state: aufstehen,
   auferstehen, and erstehen in the sense "arise".
6. Rule on übergehen by hand. See Part 4.
6a. **Added by Part 4, 2026-11-10: rule on schaffen too.** It is not an auxiliary case, so the
   audit does not list it, but it is the same kind of work. "create" is strong (schuf,
   geschaffen) and "manage, accomplish" is weak (schaffte, geschafft), and the app ships only the
   weak reading. It wants a second reading of the hängen shape, different family included. It is
   one of the five verbs at odds with Wiktionary, so the count should fall when it lands.
7. Extend the parameterized test of Part 1 with every reading ruled here.

**Stop the cause.** Tranche 3 of the import is unblocked and would repeat the error. Change the
importer so that a verb's auxiliary comes from the same kaikki sense as its gloss. A verb that
kaikki marks as taking both should arrive with a row in the rulings file that proposes its
readings from the senses' own notes, marked as unreviewed, and should not ship until the row is
ruled on. An importer that wrote second readings straight into `Verbs.xml` would skip the gloss
review. Update the roadmap under "Still open": when this part is done, the worklist in
`verbdata/tranche2-dual-auxiliary.txt` is history, and the rulings file is the current record.

*Added 2026-11-10, after the rulings were finished.* Three refinements, from what the rulings
found:

- **Where the cause sits.** `verbdata/import_tranche2.py` sets a reading's `ay` from the
  lemma-level `entry.get("auxiliary")` (around line 535), not from the sense its gloss was taken
  from, and writes dual-marked verbs to `tranche2-dual-auxiliary.txt` with one reading. Roadmap
  step 9 (tranche 3) is held on this change. Read the importer's header and `write_worklists`
  before changing it, and check whether tranche 3 is meant to reuse this script or a copy.
- **An outcome for unreviewed rows.** `audit_auxiliaries.py` accepts only five outcomes (`two
  readings`, `flip`, `flip and re-gloss`, `re-gloss`, `keep`). Add a sixth, `proposed`, for the
  rows the importer writes. `--check` should list proposed rows separately and fail while any
  remain, exactly as it fails on a listed verb with no ruling, so the existing gate ("0 awaiting
  a ruling") blocks an unreviewed import without new machinery. Ruling a proposed row means
  rewriting it with a real outcome, a source, and a note, as Part 6 did.
- **Flag more than dual-marked verbs.** The audit sees only verbs kaikki marks with both
  auxiliaries, and Part 6 found three kinds of error that pass it. A sense-level auxiliary that
  contradicts the lemma-level one (zuziehen shipped haben for "move to the area"). A gloss taken
  from one separability of a prefix that has both (durchlaufen, umlaufen, and durchdringen
  shipped separable with the inseparable verb's gloss; kaikki usually has `durch|laufen` and
  `durchlaufen` as separate entries). Two verbs under one spelling with different families (the
  anhängen shape: schleifen, bleichen, schwellen, where kaikki lists a strong and a weak entry).
  Each can be detected from kaikki's data. Route each to a `proposed` row with the reason in its
  note, rather than importing it.

**Done when.** `audit_auxiliaries.py --check` passes, the parameterized test passes, every new
pair of glosses has passed review, and the rulings file names a source for every row.

**Size.** This is the largest part, and decision 1 made it larger: 212 verbs to rule on, and
perhaps 100 or more new glosses, which is a guess until the rulings are made. It can be split by
base verb across sessions without harm, because the rulings file records where the work stands.
Finish a base verb's derivatives together, so that their glosses stay parallel.

## Part 7: Verbs That Need a Ruling or a Decision About the Model

**7a. backen and hauen.** The app ships both as weak, with the participles gebackt and gehaut.
The standard participles are gebacken and gehauen, and the weak ones are regional. Derivatives
follow: abhauen ships abgehaut. The app's own example for zusammenhauen has zusammengehauen.
Both verbs have a weak Präteritum (backte, haute) beside an older strong one (buk, hieb), so
neither the weak nor the strong family describes them. This is wrinkle 4 of
`docs/verb-sources.md`, which names mahlen, salzen, and spalten and not these two.

They probably passed the pipeline because Wiktionary lists both participles, and a verb verifies
if it matches any listed alternative. Confirm that against `verbdata/candidates.json`. If it is
so, find every member of the class with a scan for weak shipping verbs whose first-listed kaikki
participle is not the one the app generates.

Per decision 2, each base verb becomes a mixed-family verb (`fa="m"`) with an ablaut group of
its own that holds only a participle override. The family must be mixed and not weak, because
the conjugator consults an ablaut group only for strong and mixed verbs, and the mixed family's
weak endings give backte and haute. Part 2 must land first, since it is what lets a derivative
share its base verb's group: ab + gehauen, and ver + hauen with the ge- removed.

What each new group involves:

- An entry in `AblautGroups.xml`, with the participle's casing marking what is irregular, taken
  from Wiktionary.
- An entry in `AblautGroupInfo.exemplars`, in its alphabetical place.
- A description in English and German in `Localizable.xcstrings`, under the key
  `AblautGroupInfo.<exemplar>`, in the shape of the existing ones: the three principal parts in
  `$...$` markup and one sentence. Follow `CLAUDE.md` on editing that file safely.
- Pinned tests for the base verb and for one separable and one inseparable derivative.
- New ablaut-group counts in the four cache files. There are 73 groups today, and
  `check_docs.py` will name each place that says so.

Two more things to check:

- **The Mixed family's texts.** Its short description says that mixed verbs combine "strong-verb
  ablaut with weak-verb endings". These verbs have weak endings in the Präteritum and a strong
  ending, with no vowel change, in the participle. Read the family's long article and add a
  sentence about this small class if the article would otherwise contradict what the family now
  contains, in both languages.
- **salzen.** The roadmap says it shipped as weak because kaikki lists gesalzt beside gesalzen.
  It is the same case as backen and hauen, and the scan above should find it.

If the scan finds more than five base verbs, show Josh the list before adding groups. Each group
is a visible entry in the Families tab and two strings to maintain.

With the mechanism in place, mahlen and spalten can be imported. The roadmap deferred them for
want of exactly this. Record that under wrinkle 4, and do not import them here.

**7b. krauchen.** The app conjugates it as strong (kroch, gekrochen), which are the
conjugations of kriechen. Its own example sentence has krauchte. Rule against German Wiktionary
and Duden. If the weak paradigm is the standard one, the fix is a change of family in
`Verbs.xml` and one test.

**Done when.** backen, hauen, their derivatives, and every other verb the scan found generate
the standard participle with a pinned test, krauchen is ruled on, the at-odds count has not
risen, and `check_docs.py` passes with the new counts.

## Closing

1. Run the whole test suite, the classification pipeline, `python3 scripts/check_docs.py`, and
   `audit_auxiliaries.py --check`. **Expect new `shippedEncodingFailed` flags** from the
   pipeline. Part 6 changed the first reading's family, separability, or order on many verbs
   (durchlaufen and durchdringen changed their verb-level `in`, and eintauchen, verkleben, and
   zerkochen reordered their readings), and the classifier tests only reading 0 against a kaikki
   table that may describe the other verb. The at-odds summary excludes multi-reading verbs, so
   these are not regressions. Check that the at-odds count itself has not risen above 5.
2. Regenerate `forms.json` and run both scans in the appendix again.
3. Open the ten verbs of the first table in the simulator, three verbs that were ruled "keep",
   and five that gained a reading. Read the Perfekt Indikativ of each, in every reading. Suggested,
   so the check covers each kind of change Part 6 made: keeps umbrechen, aufschießen, and
   festbacken; abschieben (flipped to haben), unterliegen, frieren, überspringen (reading 1 has
   its own `in`), and durchschlagen (three readings); and durchlaufen and durchdringen, whose
   verb-level `in` became inseparable. For those two, also check where they now appear in the
   prefix browse lists. The Region setting does not affect any of these. Use the deeplink
   `xcrun simctl openurl booted "konjugieren://verb/<verb>"`.
4. Update the roadmap ("Still open", "Known gaps"), `docs/verb-classification.md` if the
   at-odds count moved, `docs/project-structure.md` for every file added, and the defects
   section of the ideas document. Search the documents that describe the current state for the
   number of verbs with more than one reading, which was 44, and update it: **118 verbs have more
   than one reading, six of them three** (durchziehen, durchbrechen, durchlaufen, umlaufen,
   durchschlagen, überschlagen). `check_docs.py` does not assert this number, so search for it by
   hand. Dated plans and journal entries keep the number they were written with.
   **Give Part 6's leftovers a home in "Known gaps"**, since they live nowhere but this plan:
   - Five unmade family splits, the anhängen shape: schleifen, bleichen, ausbleichen, schwellen,
     aufschwellen.
   - Example sentences that do not illustrate their gloss: anstehen (*befit*), dafürstehen (*für
     etwas stehen* written apart), nachschieben ("add afterwards"), überschießen (intransitive),
     and ablaufen, whose sentence needs "proceed" while the commonest sense is "expire".
   - Seven verbs kept as shipped for want of any readable source: zertreiben, überschießen,
     zusammenstreben, umeinanderstehen, hinrücken, rückdrehen, mitfolgen.
5. Tell Josh, part by part: what changed and what was deferred and why. The Part 6 review list
   is confirmed and needs no second look. When Part 5 is done, tell him that the privacy policy
   is ready to deploy and that both date lines need the day he deploys it.

## Out of Scope

- Every idea in the ideas document, including the search fixes A1 to A4.
- A second reading for a verb that fails the test in "Second Readings", and a third reading for
  any verb.
- The dual-paradigm model (wrinkle 1, 111 verbs). It is decided and unscheduled, and it needs
  its own prompt.
- Regional marking for derivatives of stehen, sitzen, and liegen.
- Importing verbs, including any that Part 2 or Part 7 unblocks.
- Cutting a release, bumping the version, and writing release notes.
- The quiz's grading defects in `docs/pedagogy.md`, and the convention for displaying separable
  verbs, which is a decision in both research documents.

## Appendix: Two Scans

Both read `corpus/working/forms.json`, so regenerate it first. Run them from the repository
root.

**Scan 1: prefixed verbs with a conjugation that lacks its prefix.**

```python
# Lists whole-word conjugations of a prefixed verb that do not begin with the verb's prefix run.
# Expect false positives of exactly one kind: the zu-infinitive of a verb with a separable prefix
# over an inseparable one (vorzubereiten for vor+be*reiten), where the zu sits inside the run.
# On 2026-11-10 the real hits were bedürfen, vermögen, and entgelten.
import collections, json, re
import xml.etree.ElementTree as ET

raw = {re.sub(r"[+*^]", "", v.get("in")): v.get("in")
       for v in ET.parse("Konjugieren/Models/Verbs.xml").getroot().findall("verb")}
by_verb = collections.defaultdict(list)
for conjugation, entries in json.load(open("corpus/working/forms.json")).items():
    for entry in entries:
        if entry["contiguous"]:
            by_verb[entry["verb"]].append(conjugation)
for infinitive, marked in sorted(raw.items()):
    run = re.match(r"^(.*[+*])", marked)
    if not run:
        continue
    prefix = re.sub(r"[+*^]", "", run.group(1)).lower()
    missing = sorted(c for c in by_verb[infinitive] if not c.startswith(prefix))
    if missing:
        print(infinitive, missing)
```

**Scan 2: example sentences in which the map does not find the sentence's verb.**

```python
# For each German example sentence, asks whether any word in it is a conjugation of the verb the
# sentence illustrates. A stranded finite part counts only if its particle is also in the
# sentence. ß and ss are folded on both sides, as the app's search does.
# On 2026-11-10 this found the verb in 3,537 of 3,572 sentences.
import collections, json, re

def fold(text):
    return text.replace("ß", "ss")

index = collections.defaultdict(list)
for conjugation, entries in json.load(open("corpus/working/forms.json")).items():
    index[fold(conjugation)].extend(entries)
sentences = json.load(open("Konjugieren/Models/ExampleSentences.json"))["de"]
for verb, entry in sentences.items():
    words = [fold(w.lower()) for w in re.findall(r"[A-Za-zÄÖÜäöüß]+", entry["sentence"])]
    found = any(e["verb"] == verb and (e["contiguous"] or fold(e.get("particle", "")) in words)
                for w in words for e in index.get(w, []))
    if not found:
        print(verb, "|", entry["sentence"][:110], "|", entry["source"])
```

## Prompt to Hand a Session

Written 2026-11-10, after Josh confirmed the away-mode review list. It covers the two pieces of
work left: Part 6's importer change, then the Closing. Josh will be present, so stop and ask
where the plan leaves a decision open.

> Read plans/fix-reference-defects.md, starting with its Status section. Part 6's rulings are
> finished and `python3 verbdata/audit_auxiliaries.py --check` passes. The list "Calls made
> without Josh, confirmed" holds settled rulings: do not reopen them. Then read the
> docs/blog_notes.md entries headed "Defect plan, Part 6".
>
> First, do Part 6's "Stop the cause", including the three refinements added under it on
> 2026-11-10: the cause in verbdata/import_tranche2.py, a `proposed` outcome that --check fails
> on, and flags for the three error kinds the dual-auxiliary audit cannot see. Read the
> importer's header and docs/roadmap.md step 9 before changing anything, and comment the script
> generously, as CLAUDE.md asks for verbdata/. Show that the change works by running the
> importer in its check mode against kaikki and confirming that the shipped verbs Part 6 fixed
> (zuziehen, durchlaufen, abschieben, bleichen) would now be flagged, not imported as they
> were. Do not import tranche 3. Update the roadmap under "Still open" and step 9's status.
> Append a journal entry and commit.
>
> Then do the plan's Closing, steps 1 to 5, as revised on 2026-11-10. Commit after each step
> that changes files, with a journal entry for the whole Closing. Finish by telling Josh what
> changed, part by part, and that the privacy policy is ready to deploy with both date lines
> set to the day he deploys it.

**Earlier prompt, finished.** Part 6's rulings were done under the prompt below, and the session
run under it emptied the worklist on 2026-11-10. It is kept as the record of how that session
worked.

That prompt let the session work while Josh was away (written 2026-11-10). It replaced the earlier
one, which asked the session to stop before a third reading, before extending the criterion-2
precedent, and whenever a ruling rested on an unreadable source. Each of those is now a default
drawn from Josh's rulings of 2026-11-10, and every call made under a default is logged for his
review. If Josh is present, he may prefer to be asked instead.

> Read plans/fix-reference-defects.md, starting with its Status section ("Where Part 6 stands"
> and Josh's rulings of 2026-11-10), then the docs/blog_notes.md entries headed "Defect plan,
> Part 6". Continue Part 6: rule the remaining verbs by base verb, in this order: treiben,
> laufen, schießen, streben, brennen, schlagen, wachsen, then the derivatives of stehen and
> liegen (plan step 5), then the small families, several to a batch. Take each batch's verbs
> from `python3 verbdata/audit_auxiliaries.py --unruled`.
>
> Josh is away and has authorized you to make judgment calls instead of stopping to ask. Use
> the method the fahren, ziehen, treten, and brechen batches used: web-fetch agents quoting
> DWDS (German Wiktionary, then Duden, as fallbacks), rulings, anchored edits to Verbs.xml,
> rows in verbdata/auxiliary-rulings.tsv and ConjugatorTests.auxiliaryRulings, a gloss review
> on Sonnet under prompts/gloss_review.md, and adjudication on Fable under
> prompts/gloss_adjudication.md (Agent tool, `model` parameter) for any finding. Where you
> would have asked Josh, apply these defaults:
>
> - Third reading: give one only when the dictionaries show the durchziehen/durchbrechen
>   shape (separable with haben, separable with sein, inseparable). Otherwise use two
>   readings at most and leave the rest unmodelled.
> - Labelled senses: follow the precedents as recorded. A sense labelled gehoben, or a
>   domain qualified by "häufig", passes criterion 2. A plain Technik, salopp,
>   umgangssprachlich, regional, or veraltet label fails it. A labelled primary sense keeps
>   a single reading (umbrechen).
> - Missing sources: if no source you could read states a sense's auxiliary, do not change
>   that sense. Keep what ships and record the verb as deferred.
> - Verbs the audit does not list: fix a clear auxiliary error you find while reading a
>   family (the zuziehen case) when a source states it. Add a reading for a split by
>   separability alone (the umfahren case) only when the sense is unlabelled and common.
> - Etymologies: after ruling a verb, read the closing paragraph of its Etymologies.json
>   entry in both languages, and correct any claim the ruling made false, splicing raw text
>   as the earlier batches did.
>
> Record every call made under these defaults, plus any ruling you are unsure of, in a list
> headed "Calls made without Josh, to review" in the plan's Status block: one line per verb,
> saying what you decided, the alternative, and why. Josh will go through it on his return.
>
> After each batch: `--check` must report 0 other problems, the full suite must pass, append
> a journal entry, update the Status block (counts, next base verb, the review list), and
> commit to main. Each batch should be safe to stop after. Do not start the importer change
> ("Stop the cause") or the plan's Closing step. Stop when the worklist is empty, or earlier
> if something comes up that the defaults above do not cover. In that case, record it in the
> review list and move to the next family rather than guessing.
