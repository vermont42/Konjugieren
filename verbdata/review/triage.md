# Review triage

182 findings across 169 verbs, from 44 of 44 shards.

| severity | n |
|---|---|
| high | 16 |
| medium | 90 |
| low | 76 |

| type | n |
|---|---|
| wrong_verb | 6 |
| wrong_sense | 43 |
| bad_gloss | 44 |
| logic | 19 |
| grammar | 19 |
| translation | 44 |
| connotation | 3 |
| comma_splice | 4 |

## high

### irreführen — `wrong_verb`
The sentence contains 'führt … in die Irre', which is the free collocation with the noun 'die Irre', not the separable verb irreführen. Separated, irreführen yields adverbial lowercase 'irre' as the stranded element ('führt … irre'), exactly as the app's forms show. The sentence therefore never displays the verb it is meant to demonstrate.
- current de: Die geschickt formulierte Werbung führt viele Kunden über den wahren Preis in die Irre.
- current en: The cleverly worded ad misleads many customers about the real price.
- **fix de:** Die geschickt formulierte Werbung führt viele Kunden über den wahren Preis irre.
- **fix en:** The cleverly worded ad misleads many customers about the real price.

### zurückmachen — `wrong_verb`
The sentence does not contain zurückmachen. Its construction is the fixed idiom 'sich auf den Heimweg machen' with a stray 'zurück' appended; 'sich auf den Heimweg zurückmachen' is not German (the idiom with a return sense is 'sich auf den Rückweg machen', where 'zurück' is not a verb particle at all). Colloquial zurückmachen in the glossed sense is intransitive and non-reflexive: 'wir machen zurück'.
- current de: Es ist schon spät geworden, wir sollten uns langsam auf den Heimweg zurückmachen.
- current en: It's gotten late already; we should slowly start heading back home.
- **fix de:** Es ist schon spät geworden, wir sollten langsam zurückmachen und nach Hause fahren.
- **fix en:** It's gotten late already; we should start back soon and head home.

### abbleiben — `wrong_sense`
The shipped gloss is 'be located', which for abbleiben lives almost entirely in the idiom 'Wo ist … abgeblieben?' ('where has it got to?'). The sentence instead means 'stay away from family gatherings', so it demonstrates nothing of the glossed sense.
- current de: Seit dem Streit bleibt er allen Familienfeiern konsequent ab und meldet sich bei niemandem.
- current en: Since the argument, he has consistently stayed away from all the family gatherings and doesn't contact anyone.
- **fix de:** Wo ist eigentlich mein zweiter Handschuh abgeblieben? Seit dem Umzug habe ich ihn nicht mehr gesehen.
- **fix en:** Where has my other glove got to? I haven't seen it since the move.

### aufrauchen — `wrong_sense`
The gloss is 'rise, appear' (of smoke or fog rising), but the sentence — 'rauchte seine letzte Zigarre in Ruhe auf' — demonstrates candidate gloss 3, 'to finish smoking (a tobacco product)', which is also what the English translation says ('finished his last cigar'). The rising-smoke sense is intransitive and takes no accusative object; this sentence is transitive.
- current de: Nach dem Essen setzte er sich auf die Terrasse und rauchte seine letzte Zigarre in Ruhe auf.
- current en: After the meal he sat down on the terrace and calmly finished his last cigar.
- **fix de:** Kaum hatte er die Kerze gelöscht, rauchte ein dünner grauer Faden auf.
- **fix en:** The moment he blew out the candle, a thin gray wisp of smoke rose.

### aufrechnen — `wrong_sense`
The gloss is 'charge', but 'die ausstehende Miete gegen die hinterlegte Kaution aufrechnen' is the legal set-off sense — candidate gloss 3, 'to offset'. The construction gegen + accusative is diagnostic of that sense, and the English translation itself renders it 'offsets'.
- current de: Der Vermieter rechnet die ausstehende Miete gegen die hinterlegte Kaution auf.
- current en: The landlord offsets the outstanding rent against the deposit that was put down.
- **fix de:** Der Vermieter rechnet die ausstehende Miete gegen die hinterlegte Kaution auf.
- **fix en:** The landlord offsets the outstanding rent against the deposit that was put down.

### aufschießen — `wrong_sense`
The gloss is 'shoot open' (candidate 1: forcing a lock with a gunshot), but the sentence — bamboo shooting up overnight after warm rain — demonstrates candidate gloss 2, 'to grow quickly, to shoot up (of plants)'. Nothing in the sentence involves a firearm or an object being opened.
- current de: Nach dem warmen Regen schoss der Bambus im Garten geradezu über Nacht auf.
- current en: After the warm rain the bamboo in the garden shot up practically overnight.
- **fix de:** Die Einsatzkräfte schossen das verrostete Vorhängeschloss auf und öffneten den Container.
- **fix en:** The responders shot the rusted padlock open and opened the container.

### vorbauen — `wrong_sense`
The sentence demonstrates 'vorsorgen, sich gegen etwas absichern' — taking precautions against hard times, the proverbial 'wer klug ist, baut vor'. It does not demonstrate the shipped gloss 'preassemble' (prefabricating a component), which would be 'vorfertigen'/'vormontieren'. The sentence itself is good German; the mismatch is with the gloss, so the cleaner fix is to change the gloss rather than the sentence.
- current de: Wer klug ist, baut vor und legt für schlechte Zeiten etwas Geld zurück.
- current en: A wise person takes precautions and sets aside a little money for hard times.

### ansinnen — `bad_gloss`
The shipped gloss 'designate' bears no relation to the verb. 'jemandem etwas ansinnen' means to expect or demand something of someone, usually something unreasonable (cf. the noun 'Ansinnen' = an unreasonable request); it is close to 'zumuten'. The German sentence and its English translation both demonstrate exactly that sense correctly, so only the gloss needs fixing. No candidate_glosses were supplied for this verb, so this is a judgment call rather than a demonstrable import mix-up. Suggested gloss: 'expect or demand (something unreasonable) of someone'.
- current de: Man kann ihm nicht ansinnen, nach der Nachtschicht auch noch das ganze Haus zu putzen.
- current en: You can't expect him to clean the whole house on top of a night shift.

### bescheißen — `bad_gloss`
The sentence ("hat uns beim Wechselkurs ganz übel beschissen") demonstrates the swindle sense, which is candidate_gloss 2, "to rip off, to screw, to swindle". The shipped gloss is the literal scatological sense, so the import took the first listed sense rather than the living one. The German sentence and the English translation are both correct and idiomatic for the swindle sense; the fix belongs in the gloss, not the sentence. The literal sense is essentially confined to fixed expressions and would make a worse example.
- current de: Der windige Händler hat uns beim Wechselkurs ganz übel beschissen.
- current en: The shady dealer totally ripped us off on the exchange rate.
- **fix en:** The shady dealer totally ripped us off on the exchange rate.

### fernschauen — `bad_gloss`
The shipped gloss 'look into the distance' is not the live meaning of fernschauen; in Austrian and southern German usage it is simply the regional word for watching television, which is exactly what the sentence demonstrates. That sense is already present in candidate_glosses ('to watch television'), so this is a mechanical import defect: the first listed sense was taken rather than the usual one. The sentence is good and should be kept; the gloss should become 'watch television'.
- current de: In Österreich schauen viele Familien am Sonntagabend gemeinsam gemütlich fern.
- current en: In Austria many families cozily watch TV together on Sunday evenings.
- **fix en:** In Austria many families settle in together on Sunday evenings to watch TV.

### niederführen — `bad_gloss`
The gloss 'run someone over' is wrong for niederführen, which means 'to lead down' — exactly what the sentence shows ('Ein schmaler Pfad führt vom Aussichtspunkt ... zum Fluss nieder'). 'Run someone over' belongs to the near-homograph niederfahren (or überfahren). The German sentence is correct for the verb's real meaning; the gloss points at a different verb.
- current de: Ein schmaler Pfad führt vom Aussichtspunkt in engen Kehren zum Fluss nieder.
- current en: A narrow path leads down from the overlook to the river in tight switchbacks.

### vorbeischauen — `bad_gloss`
The sentence demonstrates 'drop by, swing by for a short visit' — 'Schau doch morgen kurz bei uns vorbei' can only be read that way. That sense is already listed in candidate_glosses ('to swing by, to visit briefly'), so the shipped gloss 'look past' is a mechanical import defect: the importer took the first-listed literal sense rather than the dominant one. The sentence is correct and idiomatic; the gloss should change to 'drop by, swing by'.
- current de: Schau doch morgen kurz bei uns vorbei, wir haben frischen Kuchen gebacken.
- current en: Why don't you drop by our place tomorrow, we've baked a fresh cake.

### vorkehren — `bad_gloss`
The shipped gloss 'put on display, show off' is the wrong sense. The sentence ('alles Nötige vorgekehrt, damit das Hochwasser keinen Schaden anrichtet') correctly demonstrates the precaution sense: vorkehren = 'Vorkehrungen treffen', i.e. to take precautions / make provisions. That correct sense is already present as candidate_glosses[1] ('to take precaution (regarding something)'), so this is a mechanical import defect where the wrong candidate was promoted to the shipped gloss. The German sentence and English translation are both fine; only the gloss target is wrong.
- current de: Die Gemeinde hat rechtzeitig alles Nötige vorgekehrt, damit das Hochwasser keinen Schaden anrichtet.
- current en: The town made all the necessary provisions in time so that the flooding wouldn't cause any damage.
- **fix en:** The town made all the necessary provisions in time so that the flooding wouldn't cause any damage.

### überfordern — `bad_gloss`
The shipped gloss is 'overcharge', but the sentence and its translation demonstrate the primary sense — demanding more of someone than they can manage, i.e. overwhelm/overtax ('Die vielen gleichzeitigen Aufgaben überforderten den neuen Praktikanten'). Nothing in the sentence involves a price. That sense is the first entry in candidate_glosses and 'overcharge' is the second, so the importer took the wrong one: a mechanical defect, not a judgment call. The German sentence and the English translation are both correct and should be kept; the gloss should read 'overwhelm, overtax'. As shipped, a learner reading the gloss beside this sentence is told a common verb means something it does not mean here.
- current de: Die vielen gleichzeitigen Aufgaben überforderten den neuen Praktikanten schon in der ersten Woche völlig.
- current en: The many simultaneous tasks completely overwhelmed the new intern in his very first week.

### beschweigen — `grammar`
Valency error: beschweigen is transitive (etwas beschweigen), and the sentence gives it a prepositional object in an impersonal passive ("Über die dunklen Jahre … wurde … beschwiegen"), which is the frame of the simplex schweigen (über etwas schweigen). The be- prefix is precisely what promotes the prepositional object to accusative, so the sentence undoes the derivation it is meant to demonstrate. It should be a personal passive with the years as subject.
- current de: Über die dunklen Jahre der Familiengeschichte wurde am Esstisch stets beharrlich beschwiegen.
- current en: The dark years of the family history were always doggedly passed over in silence at the dinner table.
- **fix de:** Die dunklen Jahre der Familiengeschichte wurden am Esstisch stets beharrlich beschwiegen.

### klarträumen — `grammar`
'zu klarträumen' is wrong: a separable-prefix verb infixes zu between prefix and stem, giving 'klarzuträumen' (which is what the app itself generates). The sentence models the error a learner is most likely to make with this class of verb.
- current de: Nach wochenlangem Üben gelang es ihm endlich, bewusst zu klarträumen und im Traum zu fliegen.
- current en: After weeks of practice he finally managed to lucid dream consciously and fly in his dream.
- **fix de:** Nach wochenlangem Üben gelang es ihm endlich, bewusst klarzuträumen und im Traum zu fliegen.


## medium

### festkleben — `wrong_verb`
In 'klebte so fest am Schuh' the word 'fest' is a degree-modified adverb, not the separable particle: a particle cannot be modified by 'so' (compare 'er klebte es so fest an', which is impossible). The sentence therefore reads as kleben + fest 'stick firmly', not festkleben. Independently, the shipped gloss 'glue firmly' is transitive — glue something onto something — while the sentence is intransitive 'be stuck'. A transitive example fixes both at once.
- current de: Das alte Kaugummi klebte so fest am Schuh, dass ich es kaum abbekam.
- current en: The old gum stuck so firmly to the shoe that I could barely get it off.
- **fix de:** Sie klebte das Etikett mit etwas Leim sorgfältig auf dem Marmeladenglas fest.
- **fix en:** She carefully glued the label onto the jam jar with a bit of paste.

### unterheben — `wrong_verb`
'unter' here has an object — 'unter den Teig' — so it is a preposition, not the separable particle, and the verb actually demonstrated is plain heben with a directional PP. The particle verb unterheben leaves the particle bare at the end of the clause and takes only the folded-in ingredient as its object: 'den Eischnee unterheben'. The two constructions are alternatives, not combinable; recipes write either 'unter den Teig heben' or 'unterheben', never both.
- current de: Zum Schluss hebt man den steifen Eischnee ganz vorsichtig unter den Teig.
- current en: At the very end you gently fold the stiff beaten egg whites into the batter.
- **fix de:** Zum Schluss hebt man den steifen Eischnee ganz vorsichtig unter.
- **fix en:** At the very end you gently fold in the stiff beaten egg whites.

### untermischen — `wrong_verb`
Same particle-versus-preposition problem: 'unter den Teig' gives 'unter' an accusative object, making it a preposition, so the sentence demonstrates plain mischen, not untermischen. The particle verb takes the receiving substance in the dative and strands the bare particle at the end: 'Er mischte dem Teig etwas Zimt unter.'
- current de: Er mischte heimlich etwas Zimt unter den Teig, damit die Kekse besser dufteten.
- current en: He secretly mixed a little cinnamon into the dough so the cookies would smell better.
- **fix de:** Er mischte dem Teig heimlich etwas Zimt unter, damit die Kekse besser dufteten.

### wegwünschen — `wrong_verb`
'weit weg' parses as the free directional adverbial 'far away' modifying plain wünschen, not as the separable particle of wegwünschen — compare 'wirf den Ball weit weg', which is not wegwerfen in the dispose sense. The app's form for this slot is 'wünschte … weg', which the inserted 'weit' obscures. Duden also gives the verb as reflexive-dative, 'sich jemanden wegwünschen'; the missing 'sich' costs the sentence its idiomaticity even apart from the particle problem.
- current de: An anstrengenden Tagen wünschte sie ihre lärmenden Nachbarn weit weg.
- current en: On exhausting days she wished her noisy neighbors far, far away.
- **fix de:** An anstrengenden Tagen wünschte sie sich ihre lärmenden Nachbarn einfach weg.
- **fix en:** On exhausting days she simply wished her noisy neighbors away.

