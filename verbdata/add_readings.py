#!/usr/bin/env python3
"""Give the shipping dual-auxiliary verbs their second reading.

ALREADY APPLIED, on 2026-07-19, as step 5 of docs/roadmap.md. It is kept as the record of
*why* each auxiliary below was assigned, which is the one part of that pass nothing else can
re-derive — not the pipeline, not kaikki, not the test suite. Re-running it against the
current Verbs.xml aborts on the first entry, because the single <reading> lines it matches on
no longer exist; that is the intended failure and not a bug to fix.

Consumes and rewrites Konjugieren/Models/Verbs.xml, which must already be in the nested
<reading> shape. A one-shot companion, migrate_readings.py, produced that shape by wrapping
every verb's attributes in a single <reading>; it was purely mechanical, changed no attribute
value, and was not kept.

Each entry below replaces one verb's single <reading> line with two. The **first reading
keeps the verb's current sense and auxiliary**, so the app's existing answer for every one
of these verbs is unchanged and the diff shows only what was added. The second reading is
the sense the single-valued `ay` attribute had been silently suppressing.

Sourcing. kaikki tags nearly all of these `haben`, `sein`, *and* `haben or sein` at once,
because a Wiktionary conjugation table aggregates every sense of the lemma. The tags
therefore cannot be mapped sense-to-auxiliary mechanically, and the assignments here are
editorial, following the standard rules: an intransitive change of state or a directional
motion takes sein, a transitive or an atelic activity takes haben.

Note that the classify-and-verify pipeline CANNOT check this work. Its expectations cover
only the simple tenses, the participles, and the Imperativ — never a compound tense — so the
auxiliary is invisible to it. These assignments are guarded by ConjugatorTests, not by the
oracle, and the at-odds count is expected to be completely unmoved by this script.

Run from the repo root:  python3 verbdata/add_readings.py
"""

import pathlib
import re
import sys

PATH = pathlib.Path("Konjugieren/Models/Verbs.xml")

