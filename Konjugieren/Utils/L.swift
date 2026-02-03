// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

enum L {
  enum Navigation {
    static var verbs: String {
      String(localized: "Navigation.verbs")
    }

    static var families: String {
      String(localized: "Navigation.families")
    }

    static var quiz: String {
      String(localized: "Navigation.quiz")
    }

    static var info: String {
      String(localized: "Navigation.info")
    }

    static var settings: String {
      String(localized: "Navigation.settings")
    }

    static var verb: String {
      String(localized: "Navigation.verb")
    }
  }

  enum Testing {
    static var runningUnitTests: String {
      String(localized: "Testing.runningUnitTests")
    }
  }

  enum VerbBrowse {
    static var alphabetical: String {
      String(localized: "VerbBrowse.alphabetical")
    }

    static var frequency: String {
      String(localized: "VerbBrowse.frequency")
    }

    static var searchPrompt: String {
      String(localized: "VerbBrowse.searchPrompt")
    }
  }

  enum SearchScope {
    static var infinitiveOnly: String {
      String(localized: "SearchScope.infinitiveOnly")
    }

    static var infinitiveAndTranslation: String {
      String(localized: "SearchScope.infinitiveAndTranslation")
    }
  }

  enum Family {
    static var strong: String {
      String(localized: "Family.strong")
    }

    static var mixed: String {
      String(localized: "Family.mixed")
    }

    static var weak: String {
      String(localized: "Family.weak")
    }

    static var ieren: String {
      String(localized: "Family.ieren")
    }
  }

  enum BrowseableFamily {
    static var separable: String {
      String(localized: "BrowseableFamily.separable")
    }

    static var inseparable: String {
      String(localized: "BrowseableFamily.inseparable")
    }

    static var ablaut: String {
      String(localized: "BrowseableFamily.ablaut")
    }
  }

  enum FamilyBrowse {
    static var viewVerbs: String {
      String(localized: "FamilyBrowse.viewVerbs")
    }

    static var strongShort: String {
      String(localized: "FamilyBrowse.strongShort")
    }

    static var weakShort: String {
      String(localized: "FamilyBrowse.weakShort")
    }

    static var mixedShort: String {
      String(localized: "FamilyBrowse.mixedShort")
    }

    static var ierenShort: String {
      String(localized: "FamilyBrowse.ierenShort")
    }

    static var separableShort: String {
      String(localized: "FamilyBrowse.separableShort")
    }

    static var inseparableShort: String {
      String(localized: "FamilyBrowse.inseparableShort")
    }

    static var ablautShort: String {
      String(localized: "FamilyBrowse.ablautShort")
    }
  }

  enum FamilyDetail {
    static var verbsHeading: String {
      String(localized: "FamilyDetail.verbsHeading")
    }

    static var prefixesHeading: String {
      String(localized: "FamilyDetail.prefixesHeading")
    }

    static var strongLong: String {
      String(localized: "FamilyDetail.strongLong")
    }

    static var weakLong: String {
      String(localized: "FamilyDetail.weakLong")
    }

    static var mixedLong: String {
      String(localized: "FamilyDetail.mixedLong")
    }

    static var ierenLong: String {
      String(localized: "FamilyDetail.ierenLong")
    }

    static var separableLong: String {
      String(localized: "FamilyDetail.separableLong")
    }

    static var inseparableLong: String {
      String(localized: "FamilyDetail.inseparableLong")
    }

    static var ablautLong: String {
      String(localized: "FamilyDetail.ablautLong")
    }
  }

  enum PIEMeaning {
    static var ab: String {
      String(localized: "PIEMeaning.ab")
    }

    static var an: String {
      String(localized: "PIEMeaning.an")
    }

    static var auf: String {
      String(localized: "PIEMeaning.auf")
    }

    static var aus: String {
      String(localized: "PIEMeaning.aus")
    }

    static var bei: String {
      String(localized: "PIEMeaning.bei")
    }

    static var be: String {
      String(localized: "PIEMeaning.be")
    }

    static var ein: String {
      String(localized: "PIEMeaning.ein")
    }

    static var emp: String {
      String(localized: "PIEMeaning.emp")
    }

    static var ent: String {
      String(localized: "PIEMeaning.ent")
    }

