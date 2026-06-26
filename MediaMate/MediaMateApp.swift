 import SwiftUI
 
 @main
 struct MediaMateApp: App {
     @StateObject private var appState = AppState()
 
     var body: some Scene {
         WindowGroup {
             ContentView()
                 .environmentObject(appState)
                 .preferredColorScheme(.dark)
         }
     }
 }
