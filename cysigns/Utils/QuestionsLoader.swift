//
//  QuestionsLoader.swift
//  cysigns
//
//  Created by Ilia Liasin on 02/04/2024.
//

import Foundation

class QuestionsLoader {
    
    func loadQuestions() -> [Question] {
        guard let url = Bundle.main.url(forResource: "signs", withExtension: "json") else {
            print("Questions JSON file not found")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let questions = try decoder.decode([Question].self, from: data)
            return questions
        } catch {
            print("Error decoding questions: \(error)")
            return []
        }
    }
}