### abbinden — `wrong_sense`
The shipped gloss is 'untie, undo', but the sentence shows a paramedic applying a tourniquet to stop bleeding, which is the 'ligate / tie off' sense — already listed separately in candidate_glosses as 'to ligate'. The English translation ('tied off') confirms the mismatch: it does not render 'untie, undo' at all. A sentence for the shipped gloss needs abbinden as the reversal of anbinden/zubinden.
- current de: Der Sanitäter band den blutenden Oberarm rasch ab, um die schlimmste Blutung zu stoppen.
- current en: The paramedic quickly tied off the bleeding upper arm to stop the worst of the bleeding.
- **fix de:** Nach dem Kochen band sie die Schürze ab und hängte sie ordentlich an den Haken.
- **fix en:** After cooking, she untied her apron and hung it neatly on the hook.

### abkochen — `wrong_sense`
The shipped gloss is 'boil down, boil off' (reducing a liquid, especially a broth), but boiling tap water so it is safe to drink is the sanitising sense, which candidate_glosses lists separately as 'to boil a liquid shortly in order to sanitise it'. The English 'boil the tap water before drinking it' demonstrates that fourth sense, not the first.
- current de: Bei einem Stromausfall muss man das Leitungswasser vor dem Trinken sicherheitshalber abkochen.
- current en: During a power outage, you have to boil the tap water before drinking it, just to be safe.
- **fix de:** Der Koch kochte die Brühe stundenlang ab, bis nur noch ein kräftiger, dunkler Fond übrig war.
- **fix en:** The cook boiled the broth down for hours until only a strong, dark stock was left.

### antanzen — `wrong_sense`
The sentence demonstrates candidate gloss 2, 'to go and arrive (somewhere), typically against one's wishes' — the colloquial 'show up unannounced' reading, which the English translation ('He just showed up at our place unannounced') confirms. It does not demonstrate the shipped gloss 'approach or arrive dancing'; nobody in the sentence is dancing. Since the shipped sentence exercises the far more common everyday sense, aligning the gloss to candidate 2 is the cleaner fix than rewriting the German around a rare literal reading.
- current de: Er tanzte einfach unangemeldet bei uns an und erwartete auch noch Abendessen.
- current en: He just showed up at our place unannounced and expected dinner on top of it.

### antrinken — `wrong_sense`
The shipped gloss is 'get drunk or tipsy' (candidate sense 1), but the sentence 'trank er sich heimlich Mut an' demonstrates candidate sense 2, 'to obtain some quality by getting drunk, for example courage' (sich Mut antrinken). It shows acquiring courage through drink, not the state of becoming drunk. A learner reading the gloss beside this sentence would misattach the collocation.
- current de: Vor der Rede trank er sich heimlich Mut an, was man ihm später deutlich anmerkte.
- current en: Before the speech he secretly drank himself some courage, which was clearly noticeable afterward.
- **fix de:** Auf der Betriebsfeier hatte er sich noch vor dem Essen einen ordentlichen Schwips angetrunken.
- **fix en:** At the office party he had already drunk himself pleasantly tipsy before dinner.

### anwerfen — `wrong_sense`
The shipped gloss is 'throw at' (candidate sense 1), but the sentence 'warf er den alten Rasenmäher an' demonstrates candidate sense 2, 'to start up (an engine etc.)' — and the English translation itself renders it 'started up the old lawnmower', confirming the mismatch is between gloss and sentence, not within the German. Either the gloss should become 'start up (an engine)' or the sentence should be rewritten to show 'throw at'.
- current de: Mit einem kräftigen Ruck an der Schnur warf er den alten Rasenmäher an.
- current en: With a hard pull on the cord he started up the old lawnmower.
- **fix de:** Im Streit warf ihm der Bruder eine Handvoll nassen Sand an.
- **fix en:** In the quarrel his brother threw a handful of wet sand at him.

### aufstreben — `wrong_sense`
The sentence contains no finite form of aufstreben — only the attributive present participle 'aufstrebenden', which has lexicalized as an adjective meaning 'up-and-coming, burgeoning'. A neighborhood does not aspire, so the sentence does not demonstrate the glossed sense 'aspire'; it demonstrates the adjective. A learner meeting the verb here sees no conjugation and infers the wrong meaning.
- current de: In dem aufstrebenden Viertel eröffnen jede Woche neue Cafés und kleine Galerien.
- current en: In the up-and-coming neighborhood new cafés and small galleries open every week.
- **fix de:** Aus einfachen Verhältnissen strebte der junge Geiger bis auf die großen Konzertbühnen auf.
- **fix en:** From humble beginnings the young violinist rose to the great concert stages.

### auslagern — `wrong_sense`
The sentence demonstrates 'to outsource' ('Die Firma hat ihre Buchhaltung nach Polen ausgelagert' / 'The company outsourced its accounting to Poland'), which is candidate_glosses #2, not the shipped gloss 'swap' (the IT memory-swapping sense). The German and English are correct and internally consistent; the mismatch is between them and the gloss.
- current de: Die Firma hat ihre Buchhaltung nach Polen ausgelagert, um Kosten zu sparen.
- current en: The company outsourced its accounting to Poland in order to cut costs.

### ausrauchen — `wrong_sense`
The sentence and its translation both demonstrate 'to finish smoking (a tobacco product)' ('Er rauchte seine Zigarette in Ruhe aus' / 'He finished smoking his cigarette'), which is candidate_glosses #2, not the shipped gloss 'smoke out' (driving something out by smoke, candidate #1). The German is correct; the gloss is the wrong sense for this sentence.
- current de: Er rauchte seine Zigarette in Ruhe aus, bevor er wieder ins Büro ging.
- current en: He finished smoking his cigarette in peace before going back into the office.

### dichthalten — `wrong_sense`
The sentence demonstrates the figurative sense 'keep one's mouth shut, keep mum' (candidate_glosses[1]), not the shipped gloss 'stay sealed'. "eisern dichthalten" about a surprise party is unambiguously about not divulging a secret; the shipped gloss is about a seal, roof, or container not leaking.
- current de: Egal wie sehr man ihn über die Überraschungsparty ausfragte, er hielt eisern dicht.
- current en: No matter how much they quizzed him about the surprise party, he kept his mouth firmly shut.
- **fix de:** Trotz des tagelangen Dauerregens hielt das neu gedeckte Dach überall dicht.
- **fix en:** Despite days of steady rain, the newly re-shingled roof stayed watertight everywhere.

### dichtmachen — `wrong_sense`
The sentence demonstrates 'close down, shutter (a business)' (candidate_glosses[1]), not the shipped gloss 'close off, seal up'. A bakery going out of business after thirty years is the business-closure sense; the shipped gloss is the physical one (sealing windows, a gap, a container).
- current de: Nach dreißig Jahren musste die kleine Bäckerei an der Ecke endgültig dichtmachen.
- current en: After thirty years, the little bakery on the corner finally had to close down for good.
- **fix de:** Vor dem angekündigten Sturm machten wir alle Fenster und Läden sorgfältig dicht.
- **fix en:** Before the forecast storm we carefully sealed up all the windows and shutters.

### draufgehen — `wrong_sense`
The sentence demonstrates the 'be used up, be consumed' sense (money or time going on something), which is neither the shipped gloss 'fall apart' nor the listed alternative 'to die'. Savings do not fall apart; they get eaten up.
- current de: Für die teure Autoreparatur ging fast mein ganzes Erspartes drauf.
- current en: Almost all of my savings went on the expensive car repair.
- **fix de:** Bei der letzten Bergtour ist mein alter Rucksack endgültig draufgegangen.
- **fix en:** On the last mountain hike my old backpack finally fell apart for good.

### durchbrennen — `wrong_sense`
A burned-out light bulb is the 'blow, blow out (of a fuse, wire)' sense listed separately as candidate_glosses[2]. The shipped gloss 'continue to burn, burn through' corresponds to candidate_glosses[0], which is temporal — a fire burning through the night — and the sentence does not demonstrate it.
- current de: Die Glühbirne im Flur ist schon wieder durchgebrannt und muss ausgetauscht werden.
- current en: The bulb in the hallway has burned out again and needs to be replaced.
- **fix de:** Das Feuer im Kamin brannte die ganze Nacht durch, sodass es am Morgen noch warm war.
- **fix en:** The fire in the fireplace burned right through the night, so it was still warm in the morning.

### durcheinanderbringen — `wrong_sense`
The sentence demonstrates 'bewilder, confuse, befuddle (a person)' (candidate_glosses[1]) — jemanden durcheinanderbringen. The shipped gloss 'jumble' is the sense with a non-human object, etwas durcheinanderbringen, i.e. physically mixing up an ordered set of things.
- current de: Der laute Straßenlärm brachte ihn so durcheinander, dass er beim Rechnen den Faden verlor.
- current en: The loud street noise mixed him up so badly that he lost his train of thought while doing the math.
- **fix de:** Beim Suchen hat er meine sorgfältig sortierten Karteikarten völlig durcheinandergebracht.
- **fix en:** While searching, he completely jumbled my carefully sorted index cards.

### durchgreifen — `wrong_sense`
The gloss is 'grasp through' (the literal sense), but the sentence 'griff … endlich hart durch und sperrte die Handys' demonstrates the idiomatic 'hart durchgreifen' = take firm action / crack down, which is the separate candidate gloss 'to take action'. A learner reading the gloss 'grasp through' beside a sentence about a school cracking down on phones would be misled.
- current de: Nach der dritten Beschwerde griff die Schulleitung endlich hart durch und sperrte die Handys.
- current en: After the third complaint, the school administration finally cracked down and banned phones.
- **fix de:** Der Höhleneingang war zugewuchert, doch sie griff durch das Gestrüpp durch und tastete nach dem Seil.
- **fix en:** The cave entrance was overgrown, but she reached through the undergrowth and felt for the rope.

### entgegenhalten — `wrong_sense`
The purpose clause 'um ihre Version der Geschichte zu beweisen' makes the argumentative reading dominant — 'jemandem etwas entgegenhalten' in the sense of adducing something against an opponent's claim, which is candidate gloss 2 ('to counter, to retort'), not the shipped gloss 'hold out something to someone'. Holding photos out physically is demonstrated only if the goal is that he take or see them; as written, the photos function as evidence in a dispute, which is the other sense. Fix keeps the object and gesture and swaps the purpose for a physical one.
- current de: Sie hielt ihm die alten Fotos entgegen, um ihre Version der Geschichte zu beweisen.
- current en: She held out the old photos to him to prove her version of the story.
- **fix de:** Sie hielt ihm die alten Fotos entgegen, damit er die Gesichter im Licht besser erkennen konnte.
- **fix en:** She held the old photos out to him so he could make out the faces better in the light.

