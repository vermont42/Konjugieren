**Status:** ✅ executed 2026-07-18. Produced `docs/verb-sources.md`; the work it started is
now sequenced in `docs/roadmap.md`.

Konjugieren's sibling apps, Conjuguer and Conjugar, have around 6200 and 4800 verbs, respectively. Those apps live at the same level as Konjugieren. The sibling apps have lots of verbs because I used books called "French Verbs Made Simple(r)" and "Spanish Verbs Made Simple(r)", respectively, to make those apps. The books had the verbs. Konjugieren has only 990 verbs because its only source of verbs is a frequency-of-use list that had only 990 verbs after data cleansing.

I'd like to add a lot more verbs to Konjugieren. Please identify potential new sources of verbs. Tell me about some verbs you found, if any.

The Claude in Chrome MCP is running; using that if WebFetch or WebSearch doesn't work for a site because of robots.txt or JavaScript rendering.

Two obvious sources are German and English Wiktionary. Please investigate whether currently Konjugieren-unsupported verbs can be extracted from those sources. I note that, if full Wiktionary extraction does happen (it won't in this session), glosses and etymologies, if any, should be extracted with the verbs themselves to avoid recrawling.

Output your findings in a Markdown file in the docs folder.