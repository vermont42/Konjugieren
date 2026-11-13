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

    static func quizDotRow(current: Int, total: Int, correct: Int, incorrect: Int, remaining: Int) -> String {
      String(localized: "Accessibility.quizDotRow \(current) \(total) \(correct) \(incorrect) \(remaining)")
    }

    static var quizBlank: String {
      String(localized: "Accessibility.quizBlank")
    }

    static func quizBlankPosition(_ position: Int, _ count: Int) -> String {
      String(localized: "Accessibility.quizBlankPosition \(position) \(count)")
    }

    static var quizSingular: String {
      String(localized: "Accessibility.quizSingular")
    }

    static var quizPlural: String {
      String(localized: "Accessibility.quizPlural")
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

  enum Lookup {
    static func verbWithGloss(infinitiv: String, gloss: String) -> String {
      String(localized: "Lookup.verbWithGloss \(infinitiv) \(gloss)")
    }

    static func conjugation(_ conjugation: String, cells: String, infinitiv: String) -> String {
      String(localized: "Lookup.conjugation \(conjugation) \(cells) \(infinitiv)")
    }

    static func finitePartOne(_ word: String, infinitiv: String, shown: String) -> String {
      String(localized: "Lookup.finitePartOne \(word) \(infinitiv) \(shown)")
    }

    static func finitePartMany(_ word: String, infinitiv: String, shown: String, others: Int) -> String {
      String(localized: "Lookup.finitePartMany \(word) \(infinitiv) \(shown) \(others)")
    }

    static func otherMatchesOne(_ word: String, verb: String) -> String {
      String(localized: "Lookup.otherMatchesOne \(word) \(verb)")
    }

    static func otherMatchesMany(_ word: String, count: Int, verb: String) -> String {
      String(localized: "Lookup.otherMatchesMany \(word) \(count) \(verb)")
    }

    static func guessVerb(_ word: String, infinitiv: String) -> String {
      String(localized: "Lookup.guessVerb \(word) \(infinitiv)")
    }

    static func guessConjugation(_ word: String, conjugation: String, infinitiv: String) -> String {
      String(localized: "Lookup.guessConjugation \(word) \(conjugation) \(infinitiv)")
    }

    static func nothing(_ word: String) -> String {
      String(localized: "Lookup.nothing \(word)")
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

    static var sortOrder: String {
      String(localized: "VerbBrowse.sortOrder")
    }

    static var searchPromptInfinitive: String {
      String(localized: "VerbBrowse.searchPromptInfinitive")
    }

    static var searchPromptInfinitiveOrMeaning: String {
      String(localized: "VerbBrowse.searchPromptInfinitiveOrMeaning")
    }

    static var noVerbsFound: String {
      String(localized: "VerbBrowse.noVerbsFound")
    }

    static func verbCount(_ count: Int) -> String {
      String(localized: "VerbBrowse.verbCount.\(count)")
    }

    static var addressCopied: String {
      String(localized: "VerbBrowse.addressCopied")
    }

    static var findVerb: String {
      String(localized: "VerbBrowse.findVerb")
    }

    static var guessIntro: String {
      String(localized: "VerbBrowse.guessIntro")
    }

    static func separableVerbs(_ count: Int) -> String {
      String(localized: "VerbBrowse.separableVerbs.\(count)")
    }

    static var separableVerbsHidden: String {
      String(localized: "VerbBrowse.separableVerbsHidden")
    }

    static var separableVerbsShown: String {
      String(localized: "VerbBrowse.separableVerbsShown")
    }

    static func verbRequest(query: String, address: String) -> String {
      String(localized: "VerbBrowse.verbRequest \(query) \(address)")
    }

    static func verbRequestSubject(query: String) -> String {
      String(localized: "VerbBrowse.verbRequestSubject \(query)")
    }

    static func verbRequestBody(query: String) -> String {
      String(localized: "VerbBrowse.verbRequestBody \(query)")
    }
  }

  enum MyVerbs {
    static var clearRecent: String {
      String(localized: "MyVerbs.clearRecent")
    }

    static var delete: String {
      String(localized: "MyVerbs.delete")
    }

    static var emptyDescription: String {
      String(localized: "MyVerbs.emptyDescription")
    }

    static var emptyTitle: String {
      String(localized: "MyVerbs.emptyTitle")
    }

    static var recent: String {
      String(localized: "MyVerbs.recent")
    }

    static var starred: String {
      String(localized: "MyVerbs.starred")
    }

    static var title: String {
      String(localized: "MyVerbs.title")
    }

    static var unstarConfirm: String {
      String(localized: "MyVerbs.unstarConfirm")
    }

    static var unstarMessage: String {
      String(localized: "MyVerbs.unstarMessage")
    }

    static func unstarTitle(_ infinitiv: String) -> String {
      String(localized: "MyVerbs.unstarTitle \(infinitiv)")
    }
  }

  enum ReviewCard {
    static var dismiss: String {
      String(localized: "ReviewCard.dismiss")
    }

    static func lookedUp(daysAgo: Int?) -> String {
      guard let daysAgo, daysAgo > 0 else {
        return String(localized: "ReviewCard.lookedUpEarlier")
      }
      return String(localized: "ReviewCard.lookedUp.\(daysAgo)")
    }

    static var openHint: String {
      String(localized: "ReviewCard.openHint")
    }

    static var prompt: String {
      String(localized: "ReviewCard.prompt")
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

    static var otherPrefixesHeading: String {
      String(localized: "FamilyDetail.otherPrefixesHeading")
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

    static var futurIIHeading: String {
      String(localized: "Info.futurIIHeading")
    }

    static var futurIIText: String {
      String(localized: "Info.futurIIText")
    }

    static var dudenHeading: String {
      String(localized: "Info.dudenHeading")
    }

    static var dudenText: String {
      String(localized: "Info.dudenText")
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

    static var reviewCardSuppressionHeading: String {
      String(localized: "Settings.reviewCardSuppressionHeading")
    }

    static var reviewCardSuppressionDescription: String {
      String(localized: "Settings.reviewCardSuppressionDescription")
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

    static var regionHeading: String {
      String(localized: "Settings.regionHeading")
    }

    static var regionDescription: String {
      String(localized: "Settings.regionDescription")
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

  enum Region {
    static var north: String {
      String(localized: "Region.north")
    }

    static var austria: String {
      String(localized: "Region.austria")
    }

    static var switzerland: String {
      String(localized: "Region.switzerland")
    }

    static func southernNote(example: String) -> String {
      String(localized: "Region.southernNote \(example)")
    }

    static var auxiliaryVariesLabel: String {
      String(localized: "Region.auxiliaryVariesLabel")
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

  enum ReviewCardSuppression {
    static var off: String {
      String(localized: "ReviewCardSuppression.off")
    }

    static var on: String {
      String(localized: "ReviewCardSuppression.on")
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
    static var bratwurst: String {
      String(localized: "AppIcon.bratwurst")
    }

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

    static var reasonAppleIntelligenceOff: String {
      String(localized: "Tutor.reasonAppleIntelligenceOff")
    }

    static var reasonDeviceNotEligible: String {
      String(localized: "Tutor.reasonDeviceNotEligible")
    }

    static var reasonModelNotReady: String {
      String(localized: "Tutor.reasonModelNotReady")
    }

    static var reasonUnknown: String {
      String(localized: "Tutor.reasonUnknown")
    }

    static var send: String {
      String(localized: "Tutor.send")
    }

    static var unableToAnswer: String {
      String(localized: "Tutor.unableToAnswer")
    }

    static var unavailable: String {
      String(localized: "Tutor.unavailable")
    }
  }

  enum Quiz {
    static var start: String {
      String(localized: "Quiz.start")
    }

    static var allVerbs: String {
      String(localized: "Quiz.allVerbs")
    }

    static var allVerbsDescription: String {
      String(localized: "Quiz.allVerbsDescription")
    }

    static var difficultyLabel: String {
      String(localized: "Quiz.difficultyLabel")
    }

    static func moreVerbs(_ count: Int) -> String {
      String(localized: "Quiz.moreVerbs.\(count)")
    }

    static var pointsPerAnswer: String {
      String(localized: "Quiz.pointsPerAnswer")
    }

    static var questionsLabel: String {
      String(localized: "Quiz.questionsLabel")
    }

    static var myVerbsEmpty: String {
      String(localized: "Quiz.myVerbsEmpty")
    }

    static func myVerbsCount(_ count: Int) -> String {
      String(localized: "Quiz.myVerbsCount.\(count)")
    }

    static var scope: String {
      String(localized: "Quiz.scope")
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

    static var announceCorrect: String {
      String(localized: "Quiz.announceCorrect")
    }

    static var announceIncorrect: String {
      String(localized: "Quiz.announceIncorrect")
    }

    static func announceCorrectSpelling(_ spelling: String) -> String {
      String(localized: "Quiz.announceCorrectSpelling \(spelling)")
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

  enum VerbCollection {
    static func ablautGroupTitle(_ exemplar: String) -> String {
      String(localized: "VerbCollection.ablautGroupTitle \(exemplar)")
    }

    static var heading: String {
      String(localized: "VerbCollection.heading")
    }

    static var lookedUp: String {
      String(localized: "VerbCollection.lookedUp")
    }

    static var modalsDescription: String {
      String(localized: "VerbCollection.modalsDescription")
    }

    static var modalsTitle: String {
      String(localized: "VerbCollection.modalsTitle")
    }

    static func progress(opened: Int, total: Int) -> String {
      String(localized: "VerbCollection.progress \(opened) \(total)")
    }

    static func quizHint(questionCount: Int) -> String {
      String(localized: "VerbCollection.quizHint \(questionCount)")
    }

    static var seinDescription: String {
      String(localized: "VerbCollection.seinDescription")
    }

    static var seinTitle: String {
      String(localized: "VerbCollection.seinTitle")
    }

    static func shareText(title: String, count: Int, sample: String, link: String, appStoreLink: String) -> String {
      let verbCount = String(localized: "VerbCollection.verbCount.\(count)")
      return String(localized: "VerbCollection.shareText \(title) \(verbCount) \(sample) \(link) \(appStoreLink)")
    }

    static var top100Description: String {
      String(localized: "VerbCollection.top100Description")
    }

    static var top100Title: String {
      String(localized: "VerbCollection.top100Title")
    }
  }

  enum VerbView {
    static func allRelated(_ count: Int) -> String {
      String(localized: "VerbView.allRelated.\(count)")
    }

    static func builtOn(_ root: String) -> String {
      String(localized: "VerbView.builtOn \(root)")
    }

    static var copy: String {
      String(localized: "VerbView.copy")
    }

    static var etymologyHeading: String {
      String(localized: "VerbView.etymologyHeading")
    }

    static var exampleSentenceHeading: String {
      String(localized: "VerbView.exampleSentenceHeading")
    }

    static var familiesHeading: String {
      String(localized: "VerbView.familiesHeading")
    }

    static var matchesSearch: String {
      String(localized: "VerbView.matchesSearch")
    }

    static var openArticle: String {
      String(localized: "VerbView.openArticle")
    }

    static var relatedHeading: String {
      String(localized: "VerbView.relatedHeading")
    }

    static func sameAblaut(_ group: String) -> String {
      String(localized: "VerbView.sameAblaut \(group)")
    }

    static func secondName(_ name: String) -> String {
      String(localized: "VerbView.secondName \(name)")
    }

    static var share: String {
      String(localized: "VerbView.share")
    }

    static var star: String {
      String(localized: "VerbView.star")
    }

    static var testMe: String {
      String(localized: "VerbView.testMe")
    }

    static var unstar: String {
      String(localized: "VerbView.unstar")
    }

    static func shareText(infinitiv: String, gloss: String, keyConjugations: String, link: String) -> String {
      String(localized: "VerbView.shareText \(infinitiv) \(gloss) \(keyConjugations) \(link)")
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