### fernliegen — `wrong_sense`
The sentence demonstrates the fixed idiom 'es liegt mir fern, etwas zu tun' = 'far be it from me to …', which is the second candidate gloss ('to not be one's intention'), not the shipped gloss 'be alien to'. The 'be alien to' sense takes a nominal subject denoting an attitude or idea (Neid, solche Gedanken, jeder Fanatismus) rather than an extraposed zu-infinitive. Cleanest repair is probably to ship the second candidate gloss for this sentence; the alternative is to rewrite the sentence to the nominal-subject pattern, as below.
- current de: Es liegt mir fern, dir Vorschriften zu machen, aber überlege dir das gut.
- current en: It's far from my intention to boss you around, but think it over carefully.
- **fix de:** Jede Form von Neid liegt ihr völlig fern; sie gönnt anderen ihren Erfolg von Herzen.
- **fix en:** Any form of envy is utterly alien to her; she is genuinely glad of others' success.

### gehaben — `wrong_sense`
The gloss is 'behave, behave oneself', but the sentence „Gehabt euch wohl!" with its translation 'Fare you well!' demonstrates the distinct 'to fare' sense (sich wohl gehaben = to be/fare well), which candidate_glosses lists separately as 'to fare'. The shipped gloss and the English translation point at different senses; a learner reading gloss 'behave oneself' beside a farewell would be misled. Recommend aligning the gloss to 'fare (well)' for this idiom, or leaving the sentence and changing the gloss.
- current de: Zum Abschied rief der alte Wirt uns von der Tür aus „Gehabt euch wohl!“ nach.
- current en: As we left, the old innkeeper called after us from the doorway, “Fare you well!”

### gleichschalten — `wrong_sense`
The gloss is 'synchronise' — the marginal, neutral electrical-engineering sense — but the sentence about a new government forcing the press into line demonstrates the political sense of subjugating thought and action to the ruling class (Gleichschaltung), which candidate_glosses lists as 'to force into Gleichschaltung' and 'to subjugate someone's thought and action to the policies and worldview of the ruling class'. The dominant, historically Nazi-freighted meaning is what the sentence shows; glossing it as harmless 'synchronise' could lead a learner to use the word casually, which would be jarring. Recommend a gloss like 'bring into line, force into conformity'. The German sentence and English translation themselves are correct.
- current de: Die neue Regierung versuchte, die Presse gleichzuschalten und kritische Stimmen zum Schweigen zu bringen.
- current en: The new government tried to bring the press into line and silence critical voices.

### hereinlegen — `wrong_sense`
The shipped gloss is the literal 'lay down inside, put', but the sentence 'hat uns der Verkäufer gründlich hereingelegt' / 'took us in' demonstrates the figurative sense 'jemanden hereinlegen' = to trick/con someone. candidate_glosses lists 'to trick; to pull someone's leg' as a distinct sense, so this is a sense/gloss mismatch rather than a judgment call. Either the gloss should be corrected to 'trick, con' (the sentence is natural and good for that sense), or the sentence should be rewritten to show the literal 'put/lay inside' meaning.
- current de: Mit dem angeblichen Schnäppchen hat uns der Verkäufer gründlich hereingelegt.
- current en: The salesman completely took us in with that supposed bargain.

### hinwegsetzen — `wrong_sense`
The sentence 'Er setzte sich einfach über das Verbot hinweg' demonstrates the reflexive figurative sense 'sich über etwas hinwegsetzen' = to flout/disregard/defy — which is candidate_gloss #2 '(über) to flout, to override, to dismiss, to defy, to ignore'. It does not demonstrate the shipped gloss 'leap over, jump over', which is the literal, non-reflexive sein-auxiliary sense (e.g. 'über einen Graben hinwegsetzen'). To keep the shipped gloss, the sentence must show the literal leap; to keep the sentence, the gloss should be the disregard sense.
- current de: Er setzte sich einfach über das Verbot hinweg und stellte sein Rad wieder vor den Eingang.
- current en: He simply disregarded the ban and parked his bike in front of the entrance again.
- **fix de:** Das Pferd setzte in vollem Galopp mühelos über den breiten Graben hinweg.
- **fix en:** At full gallop the horse cleared the wide ditch with ease.

### lockermachen — `wrong_sense`
The shipped gloss is 'loosen', but 'achthundert Euro lockermachen' (English 'shell out eight hundred euros') demonstrates the money sense, which is already listed as candidate_glosses[1] 'to pay out'. This is a mechanical import mismatch: the sentence is correct German, but it teaches the wrong target sense.
- current de: Für das neue Rennrad musste er am Ende doch achthundert Euro lockermachen.
- current en: In the end he had to shell out eight hundred euros for the new road bike.
- **fix de:** Er machte die festgerostete Schraube mit ein paar Tropfen Öl endlich wieder locker.
- **fix en:** With a few drops of oil he finally loosened the rusted-on screw again.

### losbrechen — `wrong_sense`
The shipped gloss is 'break off', but 'brach … ein ohrenbetäubender Jubel los' (English 'a deafening cheer erupted') demonstrates the sudden-onset sense, already listed as candidate_glosses[1] 'to break out (begin suddenly)'. The sentence is correct German but teaches the wrong target sense.
- current de: Als das Tor fiel, brach im Stadion ein ohrenbetäubender Jubel los.
- current en: When the goal went in, a deafening cheer erupted in the stadium.
- **fix de:** Ein großer Felsbrocken brach von der Steilwand los und stürzte in die Tiefe.
- **fix en:** A large boulder broke loose from the cliff face and crashed into the depths below.

### nachbeten — `wrong_sense`
The sentence demonstrates the figurative sense 'to parrot' (candidate gloss 2) — pupils repeating memorized formulas mindlessly — not the shipped gloss 'repeat a prayer' (candidate gloss 1). The English translation confirms this: it renders the verb as 'parroted', with no prayer anywhere in the sentence. Either the sentence should show the literal liturgical sense, or the shipped gloss should be changed to 'parrot'.
- current de: Die Schüler beteten die auswendig gelernten Formeln nach, ohne sie wirklich zu verstehen.
- current en: The pupils parroted the memorized formulas without really understanding them.
- **fix de:** Bei der Andacht beteten die Kinder die Worte des Priesters leise nach.
- **fix en:** During the service, the children quietly repeated the priest's words after him.

### niederhauen — `wrong_sense`
The gloss is 'defeat' (candidate_glosses' 'to defeat (an enemy)'), but the sentence — a robber striking a single guard unconscious during a heist — and its own English ('struck the guard down') demonstrate candidate_glosses' third sense, 'to strike (someone) down, to beat (someone) down'. A robbery is not a contest, so 'defeat' does not fit; the label should be 'strike/cut down'.
- current de: Der Räuber hieb den Wächter nieder und verschwand mit der Kasse in der Dunkelheit.
- current en: The robber struck the guard down and disappeared into the darkness with the till.

### verbeißen — `wrong_sense`
The sentence 'Sie musste sich das Lachen verbeißen' demonstrates the reflexive 'suppress/stifle' sense (candidate gloss 'to suppress, to stifle (e.g., a smile, laughter, pain)'), which the English 'bite back her laughter' correctly renders. But the shipped gloss is 'bite the bit', a different sense. The German and English are both fine; only the gloss it is filed under is mismatched.
- current de: Sie musste sich das Lachen verbeißen, als der Chef klatschnass und ohne Schirm ins Büro kam.
- current en: She had to bite back her laughter when the boss walked into the office soaking wet and without an umbrella.

### verlügen — `wrong_sense`
The gloss is transitive 'lie about someone or something', but the sentence demonstrates a reflexive 'sich in etwas verlügen' — entangling oneself in one's own lies — which is a different (and very marginal) use. The English translation confirms the drift: 'tangled himself up in his excuses' contains no notion of lying about anything. There is a second problem that makes the sentence poor as a teaching example even on its own terms: 'verlogen' is overwhelmingly read as the everyday adjective meaning 'mendacious', so 'Er hatte sich so in seine Ausreden verlogen' garden-paths a reader rather than showing a participle of verlügen.
- current de: Er hatte sich so in seine Ausreden verlogen, dass ihm am Ende niemand mehr glaubte.
- current en: He had tangled himself up in his excuses so badly that in the end no one believed him anymore.
- **fix de:** Statt die Wahrheit zu sagen, verlog er den ganzen Hergang des Unfalls.
- **fix en:** Instead of telling the truth, he lied about the whole course of the accident.

### verstehlen — `wrong_sense`
The sentence uses the reflexive 'sich verstehlen' ('verstahl er sich leise aus dem Saal'), which means 'to steal away, sneak off' — candidate gloss #2 — not the shipped gloss 'steal' (take property). The English 'slipped out of the hall' confirms the sneak-off sense, not theft.
- current de: Als der Redner endlich Luft holte, verstahl er sich leise aus dem überfüllten Saal.
- current en: When the speaker finally paused for breath, he quietly slipped out of the packed hall.
- **fix de:** Der Dieb hatte dem schlafenden Gast in der Nacht die Brieftasche verstohlen.
- **fix en:** In the night the thief had stolen the sleeping guest's wallet.

### wegrauchen — `wrong_sense`
The shipped gloss 'smoke away something' corresponds to candidate_gloss 4, where the direct object is the feeling being suppressed (Ärger, Kummer, Stress). The sentence's object is 'eine ganze Schachtel', so it demonstrates candidate_glosses 2/3 instead — smoking an entire supply, or smoking large quantities quickly without enjoyment. 'Vor lauter Nervosität' gestures at the coping sense but does not make the pack the thing smoked away.
- current de: Vor lauter Nervosität hat er an dem Abend eine ganze Schachtel weggeraucht.
- current en: Out of sheer nervousness, he smoked his way through a whole pack that evening.
- **fix de:** Nach dem Streit ging er auf den Balkon und rauchte seinen Ärger weg.
- **fix en:** After the argument he went out on the balcony and smoked his anger away.

### wegsterben — `wrong_sense`
wegsterben takes animate subjects — people or animals dying off one after another ('die Alten sterben nach und nach weg'). With an inanimate, abstract subject such as 'die alten Handwerksberufe', German idiom requires aussterben. The English confirms the drift: 'are slowly dying out' is aussterben, not wegsterben. Restoring an animate subject keeps the village scene and demonstrates the shipped gloss 'die, vanish (by dying)'.
- current de: In dem kleinen Bergdorf sterben die alten Handwerksberufe langsam weg.
- current en: In the small mountain village, the old crafts are slowly dying out.
- **fix de:** In dem kleinen Bergdorf sind die alten Handwerker nach und nach weggestorben, und niemand führt ihre Werkstätten fort.
- **fix en:** In the small mountain village the old craftsmen died off one by one, and no one carries on their workshops.

### zupacken — `wrong_sense`
The shipped gloss is 'grab, grip, hold on', but 'Als es viel zu tragen gab, packte er ohne Zögern zu' demonstrates the second listed sense, 'to knuckle down / pitch in with work' — as the English translation ('pitched in') itself confirms. Nothing is grabbed or gripped in the sentence.
- current de: Als es viel zu tragen gab, packte er ohne Zögern zu und schleppte die schwersten Kisten.
- current en: When there was a lot to carry, he pitched in without hesitating and lugged the heaviest boxes.
- **fix de:** Als ihm das nasse Seil entglitt, packte er blitzschnell zu und hielt es fest.
- **fix en:** When the wet rope slipped out of his hand, he grabbed hold in a flash and held on.

### zurückversetzen — `wrong_sense`
The shipped gloss 'transfer back, shift back' is candidate_glosses[0] (reassigning someone back into a department/assignment they held before). The sentence 'Der Geruch von frischen Waffeln versetzte sie sofort in ihre Kindheit zurück' instead demonstrates candidate_glosses[2], the metaphorical 'transport back to an earlier time by evoked association.' The German and English are both fine, but they illustrate a different sense than the label.
- current de: Der Geruch von frischen Waffeln versetzte sie sofort in ihre Kindheit zurück.
- current en: The smell of fresh waffles instantly took her back to her childhood.

### übereintreffen — `wrong_sense`
The sentence uses the frame 'überein…, den Vertrag zu verlängern' — a zu-infinitive complement expressing a jointly resolved course of action. That frame belongs to übereinkommen ('beide Seiten kamen überein, den Vertrag zu verlängern'), not to übereintreffen. Where übereintreffen is attested at all it is the rare/archaic equivalent of übereinstimmen: two accounts, statements or figures coinciding in content ('die Aussagen trafen überein'). The particle is right and the verb is present character for character, so this is not a wrong_verb, but the sentence demonstrates a construction the verb does not license. If the shipped gloss 'come to terms, reach an agreement' is meant to stand, the verb that carries that meaning is übereinkommen and this is a gloss defect; if the verb is to stay, the sentence needs the coincide sense.
- current de: Nach zähen Verhandlungen trafen beide Seiten schließlich überein, den Vertrag zu verlängern.
- current en: After tough negotiations, both sides finally came to terms on extending the contract.
- **fix de:** Nach zähen Verhandlungen trafen die Vorstellungen beider Seiten schließlich überein.
- **fix en:** After tough negotiations, the two sides' positions finally coincided.

### überzahlen — `wrong_sense`
The sentence 'hat sie ... deutlich überzahlt' means she overpaid (paid far too much) — that is candidate_glosses[1] 'to overpay', reinforced by 'deutlich' and 'für den wackeligen Schrank'. The shipped gloss is 'pay, transfer money' (candidate_glosses[0]), a different real sense. The sentence is correct German but demonstrates the wrong target sense; 'overpay' is in fact the dominant meaning of überzahlen, so the gloss selection itself is also questionable.
- current de: Für den wackeligen Schrank hat sie beim Antiquitätenhändler deutlich überzahlt.
- current en: She paid far too much for that wobbly cabinet at the antique dealer's.
- **fix de:** Weil gute Fachkräfte so gefragt sind, überzahlt der Betrieb seine Monteure deutlich über dem Tariflohn.
- **fix en:** Because skilled workers are in such demand, the company pays its fitters well above the standard wage.

### abschmecken — `bad_gloss`
The shipped gloss 'taste a dish and, if necessary' is truncated mid-clause: the dictionary definition is 'to taste a dish and, if necessary, to season it', and the import cut it at the second comma. The German sentence and its translation both correctly demonstrate that sense (tasting, then correcting the seasoning), so only the gloss is defective. Suggested gloss: 'season to taste'.
- current de: Bevor sie die Suppe servierte, schmeckte sie sie noch einmal mit Salz und frischem Pfeffer ab.
- current en: Before serving the soup, she seasoned it one more time with salt and fresh pepper to taste.

### absenden — `bad_gloss`
The shipped gloss 'forward, send on' is the meaning of weiterleiten/weitersenden, not absenden. absenden means to send off, dispatch, mail, or (of a form) submit — it says nothing about passing something along that was received from someone else. The sentence and its English ('submit it with a single click') demonstrate the correct meaning, so the gloss is the defect. Suggested gloss: 'send off, dispatch, submit'.
- current de: Sobald du das Formular vollständig ausgefüllt hast, kannst du es mit einem Klick absenden.
- current en: As soon as you've filled out the form completely, you can submit it with a single click.

### abtöten — `bad_gloss`
The shipped gloss 'mortify' is the rare ascetic-religious sense (das Fleisch abtöten), and it is the first of the two candidate glosses — a mechanical import defect that took entry order for frequency. The everyday meaning, already present as candidate gloss 2 ('to kill; to kill off; usually in masses, of vermin or germs'), is what the sentence demonstrates: 'Kochendes Wasser tötet die meisten Keime im Trinkwasser zuverlässig ab.' The German and English are both correct; the gloss should be changed to 'kill off' rather than the sentence rewritten.
- current de: Kochendes Wasser tötet die meisten Keime im Trinkwasser zuverlässig ab.
- current en: Boiling water reliably kills off most germs in drinking water.

### anhauen — `bad_gloss`
The sentence is correct German for the colloquial 'accost / hit up for money' sense of anhauen ('haute er mich an, ob ich ihm … zwanzig Euro leihen könne'), and the English 'hit me up' renders it well. But the shipped gloss 'hit' reads as the physical-strike sense (as in 'sich den Kopf anhauen'), which the sentence does not demonstrate. candidate_glosses[1] already carries the right sense: 'to accost (to approach someone with a demand or request)'. This is a mechanical import defect: the gloss should be that sense, not 'hit'.
- current de: Auf dem Flur haute er mich an, ob ich ihm bis Montag zwanzig Euro leihen könne.
- current en: In the hallway he hit me up about whether I could lend him twenty euros until Monday.

### anscheinen — `bad_gloss`
The sentence is correct and demonstrates 'shine on (someone or something)', which is already present as candidate gloss 2. The shipped gloss 'appear, seem' is the archaic impersonal use ('es scheint mich an') that survives today essentially only in the adverb 'anscheinend'; Duden gives separable anscheinen only as '(von der Sonne, vom Mond o. Ä.) auf jemanden, etwas scheinen'. The import took candidate 1 where candidate 2 is the living sense. Keep the sentence; change the gloss.
- current de: Die Morgensonne schien die alte Fassade an und ließ den bröckelnden Putz golden leuchten.
- current en: The morning sun shone on the old façade and made the crumbling plaster glow golden.

### aufrauchen — `bad_gloss`
'rise, appear' is candidate gloss 1 and is attested, but it is the rare, literary sense. The ordinary modern sense of aufrauchen is the one the sentence already demonstrates — finishing or using up a tobacco supply. Changing the gloss to 'finish smoking, use up (tobacco)' is the cheaper fix and leaves a good sentence in place.
- current de: Nach dem Essen setzte er sich auf die Terrasse und rauchte seine letzte Zigarre in Ruhe auf.
- current en: After the meal he sat down on the terrace and calmly finished his last cigar.

### aufrechnen — `bad_gloss`
'charge' looks like a mechanical import defect: it is candidate gloss 1, but aufrechnen's core meaning is 'to offset, set off (one claim against another)', which is already present as candidate gloss 3. Fixing the gloss to 'offset' makes the existing sentence correct and needs no change to the German or the English.
- current de: Der Vermieter rechnet die ausstehende Miete gegen die hinterlegte Kaution auf.
- current en: The landlord offsets the outstanding rent against the deposit that was put down.

### aufschießen — `bad_gloss`
'shoot open' is attested but is the narrowest and rarest of the four senses; the plant sense the sentence already demonstrates is the common one and is listed as candidate gloss 2. Retargeting the gloss to 'grow quickly, shoot up' preserves the existing sentence, which is idiomatic and well chosen.
- current de: Nach dem warmen Regen schoss der Bambus im Garten geradezu über Nacht auf.
- current en: After the warm rain the bamboo in the garden shot up practically overnight.

### ausfolgen — `bad_gloss`
The shipped gloss 'follow, accompany' is wrong. 'ausfolgen' is Austrian administrative German for 'to hand over, to deliver' (= aushändigen), and the sentence ('Das Fundbüro folgte ihr die verlorene Brieftasche … aus' / 'The lost-property office handed over her lost wallet') correctly demonstrates that sense — which is already listed as candidate_glosses #2. The 'follow, accompany' reading looks like a mechanical import mis-split by analogy to 'folgen'; the German sentence itself is correct.
- current de: Das Fundbüro folgte ihr die verlorene Brieftasche erst nach Vorlage des Ausweises aus.
- current en: The lost-property office only handed over her lost wallet once she showed her ID.

### ausschweigen — `bad_gloss`
The shipped gloss "stop talking, be quiet" describes a cessative sense the verb does not have. sich ausschweigen is obligatorily reflexive and takes a topic (über/zu etwas): it means to keep silent about something, to refuse to comment. The sentence itself is correct and idiomatic and demonstrates that real sense; it is the gloss that is wrong. No candidate_glosses were imported for this verb, so this is a judgment call rather than a demonstrable import defect.
- current de: Zu den schweren Vorwürfen schwieg sich der Minister tagelang beharrlich aus.
- current en: The minister stubbornly kept silent about the serious accusations for days.
- **fix en:** Gloss should read: keep silent (about something), refuse to comment.

### beehren — `bad_gloss`
The shipped gloss 'compliment' does not match beehren. The sentence uses the canonical collocation 'beehrte ... mit seiner Anwesenheit' = 'to honor/grace someone with one's presence', and the English correctly renders it 'honored'. beehren means 'to honor/grace/favor', never 'to compliment' (which would be 'ein Kompliment machen'). The other candidate_gloss 'to favor' is the nearer sense, so the import selected the wrong one of two available senses. The German sentence and the English translation are both correct; only the target gloss is wrong.
- current de: Nach drei Jahren beehrte er das Familienfest endlich wieder mit seiner Anwesenheit.
- current en: After three years he finally honored the family party with his presence again.

### einkriegen — `bad_gloss`
The sentence uses reflexive 'sich vor Lachen gar nicht mehr einkriegen', which is the 'calm oneself / not be able to stop' sense — already listed as candidate_glosses[1] ('to calm oneself'). The shipped gloss 'catch up' is a different, real sense of einkriegen but not the one the sentence demonstrates. This is a mechanical import defect: the correct sense is in candidate_glosses. Gloss should be something like 'calm down (oneself)'.
- current de: Als er die Verkleidung seines Bruders sah, konnte er sich vor Lachen gar nicht mehr einkriegen.
- current en: When he saw his brother's costume, he simply couldn't stop laughing.

### einrollen — `bad_gloss`
The sentence 'Er rollte die Poster vorsichtig ein' means he rolled the posters UP (furled them) — candidate_glosses[1] ('to roll up something, to furl something'), which the English translation correctly renders as 'rolled up the posters'. The shipped gloss 'roll in' is candidate_glosses[0], the intransitive 'a train/tank rolls in' sense, a different meaning. Mechanical import picked the wrong candidate; gloss should be 'roll up, furl'.
- current de: Er rollte die Poster vorsichtig ein und schob sie in eine stabile Papphülse.
- current en: He rolled up the posters carefully and slid them into a sturdy cardboard tube.

### entgegensehen — `bad_gloss`
The shipped gloss 'look at' is a literal calque of the parts (entgegen + sehen) and is not a live meaning of the verb: 'einer Sache entgegensehen' means to await, face, or look forward to something. The sentence is correct German and idiomatic, but it demonstrates candidate gloss 2, 'to await something, look forward to something', which the import already found and did not ship — so this is a mechanical import defect, not a judgment call. Recommend replacing the gloss with 'look forward to, await' and leaving the sentence untouched.
- current de: Wir sehen dem Konzert am Wochenende mit großer Vorfreude entgegen.
- current en: We are looking forward to the concert this weekend with great anticipation.
- **fix en:** We are looking forward to the concert this weekend with great anticipation.

### entmieten — `bad_gloss`
The shipped gloss 'of a landlord' is a truncated dictionary usage label, not a meaning: the source entry was evidently '(of a landlord) to clear a building of its tenants', and only the parenthetical survived the import. As shipped, the learner is told nothing about what the verb means. The sentence and its translation are correct and demonstrate the verb well; only the gloss needs replacing, e.g. 'clear a building of tenants'.
- current de: Der Investor wollte das Altbauhaus entmieten, um es teuer zu sanieren und zu verkaufen.
- current en: The investor wanted to clear the old building of its tenants so he could renovate it lavishly and sell it.

### heranbrechen — `bad_gloss`
The sentence ('Als der Morgen heranbrach') is a natural and by far the most common use of heranbrechen — a period of time setting in. That is the second sense in candidate_glosses, 'to start, commence'. The shipped gloss 'surge, break' is the wave/onrush sense and does not describe what the sentence shows, so this is an import defect in the gloss rather than a defect in the sentence. The gloss should read something like 'begin, set in (of a time of day)'.
- current de: Als der Morgen heranbrach, hatten die Wanderer den Gipfel endlich fast erreicht.
- current en: As morning broke, the hikers had finally almost reached the summit.

### herumspinnen — `bad_gloss`
The shipped gloss is 'spin around', but the sentence ('Wenn du weiter so herumspinnst und nur Unsinn redest') demonstrates the colloquial sense 'act crazy, talk nonsense', which is the verb's ordinary living meaning; the literal rotational reading is essentially unattested for herumspinnen (rotation is sich drehen / herumwirbeln). The correct sense is already present in candidate_glosses as 'to act strange', so this is a mechanical import defect: the first candidate was taken rather than the right one. The sentence and translation are both fine; the gloss should read something like 'act crazy, talk nonsense'.
- current de: Wenn du weiter so herumspinnst und nur Unsinn redest, nimmt dich bald keiner mehr ernst.
- current en: If you keep acting crazy and talking nonsense like this, soon no one will take you seriously.

### kaltmachen — `bad_gloss`
The shipped gloss 'off someone, duppy' is unusable. 'Duppy' is Jamaican-English (a noun for a ghost, verbed as 'to kill') and will be opaque to essentially every learner; it looks like an unfiltered import of a dictionary's full synonym list. The German sentence is correct and its English rendering ('bump off') is the right register, so only the gloss is wrong.
- current de: Im Krimi drohte der Gangster kaltblütig, jeden Zeugen kaltzumachen.
- current en: In the crime drama, the gangster coldly threatened to bump off every witness.
- **fix en:** Suggested gloss: "bump off, kill".

### nachbacken — `bad_gloss`
The German sentence is correct and idiomatic ('die aufwendige Torte zu Hause nachzubacken'), but it demonstrates the sense 'to recreate (a dish) by baking it from a model or recipe', which is candidate gloss 2, not the shipped gloss 'recook'. 'Recook' wrongly suggests cooking or reheating something a second time, and it is odd English for a baking verb. Because the correct sense is already present in candidate_glosses, this is a mechanical import defect: the shipped gloss should be 'recreate (a dish) by baking' or similar.
- current de: Nach der Kochshow versuchten viele Zuschauer, die aufwendige Torte zu Hause nachzubacken.
- current en: After the cooking show, many viewers tried to recreate the elaborate cake at home.

### nachsteigen — `bad_gloss`
The shipped gloss 'follow' reads as candidate_glosses' first sense, 'to follow (e.g., on a climbing tour)'. The sentence ('Er stieg ihr wochenlang nach, bis sie ihm ... sagte, dass sie kein Interesse habe') demonstrates the colloquial romantic-pursuit sense, candidate_glosses' second entry 'to stalk, to pursue, to go after'. The correct sense is already listed, so this is a mechanical wrong-candidate pick. The German is fine; only the gloss is misdirected.
- current de: Er stieg ihr wochenlang nach, bis sie ihm unmissverständlich sagte, dass sie kein Interesse habe.
- current en: He chased after her for weeks until she told him in no uncertain terms that she wasn't interested.

### umlagern — `bad_gloss`
The entry is marked inseparable and the sentence correctly demonstrates inseparable umlágern = 'surround, besiege, throng around' (Fans umlagerten den Bus), which the English 'thronged around' renders accurately. But the shipped gloss 'transfer, relocate' belongs to the SEPARABLE homograph úmlagern (e.g. Waren umlagern = restock/relocate goods). The gloss describes a different verb than the one the sentence uses. Neither the correct 'surround/besiege' sense nor a matching gloss appears in candidate_glosses, so the gloss should be corrected to 'surround, besiege, throng around'. The German sentence and English translation themselves are both fine.
- current de: Nach dem Konzert umlagerten Hunderte Fans den Bus der Band und riefen nach Autogrammen.
- current en: After the concert, hundreds of fans thronged around the band's bus, calling for autographs.
- **fix en:** After the concert, hundreds of fans thronged around the band's bus, calling for autographs.

### umschulen — `bad_gloss`
The sentence demonstrates the vocational sense — 'sich zum Pflegefachmann umschulen lassen' is retraining for a new profession — while the shipped gloss says 'move schools' (transferring a pupil to a different school), which the sentence does not illustrate at all. 'to retrain (for a new profession, trade, etc.)' is already in candidate_glosses, so this is a mechanical import defect: the first candidate was taken rather than the dominant modern sense. The German and English are otherwise correct; only the gloss needs changing.
- current de: Nach der Werksschließung ließ er sich mit vierzig zum Pflegefachmann umschulen.
- current en: After the plant closed, at forty he retrained as a nursing professional.

### umtreten — `bad_gloss`
The gloss 'boot' is ambiguous to the point of being misleading: for most learners the primary English sense is 'start a computer', and the kicking sense is slangy and does not carry the 'over, so that it falls' component that the particle um- supplies. The sentence itself is correct and demonstrates exactly that component ('trat die Mülltonne um' = kicked it over). The gloss should read 'kick over, knock over'.
- current de: Der Rowdy trat im Vorbeigehen einfach die Mülltonne um.
- current en: The hooligan just kicked over the trash can as he walked past.

### untermalen — `bad_gloss`
The sentence demonstrates the musical sense — 'Klaviermusik untermalte die Szene' is the standard collocation for scoring or underlaying a scene with music — but the shipped gloss is 'underpaint', the literal painting technique (applying a base layer under the finished picture). A learner reading 'underpaint' cannot get from it to what this sentence means. Both 'to underscore (with background music)' and 'to underscore, to underline, to emphasise, to accompany' are already in candidate_glosses, so this is a mechanical import defect: the first, and by far the rarest, candidate was taken. The German and English are correct as they stand.
- current de: Sanfte Klaviermusik untermalte die ganze Abschiedsszene des Films.
- current en: Soft piano music underscored the entire farewell scene of the film.

### versteuern — `bad_gloss`
The gloss 'tax, put a tax on something' describes 'besteuern' (a tax authority levying), not 'versteuern'. 'versteuern' means the taxpayer pays tax on income/earnings ('etwas versteuern' = 'pay tax on something') — which is candidate gloss #2 ('to pay a tax on something'). The German sentence and its English translation ('declare and pay tax on the fee') correctly demonstrate that second sense, so the shipped gloss is the wrong target. Mechanical import defect: the correct sense is already in candidate_glosses.
- current de: Auch das Honorar für den Vortrag muss sie am Jahresende ordentlich versteuern.
- current en: She has to properly declare and pay tax on the fee for the talk at the end of the year, too.

### vorbauen — `bad_gloss`
The sense the sentence shows is already present in candidate_glosses as 'to prevent, obviate', so the shipped gloss 'preassemble' is a mechanical import defect, not a judgment call. 'Take precautions, guard against' is the sense a learner meets in modern German; recommend replacing the gloss with that and keeping the sentence.
- current de: Wer klug ist, baut vor und legt für schlechte Zeiten etwas Geld zurück.
- current en: A wise person takes precautions and sets aside a little money for hard times.

### widersagen — `bad_gloss`
The sentence ('Bei der Taufe widersagt der Pate feierlich dem Bösen …') is correct German and demonstrates the liturgical 'renounce, forswear' sense — 'dem Bösen widersagen', the standard baptismal renunciation. That is candidate gloss #2 ('to defy, to oppose, renounce'), not the shipped gloss 'object, contradict' (candidate #1). The import picked the less-apt listed sense; 'object, contradict' is really the province of widersprechen, and the sentence teaches a mismatched label. Suggest changing the gloss to 'renounce, forswear' (the sense the sentence actually shows) rather than altering the sentence.
- current de: Bei der Taufe widersagt der Pate feierlich dem Bösen und allen seinen Verlockungen.
- current en: At the baptism, the godfather solemnly renounces evil and all its temptations.

### zusammenkehren — `bad_gloss`
Gloss 'pile up' loses the sweeping that is the core of the verb ('kehren' = to sweep). The sentence uses a Handbesen and the English says 'swept up', both matching candidate_glosses[1], 'to sweep up'. The correct sense is already in candidate_glosses, so this is a mechanical import mislabel: the gloss should be 'sweep up / sweep together'.
- current de: Nach dem Fest kehrte er die Scherben und Krümel mit einem Handbesen zusammen.
- current en: After the party he swept up the shards and crumbs with a hand brush.

### zusammenräumen — `bad_gloss`
Gloss 'pack up' is candidate_glosses[0] (gather one's belongings in order to leave). The sentence 'räumten die Kinder das Wohnzimmer zusammen' and its English 'tidied up the living room' demonstrate candidate_glosses[1], 'to tidy up'. The correct sense is in candidate_glosses, so this is an import mislabel; the gloss should be 'tidy up / clear up'.
- current de: Nach dem Abendessen räumten die Kinder das Wohnzimmer zusammen, ohne dass jemand sie darum bat.
- current en: After dinner the children tidied up the living room without anyone asking them to.

### übereinanderhalten — `bad_gloss`
The sentence ('hielt die klammen Hände dicht übereinander') demonstrates the plain compositional sense 'to hold on top of each other', which is the second entry in candidate_glosses. The shipped gloss is the first entry, 'keep shut, clench', which the sentence does not illustrate at all — nothing is being clenched or held shut. This is a mechanical import defect: the correct sense was already in candidate_glosses and the importer took the wrong one. The German sentence and its translation are otherwise fine; the fix belongs on the gloss, which should read 'hold on top of each other'.
- current de: Vor Kälte zitternd hielt sie die klammen Hände dicht übereinander, um sie zu wärmen.
- current en: Shivering with cold, she held her numb hands close over each other to warm them.

### abkochen — `logic`
A power outage is the wrong trigger for the precaution and quietly works against it. Boil-water advisories follow contamination — a burst main, flooding, a failed treatment plant — not loss of power; and a power outage is precisely the situation in which an electric stove or kettle cannot boil anything. If the sanitising sentence is kept at all, the cause needs to be one that makes the water unsafe.
- current de: Bei einem Stromausfall muss man das Leitungswasser vor dem Trinken sicherheitshalber abkochen.
- current en: During a power outage, you have to boil the tap water before drinking it, just to be safe.
- **fix de:** Nach dem Rohrbruch muss man das Leitungswasser vor dem Trinken sicherheitshalber abkochen.
- **fix en:** After the burst water main, you have to boil the tap water before drinking it, just to be safe.

### beschallen — `logic`
"Die Ärztin beschallte vorsichtig ihren Bauch" has no antecedent for "ihren" other than the subject, because German possessives are not reflexive and no patient is introduced. The sentence therefore reads as the doctor scanning her own belly, which contradicts "um das ungeborene Kind zu untersuchen". A patient noun is needed.
- current de: Beim Termin beschallte die Ärztin vorsichtig ihren Bauch, um das ungeborene Kind zu untersuchen.
- current en: At the appointment the doctor carefully scanned her belly with ultrasound to examine the unborn child.
- **fix de:** Beim Termin beschallte die Ärztin vorsichtig den Bauch der werdenden Mutter, um das ungeborene Kind zu untersuchen.
- **fix en:** At the appointment the doctor carefully scanned the expectant mother's belly with ultrasound to examine the unborn child.

### heraufhalten — `logic`
heraufhalten presupposes a goal above the holder, with the viewpoint located up there ('her-' = toward the speaker), the same deixis as heraufgeben. The scene here has no one above: the child simply displays the drawing to everyone present, which is hochhalten or in die Höhe halten. As written, the sentence reads as an error for hochhalten and teaches the wrong distribution.
- current de: Das Kind hielt stolz seine gemalte Zeichnung herauf, damit alle sie sehen konnten.
- current en: The child proudly held up its drawing so that everyone could see it.
- **fix de:** Ich stand oben auf dem Balkon, und das Kind hielt mir stolz seine Zeichnung herauf.
- **fix en:** I was standing up on the balcony, and the child proudly held their drawing up to me.

### herreißen — `logic`
The particle 'her' denotes motion toward the narrator, but the situation is the narrator's brother taking the bag away from the narrator ('snatched the bag away from me' = motion away from narrator). The deixis runs backwards relative to the sentence's own English; a brother grabbing chips off the narrator is 'wegreißen', not 'herreißen'. To actually demonstrate herreißen, the narrator must be the one pulling the object toward themselves.
- current de: Kaum hatte ich die Chips ausgepackt, riss mir mein Bruder die Tüte einfach her.
- current en: I had barely opened the chips when my brother simply snatched the bag away from me.
- **fix de:** Ungeduldig riss ich meinem Bruder die Chipstüte einfach her, kaum dass er sie aufgemacht hatte.
- **fix en:** Impatiently, I just snatched the bag of chips over from my brother the moment he had opened it.

### herunterhalten — `logic`
herunterhalten means to hold something downward, typically extending it down toward a lower place or person ('er hielt ihm das Seil herunter'). Restraining a jumping dog by its collar is festhalten, zurückhalten, or niederhalten; nothing in the scene supplies the downward direction herunter needs, so the sentence teaches a collocation a native speaker would not use. The fix keeps the dog and the mail carrier but makes the downward motion explicit, so herunter is earned.
- current de: Er hielt den aufgeregten Hund am Halsband herunter, bis der Postbote vorbei war.
- current en: He held the excited dog down by its collar until the mail carrier had passed.
- **fix de:** Der Hund sprang immer wieder hoch, doch er hielt ihn am Halsband herunter, bis der Postbote vorbei war.
- **fix en:** The dog kept jumping up, but he held it down by its collar until the mail carrier had passed.

### reinfeiern — `logic`
'in einen Geburtstag reinfeiern' means celebrating across midnight into the new day, so the party must continue past midnight. 'bis Mitternacht' caps it at midnight and therefore contradicts the very meaning the sentence is demonstrating.
- current de: Wir haben gestern mit Freunden bis Mitternacht in ihren dreißigsten Geburtstag reingefeiert.
- current en: Last night we celebrated with friends until midnight to ring in her thirtieth birthday.
- **fix de:** Wir haben gestern mit Freunden bis weit nach Mitternacht in ihren dreißigsten Geburtstag reingefeiert.
- **fix en:** Last night we celebrated with friends well past midnight to ring in her thirtieth birthday.

### voranschieben — `logic`
The sentence gives two conflicting directional specifications: 'an den Straßenrand' names a lateral goal (over to the shoulder), while the particle 'voran' means onward/forward along a path. A native speaker would write either 'schoben das Auto an den Straßenrand' (goal) or 'schoben das Auto langsam voran' (progress), not both. The strain shows in the English too: 'pushed the stalled car forward to the side of the road' has the same double direction.
- current de: Mit vereinten Kräften schoben sie das liegengebliebene Auto langsam an den Straßenrand voran.
- current en: Together they slowly pushed the stalled car forward to the side of the road.
- **fix de:** Mit vereinten Kräften schoben sie das liegengebliebene Auto langsam voran, bis es endlich am Straßenrand stand.
- **fix en:** Working together, they slowly pushed the stalled car forward until it was finally at the side of the road.

### zukaufen — `logic`
A Bäcker has no 'eigene Ernte', and a harvest yields grain, not flour. The sentence skips the mill and attributes a farm to a baker, so the causal link ('because his own harvest wasn't enough … extra flour') does not hold. Replacing the baker with a miller and the flour with grain keeps the zukaufen construction intact.
- current de: Weil die eigene Ernte nicht reichte, musste der Bäcker zusätzliches Mehl zukaufen.
- current en: Because his own harvest wasn't enough, the baker had to buy in extra flour.
- **fix de:** Weil die eigene Ernte nicht reichte, musste der Müller zusätzliches Getreide zukaufen.
- **fix en:** Because his own harvest wasn't enough, the miller had to buy in extra grain.

### abbleiben — `grammar`
'allen Familienfeiern … abbleiben' gives abbleiben a dative complement it does not govern. The verb that means 'stay away from' and takes the dative is fernbleiben ('er bleibt allen Familienfeiern fern'); abbleiben in its stay-away reading is intransitive and regional ('er bleibt einfach ab'). Also, the English 'all the family gatherings' should be 'all family gatherings' for the generic reading.
- current de: Seit dem Streit bleibt er allen Familienfeiern konsequent ab und meldet sich bei niemandem.
- current en: Since the argument, he has consistently stayed away from all the family gatherings and doesn't contact anyone.
- **fix de:** Seit dem Streit bleibt er allen Familienfeiern konsequent fern und meldet sich bei niemandem.
- **fix en:** Since the argument, he has consistently stayed away from all family gatherings and doesn't contact anyone.

### abliefern — `grammar`
The verb abliefern itself is used correctly ('lieferte das Paket … ab'). The defect is the trailing clause 'und ließ sich unterschreiben': 'sich etwas unterschreiben lassen' is a dative-reflexive causative that requires an explicit accusative object naming what gets signed (den Empfang, die Lieferung, die Zustellung). Without an object, 'ließ sich unterschreiben' reads as 'let himself be signed', which is nonsensical for a person.
- current de: Der Bote lieferte das Paket noch am selben Abend im Büro ab und ließ sich unterschreiben.
- current en: The courier delivered the package to the office that same evening and got a signature.
- **fix de:** Der Bote lieferte das Paket noch am selben Abend im Büro ab und ließ sich den Empfang quittieren.

### ausschleichen — `grammar`
"schlich er sich leise aus dem Saal aus" doubles the aus: the directional PP "aus dem Saal" already carries the sense, so the trailing particle is redundant and the sentence reads as sich (hin)ausschleichen with a stray particle appended. Native usage is either "schlich er sich leise aus dem Saal" (schleichen) / "hinaus" (hinausschleichen), or ausschleichen used without a competing aus-PP.
- current de: Als der Vortrag immer langweiliger wurde, schlich er sich leise aus dem Saal aus.
- current en: As the lecture grew more and more boring, he quietly slipped out of the hall.
- **fix de:** Als der Vortrag immer langweiliger wurde, schlich er sich leise aus, ohne sich zu verabschieden.
- **fix en:** As the lecture grew more and more boring, he quietly slipped out without saying goodbye.

### hinaufhalten — `grammar`
hinauf is deictic and needs a goal above the speaker ('zum Fenster hinauf', 'aufs Gerüst hinauf'). Here there is no goal at all, and 'so hoch wie möglich' already supplies the upward direction, so hinaufhalten is both unanchored and redundant; a native speaker would say hochhalten or 'in die Höhe halten'. The fix supplies a target above, which is what licenses hinauf.
- current de: Das kleine Mädchen hielt den bunten Luftballon so hoch wie möglich hinauf.
- current en: The little girl held the colorful balloon up as high as she possibly could.
- **fix de:** Das kleine Mädchen hielt den bunten Luftballon zum offenen Fenster hinauf.
- **fix en:** The little girl held the colorful balloon up to the open window.

### kaputtreißen — `grammar`
Two competing resultatives in one clause: the directional/resultative PP 'in tausend Stücke' and the resultative predicate 'kaputt' both specify the end state of the letter. German licenses only one ('riss den Brief kaputt' or 'riss den Brief in tausend Stücke'), so 'in tausend Stücke kaputtreißen' is ill-formed. The English translation quietly drops 'kaputt', which is how the doubling escaped notice.
- current de: Vor Wut riss er den Brief in tausend Stücke kaputt.
- current en: In a fit of rage he tore the letter to shreds.
- **fix de:** Vor Wut riss er den Brief kaputt und warf die Fetzen in den Papierkorb.
- **fix en:** In a fit of rage he tore the letter up and threw the scraps in the wastebasket.

### raufhalten — `grammar`
'in die Höhe rauf' doubles the directional: 'in die Höhe halten' and 'raufhalten' each already express holding something up, and combining them is not idiomatic German. Either 'in die Höhe' or 'rauf' must go, and since 'rauf' is the verb being demonstrated, 'in die Höhe' should be replaced by a goal phrase.
- current de: Er hielt seinen Ausweis in die Höhe rauf, damit der Kontrolleur ihn deutlich sehen konnte.
- current en: He held his ID up high so the inspector could see it clearly.
- **fix de:** Er hielt seinen Ausweis zum Fenster rauf, damit der Kontrolleur ihn deutlich sehen konnte.
- **fix en:** He held his ID up to the window so the inspector could see it clearly.

### rechtschreiben — `grammar`
rechtschreiben is intransitive ('die Rechtschreibung beherrschen', used almost only in the infinitive: 'er kann nicht rechtschreiben'). Giving it the accusative object 'bestimmte Fremdwörter' is nonstandard; with a direct object German uses plain 'schreiben' ('Fremdwörter richtig schreiben'). 'fehlerfrei rechtschreiben' is additionally pleonastic, since the recht- already means 'correctly'.
- current de: Selbst viele Erwachsene können bestimmte Fremdwörter nicht fehlerfrei rechtschreiben.
- current en: Even many adults can't spell certain foreign words without mistakes.
- **fix de:** Selbst viele Erwachsene können nicht rechtschreiben, wenn Fremdwörter im Spiel sind.
- **fix en:** Even many adults can't spell correctly when foreign words are involved.

### umstreiten — `grammar`
Valency: transitive umstreiten takes as its object the contested thing itself — a territory, an inheritance, a title, something two parties both claim ('ein heiß umstrittenes Gebiet'). It does not take a proposition or a question under debate. One disputes *about* reasons: 'Historiker streiten bis heute über die wahren Gründe.' As written, 'die Gründe umstreiten' is not German, and the finite active form is in any case largely confined to this claim-to-possession reading; the everyday word is the participial 'umstritten'.
- current de: Historiker umstreiten bis heute die wahren Gründe für den Niedergang des Reiches.
- current en: Historians dispute to this day the true reasons for the empire's decline.
- **fix de:** Beide Königshäuser umstreiten seit Generationen das kleine Herzogtum an der Grenze.
- **fix en:** The two royal houses have been contesting the small duchy on the border for generations.

### verhassen — `grammar`
The sentence uses 'verhasste ... den Krieg' as an active transitive verb meaning 'loathed the war' (subject hates object). That is not standard German: the verb for hating is 'hassen'. Where 'verhassen' is attested it means 'jemandem etwas verhassen' — to make something loathsome/odious TO someone — and requires a dative recipient plus an accusative object of what becomes hateful. With no dative here, 'verhasste den Krieg' reads as an error to a native speaker.
- current de: In seinen Tagebüchern verhasste der alte Chronist den Krieg mit jeder Zeile, die er schrieb.
- current en: In his diaries the old chronicler loathed the war with every line he wrote.
- **fix de:** In seinen Tagebüchern schrieb der alte Chronist, wie der endlose Krieg ihm seine Heimat verhasst hatte.
- **fix en:** In his diaries the old chronicler wrote how the endless war had made his homeland hateful to him.

### zurückbilden — `grammar`
'stillgelegt' is the wrong collocation for a limb: 'stilllegen' applies to factories, mines, and rail lines. Immobilizing a body part is 'ruhigstellen' ('das Bein war ruhiggestellt'). The rest of the sentence, including the reflexive 'sich zurückbilden', is correct.
- current de: Nach der langen Ruhephase bildete sich der Muskel deutlich zurück, weil das Bein wochenlang stillgelegt war.
- current en: After the long period of rest the muscle noticeably wasted away, because the leg had been immobilized for weeks.
- **fix de:** Nach der langen Ruhephase bildete sich der Muskel deutlich zurück, weil das Bein wochenlang ruhiggestellt war.

### anzählen — `translation`
'counted out' is auszählen (complete the ten-count = knockout), not anzählen (begin/administer the count). The sentence's own logic contradicts 'counted out': the boxer 'kam noch vor der Acht wieder hoch', so he was precisely NOT counted out. German keeps anzählen and auszählen distinct; the English should say 'counted' or 'began the count over', not 'counted out'.
- current de: Der Ringrichter zählte den gestürzten Boxer an, doch der kam noch vor der Acht wieder hoch.
- current en: The referee counted out the fallen boxer, but he got back up before the count of eight.
- **fix en:** The referee began the count over the fallen boxer, but he got back up before the count of eight.

### fehlleiten — `translation`
"misdirected the hikers into completely the wrong direction" is not English: one misdirects someone *in* a direction, or sends someone off in a direction, but not 'into a direction'. The trailing 'for hours' also strands the time adverbial.
- current de: Ein umgedrehtes Schild leitete die Wanderer stundenlang in die völlig falsche Richtung fehl.
- current en: A turned-around sign misdirected the hikers into completely the wrong direction for hours.
- **fix en:** A sign turned the wrong way sent the hikers off in completely the wrong direction for hours.

### großziehen — `translation`
The German 'deren drei Kinder' unambiguously means the sister's children; the English 'her three children' reads as the subject's own children, which then contradicts 'as if they were her own'. The English loses the whole point of 'deren'.
- current de: Nach dem Tod ihrer Schwester zog sie deren drei Kinder wie ihre eigenen groß.
- current en: After her sister's death, she raised her three children as if they were her own.
- **fix en:** After her sister's death, she raised her sister's three children as if they were her own.

### heranreichen — `translation`
'So gut sie auch kocht' is a concessive ('however well she cooks'). English 'As well as she cooks' first parses as 'in addition to cooking', which inverts the sense of the clause. Also, 'Rouladen' is a German noun and should keep its capital in English or be glossed.
- current de: So gut sie auch kocht, an die Rouladen ihrer Oma reicht sie einfach nicht heran.
- current en: As well as she cooks, she simply can't measure up to her grandma's rouladen.
- **fix en:** However well she cooks, she simply can't match her grandmother's Rouladen.

### schöntrinken — `translation`
"he drinks them away" renders wegtrinken / seine Sorgen ertränken, not schöntrinken. sich etwas schöntrinken means to drink until the thing seems fine or attractive to you; the English says he makes the worries disappear, which is the opposite mechanism (perception changes, not the object). A learner reading the pair would take away the wrong meaning for the very verb the sentence exists to teach.
- current de: Statt seine Sorgen anzugehen, trinkt er sie sich Abend für Abend schön.
- current en: Instead of dealing with his worries, he drinks them away every single evening.
- **fix en:** Instead of dealing with his worries, he drinks every single evening until they look harmless to him.


## low

### abrollen — `wrong_sense`
The German ('Sie rollte den Draht … von der Spule ab') and the English ('unwound the wire from the spool') both demonstrate the 'unwind, unroll' sense, but the shipped gloss is 'roll off'. The intended sense 'to unwind, to unroll' is already present in candidate_glosses, so this is a mechanical gloss-selection mismatch, not a sentence defect. Either point the gloss at the unwind sense or rewrite a sentence for the 'roll off (of a vehicle)' sense.
- current de: Sie rollte den Draht vorsichtig von der Spule ab, damit er sich nicht verknotete.
- current en: She carefully unwound the wire from the spool so that it wouldn't get tangled.

### anheimfallen — `wrong_sense`
'dem Staat anheimfallen' here is the neutral legal sense of escheat — the estate reverting to the state after the last heir dies — which candidate_glosses[1] captures as 'to become subject'. The shipped gloss 'fall victim' carries a negative 'fall prey to' framing that the neutral sentence (and its accurate English 'passed to the state') does not demonstrate. The German and English are both correct; only the gloss sense is mismatched.
- current de: Nach dem Tod des letzten Erben fiel das ganze Gut dem Staat anheim.
- current en: After the death of the last heir, the entire estate passed to the state.

### anreisen — `wrong_sense`
The English renders the sentence with 'arrive', which is candidate gloss 2, not the shipped gloss 'travel, take a trip'. The German is correct and idiomatic, but a learner reading gloss and translation together sees a mismatch. Note also that anreisen never means simply 'take a trip' (that is reisen/verreisen); it always means travelling to a destination, so the shipped gloss is weak on its own.
- current de: Die meisten Gäste reisen schon am Freitagabend an, um das ganze Wochenende zu bleiben.
- current en: Most guests arrive as early as Friday evening so they can stay for the whole weekend.
- **fix en:** Most guests travel in as early as Friday evening so they can stay for the whole weekend.

### einfahren — `wrong_sense`
A train entering a station is the 'to arrive, to pull in' sense, which candidate_glosses lists separately from the shipped gloss 'drive in'. The English translation itself says 'pulled into', not 'drove in', so the sentence visibly illustrates the neighboring sense. Either retarget the gloss to 'pull in, arrive' or use a drive-in example such as a vehicle entering a yard.
- current de: Mit einer Minute Verspätung fuhr der Zug endlich in den Bahnhof ein.
- current en: One minute late, the train finally pulled into the station.
- **fix de:** Der Lastwagen fuhr rückwärts in den engen Hof ein.
- **fix en:** The truck drove backwards into the narrow yard.

### totsagen — `wrong_sense`
The gloss is 'falsely report someone's death' (a person), but the sentence is about a vinyl record being pronounced dead — the 'falsely report something's end' sense, which is candidate_glosses[1]. The German and English are correct; they just demonstrate the second listed sense rather than the shipped one. A mechanical import defect: the gloss picked the person sense while the sentence illustrates the thing sense.
- current de: Die Schallplatte wurde in den Neunzigern totgesagt und verkauft sich heute besser denn je.
- current en: The vinyl record was pronounced dead in the nineties, and today it sells better than ever.

### durchspielen — `bad_gloss`
The shipped gloss 'play out to its conclusion)' has an unbalanced trailing parenthesis, an import artifact from a nested dictionary gloss like 'to play out (to play (a game etc.) to its conclusion)'. The German sentence itself is correct.
- current de: Bevor wir uns entscheiden, sollten wir alle Möglichkeiten in Ruhe einmal gemeinsam durchspielen.
- current en: Before we decide, we should calmly play through all the options together.

### einflechten — `bad_gloss`
'weave together' describes verflechten/zusammenflechten — combining strands with each other. einflechten is 'weave in, braid in': adding something into an existing braid, which is exactly what the sentence shows (ribbons into braids) and what the English translation says ('wove … into'). The gloss and the sentence therefore point at different actions. Note that 'weave in' is not among candidate_glosses, so this is a defect in the imported gloss itself rather than a wrong pick from the available senses.
- current de: Zum Fest flocht die Mutter bunte Bänder in die langen Zöpfe ihrer Tochter ein.
- current en: For the celebration, the mother wove colorful ribbons into her daughter's long braids.

### freihaben — `bad_gloss`
The gloss is 'be on vacation' (= Urlaub haben), but freihaben means 'to have off / be off duty', and the sentence „Am Freitag habe ich frei" demonstrates having a single Friday off, not a vacation. The German sentence and its English translation ('I have Friday off') are correct; only the gloss is too narrow/wrong. Recommend a gloss like 'have off, have time off'.
- current de: Am Freitag habe ich frei und fahre mit dem Rad an den See.
- current en: I have Friday off and I'm riding my bike out to the lake.

### hinwegschauen — `bad_gloss`
The shipped gloss 'synonym of hinwegsehen' is a dictionary cross-reference, not a meaning a learner can use. The German sentence correctly demonstrates the verb (turning a blind eye to typos), so the gloss should state that sense directly, e.g. 'overlook, turn a blind eye to, disregard'.
- current de: Über kleine Tippfehler in der Bewerbung schaut die Chefin gern hinweg, über Unpünktlichkeit nicht.
- current en: The boss is happy to overlook small typos in an application, but not lateness.

### verkochen — `bad_gloss`
The shipped gloss 'vaporize, forwall' contains 'forwall', an obsolete English verb that a learner cannot parse; it is a mechanical carry-over of the first candidate gloss ('to vaporize, to forwall'). The sentence itself correctly demonstrates the intransitive 'boil away' sense of verkochen, so only the gloss wording is at fault. A plain gloss such as 'boil away, boil dry' would name the sense the sentence teaches.
- current de: Wenn du die Soße zu lange köcheln lässt, verkocht das ganze Wasser und sie brennt an.
- current en: If you let the sauce simmer too long, all the water boils away and it burns.

### zuschwellen — `bad_gloss`
Gloss 'swell up' blurs the 'zu-' = shut/closed nuance. 'zuschwellen' means to swell until closed (eye, throat), distinct from 'anschwellen' (swell up). The sentence and its English translation ('swelled shut completely') are correct; only the label is imprecise and could lead a learner to use zuschwellen where anschwellen is meant. Gloss should be 'swell shut / swell closed'.
- current de: Nach dem Wespenstich schwoll ihm das linke Auge innerhalb weniger Minuten völlig zu.
- current en: After the wasp sting, his left eye swelled shut completely within a few minutes.

### überhelfen — `bad_gloss`
The gloss 'force on someone' implies coercion, but überhelfen means to help someone put on / into a garment (jemandem den Mantel überhelfen). The German sentence and the English translation both correctly show the helping sense; only the gloss label is misleading. A learner reading 'force on someone' would misread a helpful act as a forceful one.
- current de: Draußen war es eisig, deshalb half er seiner Großmutter den dicken Mantel über.
- current en: It was freezing outside, so he helped his grandmother into her heavy coat.
- **fix en:** It was freezing outside, so he helped his grandmother on with her heavy coat.

### absaugen — `logic`
The purpose clause inverts the real-world causality. Dental suction clears pooled saliva precisely so the patient does NOT have to swallow while the mouth is held open, not 'so that I could swallow'. The suction substitutes for swallowing rather than enabling it.
- current de: Der Zahnarzt saugte während der Behandlung ständig Speichel ab, damit ich schlucken konnte.
- current en: The dentist kept suctioning off saliva during the treatment so that I could swallow.
- **fix de:** Der Zahnarzt saugte während der Behandlung ständig Speichel ab, damit ich nicht dauernd schlucken musste.
- **fix en:** The dentist kept suctioning off saliva during the treatment so that I didn't have to keep swallowing.

### allemachen — `logic`
'Mit einer einzigen Falle' contradicts the punctual, exhaustive 'machte … die Ratten … alle'. A single trap catches one rat at a time, so it cannot finish off a barn's rat population in one stroke; the instrument undercuts the totality the verb expresses. Either the instrument or the time frame needs to allow for repetition.
- current de: Mit einer einzigen Falle machte der Bauer die Ratten in der Scheune alle.
- current en: With a single trap the farmer finished off the rats in the barn.
- **fix de:** Mit immer neuen Fallen machte der Bauer die Ratten in der Scheune nach und nach alle.
- **fix en:** Setting trap after trap, the farmer gradually finished off the rats in the barn.

### ausschenken — `logic`
"frisch gezapft" collocates with beer, not wine: zapfen is drawing from a tap/keg, and "frisch gezapftes Bier" is the fixed phrase. Wine in a Wirtschaft is "offen", "vom Fass", or simply "frisch geöffnet". The verb ausschenken and its "an + Akkusativ" object are both correct; only the modifier is mismatched.
- current de: Der Wirt schenkte den frisch gezapften Wein großzügig an seine Stammgäste aus.
- current en: The innkeeper generously poured out the freshly tapped wine for his regulars.
- **fix de:** Der Wirt schenkte den jungen Wein vom Fass großzügig an seine Stammgäste aus.
- **fix en:** The innkeeper generously poured out the young wine from the barrel for his regulars.

### einfahren — `logic`
'endlich' presupposes a wait long enough to have tried the speaker's patience, but the same sentence puts the delay at one minute. The adverb and the quantity undercut each other.
- current de: Mit einer Minute Verspätung fuhr der Zug endlich in den Bahnhof ein.
- current en: One minute late, the train finally pulled into the station.
- **fix de:** Mit zwanzig Minuten Verspätung fuhr der Zug endlich in den Bahnhof ein.
- **fix en:** Twenty minutes late, the train finally pulled into the station.

### entfließen — `logic`
Collocation misfire: a Quelle is the point of emergence, not the fluid, so it is water that 'entfließt' a rock while a spring 'entspringt' it — 'Dem Felsen entspringt eine Quelle' is the fixed idiom. As written, the spring is made the thing doing the flowing out of itself. The dative object and the elevated register are both correct; only the subject noun is misplaced.
- current de: Dem moosbewachsenen Felsen entfließt eine klare Quelle, die das Tal versorgt.
- current en: A clear spring flows out of the moss-covered rock and supplies the valley.
- **fix de:** Dem moosbewachsenen Felsen entfließt klares Quellwasser, das das ganze Tal versorgt.
- **fix en:** Clear spring water flows out of the moss-covered rock and supplies the whole valley.

### fehlleiten — `logic`
Pleonasm: the particle fehl- already encodes 'in the wrong direction', so 'in die völlig falsche Richtung fehlleiten' says the same thing twice, which blurs what the particle contributes for a learner.
- current de: Ein umgedrehtes Schild leitete die Wanderer stundenlang in die völlig falsche Richtung fehl.
- current en: A turned-around sign misdirected the hikers into completely the wrong direction for hours.
- **fix de:** Ein umgedrehtes Schild leitete die Wanderer stundenlang fehl, bis sie endlich einen Einheimischen fragten.
- **fix en:** A sign turned the wrong way misdirected the hikers for hours, until they finally asked a local.

### heraufhalten — `logic`
'seine gemalte Zeichnung' is self-contradictory: a Zeichnung is drawn (zeichnen), not painted (malen). Either 'seine Zeichnung' or 'sein gemaltes Bild'.
- current de: Das Kind hielt stolz seine gemalte Zeichnung herauf, damit alle sie sehen konnten.
- current en: The child proudly held up its drawing so that everyone could see it.

### hinaufschauen — `logic`
The spires of the Kölner Dom are dark, weathered sandstone and trachyte, not gilded; there is no 'vergoldete Spitze'. The factual error is the kind a German learner using the app in Cologne would notice immediately. The German construction with hinaufschauen is otherwise correct.
- current de: Ehrfürchtig schaute sie zur vergoldeten Spitze des Kölner Doms hinauf.
- current en: In awe she looked up at the gilded spire of Cologne Cathedral.
- **fix de:** Ehrfürchtig schaute sie zur steinernen Spitze des Kölner Doms hinauf.
- **fix en:** In awe she looked up at the stone spire of Cologne Cathedral.

### schöntrinken — `logic`
Sorgen is a poor object for schöntrinken. The verb takes something one is stuck with and perceives as bad — die Lage, das Leben, den Job, die Wohnung — and makes it look good. Worries are not made to look good; they are drowned (ertränken) or drunk away (wegtrinken), which is exactly the collocation the English translation slipped into. Swapping the object to a situation makes the German idiomatic and the translation straightforward.
- current de: Statt seine Sorgen anzugehen, trinkt er sie sich Abend für Abend schön.
- current en: Instead of dealing with his worries, he drinks them away every single evening.
- **fix de:** Statt seine Probleme anzugehen, trinkt er sich seine Lage Abend für Abend schön.
- **fix en:** Instead of tackling his problems, he drinks until his situation looks fine to him, evening after evening.

### wegschleifen — `logic`
'vorsichtig' undercuts the verb it is meant to demonstrate. schleifen (weak: schleifte, geschleift) means dragging a body along the ground, which is inherently rough — it is the emergency grip you use precisely when there is no time to be careful. 'Vorsichtig schleifen' reads like 'gently drag'. Making the urgency explicit motivates the choice of wegschleifen over wegziehen or wegtragen.
- current de: Die Sanitäter schleiften den Verletzten vorsichtig von der befahrenen Straße weg.
- current en: The paramedics dragged the injured man carefully away from the busy road.
- **fix de:** Die Sanitäter schleiften den Verletzten so schnell wie möglich von der befahrenen Straße weg.
- **fix en:** The paramedics dragged the injured man off the busy road as fast as they could.

### zurücklächeln — `logic`
The 'zurück' in zurücklächeln reciprocates a smile, but the trigger clause has him only looking at her ('ansah'), not smiling. There is no smile for hers to answer; 'anlächelte' supplies one and leaves the rest of the sentence untouched.
- current de: Als er sie freundlich ansah, lächelte sie ein wenig schüchtern zurück.
- current en: When he looked at her kindly, she smiled back a little shyly.
- **fix de:** Als er sie freundlich anlächelte, lächelte sie ein wenig schüchtern zurück.
- **fix en:** When he smiled at her kindly, she smiled back a little shyly.

### ansenken — `grammar`
Zeitenfolge mismatch: the main clause narrates a specific past event in the Präteritum ('senkte … an') but the damit-clause is in the present ('sitzen'). Present tense there forces a generic-truth reading. German expects 'saßen', which is also what the English 'would sit flush' already conveys.
- current de: Vor dem Verschrauben senkte der Tischler jedes Bohrloch sorgfältig an, damit die Schraubenköpfe bündig sitzen.
- current en: Before screwing them in, the carpenter carefully countersank each drilled hole so the screw heads would sit flush.
- **fix de:** Vor dem Verschrauben senkte der Tischler jedes Bohrloch sorgfältig an, damit die Schraubenköpfe bündig saßen.

### eislaufen — `grammar`
Orthography: the separated form is written lowercase, 'laufen … eis', because 'eislaufen' is one of the univerbated noun+verb compounds restored by the 2006 revision of the amtliches Regelwerk (alongside 'kopfstehen'), unlike 'Rad fahren' or 'Ski fahren', which stayed separate. 'Eis laufen' with a capital was the 1996–2004 spelling, so it is superseded rather than nonsense, but it contradicts the app's own paradigm, which the learner sees on the same screen ('lauf … eis', 'läuft … eis', 'eisgelaufen').
- current de: Sobald der Teich zugefroren ist, laufen die Kinder dort stundenlang Eis.
- current en: As soon as the pond freezes over, the children ice-skate there for hours.
- **fix de:** Sobald der Teich zugefroren ist, laufen die Kinder dort stundenlang eis.

### heraufgeben — `grammar`
'Steh schon mal oben auf der Leiter' commands a stative posture with a dative location, but the situation requires a change of position, which German expresses with 'steig auf die Leiter' or 'stell dich auf die Leiter' plus accusative. The English 'Get up on the ladder' translates the inchoative reading the German does not have.
- current de: Steh schon mal oben auf der Leiter, dann gebe ich dir die Ziegel einzeln herauf.
- current en: Get up on the ladder and I'll hand the bricks up to you one at a time.
- **fix de:** Steig schon mal auf die Leiter, dann gebe ich dir die Ziegel einzeln herauf.

### hinaufgeben — `grammar`
'nach oben aufs Gerüst hinauf' marks the upward direction three times: nach oben, the goal aufs Gerüst, and the particle hinauf. The particle alone carries it, so 'nach oben' is pleonastic and reads as padding in a sentence whose job is to show the particle.
- current de: Der Lehrling gab dem Dachdecker die schweren Ziegel nach oben aufs Gerüst hinauf.
- current en: The apprentice handed the heavy tiles up to the roofer on the scaffold.
- **fix de:** Der Lehrling gab dem Dachdecker die schweren Ziegel aufs Gerüst hinauf.

### umnutzen — `grammar`
Collocation: umnutzen governs 'zu' + dative for the new use ('ein Gebäude zu Wohnungen umnutzen'). 'als' belongs to plain 'nutzen als' ('etwas als Kulturzentrum nutzen'), so with 'als' the particle 'um' is left doing nothing and the sentence reads as simple nutzen. The perfect ('hat ... umgenutzt') would also be more idiomatic than the present for a completed conversion.
- current de: Die Stadt nutzt die alte Textilfabrik jetzt als lebendiges Kulturzentrum um.
- current en: The city is now repurposing the old textile factory as a lively cultural center.
- **fix de:** Die Stadt nutzt die alte Textilfabrik jetzt zu einem lebendigen Kulturzentrum um.

### verrennen — `grammar`
'seine eine Idee' stacks a possessive on the numeral/emphatic 'ein', which is a calque of English 'his one idea'. Standard German uses either 'diese eine Idee' for the emphatic reading or a bare 'seine Idee'; possessive + 'ein' survives only as colloquial regional usage ('mein einer Freund') and reads as an error here. The verb itself and its reflexive construction are correct.
- current de: Er hat sich so in seine eine Idee verrannt, dass er keine Kritik mehr zuließ.
- current en: He got so fixated on his one idea that he no longer allowed any criticism.
- **fix de:** Er hat sich so in diese eine Idee verrannt, dass er keine Kritik mehr zuließ.

### verwaschen — `grammar`
'die vielen heißen Wäschen' uses a nonstandard plural of 'Wäsche', which is a mass noun in standard German. The target usage 'die Farben ... verwaschen' is correct; only the plural is off. Natural phrasings are 'die vielen heißen Waschgänge' or the nominalized 'das viele heiße Waschen'.
- current de: Die vielen heißen Wäschen haben die Farben des T-Shirts ganz verwaschen.
- current en: All those hot washes have left the colors of the T-shirt completely faded.
- **fix de:** Die vielen heißen Waschgänge haben die Farben des T-Shirts ganz verwaschen.
- **fix en:** All those hot wash cycles have left the colors of the T-shirt completely faded.

### abfüllen — `translation`
'they bottle the young wine by hand into clean bottles' is redundant in English: 'bottle' already names the container, so 'into clean bottles' repeats it. The German 'in saubere Flaschen abfüllen' is not redundant because abfüllen names the decanting, not the vessel.
- current de: In der kleinen Kellerei füllen sie den jungen Wein von Hand in saubere Flaschen ab.
- current en: At the small winery, they bottle the young wine by hand into clean bottles.
- **fix en:** At the small winery, they pour the young wine by hand into clean bottles.

### abgießen — `translation`
'you carefully drain the hot water off over the colander' is word-for-word from 'über dem Sieb ab'. English drains water *through* a colander, not *over* one, and 'drain … off over' reads as an error rather than a register choice.
- current de: Sobald die Nudeln gar sind, gießt du das heiße Wasser vorsichtig über dem Sieb ab.
- current en: As soon as the pasta is done, you carefully drain the hot water off over the colander.
- **fix en:** As soon as the pasta is done, you carefully pour the hot water off through a colander.

### abtrinken — `translation`
'drink a little off it' is a word-for-word rendering of 'einen Schluck abtrinken' and is not idiomatic English; 'off it' has no natural antecedent reading here. English takes a sip off the top of an overfull glass.
- current de: Das Glas war so voll, dass er erst einen Schluck abtrinken musste, um es tragen zu können.
- current en: The glass was so full that he first had to drink a little off it to be able to carry it.
- **fix en:** The glass was so full that he first had to take a sip off the top to be able to carry it.

### anmischen — `translation`
'kept mixing the paint fresh' is a word-for-word carry-over of 'frisch … an' and is not idiomatic English; 'fresh' cannot post-modify 'the paint' this way. The German means he mixed up fresh batches until the shade matched.
- current de: Der Maler mischte die Farbe so lange frisch an, bis der Ton genau zur Wand passte.
- current en: The painter kept mixing the paint fresh until the shade matched the wall exactly.
- **fix en:** The painter kept mixing fresh batches of paint until the shade matched the wall exactly.

### antauchen — `translation`
'shoved the stalled car off the intersection' uses the wrong preposition; a car is pushed 'out of' an intersection, not 'off' it. 'off' would suit a surface one sits on (off the road, off the tracks).
- current de: Gemeinsam tauchten die Nachbarn an und schoben das liegengebliebene Auto von der Kreuzung.
- current en: Together the neighbors gave it a good push and shoved the stalled car off the intersection.
- **fix en:** Together the neighbors put their backs into it and pushed the stalled car out of the intersection.

### ausrücken — `translation`
"set out to a major blaze" is not idiomatic: "set out to" takes a verb ("set out to find them"), while a destination takes "set out for". English fire-service usage is "was called out to" / "turned out to" a blaze.
- current de: Mitten in der Nacht rückte die Feuerwehr zu einem Großbrand am Stadtrand aus.
- current en: In the middle of the night the fire brigade set out to a major blaze on the edge of town.
- **fix en:** In the middle of the night the fire brigade was called out to a major blaze on the edge of town.

### auswaschen — `translation`
"before it could dry in" is a Germanism for eintrocknen. English has no phrasal verb "dry in" in this sense; a stain "dries" or, idiomatically, "sets".
- current de: Sie wusch den Rotweinfleck sofort mit kaltem Wasser aus, bevor er eintrocknen konnte.
- current en: She washed the red wine stain out immediately with cold water before it could dry in.
- **fix en:** She washed the red wine stain out immediately with cold water before it could set.

### bereinigen — `translation`
"in a clearing-the-air conversation" is a mis-formed version of the English idiom, which is the attributive "a clear-the-air conversation" (or "a conversation that cleared the air"). The gerund form reads as word-for-word carryover of "klärendes Gespräch".
- current de: Nach dem langen Streit versuchten die beiden, ihre Differenzen in einem klärenden Gespräch zu bereinigen.
- current en: After the long quarrel the two of them tried to settle their differences in a clearing-the-air conversation.
- **fix en:** After the long quarrel the two of them tried to settle their differences in a clear-the-air conversation.

### davonreisen — `translation`
"simply traveled away" is a word-for-word calque of "reiste einfach davon" and is not idiomatic English; "travel away" is not a normal English collocation for departing.
- current de: Kaum hatte sie den Streit beendet, packte sie ihren Koffer und reiste einfach davon.
- current en: No sooner had she ended the argument than she packed her suitcase and simply traveled away.
- **fix en:** No sooner had she ended the argument than she packed her suitcase and simply departed.

### davorhalten — `translation`
The English supplies an antecedent the German does not have. In the German the only available referent for "davor" is "die Sonne", so the sentence says he held his hand in front of it; "in front of his eyes" introduces a noun (Augen) that appears nowhere in the German.
- current de: Als die Sonne ihn blendete, hielt er sich schnell die Hand davor.
- current en: When the sun blinded him, he quickly held his hand in front of his eyes.
- **fix en:** When the sun blinded him, he quickly held his hand up in front of it.

### draufhalten — `translation`
"held a swab pressed firmly on it" is not idiomatic English: it stacks a participle onto "held" where English wants either "held ... firmly on" or "pressed ... firmly onto".
- current de: Damit die Blutung endlich aufhörte, hielt die Ärztin einen Tupfer fest drauf.
- current en: To finally stop the bleeding, the doctor held a swab pressed firmly on it.
- **fix en:** To finally stop the bleeding, the doctor held a swab firmly on it.

### durchwachsen — `translation`
The English renders 'wuchs … durch' as 'grew up … between', which drops the through-a-barrier sense the verb exists to demonstrate. A learner reading gloss 'grow through' beside 'grew up between' gets no evidence of the particle's contribution.
- current de: Zwischen den Pflastersteinen wuchs im Frühling überall frisches Moos durch.
- current en: In spring, fresh moss grew up everywhere between the paving stones.
- **fix en:** In spring, fresh moss grew up everywhere through the gaps between the paving stones.

### einstechen — `translation`
The German 'stach die Nadel ... ein' (inserted/stuck the needle in) is correct, but 'pricked the needle in' misuses 'prick': in English you prick skin WITH a needle, not prick the needle itself. Cosmetic.
- current de: Die Krankenschwester stach die Nadel so behutsam ein, dass er es kaum spürte.
- current en: The nurse pricked the needle in so gently that he barely felt it.
- **fix en:** The nurse slid the needle in so gently that he barely felt it.

### entfolgen — `translation`
'posted nothing but ads anymore' is not idiomatic English: 'anymore' in an affirmative clause is regionally marked, and stacking it on the negative 'nothing but' reads as a word-for-word carry-over of 'nur noch'. The German is fine.
- current de: Weil er nur noch Werbung postete, entfolgte ich ihm auf allen Kanälen.
- current en: Because he posted nothing but ads anymore, I unfollowed him on every channel.
- **fix en:** Since all he posted now was ads, I unfollowed him on every channel.

### entnerven — `translation`
'unnerve' is a near-false friend here. English 'unnerve' means to deprive of composure or courage (a disconcerting effect), whereas 'entnerven' means to wear someone's nerves down to exasperation. A ringing phone exasperates; it does not rob anyone of nerve, so the English will teach the wrong equivalence.
- current de: Das pausenlose Klingeln des Telefons entnervte ihn so sehr, dass er es schließlich ausschaltete.
- current en: The nonstop ringing of the phone unnerved him so much that he finally switched it off.
- **fix en:** The nonstop ringing of the phone frayed his nerves so much that he finally switched it off.

### festbacken — `translation`
"bakes fast onto the tray" invites the wrong reading of 'fast': next to 'easily' a learner parses it as 'quickly' rather than as the archaic 'stuck fast'. Say 'sticks fast to'.
- current de: Ohne Backpapier backt der Teig im heißen Ofen leicht am Blech fest.
- current en: Without baking paper the dough easily bakes fast onto the tray in the hot oven.
- **fix en:** Without baking paper the dough easily sticks fast to the tray in the hot oven.

### festtreten — `translation`
"trod the soil firm around the seedling" is word-for-word rather than idiomatic; the resultative 'trod X firm' is not current English, and 'After planting it' puts the pronoun before its antecedent. 'Tamped down' is the ordinary gardening verb.
- current de: Nach dem Einpflanzen trat der Gärtner die Erde rund um den Setzling sorgfältig fest.
- current en: After planting it, the gardener carefully trod the soil firm around the seedling.
- **fix en:** After planting, the gardener carefully tamped down the soil around the seedling.

### flachlegen — `translation`
'erst einmal' means 'to start with, the first thing I did', but sentence-final 'first thing' in English is read as 'first thing in the morning', which contradicts 'after the long hike'.
- current de: Nach der langen Wanderung legte ich mich erst einmal eine Stunde flach.
- current en: After the long hike I lay down for an hour first thing.
- **fix en:** After the long hike, the first thing I did was lie down for an hour.

### heimleuchten — `translation`
'über den dunklen Feldweg' is 'along the dark farm track'; 'across the dark path' both mistranslates 'Feldweg' (a rural track between fields, not a generic path) and uses the wrong preposition — one walks along a track, not across it.
- current de: Der Großvater nahm die Laterne und leuchtete den Kindern über den dunklen Feldweg heim.
- current en: The grandfather took the lantern and lit the children's way home across the dark path.
- **fix en:** Grandfather took the lantern and lit the children's way home along the dark farm track.

### heimtrauen — `translation`
'After the broken vase' is a word-for-word calque of 'Nach der zerbrochenen Vase'. English does not use a bare result noun phrase this way; it needs the event, not the object.
- current de: Nach der zerbrochenen Vase traute sich der Junge den ganzen Nachmittag nicht heim.
- current en: After the broken vase, the boy didn't dare go home all afternoon.
- **fix en:** After breaking the vase, the boy didn't dare go home all afternoon.

### herunterziehen — `translation`
'shining too glaringly' is a word-for-word rendering of 'schien zu grell' and is not idiomatic English; the adverb 'glaringly' is used of statements ('glaringly obvious'), not of light. Natural English is 'too brightly' or 'the sun was glaring into the room'.
- current de: Weil die Sonne zu grell ins Zimmer schien, zog sie die Jalousien herunter.
- current en: Because the sun was shining too glaringly into the room, she pulled the blinds down.
- **fix en:** Because the sun was shining too brightly into the room, she pulled the blinds down.

### herüberkommen — `translation`
The English is punctuated as a statement but framed as a 'Why don't you …' question, so it ends with a period where it needs a question mark. Rendering the German invitation ('Komm doch …') as a plain imperative avoids the mismatch entirely and matches the German mood.
- current de: Komm doch am Samstag zu uns herüber, dann grillen wir gemeinsam im Garten.
- current en: Why don't you come over to our place on Saturday, and we'll barbecue together in the garden.
- **fix en:** Come over to our place on Saturday and we'll barbecue together in the garden.

### kaputtlachen — `translation`
'laughed ourselves to death' is a word-for-word rendering that is not idiomatic English; the fixed expression is 'died laughing'. The gloss's own 'crack up, laugh one's head off' points at the idiomatic options.
- current de: Bei seinem alten Witz haben wir uns fast kaputtgelacht.
- current en: We nearly laughed ourselves to death at his old joke.
- **fix en:** We almost died laughing at his old joke.

### klarlegen — `translation`
'laid out her expectations unmistakably clearly' stacks two adverbs of the same sense and reads as a calque. klarlegen is 'make clear', so the adjective belongs in the predicate rather than as a second adverb.
- current de: In der Besprechung legte die Chefin ihre Erwartungen unmissverständlich klar.
- current en: In the meeting, the boss laid out her expectations unmistakably clearly.
- **fix en:** In the meeting, the boss made her expectations unmistakably clear.

### mausrutschen — `translation`
Dangling participle in the English: the participial phrase 'Clicking too hastily' attaches to the main-clause subject 'my mouse', so the sentence literally says the mouse was clicking. The German subject is 'ich' throughout ('bin ich mausgerutscht'), so the person, not the mouse, should govern the participle.
- current de: Beim hastigen Klicken bin ich mausgerutscht und habe versehentlich die falsche Datei gelöscht.
- current en: Clicking too hastily, my mouse slipped and I accidentally deleted the wrong file.
- **fix en:** Clicking in haste, I slipped with the mouse and accidentally deleted the wrong file.

### niederreden — `translation`
'Talked his colleague down' is misleading English: 'talk someone down' means to condescend to them, to negotiate a price lower, or to guide a pilot to land. The German means overwhelming someone with a torrent of talk until they give up, which the English does not convey.
- current de: Er redete seine Kollegin in jeder Besprechung so lange nieder, bis sie schließlich verstummte.
- current en: He talked his colleague down in every meeting until she finally fell silent.
- **fix en:** He wore his colleague down with talk in every meeting until she finally fell silent.

### näherstehen — `translation`
The German is 'mein Bruder steht mir näher' — my brother is closer to me. The English swaps the subject and adds 'feel' ('I feel much closer to my brother'), so the clause the learner must align with the verb no longer matches it word for word.
- current de: Seit unserer gemeinsamen Reise durch Italien steht mir mein Bruder viel näher als früher.
- current en: Since our trip through Italy together, I feel much closer to my brother than before.
- **fix en:** Since our trip through Italy together, my brother is much closer to me than before.

### raufgehen — `translation`
'Walking up the four floors on foot' is pleonastic in English — 'walking up' already means on foot. The German 'zu Fuß' is not redundant, because it contrasts with the broken elevator, but it must not be rendered literally.
- current de: Weil der Aufzug wieder kaputt ist, gehen wir die vier Stockwerke zu Fuß rauf.
- current en: Since the elevator is broken again, we're walking up the four floors on foot.
- **fix en:** Since the elevator is broken again, we're walking up the four flights of stairs.

### rauslassen — `translation`
'at the next corner already' is a calque of 'schon'. German 'schon an der nächsten Ecke' means 'as early as the next corner'; English 'already' in that slot is not idiomatic.
- current de: Kannst du mich bitte schon an der nächsten Ecke rauslassen? Von dort laufe ich.
- current en: Can you please let me out at the next corner already? I'll walk from there.
- **fix en:** Can you please let me out as early as the next corner? I'll walk from there.

### umschalten — `translation`
'annoyedly' is a word-for-word rendering of 'genervt' and is vanishingly rare in real English; a learner would take it for normal usage. Idiomatic English puts the state before the verb ('irritated, he switched') or uses a prepositional phrase ('in irritation').
- current de: Als die Werbung begann, schaltete er genervt auf einen anderen Sender um.
- current en: When the commercials came on, he annoyedly switched to another channel.
- **fix en:** When the commercials came on, he switched to another channel in irritation.

### verrauchen — `translation`
The English stacks two adverbs before the verb in German word order — 'his anger surprisingly quickly evaporated'. English puts manner/degree adverbials after the verb here.
- current de: Nach einem tiefen Atemzug war sein Ärger überraschend schnell verraucht.
- current en: After a deep breath his anger surprisingly quickly evaporated.
- **fix en:** After a deep breath, his anger evaporated surprisingly quickly.

### vorherberechnen — `translation`
'Precalculate a solar eclipse' is a word-for-word rendering that English does not use with an event as object; one calculates or predicts an eclipse in advance. 'Heute' is also better rendered as 'today' in the sense of 'nowadays', which 'now' only partly carries.
- current de: Astronomen können eine Sonnenfinsternis heute auf die Minute genau vorherberechnen.
- current en: Astronomers can now precalculate a solar eclipse down to the exact minute.
- **fix en:** Astronomers today can calculate a solar eclipse in advance down to the exact minute.

### weiterverarbeiten — `translation`
'processes the fresh milk right on into cheese and yogurt' is not idiomatic English; 'right on into' is a word-for-word attempt at the continuation sense of weiter- plus 'gleich'. English carries that with an ordinary adverb of immediacy.
- current de: Die kleine Molkerei verarbeitet die frische Milch gleich zu Käse und Joghurt weiter.
- current en: The small dairy processes the fresh milk right on into cheese and yogurt.
- **fix en:** The small dairy processes the fresh milk into cheese and yogurt right away.

### widerreden — `translation`
'at every instruction' is a word-for-word rendering of 'bei jeder Anweisung'. English does not use 'at' with a count noun this way; the natural preposition here is 'over' (or a clause, 'every time an instruction was given').
- current de: Der Lehrling widerredete dem Meister bei jeder Anweisung und sorgte ständig für Ärger.
- current en: The apprentice talked back to the master at every instruction and constantly caused trouble.
- **fix en:** The apprentice talked back to the master over every instruction and constantly caused trouble.

### zufassen — `translation`
The English calls the child 'it' ('steadied it'), which German 'das Kind' → 'es' licenses but English does not; referring to a child as 'it' reads as a calque. 'hielt es fest' also drifts slightly: it is 'held fast/tight', not 'steadied'.
- current de: Als das Kind zu stolpern drohte, fasste die Mutter blitzschnell zu und hielt es fest.
- current en: When the child was about to stumble, the mother grabbed hold in a flash and steadied it.
- **fix en:** When the child was about to stumble, the mother grabbed hold in a flash and held the child fast.

### zurückbauen — `translation`
'wieder' in 'bauten … wieder zurück' is the idiomatic German 'back (to the prior state)', but it is rendered as 'again', which in English asserts a repetition — it reads as though the crew had dismantled the stage once before.
- current de: Nach dem Festival bauten die Helfer die große Bühne wieder zurück und räumten das ganze Gelände.
- current en: After the festival the crew dismantled the big stage again and cleared the whole site.
- **fix en:** After the festival the crew took the big stage back down and cleared the whole site.

### zurückmachen — `translation`
'langsam' here is the German discourse use meaning 'gradually, it's about time', not manner. 'we should slowly start heading back' renders it as speed, which is not what the German says.
- current de: Es ist schon spät geworden, wir sollten uns langsam auf den Heimweg zurückmachen.
- current en: It's gotten late already; we should slowly start heading back home.
- **fix en:** It's gotten late already; we should start back soon and head home.

### zutreten — `translation`
'trat er noch zu' is a single punctual kick ('he still got a kick in', 'he kicked him even then'); the English 'kept kicking' asserts a repeated action the German does not.
- current de: Feige trat er noch zu, als sein Gegner längst am Boden lag.
- current en: Like a coward, he kept kicking even after his opponent was long since on the ground.
- **fix en:** Like a coward, he kicked him even when his opponent was long since on the ground.

### übereinanderhalten — `translation`
'held her numb hands close over each other' is word-for-word rather than idiomatic English; 'over each other' is not how English describes hands stacked for warmth.
- current de: Vor Kälte zitternd hielt sie die klammen Hände dicht übereinander, um sie zu wärmen.
- current en: Shivering with cold, she held her numb hands close over each other to warm them.
- **fix en:** Shivering with cold, she held her numb hands pressed one on top of the other to warm them.

### bankrottgehen — `connotation`
"Nach den langen Lockdowns gingen zahlreiche kleine Restaurants ... bankrott" asserts a causal link between pandemic restrictions and small-business failure, which remains a contested political claim in German-language discourse. The German and the translation are both correct; the freight is in the subject matter, and a neutral cause costs the example nothing.
- current de: Nach den langen Lockdowns gingen zahlreiche kleine Restaurants in der Innenstadt bankrott.
- current en: After the long lockdowns, numerous small restaurants in the city center went bankrupt.
- **fix de:** Nach der langen Wirtschaftskrise gingen zahlreiche kleine Restaurants in der Innenstadt bankrott.
- **fix en:** After the long economic crisis, numerous small restaurants in the city center went bankrupt.

### keifen — `connotation`
keifen is a lexically gendered pejorative — dictionaries note it is applied disparagingly to women — and the sentence pairs it with 'die Nachbarin' shrieking over a fence about a flowerbed, which is the stock shrew image. The verb still needs teaching, but a male subject demonstrates it just as well without the stereotype.
- current de: Die Nachbarin keifte lautstark über den Zaun, weil unser Ball in ihrem Beet lag.
- current en: The neighbor shrilly scolded over the fence because our ball had landed in her flowerbed.
- **fix de:** Der Nachbar keifte lautstark über den Zaun, weil unser Ball in seinem Beet lag.
- **fix en:** The neighbor shrilly scolded over the fence because our ball had landed in his flowerbed.

### niedermachen — `connotation`
Soldiers massacring the inhabitants of a village 'ohne jede Gnade' reads, in a German-language context, as a depiction of a Wehrmacht/SS village massacre. The verb is inherently violent, so some violence is unavoidable, but the specific soldiers-versus-civilians framing carries freight a learner sentence does not need; a historical or non-civilian object keeps the sense without it.
- current de: Die Soldaten machten die Bewohner des kleinen Dorfes ohne jede Gnade nieder.
- current en: The soldiers slaughtered the inhabitants of the small village without any mercy.
- **fix de:** Die Truppen des Belagerers machten die letzten Verteidiger der Festung ohne jede Gnade nieder.
- **fix en:** The besieger's troops cut down the last defenders of the fortress without any mercy.

### ausschauen — `comma_splice`
"You really look tired today" and "did you sleep badly?" are both independent clauses joined by a bare comma. The German comma is correct German but does not carry into English; a statement joined to a question by a comma is still a splice.
- current de: Du schaust heute wirklich müde aus, hast du schlecht geschlafen?
- current en: You really look tired today, did you sleep badly?
- **fix en:** You really look tired today — did you sleep badly?

### dabeihaben — `comma_splice`
The English joins two independent clauses ('Luckily she had her ID on her' and 'they wouldn't have let her into the stadium') with only a comma plus the conjunctive adverb 'otherwise'. Since 'otherwise' is an adverb rather than a coordinating conjunction, the comma alone links the clauses, which is a splice in English. The German original's comma before 'sonst' is correct German but does not carry into English.
- current de: Zum Glück hatte sie ihren Ausweis dabei, sonst hätte man sie nicht ins Stadion gelassen.
- current en: Luckily she had her ID on her, otherwise they wouldn't have let her into the stadium.
- **fix en:** Luckily she had her ID on her; otherwise they wouldn't have let her into the stadium.

### hinauslehnen — `comma_splice`
'Don't lean so far out of the moving train' and 'it's really dangerous' are both independent clauses joined by a bare comma. The German comma before 'das ist wirklich gefährlich' is correct German; English needs a semicolon, dash, or period.
- current de: Lehn dich nicht so weit aus dem fahrenden Zug hinaus, das ist wirklich gefährlich!
- current en: Don't lean so far out of the moving train, it's really dangerous!
- **fix en:** Don't lean so far out of the moving train; it's really dangerous!

### vorbeischauen — `comma_splice`
The English joins two independent clauses ('Why don't you drop by our place tomorrow' / 'we've baked a fresh cake') with only a comma. The German comma is correct German, but it does not carry into English.
- current de: Schau doch morgen kurz bei uns vorbei, wir haben frischen Kuchen gebacken.
- current en: Why don't you drop by our place tomorrow, we've baked a fresh cake.
- **fix en:** Why don't you drop by our place tomorrow? We've baked a fresh cake.
