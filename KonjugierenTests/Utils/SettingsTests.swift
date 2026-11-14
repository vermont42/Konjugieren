// Copyright © 2026 Josh Adams. All rights reserved.

import Testing
@testable import Konjugieren

@Suite("Settings", .serialized)
@MainActor
struct SettingsTests {
  @Test func defaultValues() {
    let settings = Settings(getterSetter: GetterSetterFake())
    #expect(settings.conjugationgroupLang == .german)
    #expect(settings.thirdPersonPronounGender == .er)
    #expect(settings.quizLevel == .beginner)
    #expect(settings.audioFeedback == .enable)
    #expect(settings.searchScope == .infinitiveAndTranslation)
    #expect(settings.reviewCardSuppression == .off)
    #expect(settings.appIcon == .hat)
    #expect(settings.hasSeenOnboarding == false)
  }

  @Test func restoresPersistedValues() {
    let fake = GetterSetterFake(dictionary: [
      Settings.conjugationgroupLangKey: "english",
      Settings.thirdPersonPronounGenderKey: "sie",
      Settings.quizLevelKey: "intermediate",
      Settings.audioFeedbackKey: "disable",
      Settings.searchScopeKey: "infinitiveAndTranslation",
      Settings.reviewCardSuppressionKey: "on",
      Settings.hasSeenOnboardingKey: "true",
    ])

    let settings = Settings(getterSetter: fake)
    #expect(settings.conjugationgroupLang == .english)
    #expect(settings.thirdPersonPronounGender == .sie)
    #expect(settings.quizLevel == .intermediate)
    #expect(settings.audioFeedback == .disable)
    #expect(settings.searchScope == .infinitiveAndTranslation)
    #expect(settings.reviewCardSuppression == .on)
    #expect(settings.hasSeenOnboarding == true)
  }

  @Test func invalidStoredValueFallsBackToDefault() {
    let fake = GetterSetterFake(dictionary: [
      Settings.conjugationgroupLangKey: "nonsense",
      Settings.quizLevelKey: "extreme",
      Settings.hasSeenOnboardingKey: "maybe",
    ])

    let settings = Settings(getterSetter: fake)
    #expect(settings.conjugationgroupLang == .german)
    #expect(settings.quizLevel == .beginner)
    #expect(settings.hasSeenOnboarding == false)
  }

  @Test func writesDefaultOnFirstUse() {
    let fake = GetterSetterFake()
    _ = Settings(getterSetter: fake)

    #expect(fake.get(key: Settings.conjugationgroupLangKey) == "german")
    #expect(fake.get(key: Settings.thirdPersonPronounGenderKey) == "er")
    #expect(fake.get(key: Settings.quizLevelKey) == "beginner")
    #expect(fake.get(key: Settings.audioFeedbackKey) == "enable")
    #expect(fake.get(key: Settings.reviewCardSuppressionKey) == "off")
    #expect(fake.get(key: Settings.hasSeenOnboardingKey) == "false")
  }

  @Test func didSetPersistsChange() {
    let fake = GetterSetterFake()
    let settings = Settings(getterSetter: fake)

    settings.conjugationgroupLang = .english
    #expect(fake.get(key: Settings.conjugationgroupLangKey) == "english")

    settings.thirdPersonPronounGender = .es
    #expect(fake.get(key: Settings.thirdPersonPronounGenderKey) == "es")

    settings.quizLevel = .advanced
    #expect(fake.get(key: Settings.quizLevelKey) == "advanced")

    settings.audioFeedback = .disable
    #expect(fake.get(key: Settings.audioFeedbackKey) == "disable")

    settings.reviewCardSuppression = .on
    #expect(fake.get(key: Settings.reviewCardSuppressionKey) == "on")

    settings.hasSeenOnboarding = true
    #expect(fake.get(key: Settings.hasSeenOnboardingKey) == "true")
  }

  @Test(arguments: [
    ("regular", QuizLevel.elementary),
    ("ridiculous", QuizLevel.advanced),
    ("extreme", QuizLevel.elementary)
  ])
  func storedDifficultyMigratesToALevel(difficulty: String, level: QuizLevel) {
    let fake = GetterSetterFake(dictionary: [Settings.quizDifficultyKey: difficulty])

    let settings = Settings(getterSetter: fake)
    #expect(settings.quizLevel == level)
    #expect(fake.get(key: Settings.quizLevelKey) == level.rawValue)
    #expect(fake.get(key: Settings.quizDifficultyKey) == nil)
  }

  @Test func aChosenLevelOutlivesTheMigration() {
    let fake = GetterSetterFake(dictionary: [Settings.quizDifficultyKey: "ridiculous"])
    let settings = Settings(getterSetter: fake)
    settings.quizLevel = .beginner

    #expect(Settings(getterSetter: fake).quizLevel == .beginner)
  }

  @Test func aLevelAlreadyStoredIsNotMigratedAgain() {
    let fake = GetterSetterFake(dictionary: [
      Settings.quizLevelKey: "beginner",
      Settings.quizDifficultyKey: "ridiculous"
    ])

    #expect(Settings(getterSetter: fake).quizLevel == .beginner)
  }

  @Test func existingInstallMovesToTheNewSearchScopeDefaultOnce() {
    let fake = GetterSetterFake(dictionary: [Settings.searchScopeKey: "infinitiveOnly"])
    let settings = Settings(getterSetter: fake)
    #expect(settings.searchScope == .infinitiveAndTranslation)
    #expect(fake.get(key: Settings.searchScopeKey) == "infinitiveAndTranslation")
    #expect(fake.get(key: Settings.searchScopeDefaultFlippedKey) == "true")
  }

  @Test func searchScopeChosenAfterTheFlipIsKept() {
    let fake = GetterSetterFake()
    let settings = Settings(getterSetter: fake)
    settings.searchScope = .infinitiveOnly

    let relaunched = Settings(getterSetter: fake)
    #expect(relaunched.searchScope == .infinitiveOnly)
  }

  @Test func freshInstallRecordsTheFlipSoItNeverRuns() {
    let fake = GetterSetterFake()
    _ = Settings(getterSetter: fake)
    #expect(fake.get(key: Settings.searchScopeDefaultFlippedKey) == "true")
  }

  @Test func didSetDoesNotWriteWhenUnchanged() {
    let fake = GetterSetterFake()
    let settings = Settings(getterSetter: fake)

    fake.dictionary.removeAll()

    settings.conjugationgroupLang = .german
    #expect(fake.get(key: Settings.conjugationgroupLangKey) == nil)
  }
}