# key -> (old single reading, [new reading lines])
# `h` is the default and is written by omitting `ay`, matching the rest of the file.
READINGS = {
    # ---- Class 1: transitivity alternation. Transitive haben, intransitive sein. ----
    "abbrechen": ('<reading tn="break off, cancel" fa="s" ag="sprechen" />', [
        '<reading tn="break off, cancel" fa="s" ag="sprechen" />',
        '<reading tn="break off, snap (come apart)" fa="s" ag="sprechen" ay="s" />']),
    "abziehen": ('<reading tn="deduct, withdraw" fa="s" ag="ziehen" />', [
        '<reading tn="deduct, withdraw" fa="s" ag="ziehen" />',
        '<reading tn="leave, depart" fa="s" ag="ziehen" ay="s" />']),
    "anziehen": ('<reading tn="attract, dress" fa="s" ag="ziehen" />', [
        '<reading tn="attract, dress" fa="s" ag="ziehen" />',
        '<reading tn="set off, start moving" fa="s" ag="ziehen" ay="s" />']),
    "brechen": ('<reading tn="break" fa="s" ag="sprechen" />', [
        '<reading tn="break (something)" fa="s" ag="sprechen" />',
        '<reading tn="break, snap (come apart)" fa="s" ag="sprechen" ay="s" />']),
    "einziehen": ('<reading tn="move in, collect" fa="s" ag="ziehen" />', [
        '<reading tn="collect, retract" fa="s" ag="ziehen" />',
        '<reading tn="move in (take up residence)" fa="s" ag="ziehen" ay="s" />']),
    "fahren": ('<reading tn="drive, go" fa="s" ag="fahren" />', [
        '<reading tn="drive (a vehicle)" fa="s" ag="fahren" />',
        '<reading tn="travel, go" fa="s" ag="fahren" ay="s" />']),
    "fliegen": ('<reading tn="fly" fa="s" ag="fliegen" ay="s" />', [
        '<reading tn="fly (travel by air)" fa="s" ag="fliegen" ay="s" />',
        '<reading tn="fly, pilot (an aircraft)" fa="s" ag="fliegen" />']),
    "heilen": ('<reading tn="heal, cure" fa="w" />', [
        '<reading tn="heal, cure (someone)" fa="w" />',
        '<reading tn="heal, mend (become whole)" fa="w" ay="s" />']),
    "reißen": ('<reading tn="tear, rip" fa="s" ag="reißen" />', [
        '<reading tn="tear, rip (something)" fa="s" ag="reißen" />',
        '<reading tn="tear, snap (come apart)" fa="s" ag="reißen" ay="s" />']),
    "rollen": ('<reading tn="roll" fa="w" />', [
        '<reading tn="roll (something)" fa="w" />',
        '<reading tn="roll (move by rolling)" fa="w" ay="s" />']),
    "rücken": ('<reading tn="move" fa="w" />', [
        '<reading tn="move (something) over" fa="w" />',
        '<reading tn="move over, shift" fa="w" ay="s" />']),
    "schießen": ('<reading tn="shoot" fa="s" ag="schließen" />', [
        '<reading tn="shoot, fire" fa="s" ag="schließen" />',
        '<reading tn="dart, shoot (rush)" fa="s" ag="schließen" ay="s" />']),
    "stoßen": ('<reading tn="push, bump" fa="s" ag="stoßen" />', [
        '<reading tn="push, shove" fa="s" ag="stoßen" />',
        '<reading tn="come across, bump into" fa="s" ag="stoßen" ay="s" />']),
    "treiben": ('<reading tn="drive, do" fa="s" ag="bleiben" />', [
        '<reading tn="drive, propel" fa="s" ag="bleiben" />',
        '<reading tn="drift, float" fa="s" ag="bleiben" ay="s" />']),
    "trocknen": ('<reading tn="dry" fa="w" />', [
        '<reading tn="dry (something)" fa="w" />',
        '<reading tn="dry, become dry" fa="w" ay="s" />']),
    "verbrennen": ('<reading tn="burn" fa="m" ag="kennen" />', [
        '<reading tn="burn (something)" fa="m" ag="kennen" />',
        '<reading tn="burn up, be consumed" fa="m" ag="kennen" ay="s" />']),
    "ziehen": ('<reading tn="pull, move" fa="s" ag="ziehen" />', [
        '<reading tn="pull, draw" fa="s" ag="ziehen" />',
        '<reading tn="move, migrate" fa="s" ag="ziehen" ay="s" />']),
    "zurückziehen": ('<reading tn="withdraw, pull back" fa="s" ag="ziehen" />', [
        '<reading tn="withdraw, pull back" fa="s" ag="ziehen" />',
        '<reading tn="retreat, move away" fa="s" ag="ziehen" ay="s" />']),

    # ---- Class 2: motion. sein when a destination is reached, haben for the activity. ----
    "fliehen": ('<reading tn="flee, escape" fa="s" ag="fliegen" ay="s" />', [
        '<reading tn="flee, escape" fa="s" ag="fliegen" ay="s" />',
        '<reading tn="flee from, avoid" fa="s" ag="fliegen" />']),
    "landen": ('<reading tn="land" fa="w" ay="s" />', [
        '<reading tn="land, touch down" fa="w" ay="s" />',
        '<reading tn="land (an aircraft)" fa="w" />']),
    "reiten": ('<reading tn="ride" fa="s" ag="schneiden" />', [
        '<reading tn="ride (as an activity)" fa="s" ag="schneiden" />',
        '<reading tn="ride (to a destination)" fa="s" ag="schneiden" ay="s" />']),
    "rennen": ('<reading tn="run, race" fa="m" ag="kennen" ay="s" />', [
        '<reading tn="run, race" fa="m" ag="kennen" ay="s" />',
        '<reading tn="run over (someone)" fa="m" ag="kennen" />']),
    "schwimmen": ('<reading tn="swim" fa="s" ag="singen" ay="s" />', [
        '<reading tn="swim (to a destination)" fa="s" ag="singen" ay="s" />',
        '<reading tn="swim (as an activity)" fa="s" ag="singen" />']),
    "starten": ('<reading tn="start" fa="w" />', [
        '<reading tn="start (something)" fa="w" />',
        '<reading tn="start off, take off" fa="w" ay="s" />']),
    "stürzen": ('<reading tn="fall, plunge" fa="w" ay="s" />', [
        '<reading tn="fall, plunge" fa="w" ay="s" />',
        '<reading tn="hurl, topple (something)" fa="w" />']),
    "tanzen": ('<reading tn="dance" fa="w" />', [
        '<reading tn="dance (as an activity)" fa="w" />',
        '<reading tn="dance (to a destination)" fa="w" ay="s" />']),
    "tauchen": ('<reading tn="dive, dip" fa="w" />', [
        '<reading tn="dive, immerse (something)" fa="w" />',
        '<reading tn="dive, surface" fa="w" ay="s" />']),
    "treten": ('<reading tn="step, kick" fa="s" ag="treten" />', [
        '<reading tn="kick" fa="s" ag="treten" />',
        '<reading tn="step, tread" fa="s" ag="treten" ay="s" />']),

    # ---- Class 5 and mixed: the sense split is lexical rather than argument structure. ----
    "antreten": ('<reading tn="start, take up" fa="s" ag="treten" ay="s" />', [
        '<reading tn="line up, report for duty" fa="s" ag="treten" ay="s" />',
        '<reading tn="take up (office), begin (a journey)" fa="s" ag="treten" />']),
    "dringen": ('<reading tn="penetrate, urge" fa="s" ag="singen" ay="s" />', [
        '<reading tn="penetrate, force a way through" fa="s" ag="singen" ay="s" />',
        '<reading tn="insist, press" fa="s" ag="singen" />']),
    "eingehen": ('<reading tn="enter into" fa="s" ag="gehen" />', [
        '<reading tn="enter into (an agreement)" fa="s" ag="gehen" />',
        '<reading tn="arrive, shrink, die" fa="s" ag="gehen" ay="s" />']),
    "eintreten": ('<reading tn="enter, occur" fa="s" ag="treten" ay="s" />', [
        '<reading tn="enter, occur" fa="s" ag="treten" ay="s" />',
        '<reading tn="kick in (something)" fa="s" ag="treten" />']),
    "passieren": ('<reading tn="happen" fa="i" ay="s" />', [
        '<reading tn="happen, occur" fa="i" ay="s" />',
        '<reading tn="pass through, strain" fa="i" />']),
    # scheiden transitive (dissolve a marriage) takes haben; the intransitive "part, depart"
    # takes sein. The shipped gloss named the transitive sense but carried sein.
    "scheiden": ('<reading tn="divorce, separate" fa="s" ag="bleiben" ay="s" />', [
        '<reading tn="divorce, separate (a couple)" fa="s" ag="bleiben" />',
        '<reading tn="part, depart" fa="s" ag="bleiben" ay="s" />']),
    "verlaufen": ('<reading tn="proceed, get lost" fa="s" ag="laufen" ay="s" />', [
        '<reading tn="run, proceed" fa="s" ag="laufen" ay="s" />',
        '<reading tn="lose one\'s way" fa="s" ag="laufen" />']),
    # weichen is class 4 as well as class 5: the "yield" reading is strong (wich, gewichen)
    # and the "soak" reading is a different, weak verb (weichte, geweicht). The weak reading
    # respells `in` to drop the ablaut region, which a weak family may not carry.
    "weichen": ('<reading tn="yield, give way" fa="s" ag="streichen" ay="s" />', [
        '<reading tn="yield, give way" fa="s" ag="streichen" ay="s" />',
        '<reading in="weichen" tn="soak, soften" fa="w" />']),
    # The flagship class 5 pair: the readings differ in the `in` attribute itself.
    # über*setzen "translate" is inseparable (übersetzt); über+setzen "ferry across" is
    # separable (übergesetzt) and takes sein.
    "übersetzen": ('<reading tn="translate" fa="w" />', [
        '<reading tn="translate, interpret" fa="w" />',
        '<reading in="über+setzen" tn="ferry across" fa="w" ay="s" />']),
    "überstehen": ('<reading tn="survive, withstand" fa="s" ag="stehen" />', [
        '<reading tn="survive, withstand" fa="s" ag="stehen" />',
        '<reading in="über+st^eh^en" tn="protrude, jut out" fa="s" ag="stehen" />']),
}


def main():
    text = PATH.read_text(encoding="utf-8")
    applied = 0

    for key, (old, new) in READINGS.items():
        # Anchored on the verb's own key, not just its reading line: several verbs share a
        # gloss, and `<reading tn="move" fa="w" />` alone matches both rücken and bewegen.
        # The key is the `in` attribute with every +, *, and ^ marker stripped.
        marked = r'[+*^]*'.join(re.escape(character) for character in key)
        pattern = re.compile(
            r'(  <verb in="' + marked + r'" [^>]*>\n)    ' + re.escape(old) + r'\n(  </verb>)')
        matches = pattern.findall(text)
        if len(matches) != 1:
            sys.exit(f"{key}: expected exactly 1 match, found {len(matches)}")
        replacement = matches[0][0] + "".join(f"    {line}\n" for line in new) + matches[0][1]
        text = pattern.sub(lambda _: replacement, text, count=1)
        applied += 1

    PATH.write_text(text, encoding="utf-8")
    print(f"gave {applied} verbs a second reading")


if __name__ == "__main__":
    main()
