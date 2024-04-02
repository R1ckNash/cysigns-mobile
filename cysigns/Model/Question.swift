//
//  Question.swift
//  cysigns
//
//  Created by Ilia Liasin on 02/04/2024.
//

import Foundation

struct Question: Codable {
    let image: String
    let correctAnswer: String
    let correctAnswerRu: String
    
    enum CodingKeys: String, CodingKey {
        case image
        case correctAnswer = "name"
        case correctAnswerRu = "ru"
    }
}
