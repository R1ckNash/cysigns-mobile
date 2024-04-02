//
//  QuizViewModel.swift
//  cysigns
//
//  Created by Ilia Liasin on 02/04/2024.
//

import Foundation
import SwiftUI

struct Option: Hashable, Identifiable {
    let id: UUID = UUID()
    let text: String
    let textRu: String
}

class QuizViewModel: ObservableObject {
    
    @Published var questions: [Question] = []
    @Published var currentQuestionIndex = 0
    @Published var correctAnswers = 0
    @Published var wrongAnswers = 0
    @Published var useRussianLanguage: Bool = false
    
    let questionsLoader = QuestionsLoader()
    
    var currentQuestion: Question? {
        questions[safe: currentQuestionIndex]
    }
    
    func loadQuestions() {
        questions = questionsLoader.loadQuestions().shuffled()
    }
    
    func resetAndStart() {
        currentQuestionIndex = 0
        correctAnswers = 0
        wrongAnswers = 0
        loadQuestions()
    }
    
    func getCorrectAnswer() -> Option? {
        guard let question = currentQuestion else {
            print("Error while getting correct answer")
            return nil
        }
        return Option(text: question.correctAnswer, textRu: question.correctAnswerRu)
    }
    
    func answersForCurrentQuestion() -> [Option] {
        guard let question = currentQuestion else { return [] }
        guard let correctAnswer = getCorrectAnswer() else { return [] }
        
        let wrongAnswers = generateWrongAnswers(for: question)
        let allAnswersLocalized = wrongAnswers + [correctAnswer]
        return allAnswersLocalized.shuffled()
    }
    
    func generateWrongAnswers(for currentQuestion: Question) -> [Option] {
        let allAnswers = questions.map { Option(text: $0.correctAnswer, textRu: $0.correctAnswerRu) }
        let filteredAnswers = allAnswers.filter { $0.text != currentQuestion.correctAnswer }
        let wrongAnswers = filteredAnswers.shuffled().prefix(3)
        return Array(wrongAnswers)
    }
    
    func isAnswerCorrect(_ answer: Option) -> Bool {
        guard let correctAnswer = getCorrectAnswer() else { return false }
        return answer.text == correctAnswer.text
    }
    
    func moveToNextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
        } 
    }
    
    func submitAnswer(_ answer: Option) {
        if isAnswerCorrect(answer) {
            correctAnswers += 1
        } else {
            wrongAnswers += 1
        }
    }
    
    func toggleLanguage() {
        useRussianLanguage.toggle()
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
