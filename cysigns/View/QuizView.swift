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
                HStack(spacing: 5) {
                    Text("\(viewModel.currentQuestionIndex + 1) / \(viewModel.questions.count)")
                    
                    Spacer()
                    
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                    Text("\(viewModel.correctAnswers)")
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                    Text("\(viewModel.wrongAnswers)")
                }
                .padding(.horizontal)
                
                ProgressView(value: Double(viewModel.currentQuestionIndex), total: Double(viewModel.questions.count))
                    .tint(.purple)
                    .padding(.horizontal)
                
                if let question = viewModel.currentQuestion {
                    Image(question.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width * 0.85,
                               height: geometry.size.height * 0.3)
                        .padding(.horizontal)
                        .background(.white)
                        .cornerRadius(10)
                        .shadow(radius: 0.3)
                    
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
                                .frame(maxWidth: geometry.size.width * 0.85, maxHeight: geometry.size.height)
                                .padding()
                        }
                        .disabled(selectedAnswer != nil)
                        .background(colorForAnswer(answer, correctAnswer: viewModel.getCorrectAnswer(), selectedAnswer: selectedAnswer))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                        .shadow(radius: 0.3, y: 0.3)
                    }
                }
                
                Spacer()
                
                ZStack() {
                    Button {
                        selectedAnswer = nil
                        checkEndOfGameAndShowAlert()
                        viewModel.moveToNextQuestion()
                        currentAnswers = viewModel.answersForCurrentQuestion()
                    } label: {
                        Text(Constants.nextButtonText)
                            .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.01)
                            .padding()
                            .background(.white)
                            .cornerRadius(10)
                            .shadow(radius: 1, y: 1)
                            .foregroundColor(.primary)
                    }
                    
                    Toggle(isOn: $viewModel.useRussianLanguage) {
                        Image(systemName: "globe")
                            .font(.system(size: 24))
                    }
                    .tint(.purple)
                    .toggleStyle(.button)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .padding(.top)
            .background(Color(.systemGroupedBackground))
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
        guard let selectedAnswer = selectedAnswer else { return .white }
        guard let correctAnswer = correctAnswer else { return .white }
        
        if answer.text == correctAnswer.text {
            return .green
        } else if answer.text == selectedAnswer.text {
            return .red
        } else {
            return .white
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
