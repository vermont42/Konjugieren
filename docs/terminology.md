# Terminology

## Conjugation Group

The term "conjugationgroup" was invented for this project because no existing term adequately described the concept. A conjugationgroup with more than one member, like Präsens Indikativ, combines tense, mood, and voice to identify a specific set of verb forms. The conjugationgroups with one member are Infinitiv (infinitive), Perfektpartizip (past participle), and Präsenspartizip (present participle). When translating conjugationgroup to German, use the word "Conjugationgroup", plural "Conjugationgroups". By analogy with Gruppe, Conjugationgroup is a feminine noun.

## Tense, Mood, and Voice

In discourse about Indo-European languages, "tense" refers only to the time that an action occurs. German conjugationgroups have three tenses:
- **Präsens** (present)
- **Präteritum** (past)
- **Futur** (future)

There is no Futur Partizip (participle).

Multiple-member (not Perfektpartizip or Präsenspartizip) German verbs are also encoded with **mood**. German has four moods:
- **Indikativ** - corresponds to the English indicative mood
- **Konjunktiv I** - corresponds to the English subjunctive mood
- **Konjunktiv II** - corresponds to the English conditional mood
- **Imperativ** - corresponds to the English imperative mood

Multiple-member conjugationgroup have a tense and mood. For example, Präsens Indikativ has Präsens tense and Indikativ mood. Certain tense/mood combinations do not occur. For example, there is no conjugationgroup for Futur/Imperativ.

Multi-member conjugationgroups also sometimes encode **voice**. In English, the two voices are active and passive. German has Aktiv (active) voice and two passive voices, Vorgangspassiv and Zustandpassiv.

## Conjugationgroups Currently in This Codebase

### Simple Conjugationgroups

| Conjugationgroup | Tense | Mood | English Equivalent |
|-------------------|-------|------|-------------------|
| Präsens Indikativ | Präsens | Indikativ | Present indicative |
| Präteritum Indikativ | Präteritum | Indikativ | Past indicative |
| Präsens Konjunktiv I | Präsens | Konjunktiv I | Present subjunctive |
| Präteritum Konjunktiv II | Präteritum | Konjunktiv II | Past conditional |
| Imperativ | - | Imperativ | Imperative |
| Perfektpartizip | Präteritum | - | Past participle |
| Präsenspartizip | Präsens | - | Present participle |

### Compound Conjugationgroups

These conjugationgroups use auxiliary verbs (haben/sein or werden) combined with the Perfektpartizip or Infinitiv:

**Perfekt (auxiliary in Präsens + Perfektpartizip):**

| Conjugation Group | Auxiliary Tense | Auxiliary Mood | English Equivalent |
|-------------------|-----------------|----------------|-------------------|
| Perfekt Indikativ | Präsens | Indikativ | Present perfect indicative |
| Perfekt Konjunktiv I | Präsens | Konjunktiv I | Present perfect subjunctive |

**Plusquamperfekt (auxiliary in Präteritum + Perfektpartizip):**

| Conjugation Group | Auxiliary Tense | Auxiliary Mood | English Equivalent |
|-------------------|-----------------|----------------|-------------------|
| Plusquamperfekt Indikativ | Präteritum | Indikativ | Pluperfect indicative |
| Plusquamperfekt Konjunktiv II | Präteritum | Konjunktiv II | Pluperfect conditional |

**Futur (werden + Infinitiv):**

| Conjugation Group | Auxiliary Tense | Auxiliary Mood | English Equivalent |
|-------------------|-----------------|----------------|-------------------|
| Futur Indikativ | Präsens | Indikativ | Future indicative |
| Futur Konjunktiv I | Präsens | Konjunktiv I | Future subjunctive |
| Futur Konjunktiv II | Präsens | Konjunktiv II | Future conditional |

## Usage Notes

- Avoid using "tense" to describe conjugationgroups
- The participles (Perfektpartizip, Präsenspartizip) do not have mood
- Compound conjugationgroups combine an auxiliary verb conjugation with the Perfektpartizip
