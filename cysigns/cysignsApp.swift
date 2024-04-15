//
//  cysignsApp.swift
//  cysigns
//
//  Created by Ilia Liasin on 02/04/2024.
//

import SwiftUI

@main
struct cysignsApp: App {
    
    var body: some Scene {
        WindowGroup {
            QuizView()
                .environment(\.colorScheme, .light)
        }
    }
}
