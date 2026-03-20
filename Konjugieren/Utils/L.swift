// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

enum L {
  enum Accessibility {
    static var isIrregular: String {
      String(localized: "Accessibility.isIrregular")
    }

    static var areIrregular: String {
      String(localized: "Accessibility.areIrregular")
    }

    static var quizTextFieldHint: String {
      String(localized: "Accessibility.quizTextFieldHint")
    }

    static var quizStartHint: String {
      String(localized: "Accessibility.quizStartHint")
    }

    static var quizQuitHint: String {
      String(localized: "Accessibility.quizQuitHint")
    }

    static var leaderboardHint: String {
      String(localized: "Accessibility.leaderboardHint")
    }

    static var showOnboardingHint: String {
      String(localized: "Accessibility.showOnboardingHint")
    }
  }

  enum RatingsFetcher {
    static var noRating: String {
      String(localized: "RatingsFetcher.noRating")
    }

    static var oneRating: String {
      String(localized: "RatingsFetcher.oneRating")
    }

    static func multipleRatings(count: Int) -> String {
      String(localized: "RatingsFetcher.multipleRatings \(count)")
    }
  }

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

    static var dismiss: String {
      String(localized: "Navigation.dismiss")
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

    static var gameHeading: String {
      String(localized: "Info.gameHeading")
    }

    static var gameText: String {
      String(localized: "Info.gameText")
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

    static var appIconHeading: String {
      String(localized: "Settings.appIconHeading")
    }

    static var appIconDescription: String {
      String(localized: "Settings.appIconDescription")
    }

    static var rateOrReview: String {
      String(localized: "Settings.rateOrReview")
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

  enum AppIcon {
    static var hat: String {
      String(localized: "AppIcon.hat")
    }

    static var pretzel: String {
      String(localized: "AppIcon.pretzel")
    }

    static var bundestag: String {
      String(localized: "AppIcon.bundestag")
    }
  }

  enum Tutor {
    static var deleteChatHistory: String {
      String(localized: "Tutor.deleteChatHistory")
    }

    static var deleteChatHistoryDescription: String {
      String(localized: "Tutor.deleteChatHistoryDescription")
    }

    static var description: String {
      String(localized: "Tutor.description")
    }

    static var getSampleQuery: String {
      String(localized: "Tutor.getSampleQuery")
    }

    static var getSampleQueryDescription: String {
      String(localized: "Tutor.getSampleQueryDescription")
    }

    static var getSuggestions: String {
      String(localized: "Tutor.getSuggestions")
    }

    static var heading: String {
      String(localized: "Tutor.heading")
    }

    static var inputPlaceholder: String {
      String(localized: "Tutor.inputPlaceholder")
    }

    static var loading: String {
      String(localized: "Tutor.loading")
    }

    static var poweredBy: String {
      String(localized: "Tutor.poweredBy")
    }

    static var practiceRecommendations: String {
      String(localized: "Tutor.practiceRecommendations")
    }

    static var practiceRecommendationsDescription: String {
      String(localized: "Tutor.practiceRecommendationsDescription")
    }

    static var send: String {
      String(localized: "Tutor.send")
    }

    static var unavailable: String {
      String(localized: "Tutor.unavailable")
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

  enum Game {
    static var playGame: String {
      String(localized: "Game.playGame")
    }

    static var playGameDescription: String {
      String(localized: "Game.playGameDescription")
    }

    static func highScoreChallenge(score: Int) -> String {
      String(localized: "Game.highScoreChallenge \(score)")
    }

    static var score: String {
      String(localized: "Game.score")
    }

    static var health: String {
      String(localized: "Game.health")
    }

    static var gameOver: String {
      String(localized: "Game.gameOver")
    }

    static var wave: String {
      String(localized: "Game.wave")
    }

    static var waveScore: String {
      String(localized: "Game.waveScore")
    }

    static var newHighScore: String {
      String(localized: "Game.newHighScore")
    }

    static var finalScore: String {
      String(localized: "Game.finalScore")
    }

    static var tapToPlayAgain: String {
      String(localized: "Game.tapToPlayAgain")
    }

    static var quit: String {
      String(localized: "Game.quit")
    }
  }

  enum GameCenter {
    static var leaderboard: String {
      String(localized: "GameCenter.leaderboard")
    }

    static var viewLeaderboard: String {
      String(localized: "GameCenter.viewLeaderboard")
    }

    static var viewLeaderboardDescription: String {
      String(localized: "GameCenter.viewLeaderboardDescription")
    }
  }

  enum ErrorExplainer {
    static var explanation: String {
      String(localized: "ErrorExplainer.explanation")
    }

    static var loading: String {
      String(localized: "ErrorExplainer.loading")
    }

    static var mnemonic: String {
      String(localized: "ErrorExplainer.mnemonic")
    }

    static var retry: String {
      String(localized: "ErrorExplainer.retry")
    }

    static var rule: String {
      String(localized: "ErrorExplainer.rule")
    }

    static var whyWrong: String {
      String(localized: "ErrorExplainer.whyWrong")
    }
  }

  enum VerbView {
    static var etymologyHeading: String {
      String(localized: "VerbView.etymologyHeading")
    }

    static var exampleSentenceHeading: String {
      String(localized: "VerbView.exampleSentenceHeading")
    }
  }

  enum Onboarding {
    static var aiBody: String {
      String(localized: "Onboarding.aiBody")
    }

    static var aiTitle: String {
      String(localized: "Onboarding.aiTitle")
    }

    static var conjugationgroupBody: String {
      String(localized: "Onboarding.conjugationgroupBody")
    }

    static var conjugationgroupButtonTitle: String {
      String(localized: "Onboarding.conjugationgroupButtonTitle")
    }

    static var conjugationgroupHeading: String {
      String(localized: "Onboarding.conjugationgroupHeading")
    }

    static var dismiss: String {
      String(localized: "Onboarding.dismiss")
    }

    static var skip: String {
      String(localized: "Onboarding.skip")
    }

    static var getStarted: String {
      String(localized: "Onboarding.getStarted")
    }

    static var showOnboarding: String {
      String(localized: "Onboarding.showOnboarding")
    }

    static var showOnboardingDescription: String {
      String(localized: "Onboarding.showOnboardingDescription")
    }

    static var welcomeTitle: String {
      String(localized: "Onboarding.welcomeTitle")
    }

    static var welcomeBody: String {
      String(localized: "Onboarding.welcomeBody")
    }

    static var browseTitle: String {
      String(localized: "Onboarding.browseTitle")
    }

    static var browseBody: String {
      String(localized: "Onboarding.browseBody")
    }

    static var quizTitle: String {
      String(localized: "Onboarding.quizTitle")
    }

    static var quizBody: String {
      String(localized: "Onboarding.quizBody")
    }

    static var learnTitle: String {
      String(localized: "Onboarding.learnTitle")
    }

    static var learnBody: String {
      String(localized: "Onboarding.learnBody")
    }

    static var familiesTitle: String {
      String(localized: "Onboarding.familiesTitle")
    }

    static var familiesBody: String {
      String(localized: "Onboarding.familiesBody")
    }

    static var browseVerbsButton: String {
      String(localized: "Onboarding.browseVerbsButton")
    }

    static var exploreFamiliesButton: String {
      String(localized: "Onboarding.exploreFamiliesButton")
    }

    static var startQuizButton: String {
      String(localized: "Onboarding.startQuizButton")
    }

    static var meetTutorButton: String {
      String(localized: "Onboarding.meetTutorButton")
    }

    static var readArticlesButton: String {
      String(localized: "Onboarding.readArticlesButton")
    }
  }

}
