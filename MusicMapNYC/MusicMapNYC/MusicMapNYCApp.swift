import SwiftUI
import MusicKit

@main
struct MusicMapNYCApp: App {
    @StateObject private var store = LocationStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .task {
                    // MusicAuthorization.request() must complete before any
                    // MusicCatalogSearchRequest will succeed. This shows the
                    // system permission prompt the first time the app runs.
                    _ = await MusicAuthorization.request()
                    store.loadLocations()
                }
        }
    }
}
