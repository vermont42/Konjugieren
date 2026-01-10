# Overview

Please create a quiz feature for the Quiz tab.

This will involve creation of three new files.

The first, Quiz.swift, will hold the model for the quiz.

The second, QuizView.swift, shows a quiz either before it begins or while the quiz is in progress.

The third, ResultsView.swift, shows the results of a quiz.

Please ultrathink when performing this work.

Here are details about and requirements for each file.

# QuizView.swift

Put this new file in the Views group.

QuizView gets quiz from the Environment with a line like this: @Environment(Quiz.self) var quiz

When the screen first appears, the UI is blank except for a SubheadingLabel at the top that says "Quiz" and a FunButton at the bottom that says "Start". When the user taps that button, the quiz begins. During a quiz, there are six leading-aligned Texts below the SubheadingLabel:

The first says "Verb: xxx", where "xxx" is the infinitiv of the German verb currently being quizzed.
The second says "Translation: xxx", where xxx is the English translation of the current verb.
The third says "Pronoun: xxx", where xxx is ich, du, er/sie/es, wir, ihr, or sie.
The fourth says "Conjugationgroup: xxx", where xxx is the Conjugationgroup that the user should conjugate the verb to.
The fifth says "Progress: xxx / 30", where xxx is the number of the verb in the quiz, 1 to 30.
The sixth says "Elapsed: xxx", where xxx is the number of seconds that have passed since the start of the quiz.

Below the texts is a TextField for input of the conjugation. The SwiftUI title of the TextField is "Conjugation".

To the right of the progress Text is a trailing-aligned text that says "Score: xxx", where xxx is the current score.

To the right of the elapsed Text is a trailing-aligned FunButton with title "Quit". This button ends the quiz and resets QuizView to the initial state.

When the user gets a conjugation wrong, two new Texts appear between the elapsed Text and the TextField. The first says "Last Answer: xxx", where xxx is the incorrect conjugation. Make this Text customYellow. The second says "Correct Answer: xxx", where xxx is the correct conjugation. Break this text into two Texts, side-by-side, using and HStack, so that the Text with the correct conjugation can use the mixedCaseString Text initializer.

When all verbs have been conjugated, correctly or incorrectly, reset the state of the QuizView to the initial state and show ResultsView modally.

There are three images from my French-verb-conjugation app, Conjuguer, to inspire and clarify. quiz_before_start.png shows the initial state. quiz_in_progress.png shows a quiz in progress. quiz_reporting_incorrect_answer.png shows the quiz reporting and incorrect answer. Note the Conjuguer app uses the word "Tense" where Konjugieren uses "Conjugationgroup". The color scheme for Conjuguer is also obviously different.

# ResultsView.swift

Put this new file in the Views group.

There is a SubheadingLabel at the top that says "Results".

Below that are four leading (left) aligned Texts.

The first says "Score: xxx", where xxx is the score the user got.
The second says "Correct: xxx / 30", where xxx is the number of conjugations the user got right.
The third says "Regular Difficulty" or "Ridiculous Difficult", depending on the setting used.
The fourth says "Time: xxx", where xxx is the elapsed time for the quiz.

Below the texts is a center-aligned List with each of the verbs in the quiz. Each List item has the following Texts:

xxx, where xxx is the infinitiv of the verb
xxx - yyy, where xxx is the conjugationgroup, and yyy is the pronoun.
xxx, where xxx is correct conjugation. Use the mixedCaseString Text initializer for this.

If the user got a particular conjugation wrong, append " x" to the infinitiv text and put a Text with the user's conjugation below the correct conjugation.

There is an image from my French-verb-conjugation app, Conjuguer, to inspire and clarify: results.png. The color scheme for Conjuguer is obviously different.

# Quiz.swift

This is the model powering QuizView. The model is an @Observable class called Quiz.

Put this new file in the Models group.

QuizView's Start button tells a quiz to start. When the quiz starts, a timer starts running. Each second, the Quiz model updates the Elapsed Text in QuizView with properly formatted elapsed time.

The model tracks the progress of the quiz, as well as the score and which conjugations the user got wrong.

A quiz should have thirty conjugations.

When a quiz begins, create an array of thirty infinitivs, thirty PersonNumbers, and thirty Conjugationgroups.

Choose the infinitivs randomly from all verbs available.

Choose the PersonNumbers randomly, repecting the thirdPersonPronounGender setting.

If the quizDifficulty setting is regular, randomly use Conjugationgroups präsenspartizip, präsensIndicativ, perfektpartizip, perfektIndikativ, or imperativ. If imperativ, use a PersonNumber appropriate for that.

If the quizDifficulty setting is ridiculous, randomly use any ConjugationGroup. If imperativ, use a PersonNumber appropriate for that.

A correct conjugation is worth 10 points. A incorrect conjugation is worth 0 points.

When a quiz completes, multiply the score by 2 if the quizDifficulty setting is ridiculous.

Quiz has a property like this: var shouldShowResults = false

QuizView uses this property to show QuizResultsView in a sheet when the quiz is finished.

Properties of Quiz should be private unless needed to power QuizView.