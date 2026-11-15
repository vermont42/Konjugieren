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

    static var customQuizEditHint: String {
      String(localized: "Accessibility.customQuizEditHint")
    }

    static var customQuizStartHint: String {
      String(localized: "Accessibility.customQuizStartHint")
    }

    static var practiceSetShareHint: String {
      String(localized: "Accessibility.practiceSetShareHint")
    }

    static var practiceSetStartHint: String {
      String(localized: "Accessibility.practiceSetStartHint")
    }

    static var quizStartHint: String {
      String(localized: "Accessibility.quizStartHint")
    }

    static var mistakesStartHint: String {
      String(localized: "Accessibility.mistakesStartHint")
    }

    static var reviewStartHint: String {
      String(localized: "Accessibility.reviewStartHint")
    }

    static var recognitionCheckHint: String {
      String(localized: "Accessibility.recognitionCheckHint")
    }

    static var recognitionFieldHint: String {
      String(localized: "Accessibility.recognitionFieldHint")
    }

    static var recognitionStartHint: String {
      String(localized: "Accessibility.recognitionStartHint")
    }

    static var exampleSentenceHint: String {
      String(localized: "Accessibility.exampleSentenceHint")
    }

    static var sentencesStartHint: String {
      String(localized: "Accessibility.sentencesStartHint")
    }

    static var speedRoundAgainHint: String {
      String(localized: "Accessibility.speedRoundAgainHint")
    }

    static var speedRoundStartHint: String {
      String(localized: "Accessibility.speedRoundStartHint")
    }

    static var dailySessionStartHint: String {
      String(localized: "Accessibility.dailySessionStartHint")
    }

    static var dailySessionAgainHint: String {
      String(localized: "Accessibility.dailySessionAgainHint")
    }

    static var verbEssentialsStartHint: String {
      String(localized: "Accessibility.verbEssentialsStartHint")
    }

    static var verbEssentialsMoreHint: String {
      String(localized: "Accessibility.verbEssentialsMoreHint")
    }

    static var verbEssentialsNotYet: String {
      String(localized: "Accessibility.verbEssentialsNotYet")
    }

    static var verbEssentialsRight: String {
      String(localized: "Accessibility.verbEssentialsRight")
    }

    static var verbEssentialsRightSecondTry: String {
      String(localized: "Accessibility.verbEssentialsRightSecondTry")
    }

    static var verbEssentialsWrong: String {
      String(localized: "Accessibility.verbEssentialsWrong")
    }

    static var ablautPracticeAloneHint: String {
      String(localized: "Accessibility.ablautPracticeAloneHint")
    }

    static var ablautPracticeHubHint: String {
      String(localized: "Accessibility.ablautPracticeHubHint")
    }

    static var masteryHubHint: String {
      String(localized: "Accessibility.masteryHubHint")
    }

    static var ablautPracticeMixedHint: String {
      String(localized: "Accessibility.ablautPracticeMixedHint")
    }

    static var ablautPracticeMoreHint: String {
      String(localized: "Accessibility.ablautPracticeMoreHint")
    }

    static var quizQuitHint: String {
      String(localized: "Accessibility.quizQuitHint")
    }

    static var leaderboardHint: String {
      String(localized: "Accessibility.leaderboardHint")
    }

    static var quizLevelMenuHint: String {
      String(localized: "Accessibility.quizLevelMenuHint")
    }

    static var quizSessionLength: String {
      String(localized: "Accessibility.quizSessionLength")
    }

    static var leaderboardsHint: String {
      String(localized: "Accessibility.leaderboardsHint")
    }

    static var showOnboardingHint: String {
      String(localized: "Accessibility.showOnboardingHint")
    }

    static func quizDotRow(current: Int, total: Int, correct: Int, secondTry: Int, incorrect: Int, remaining: Int) -> String {
      String(localized: "Accessibility.quizDotRow \(current) \(total) \(correct) \(secondTry) \(incorrect) \(remaining)")
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

    static func quizCorrection(given: String, expected: String) -> String {
      String(localized: "Accessibility.quizCorrection \(given) \(expected)")
    }

    static func quizDifferingLetters(_ letters: String) -> String {
      String(localized: "Accessibility.quizDifferingLetters \(letters)")
    }

    static var quizCorrectionHint: String {
      String(localized: "Accessibility.quizCorrectionHint")
    }

    static var quizCorrectionLinkHint: String {
      String(localized: "Accessibility.quizCorrectionLinkHint")
    }

    static var quizTenMoreHint: String {
      String(localized: "Accessibility.quizTenMoreHint")
    }

    static var quizContinueHint: String {
      String(localized: "Accessibility.quizContinueHint")
    }

    static var choiceOptionHint: String {
      String(localized: "Accessibility.choiceOptionHint")
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

    /// When the card's verb was last looked up, or last practiced in a quiz.
    static func caption(daysAgo: Int?, wasLookedUp: Bool) -> String {
      guard let daysAgo, daysAgo > 0 else {
        return wasLookedUp ? String(localized: "ReviewCard.lookedUpEarlier") : String(localized: "ReviewCard.practicedEarlier")
      }
      return wasLookedUp ? String(localized: "ReviewCard.lookedUp.\(daysAgo)") : String(localized: "ReviewCard.practiced.\(daysAgo)")
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

    static var quizLevelHeading: String {
      String(localized: "Settings.quizLevelHeading")
    }

    static var quizLevelDescription: String {
      String(localized: "Settings.quizLevelDescription")
    }

    static var quizClockHeading: String {
      String(localized: "Settings.quizClockHeading")
    }

    static var quizClockDescription: String {
      String(localized: "Settings.quizClockDescription")
    }

    static var resetPractice: String {
      String(localized: "Settings.resetPractice")
    }

    static var resetPracticeConfirm: String {
      String(localized: "Settings.resetPracticeConfirm")
    }

    static var resetPracticeConfirmMessage: String {
      String(localized: "Settings.resetPracticeConfirmMessage")
    }

    static var resetPracticeConfirmTitle: String {
      String(localized: "Settings.resetPracticeConfirmTitle")
    }

    static var resetPracticeDescription: String {
      String(localized: "Settings.resetPracticeDescription")
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

  enum QuizLevel {
    static var advanced: String {
      String(localized: "QuizLevel.advanced")
    }

    static var beginner: String {
      String(localized: "QuizLevel.beginner")
    }

    static var elementary: String {
      String(localized: "QuizLevel.elementary")
    }

    static var intermediate: String {
      String(localized: "QuizLevel.intermediate")
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

    static var levelLabel: String {
      String(localized: "Quiz.levelLabel")
    }

    static func moreVerbs(_ count: Int) -> String {
      String(localized: "Quiz.moreVerbs.\(count)")
    }

    static var lastQuiz: String {
      String(localized: "Quiz.lastQuiz")
    }

    static var minutesLabel: String {
      String(localized: "Quiz.minutesLabel")
    }

    static var sessionMinutes: String {
      String(localized: "Quiz.sessionMinutes")
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

    static var exercises: String {
      String(localized: "Quiz.exercises")
    }

    static var elapsed: String {
      String(localized: "Quiz.elapsed")
    }

    static var score: String {
      String(localized: "Quiz.score")
    }

    static var yourAnswer: String {
      String(localized: "Quiz.yourAnswer")
    }

    static var almost: String {
      String(localized: "Quiz.almost")
    }

    static var tryOnceMore: String {
      String(localized: "Quiz.tryOnceMore")
    }

    static var secondTry: String {
      String(localized: "Quiz.secondTry")
    }

    static var firstTry: String {
      String(localized: "Quiz.firstTry")
    }

    static var continueAfterCorrection: String {
      String(localized: "Quiz.continueAfterCorrection")
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

    static var level: String {
      String(localized: "Quiz.level")
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

    static var askedAgain: String {
      String(localized: "Quiz.askedAgain")
    }

    static var askedAgainLabel: String {
      String(localized: "Quiz.askedAgainLabel")
    }

    static var willAskAgain: String {
      String(localized: "Quiz.willAskAgain")
    }

    static var tenMore: String {
      String(localized: "Quiz.tenMore")
    }
  }

  enum PracticeSession {
    static var heading: String {
      String(localized: "PracticeSession.heading")
    }

    static var mistakes: String {
      String(localized: "PracticeSession.mistakes")
    }

    static func mistakesCount(_ count: Int) -> String {
      String(localized: "PracticeSession.mistakesCount.\(count)")
    }

    static var mistakesEmpty: String {
      String(localized: "PracticeSession.mistakesEmpty")
    }

    static var review: String {
      String(localized: "PracticeSession.review")
    }

    static func reviewCount(_ count: Int) -> String {
      String(localized: "PracticeSession.reviewCount.\(count)")
    }

    static var reviewEmpty: String {
      String(localized: "PracticeSession.reviewEmpty")
    }

    static func reviewNextDue(_ days: Int) -> String {
      String(localized: "PracticeSession.reviewNextDue.\(days)")
    }
  }

  enum Mastery {
    static func count(_ mastered: Int, _ total: Int) -> String {
      String(localized: "Mastery.count \(mastered) \(total)")
    }

    static var everyVerb: String {
      String(localized: "Mastery.everyVerb")
    }

    static func hubSummary(_ masteredPatterns: Int, _ patterns: Int, _ masteredVerbs: Int, _ verbs: Int) -> String {
      String(localized: "Mastery.hubSummary \(masteredPatterns) \(patterns) \(masteredVerbs) \(verbs)")
    }

    static func intro(_ level: String) -> String {
      String(localized: "Mastery.intro \(level)")
    }

    static var learning: String {
      String(localized: "Mastery.learning")
    }

    static var mastered: String {
      String(localized: "Mastery.mastered")
    }

    static var notPracticed: String {
      String(localized: "Mastery.notPracticed")
    }

    static var patterns: String {
      String(localized: "Mastery.patterns")
    }

    static var patternsDescription: String {
      String(localized: "Mastery.patternsDescription")
    }

    static var title: String {
      String(localized: "Mastery.title")
    }

    static var verbs: String {
      String(localized: "Mastery.verbs")
    }

    static var verbsDescription: String {
      String(localized: "Mastery.verbsDescription")
    }
  }

  enum Choice {
    static func announceRight(_ reason: String) -> String {
      String(localized: "Choice.announceRight \(reason)")
    }

    static func announceWrong(right: String, reason: String) -> String {
      String(localized: "Choice.announceWrong \(right) \(reason)")
    }

    static var prompt: String {
      String(localized: "Choice.prompt")
    }

    static func reasonFuturWithoutTimeWord(right: String, other: String) -> String {
      String(localized: "Choice.reasonFuturWithoutTimeWord \(right) \(other)")
    }

    static func reasonIndikativInConversation(right: String, other: String) -> String {
      String(localized: "Choice.reasonIndikativInConversation \(right) \(other)")
    }

    static func reasonKonjunktivIInReports(_ right: String) -> String {
      String(localized: "Choice.reasonKonjunktivIInReports \(right)")
    }

    static func reasonOneWordKonjunktivII(_ right: String) -> String {
      String(localized: "Choice.reasonOneWordKonjunktivII \(right)")
    }

    static func reasonPerfektInConversation(_ right: String) -> String {
      String(localized: "Choice.reasonPerfektInConversation \(right)")
    }

    static func reasonPräsensForFuture(_ right: String) -> String {
      String(localized: "Choice.reasonPraesensForFuture \(right)")
    }

    static func reasonPräteritumInWriting(_ right: String) -> String {
      String(localized: "Choice.reasonPraeteritumInWriting \(right)")
    }

    static func reasonPräteritumOfSeinHaben(_ right: String) -> String {
      String(localized: "Choice.reasonPraeteritumOfSeinHaben \(right)")
    }

    static func reasonWürdeForMostVerbs(_ right: String) -> String {
      String(localized: "Choice.reasonWuerdeForMostVerbs \(right)")
    }

    static var rightChoice: String {
      String(localized: "Choice.rightChoice")
    }

    static var yourChoice: String {
      String(localized: "Choice.yourChoice")
    }
  }

  enum Recognition {
    static var check: String {
      String(localized: "Recognition.check")
    }

    static var checkConjugationgroup: String {
      String(localized: "Recognition.checkConjugationgroup")
    }

    static var checkConjugationgroupAndPerson: String {
      String(localized: "Recognition.checkConjugationgroupAndPerson")
    }

    static var checkInfinitive: String {
      String(localized: "Recognition.checkInfinitive")
    }

    static var checkInfinitiveAndConjugationgroup: String {
      String(localized: "Recognition.checkInfinitiveAndConjugationgroup")
    }

    static var checkInfinitiveAndPerson: String {
      String(localized: "Recognition.checkInfinitiveAndPerson")
    }

    static var checkPerson: String {
      String(localized: "Recognition.checkPerson")
    }

    static var conjugationgroupHeading: String {
      String(localized: "Recognition.conjugationgroupHeading")
    }

    static var description: String {
      String(localized: "Recognition.description")
    }

    static var incomplete: String {
      String(localized: "Recognition.incomplete")
    }

    static var infinitiveHeading: String {
      String(localized: "Recognition.infinitiveHeading")
    }

    static var personHeading: String {
      String(localized: "Recognition.personHeading")
    }

    static var promptHeading: String {
      String(localized: "Recognition.promptHeading")
    }

    static var title: String {
      String(localized: "Recognition.title")
    }
  }

  enum Sentences {
    static var description: String {
      String(localized: "Sentences.description")
    }

    static var draft: String {
      String(localized: "Sentences.draft")
    }

    static var empty: String {
      String(localized: "Sentences.empty")
    }

    static var title: String {
      String(localized: "Sentences.title")
    }
  }

  enum DailySession {
    static var another: String {
      String(localized: "DailySession.another")
    }

    static var description: String {
      String(localized: "DailySession.description")
    }

    static func repairOne(_ length: Int) -> String {
      String(localized: "DailySession.repairOne.\(length)")
    }

    static func repairTwo(_ length: Int) -> String {
      String(localized: "DailySession.repairTwo.\(length)")
    }

    static func streak(_ length: Int) -> String {
      String(localized: "DailySession.streak.\(length)")
    }

    static func streakDoneToday(_ length: Int) -> String {
      String(localized: "DailySession.streakDoneToday.\(length)")
    }

    static func streakKeepGoing(_ length: Int) -> String {
      String(localized: "DailySession.streakKeepGoing.\(length)")
    }

    static var title: String {
      String(localized: "DailySession.title")
    }
  }

  enum DailyReminder {
    static var body: String {
      String(localized: "DailyReminder.body")
    }

    static func bodyDue(_ count: Int) -> String {
      String(localized: "DailyReminder.bodyDue.\(count)")
    }

    static var denied: String {
      String(localized: "DailyReminder.denied")
    }

    static var description: String {
      String(localized: "DailyReminder.description")
    }

    static var heading: String {
      String(localized: "DailyReminder.heading")
    }

    static var off: String {
      String(localized: "DailyReminder.off")
    }

    static var on: String {
      String(localized: "DailyReminder.on")
    }

    static var openSettings: String {
      String(localized: "DailyReminder.openSettings")
    }

    static var time: String {
      String(localized: "DailyReminder.time")
    }

    static var title: String {
      String(localized: "DailyReminder.title")
    }
  }

  enum SpeedRound {
    static var again: String {
      String(localized: "SpeedRound.again")
    }

    static func announceTimeUp(_ correctCount: Int) -> String {
      String(localized: "SpeedRound.announceTimeUp \(correctCount)")
    }

    static var announceWarning: String {
      String(localized: "SpeedRound.announceWarning")
    }

    static func best(_ best: Int) -> String {
      String(localized: "SpeedRound.best \(best)")
    }

    static var description: String {
      String(localized: "SpeedRound.description")
    }

    static func descriptionWithBest(_ best: Int) -> String {
      String(localized: "SpeedRound.descriptionWithBest \(best)")
    }

    static func locked(needed: Int, mastered: Int) -> String {
      String(localized: "SpeedRound.locked \(needed) \(mastered)")
    }

    static func missed(_ answer: String) -> String {
      String(localized: "SpeedRound.missed \(answer)")
    }

    static var newBest: String {
      String(localized: "SpeedRound.newBest")
    }

    static var resultsHeading: String {
      String(localized: "SpeedRound.resultsHeading")
    }

    static var timeLeft: String {
      String(localized: "SpeedRound.timeLeft")
    }

    static var title: String {
      String(localized: "SpeedRound.title")
    }
  }

  enum VerbEssentials {
    static var description: String {
      String(localized: "VerbEssentials.description")
    }

    /// The results' Ten More, which for Verb Essentials asks five more verbs.
    static var fiveMore: String {
      String(localized: "VerbEssentials.fiveMore")
    }

    static var title: String {
      String(localized: "VerbEssentials.title")
    }
  }

  enum AblautPractice {
    static var alone: String {
      String(localized: "AblautPractice.alone")
    }

    /// The results' Ten More, which for an ablaut group's practice asks another round.
    static var anotherRound: String {
      String(localized: "AblautPractice.anotherRound")
    }

    static var descriptionAll: String {
      String(localized: "AblautPractice.descriptionAll")
    }

    static var descriptionFrequent: String {
      String(localized: "AblautPractice.descriptionFrequent")
    }

    static var heading: String {
      String(localized: "AblautPractice.heading")
    }

    static var hubDescription: String {
      String(localized: "AblautPractice.hubDescription")
    }

    static var known: String {
      String(localized: "AblautPractice.known")
    }

    static var listIntro: String {
      String(localized: "AblautPractice.listIntro")
    }

    static var mixed: String {
      String(localized: "AblautPractice.mixed")
    }

    static var mixedLocked: String {
      String(localized: "AblautPractice.mixedLocked")
    }

    static func mixedTitle(_ exemplar: String) -> String {
      String(localized: "AblautPractice.mixedTitle \(exemplar)")
    }

    static func mixedWith(_ exemplars: String) -> String {
      String(localized: "AblautPractice.mixedWith \(exemplars)")
    }

    static var singleVerb: String {
      String(localized: "AblautPractice.singleVerb")
    }

    static var title: String {
      String(localized: "AblautPractice.title")
    }
  }

  enum CustomQuiz {
    static var ablautGroups: String {
      String(localized: "CustomQuiz.ablautGroups")
    }

    static func band(_ count: String) -> String {
      String(localized: "CustomQuiz.band \(count)")
    }

    static var byLevel: String {
      String(localized: "CustomQuiz.byLevel")
    }

    static var change: String {
      String(localized: "CustomQuiz.change")
    }

    static var choose: String {
      String(localized: "CustomQuiz.choose")
    }

    static var conjugationgroups: String {
      String(localized: "CustomQuiz.conjugationgroups")
    }

    static var conjugationgroupsFooter: String {
      String(localized: "CustomQuiz.conjugationgroupsFooter")
    }

    static var description: String {
      String(localized: "CustomQuiz.description")
    }

    static var emptyDescription: String {
      String(localized: "CustomQuiz.emptyDescription")
    }

    static var segment: String {
      String(localized: "CustomQuiz.segment")
    }

    static var title: String {
      String(localized: "CustomQuiz.title")
    }

    static var verbList: String {
      String(localized: "CustomQuiz.verbList")
    }

    static var verbs: String {
      String(localized: "CustomQuiz.verbs")
    }
  }

  enum PracticeSet {
    static var byLevel: String {
      String(localized: "PracticeSet.byLevel")
    }

    static var description: String {
      String(localized: "PracticeSet.description")
    }

    static var invalidDescription: String {
      String(localized: "PracticeSet.invalidDescription")
    }

    static var invalidTitle: String {
      String(localized: "PracticeSet.invalidTitle")
    }

    static var keep: String {
      String(localized: "PracticeSet.keep")
    }

    static var keepFooter: String {
      String(localized: "PracticeSet.keepFooter")
    }

    static var kept: String {
      String(localized: "PracticeSet.kept")
    }

    static var qrCodeLabel: String {
      String(localized: "PracticeSet.qrCodeLabel")
    }

    static var scanNote: String {
      String(localized: "PracticeSet.scanNote")
    }

    static var scanTitle: String {
      String(localized: "PracticeSet.scanTitle")
    }

    static func shareText(summary: String, link: String, appStoreLink: String) -> String {
      String(localized: "PracticeSet.shareText \(summary) \(link) \(appStoreLink)")
    }

    static var shareLink: String {
      String(localized: "PracticeSet.shareLink")
    }

    static var showQRCode: String {
      String(localized: "PracticeSet.showQRCode")
    }

    static var title: String {
      String(localized: "PracticeSet.title")
    }
  }

  enum Diagnosis {
    static func geBeforeSeparablePrefix(_ prefix: String) -> String {
      String(localized: "Diagnosis.geBeforeSeparablePrefix \(prefix)")
    }

    static var geOnIeren: String {
      String(localized: "Diagnosis.geOnIeren")
    }

    static func geOnInseparable(_ prefix: String) -> String {
      String(localized: "Diagnosis.geOnInseparable \(prefix)")
    }

    static func missingAuxiliary(_ conjugationgroup: String) -> String {
      String(localized: "Diagnosis.missingAuxiliary \(conjugationgroup)")
    }

    static var missingGe: String {
      String(localized: "Diagnosis.missingGe")
    }

    static func otherConjugationgroup(_ conjugationgroup: String) -> String {
      String(localized: "Diagnosis.otherConjugationgroup \(conjugationgroup)")
    }

    static func otherConjugationgroupPersons(_ conjugationgroup: String, _ persons: String) -> String {
      String(localized: "Diagnosis.otherConjugationgroupPersons \(conjugationgroup) \(persons)")
    }

    static func otherPerson(_ persons: String) -> String {
      String(localized: "Diagnosis.otherPerson \(persons)")
    }

    static func otherReading(_ infinitiv: String, _ translation: String) -> String {
      String(localized: "Diagnosis.otherReading \(infinitiv) \(translation)")
    }

    static func participleIsOneWord(_ prefix: String) -> String {
      String(localized: "Diagnosis.participleIsOneWord \(prefix)")
    }

    static func prefixAtEnd(_ conjugationgroup: String, _ prefix: String) -> String {
      String(localized: "Diagnosis.prefixAtEnd \(conjugationgroup) \(prefix)")
    }

    static func weakConjugationMixed(_ infinitiv: String) -> String {
      String(localized: "Diagnosis.weakConjugationMixed \(infinitiv)")
    }

    static func weakConjugationStrong(_ infinitiv: String) -> String {
      String(localized: "Diagnosis.weakConjugationStrong \(infinitiv)")
    }

    static func wrongAuxiliary(_ infinitiv: String, _ expected: String, _ given: String) -> String {
      String(localized: "Diagnosis.wrongAuxiliary \(infinitiv) \(expected) \(given)")
    }
  }

  enum QuizClock {
    static var hide: String {
      String(localized: "QuizClock.hide")
    }

    static var show: String {
      String(localized: "QuizClock.show")
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

    static var viewLeaderboards: String {
      String(localized: "GameCenter.viewLeaderboards")
    }

    static var viewLeaderboardsDescription: String {
      String(localized: "GameCenter.viewLeaderboardsDescription")
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

    static func verbCount(_ count: Int) -> String {
      String(localized: "VerbCollection.verbCount.\(count)")
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
      let verbCount = verbCount(count)
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
