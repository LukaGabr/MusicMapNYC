import SwiftUI

@main
struct MusicMapNYCApp: App {
    @StateObject private var store = LocationStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .onAppear {
                    store.loadLocations()
                }
        }
    }
}