    static var er: String {
      String(localized: "PIEMeaning.er")
    }

    static var fest: String {
      String(localized: "PIEMeaning.fest")
    }

    static var fort: String {
      String(localized: "PIEMeaning.fort")
    }

    static var ge: String {
      String(localized: "PIEMeaning.ge")
    }

    static var her: String {
      String(localized: "PIEMeaning.her")
    }

    static var hin: String {
      String(localized: "PIEMeaning.hin")
    }

    static var hoch: String {
      String(localized: "PIEMeaning.hoch")
    }

    static var mit: String {
      String(localized: "PIEMeaning.mit")
    }

    static var nach: String {
      String(localized: "PIEMeaning.nach")
    }

    static var um: String {
      String(localized: "PIEMeaning.um")
    }

    static var ver: String {
      String(localized: "PIEMeaning.ver")
    }

    static var vor: String {
      String(localized: "PIEMeaning.vor")
    }

    static var zer: String {
      String(localized: "PIEMeaning.zer")
    }

    static var zu: String {
      String(localized: "PIEMeaning.zu")
    }

    static var zurueck: String {
      String(localized: "PIEMeaning.zurueck")
    }

    static var zusammen: String {
      String(localized: "PIEMeaning.zusammen")
    }
  }

  enum AblautGroupInfo {
    static var beginnen: String {
      String(localized: "AblautGroupInfo.beginnen")
    }

    static var bieten: String {
      String(localized: "AblautGroupInfo.bieten")
    }

    static var bitten: String {
      String(localized: "AblautGroupInfo.bitten")
    }

    static var bleiben: String {
      String(localized: "AblautGroupInfo.bleiben")
    }

    static var bringen: String {
      String(localized: "AblautGroupInfo.bringen")
    }

    static var dürfen: String {
      String(localized: "AblautGroupInfo.dürfen")
    }

    static var empfehlen: String {
      String(localized: "AblautGroupInfo.empfehlen")
    }

    static var essen: String {
      String(localized: "AblautGroupInfo.essen")
    }

    static var erscheinen: String {
      String(localized: "AblautGroupInfo.erscheinen")
    }

    static var fahren: String {
      String(localized: "AblautGroupInfo.fahren")
    }

    static var fallen: String {
      String(localized: "AblautGroupInfo.fallen")
    }

    static var fangen: String {
      String(localized: "AblautGroupInfo.fangen")
    }

    static var finden: String {
      String(localized: "AblautGroupInfo.finden")
    }

    static var fliegen: String {
      String(localized: "AblautGroupInfo.fliegen")
    }

    static var geben: String {
      String(localized: "AblautGroupInfo.geben")
    }

    static var gebären: String {
      String(localized: "AblautGroupInfo.gebären")
    }

    static var gehen: String {
      String(localized: "AblautGroupInfo.gehen")
    }

    static var greifen: String {
      String(localized: "AblautGroupInfo.greifen")
    }

    static var gelingen: String {
      String(localized: "AblautGroupInfo.gelingen")
    }

    static var gelten: String {
      String(localized: "AblautGroupInfo.gelten")
    }

    static var gewinnen: String {
      String(localized: "AblautGroupInfo.gewinnen")
    }

    static var haben: String {
      String(localized: "AblautGroupInfo.haben")
    }

    static var halten: String {
      String(localized: "AblautGroupInfo.halten")
    }

    static var heben: String {
      String(localized: "AblautGroupInfo.heben")
    }

    static var heißen: String {
      String(localized: "AblautGroupInfo.heißen")
    }

    static var kennen: String {
      String(localized: "AblautGroupInfo.kennen")
    }

    static var kommen: String {
      String(localized: "AblautGroupInfo.kommen")
    }

    static var können: String {
      String(localized: "AblautGroupInfo.können")
    }

    static var laden: String {
      String(localized: "AblautGroupInfo.laden")
    }

    static var lassen: String {
      String(localized: "AblautGroupInfo.lassen")
    }

    static var laufen: String {
      String(localized: "AblautGroupInfo.laufen")
    }

    static var liegen: String {
      String(localized: "AblautGroupInfo.liegen")
    }

    static var mögen: String {
      String(localized: "AblautGroupInfo.mögen")
    }

