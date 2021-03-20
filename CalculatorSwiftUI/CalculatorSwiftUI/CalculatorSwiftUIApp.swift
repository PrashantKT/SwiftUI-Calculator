//
//  CalculatorSwiftUIApp.swift
//  CalculatorSwiftUI
//
//  Created by Prashant Tukadiya on 20/03/21.
//

import SwiftUI

@main
struct CalculatorSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(CalModel())
        }
    }
}
