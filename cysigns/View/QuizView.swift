//
//  QuizView.swift
//  cysigns
//
//  Created by Ilia Liasin on 02/04/2024.
//

import Foundation
import SwiftUI

struct QuizView: View {
    
    @ObservedObject var viewModel = QuizViewModel()
    @State private var selectedAnswer: Option? = nil
    @State private var currentAnswers: [Option] = []
    @State private var showAlert = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 10) {
                HStack {
                    Text("❓\(viewModel.currentQuestionIndex + 1) of \(viewModel.questions.count)")
                    Spacer()
                    Text("🟢 \(viewModel.correctAnswers)")
                    Text("🔴 \(viewModel.wrongAnswers)")
                }
                .padding(.horizontal)
                
                if let question = viewModel.currentQuestion {
                    Image(question.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: geometry.size.height * 0.25)
                        .clipped()
                        .cornerRadius(8)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    ForEach(currentAnswers) { answer in
                        Button {
                            selectedAnswer = answer
                            viewModel.submitAnswer(answer)
                            
                            if viewModel.isAnswerCorrect(answer) {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    selectedAnswer = nil
                                    checkEndOfGameAndShowAlert()
                                    viewModel.moveToNextQuestion()
                                    currentAnswers = viewModel.answersForCurrentQuestion()
                                }
                            }
                        } label: {
                            Text(viewModel.useRussianLanguage ? answer.textRu : answer.text)
                                .frame(maxWidth: geometry.size.width * 0.8, maxHeight: geometry.size.height)
                                .padding()
                        }
                        .disabled(selectedAnswer != nil)
                        .padding(.horizontal)
                        .background(colorForAnswer(answer, correctAnswer: viewModel.getCorrectAnswer(), selectedAnswer: selectedAnswer))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.primary, lineWidth: 2))
                    }
                }
                
                Spacer()
                
                HStack {
                    Button {
                        selectedAnswer = nil
                        checkEndOfGameAndShowAlert()
                        viewModel.moveToNextQuestion()
                        currentAnswers = viewModel.answersForCurrentQuestion()
                    } label: {
                        Text(Constants.nextButtonText)
                            .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.01)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(.primary, lineWidth: 2))
                            .foregroundColor(.primary)
                    }
                }
                
                VStack {
                    Toggle("🌏", isOn: $viewModel.useRussianLanguage)
                        .padding(.horizontal, 140)
                }
            }
            .padding(.top)
            .background(Color(.systemBackground))
        }
        .onAppear {
            viewModel.loadQuestions()
            currentAnswers = viewModel.answersForCurrentQuestion()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(Constants.alertTitle),
                message: Text("Score: \(viewModel.correctAnswers) out of \(viewModel.questions.count)"),
                dismissButton: .default(Text(Constants.newGameAlertButton)) {
                    viewModel.resetAndStart()
                    currentAnswers = viewModel.answersForCurrentQuestion()
                }
            )
        }
    }
    
    func colorForAnswer(_ answer: Option, correctAnswer: Option?, selectedAnswer: Option?) -> Color {
        guard let selectedAnswer = selectedAnswer else { return Color(.systemBackground) }
        guard let correctAnswer = correctAnswer else { return Color(.systemBackground) }
        
        if answer.text == correctAnswer.text {
            return .green
        } else if answer.text == selectedAnswer.text {
            return .red
        } else {
            return Color(.systemBackground)
        }
    }
    
    func checkEndOfGameAndShowAlert() {
        if viewModel.currentQuestionIndex == viewModel.questions.count - 1 {
            showAlert = true
        }
    }
}

#Preview {
    QuizView(viewModel: QuizViewModel())
}

#Preview {
    QuizView(viewModel: QuizViewModel())
        .preferredColorScheme(.dark)
}