    static var müssen: String {
      String(localized: "AblautGroupInfo.müssen")
    }

    static var nehmen: String {
      String(localized: "AblautGroupInfo.nehmen")
    }

    static var rufen: String {
      String(localized: "AblautGroupInfo.rufen")
    }

    static var reißen: String {
      String(localized: "AblautGroupInfo.reißen")
    }

    static var schaffen: String {
      String(localized: "AblautGroupInfo.schaffen")
    }

    static var schlagen: String {
      String(localized: "AblautGroupInfo.schlagen")
    }

    static var schlafen: String {
      String(localized: "AblautGroupInfo.schlafen")
    }

    static var schließen: String {
      String(localized: "AblautGroupInfo.schließen")
    }

    static var schreien: String {
      String(localized: "AblautGroupInfo.schreien")
    }

    static var schreiten: String {
      String(localized: "AblautGroupInfo.schreiten")
    }

    static var schneiden: String {
      String(localized: "AblautGroupInfo.schneiden")
    }

    static var sehen: String {
      String(localized: "AblautGroupInfo.sehen")
    }

    static var sein: String {
      String(localized: "AblautGroupInfo.sein")
    }

    static var singen: String {
      String(localized: "AblautGroupInfo.singen")
    }

    static var sitzen: String {
      String(localized: "AblautGroupInfo.sitzen")
    }

    static var sprechen: String {
      String(localized: "AblautGroupInfo.sprechen")
    }

    static var stehen: String {
      String(localized: "AblautGroupInfo.stehen")
    }

    static var steigen: String {
      String(localized: "AblautGroupInfo.steigen")
    }

    static var sterben: String {
      String(localized: "AblautGroupInfo.sterben")
    }

    static var stoßen: String {
      String(localized: "AblautGroupInfo.stoßen")
    }

    static var streichen: String {
      String(localized: "AblautGroupInfo.streichen")
    }

    static var tragen: String {
      String(localized: "AblautGroupInfo.tragen")
    }

    static var treffen: String {
      String(localized: "AblautGroupInfo.treffen")
    }

    static var treten: String {
      String(localized: "AblautGroupInfo.treten")
    }

    static var tun: String {
      String(localized: "AblautGroupInfo.tun")
    }

    static var verlieren: String {
      String(localized: "AblautGroupInfo.verlieren")
    }

    static var wachsen: String {
      String(localized: "AblautGroupInfo.wachsen")
    }

    static var weisen: String {
      String(localized: "AblautGroupInfo.weisen")
    }

    static var werden: String {
      String(localized: "AblautGroupInfo.werden")
    }

    static var werfen: String {
      String(localized: "AblautGroupInfo.werfen")
    }

    static var wissen: String {
      String(localized: "AblautGroupInfo.wissen")
    }

    static var wollen: String {
      String(localized: "AblautGroupInfo.wollen")
    }

    static var ziehen: String {
      String(localized: "AblautGroupInfo.ziehen")
    }
  }

  enum Info {
    static var dedicationHeading: String {
      String(localized: "Info.dedicationHeading")
    }

    static var dedicationText: String {
      String(localized: "Info.dedicationText")
    }

    static var terminologyHeading: String {
      String(localized: "Info.terminologyHeading")
    }

    static var terminologyText: String {
      String(localized: "Info.terminologyText")
    }

    static var tenseHeading: String {
      String(localized: "Info.tenseHeading")
    }

    static var tenseText: String {
      String(localized: "Info.tenseText")
    }

    static var moodHeading: String {
      String(localized: "Info.moodHeading")
    }

    static var moodText: String {
      String(localized: "Info.moodText")
    }

    static var voiceHeading: String {
      String(localized: "Info.voiceHeading")
    }

    static var voiceText: String {
      String(localized: "Info.voiceText")
    }

    static var perfektpartizipHeading: String {
      String(localized: "Info.perfektpartizipHeading")
    }

    static var perfektpartizipText: String {
      String(localized: "Info.perfektpartizipText")
    }

    static var präsenspartizipHeading: String {
      String(localized: "Info.präsenspartizipHeading")
    }

    static var präsenspartizipText: String {
      String(localized: "Info.präsenspartizipText")
    }

