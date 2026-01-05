// Copyright © 2025 Josh Adams. All rights reserved.

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
  }

  enum VerbView {
    static var translation: String {
      String(localized: "VerbView.translation")
    }

    static var family: String {
      String(localized: "VerbView.family")
    }

    static var auxiliary: String {
      String(localized: "VerbView.auxiliary")
    }

    static var conjugations: String {
      String(localized: "VerbView.conjugations")
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

  enum Info {
    static var history: String {
      String(localized: "Info.history")
    }

    static var historySubtitle: String {
      String(localized: "Info.historySubtitle")
    }
  }

  enum History {
    static var stardustTitle: String {
      String(localized: "History.stardustTitle")
    }

    static var stardustContent: String {
      String(localized: "History.stardustContent")
    }

    static var longRoadTitle: String {
      String(localized: "History.longRoadTitle")
    }

    static var longRoadContent: String {
      String(localized: "History.longRoadContent")
    }

    static var yamnayaTitle: String {
      String(localized: "History.yamnayaTitle")
    }

    static var yamnayaContent: String {
      String(localized: "History.yamnayaContent")
    }

    static var pieVerbSystemTitle: String {
      String(localized: "History.pieVerbSystemTitle")
    }

    static var pieVerbSystemContent: String {
      String(localized: "History.pieVerbSystemContent")
    }

    static var ablautTitle: String {
      String(localized: "History.ablautTitle")
    }

    static var ablautContent: String {
      String(localized: "History.ablautContent")
    }

    static var migrationTitle: String {
      String(localized: "History.migrationTitle")
    }

    static var migrationContent: String {
      String(localized: "History.migrationContent")
    }

    static var teutoburgTitle: String {
      String(localized: "History.teutoburgTitle")
    }

    static var teutoburgContent: String {
      String(localized: "History.teutoburgContent")
    }

    static var germanicLifewaysTitle: String {
      String(localized: "History.germanicLifewaysTitle")
    }

    static var germanicLifewaysContent: String {
      String(localized: "History.germanicLifewaysContent")
    }

    static var germanicVerbSystemTitle: String {
      String(localized: "History.germanicVerbSystemTitle")
    }

    static var germanicVerbSystemContent: String {
      String(localized: "History.germanicVerbSystemContent")
    }

    static var weakVerbsTitle: String {
      String(localized: "History.weakVerbsTitle")
    }

    static var weakVerbsContent: String {
      String(localized: "History.weakVerbsContent")
    }

    static var oldHighGermanTitle: String {
      String(localized: "History.oldHighGermanTitle")
    }

    static var oldHighGermanContent: String {
      String(localized: "History.oldHighGermanContent")
    }

    static var perfectTenseTitle: String {
      String(localized: "History.perfectTenseTitle")
    }

    static var perfectTenseContent: String {
      String(localized: "History.perfectTenseContent")
    }

    static var futureTenseTitle: String {
      String(localized: "History.futureTenseTitle")
    }

    static var futureTenseContent: String {
      String(localized: "History.futureTenseContent")
    }

    static var subjunctiveTitle: String {
      String(localized: "History.subjunctiveTitle")
    }

    static var subjunctiveContent: String {
      String(localized: "History.subjunctiveContent")
    }

    static var verbSystemTodayTitle: String {
      String(localized: "History.verbSystemTodayTitle")
    }

    static var verbSystemTodayContent: String {
      String(localized: "History.verbSystemTodayContent")
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

    static var präteritumKonditional: String {
      String(localized: "Conjugationgroup.präteritumKonditional")
    }

    static var imperativ: String {
      String(localized: "Conjugationgroup.imperativ")
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
}
