# Missing Articles Are Okay

Do not flag absent articles as errors when both forms (with and without article) are standard English. For example, "interested in use of Claude Code" is correct — the article is optional, not required. The bare form is common in formal/resume register.

**Why:** AI models tend to normalize toward the statistically more frequent form, but frequency isn't correctness. Josh is a strong writer with fifty years of English and finds these false corrections irritating.

**How to apply:** When proofreading, only flag article usage if the sentence is genuinely ungrammatical without it, not merely because the article-included form is more common.

# Phrasal Adjectives

Aggressively hyphenate phrasal adjectives (compound modifiers that appear before a noun). There are two exceptions:

1. **-ly adverbs**: Do not hyphenate when the first word ends in -ly
2. **Proper nouns**: Do not hyphenate proper noun phrases

**Examples:**

| Correct | Incorrect | Reason |
|---------|-----------|--------|
| verb-list search | verb list search | Phrasal adjective before noun |
| case-insensitive matching | case insensitive matching | Phrasal adjective before noun |
| swiftly tilting planet | swiftly-tilting planet | -ly adverb exception |
| New Jersey Turnpike | New-Jersey Turnpike | Proper noun exception |
| user-facing text | user facing text | Phrasal adjective before noun |

# No Em Dashes

Avoid em dashes entirely. Instead, use a colon, semicolon, or comma. Or break into a new sentence with a period. This prohibition springs from two facts. First, Josh dislikes em dashes as an æsthetic matter. Second, many readers infer, often correctly, that prose containing em-dashes is AI-generated.

# Logical Punctuation

Place commas and periods outside closing quotation marks unless they are part of the original quoted material. This convention, also called British-style punctuation, prioritizes semantic accuracy over the American typographical convention. Thus, the word "German", not the word "German," and he said "hello". But: He said "I am leaving."

# No Comma Splices

Do not join two independent clauses with a comma alone. Fix a splice in whichever of four ways reads best: a period, a semicolon, a coordinating conjunction after the comma (and, but, so, for, yet), or subordinating one of the clauses.

**Why:** it is an error in English, and Josh's style implies not making it.

**Watch for it especially when translating German.** German licenses the bare comma between independent clauses, because German comma rules are grammatical rather than rhetorical. „Wirf die alten Zeitungen bitte nicht weg, ich brauche sie noch zum Basteln" is correct German. An idiomatic English translation must therefore *re-punctuate*, not merely re-word, and a translator can be perfectly fluent and still carry the German comma across. This is the one place in this project where the error reliably appears.

| Correct | Incorrect | Fix used |
|---------|-----------|----------|
| Please don't throw the old newspapers out; I still need them for crafts. | Please don't throw the old newspapers out, I still need them for crafts. | Semicolon |
| Please don't throw the old newspapers out, because I still need them for crafts. | (same as above) | Subordination |
| The rent is debited automatically. I never have to think about it. | The rent is debited automatically, I never have to think about it. | Period |

**How to apply:** flag only genuine splices, where the text on *both* sides of the comma could stand alone as a sentence. A comma after a fronted phrase or before a subordinate clause is correct and must not be "fixed":

| Correct, do not flag | Why |
|---------|-----|
| At the small winery, they bottle the young wine by hand. | Fronted prepositional phrase, not a clause |
| To be absolutely sure, she called the hotel once more. | Infinitive phrase |
| The moment the light turned green, she took off running. | Subordinate temporal clause |
| So that the patient doesn't develop bedsores, he is repositioned every two hours. | Subordinate purpose clause |

The second table matters as much as the first. An automated scan for "comma followed by a pronoun" over the 1,097 authored example sentences returned 33 hits, of which exactly one was a real splice; the other 32 were of the kinds shown directly above. Over-correction is by far the likelier failure here, exactly as with missing articles.

# Singular They

Find a different construction. Alternating "he" and "she" is fine. Thus, "the relationship between a lawyer and a legal assistant who works with her for years" and not "the relationship between a lawyer and a legal assistant who works with them for years". Josh recognizes that English speakers increasingly use singular they, but he resents the loss of linguistic precision and accuracy that singular they represents. He probably would have been a member of the thou rearguard if he had been born 300 years earlier.