    static var präsensIndikativHeading: String {
      String(localized: "Info.präsensIndikativHeading")
    }

    static var präsensIndikativText: String {
      String(localized: "Info.präsensIndikativText")
    }

    static var präteritumIndikativHeading: String {
      String(localized: "Info.präteritumIndikativHeading")
    }

    static var präteritumIndikativText: String {
      String(localized: "Info.präteritumIndikativText")
    }

    static var präsensKonjunktivIHeading: String {
      String(localized: "Info.präsensKonjunktivIHeading")
    }

    static var präsensKonjunktivIText: String {
      String(localized: "Info.präsensKonjunktivIText")
    }

    static var präteritumKonjunktivIIHeading: String {
      String(localized: "Info.präteritumKonjunktivIIHeading")
    }

    static var präteritumKonjunktivIIText: String {
      String(localized: "Info.präteritumKonjunktivIIText")
    }

    static var imperativHeading: String {
      String(localized: "Info.imperativHeading")
    }

    static var imperativText: String {
      String(localized: "Info.imperativText")
    }

    static var perfektIndikativHeading: String {
      String(localized: "Info.perfektIndikativHeading")
    }

    static var perfektIndikativText: String {
      String(localized: "Info.perfektIndikativText")
    }

    static var perfektKonjunktivIHeading: String {
      String(localized: "Info.perfektKonjunktivIHeading")
    }

    static var perfektKonjunktivIText: String {
      String(localized: "Info.perfektKonjunktivIText")
    }

    static var plusquamperfektIndikativHeading: String {
      String(localized: "Info.plusquamperfektIndikativHeading")
    }

    static var plusquamperfektIndikativText: String {
      String(localized: "Info.plusquamperfektIndikativText")
    }

    static var plusquamperfektKonjunktivIIHeading: String {
      String(localized: "Info.plusquamperfektKonjunktivIIHeading")
    }

    static var plusquamperfektKonjunktivIIText: String {
      String(localized: "Info.plusquamperfektKonjunktivIIText")
    }

    static var futurIndikativHeading: String {
      String(localized: "Info.futurIndikativHeading")
    }

    static var futurIndikativText: String {
      String(localized: "Info.futurIndikativText")
    }

    static var futurKonjunktivIHeading: String {
      String(localized: "Info.futurKonjunktivIHeading")
    }

    static var futurKonjunktivIText: String {
      String(localized: "Info.futurKonjunktivIText")
    }

    static var futurKonjunktivIIHeading: String {
      String(localized: "Info.futurKonjunktivIIHeading")
    }

    static var futurKonjunktivIIText: String {
      String(localized: "Info.futurKonjunktivIIText")
    }

    static var creditsHeading: String {
      String(localized: "Info.creditsHeading")
    }

    static var creditsText: String {
      String(localized: "Info.creditsText")
    }

    static var verbHistoryHeading: String {
      String(localized: "Info.verbHistoryHeading")
    }

    static var verbHistoryText: String {
      String(localized: "Info.verbHistoryText")
    }
  }

  enum Settings {
    static var conjugationgroupLangHeading: String {
      String(localized: "Settings.conjugationgroupLangHeading")
    }

    static var conjugationgroupLangDescription: String {
      String(localized: "Settings.conjugationgroupLangDescription")
    }

    static var thirdPersonPronounGenderHeading: String {
      String(localized: "Settings.thirdPersonPronounGenderHeading")
    }

    static var thirdPersonPronounGenderDescription: String {
      String(localized: "Settings.thirdPersonPronounGenderDescription")
    }

    static var quizDifficultyHeading: String {
      String(localized: "Settings.quizDifficultyHeading")
    }

    static var quizDifficultyDescription: String {
      String(localized: "Settings.quizDifficultyDescription")
    }

    static var audioFeedbackHeading: String {
      String(localized: "Settings.audioFeedbackHeading")
    }

    static var audioFeedbackDescription: String {
      String(localized: "Settings.audioFeedbackDescription")
    }

    static var searchScopeHeading: String {
      String(localized: "Settings.searchScopeHeading")
    }

    static var searchScopeDescription: String {
      String(localized: "Settings.searchScopeDescription")
    }
  }

  enum Conjugationgroup {
    static var perfektpartizip: String {
      String(localized: "Conjugationgroup.perfektpartizip")
    }

