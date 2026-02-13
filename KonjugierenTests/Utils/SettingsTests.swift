// Copyright © 2026 Josh Adams. All rights reserved.

import Testing
@testable import Konjugieren

@MainActor
struct SettingsTests {
  @Test func defaultValues() {
    let settings = Settings(getterSetter: GetterSetterFake())
    #expect(settings.conjugationgroupLang == .german)
    #expect(settings.thirdPersonPronounGender == .er)
    #expect(settings.quizDifficulty == .regular)
    #expect(settings.audioFeedback == .enable)
    #expect(settings.searchScope == .infinitiveOnly)
    #expect(settings.appIcon == .hat)
    #expect(settings.hasSeenOnboarding == false)
  }

  @Test func restoresPersistedValues() {
    let fake = GetterSetterFake(dictionary: [
      Settings.conjugationgroupLangKey: "english",
      Settings.thirdPersonPronounGenderKey: "sie",
      Settings.quizDifficultyKey: "ridiculous",
      Settings.audioFeedbackKey: "disable",
      Settings.searchScopeKey: "infinitiveAndTranslation",
      Settings.hasSeenOnboardingKey: "true",
    ])

    let settings = Settings(getterSetter: fake)
    #expect(settings.conjugationgroupLang == .english)
    #expect(settings.thirdPersonPronounGender == .sie)
    #expect(settings.quizDifficulty == .ridiculous)
    #expect(settings.audioFeedback == .disable)
    #expect(settings.searchScope == .infinitiveAndTranslation)
    #expect(settings.hasSeenOnboarding == true)
  }

  @Test func invalidStoredValueFallsBackToDefault() {
    let fake = GetterSetterFake(dictionary: [
      Settings.conjugationgroupLangKey: "nonsense",
      Settings.quizDifficultyKey: "extreme",
      Settings.hasSeenOnboardingKey: "maybe",
    ])

    let settings = Settings(getterSetter: fake)
    #expect(settings.conjugationgroupLang == .german)
    #expect(settings.quizDifficulty == .regular)
    #expect(settings.hasSeenOnboarding == false)
  }

  @Test func writesDefaultOnFirstUse() {
    let fake = GetterSetterFake()
    _ = Settings(getterSetter: fake)

    #expect(fake.get(key: Settings.conjugationgroupLangKey) == "german")
    #expect(fake.get(key: Settings.thirdPersonPronounGenderKey) == "er")
    #expect(fake.get(key: Settings.quizDifficultyKey) == "regular")
    #expect(fake.get(key: Settings.audioFeedbackKey) == "enable")
    #expect(fake.get(key: Settings.hasSeenOnboardingKey) == "false")
  }

  @Test func didSetPersistsChange() {
    let fake = GetterSetterFake()
    let settings = Settings(getterSetter: fake)

    settings.conjugationgroupLang = .english
    #expect(fake.get(key: Settings.conjugationgroupLangKey) == "english")

    settings.thirdPersonPronounGender = .es
    #expect(fake.get(key: Settings.thirdPersonPronounGenderKey) == "es")

    settings.quizDifficulty = .ridiculous
    #expect(fake.get(key: Settings.quizDifficultyKey) == "ridiculous")

    settings.audioFeedback = .disable
    #expect(fake.get(key: Settings.audioFeedbackKey) == "disable")

    settings.hasSeenOnboarding = true
    #expect(fake.get(key: Settings.hasSeenOnboardingKey) == "true")
  }

  @Test func didSetDoesNotWriteWhenUnchanged() {
    let fake = GetterSetterFake()
    let settings = Settings(getterSetter: fake)

    fake.dictionary.removeAll()

    settings.conjugationgroupLang = .german
    #expect(fake.get(key: Settings.conjugationgroupLangKey) == nil)
  }
}
