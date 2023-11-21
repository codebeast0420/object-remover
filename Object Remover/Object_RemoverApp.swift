//
//  Object_RemoverApp.swift
//  Object Remover
//
//  Created by ZhangTong on 2023/9/26.
//

import SwiftUI

@main
struct Object_RemoverApp: App {
    let appSettings = AppSettings()
    var body: some Scene {
        WindowGroup {
            ContentView(appSettings: appSettings)
        }
    }
}