    static var präsenspartizip: String {
      String(localized: "Conjugationgroup.präsenspartizip")
    }

    static var präsensIndicativ: String {
      String(localized: "Conjugationgroup.präsensIndicativ")
    }

    static var präsensKonjunktivI: String {
      String(localized: "Conjugationgroup.präsensKonjunktivI")
    }

    static var präteritumIndicativ: String {
      String(localized: "Conjugationgroup.präteritumIndicativ")
    }

    static var präteritumKonjunktivII: String {
      String(localized: "Conjugationgroup.präteritumKonjunktivII")
    }

    static var imperativ: String {
      String(localized: "Conjugationgroup.imperativ")
    }

    static var perfektIndikativ: String {
      String(localized: "Conjugationgroup.perfektIndikativ")
    }

    static var perfektKonjunktivI: String {
      String(localized: "Conjugationgroup.perfektKonjunktivI")
    }

    static var plusquamperfektIndikativ: String {
      String(localized: "Conjugationgroup.plusquamperfektIndikativ")
    }

    static var plusquamperfektKonjunktivII: String {
      String(localized: "Conjugationgroup.plusquamperfektKonjunktivII")
    }

    static var futurIndikativ: String {
      String(localized: "Conjugationgroup.futurIndikativ")
    }

    static var futurKonjunktivI: String {
      String(localized: "Conjugationgroup.futurKonjunktivI")
    }

    static var futurKonjunktivII: String {
      String(localized: "Conjugationgroup.futurKonjunktivII")
    }
  }

  enum ConjugationgroupLang {
    static var english: String {
      String(localized: "ConjugationgroupLang.english")
    }

    static var german: String {
      String(localized: "ConjugationgroupLang.german")
    }
  }

  enum ThirdPersonPronounGender {
    static var er: String {
      String(localized: "ThirdPersonPronounGender.er")
    }

    static var sie: String {
      String(localized: "ThirdPersonPronounGender.sie")
    }

    static var es: String {
      String(localized: "ThirdPersonPronounGender.es")
    }
  }

  enum QuizDifficulty {
    static var regular: String {
      String(localized: "QuizDifficulty.regular")
    }

    static var ridiculous: String {
      String(localized: "QuizDifficulty.ridiculous")
    }
  }

  enum AudioFeedback {
    static var enable: String {
      String(localized: "AudioFeedback.enable")
    }

    static var disable: String {
      String(localized: "AudioFeedback.disable")
    }
  }

  enum Quiz {
    static var start: String {
      String(localized: "Quiz.start")
    }

    static var quit: String {
      String(localized: "Quiz.quit")
    }

    static var verb: String {
      String(localized: "Quiz.verb")
    }

    static var translation: String {
      String(localized: "Quiz.translation")
    }

    static var pronoun: String {
      String(localized: "Quiz.pronoun")
    }

    static var conjugationgroup: String {
      String(localized: "Quiz.conjugationgroup")
    }

    static var progress: String {
      String(localized: "Quiz.progress")
    }

    static var elapsed: String {
      String(localized: "Quiz.elapsed")
    }

    static var score: String {
      String(localized: "Quiz.score")
    }

    static var lastAnswer: String {
      String(localized: "Quiz.lastAnswer")
    }

    static var correctAnswer: String {
      String(localized: "Quiz.correctAnswer")
    }

    static var conjugation: String {
      String(localized: "Quiz.conjugation")
    }

    static var results: String {
      String(localized: "Quiz.results")
    }

    static var correct: String {
      String(localized: "Quiz.correct")
    }

    static var difficulty: String {
      String(localized: "Quiz.difficulty")
    }

    static var time: String {
      String(localized: "Quiz.time")
    }
  }

  enum ImageInfo {
    static var cliffSchmiesing: String {
      String(localized: "ImageInfo.cliffSchmiesing")
    }

    static var joshAdams: String {
      String(localized: "ImageInfo.joshAdams")
    }
  }

  enum GameCenter {
    static var leaderboard: String {
      String(localized: "GameCenter.leaderboard")
    }

    static var viewLeaderboard: String {
      String(localized: "GameCenter.viewLeaderboard")
    }
  }
}
