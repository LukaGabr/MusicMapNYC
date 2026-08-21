import Foundation
import Combine

@MainActor
final class LocationStore: ObservableObject {
    @Published var locations: [Location] = []
    @Published var isLoading = false

    // Reviews are kept separately from Location, keyed by location id.
    // In-memory only for now — they reset every time the app relaunches.
    // Swapping this for real persistence later won't require changing
    // any of the views that call reviews(for:) or addReview(_:for:).
    @Published var reviewsByLocationID: [String: [Review]] = [:]

    func reviews(for locationID: String) -> [Review] {
        reviewsByLocationID[locationID] ?? []
    }

    func addReview(_ review: Review, for locationID: String) {
        reviewsByLocationID[locationID, default: []].append(review)
    }

    // Artwork URLs fetched from MusicKit, cached by location id so we
    // only search the catalog once per location, not on every screen visit.
    @Published var artworkURLByLocationID: [String: URL] = [:]
    private let artworkService = MusicKitArtworkService()

    func loadArtworkIfNeeded(for location: Location) {
        guard let artist = location.artist, let album = location.albumTitle else { return }
        guard artworkURLByLocationID[location.id] == nil else { return }

        Task {
            if let url = await artworkService.fetchArtworkURL(artist: artist, album: album) {
                artworkURLByLocationID[location.id] = url
            }
        }
    }

    private let geocodingService = GeocodingService()

    // Call this once when the app launches (see MusicMapNYCApp.swift).
    func loadLocations() {
        guard let url = Bundle.main.url(forResource: "locations_seed", withExtension: "json") else {
            print("Could not find locations_seed.json in the app bundle. Did you add it to the target?")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([Location].self, from: data)
            self.locations = decoded
            Task { await geocodeAll() }
        } catch {
            print("Failed to decode locations_seed.json: \(error)")
        }
    }

    // Geocodes addresses one at a time (not in parallel) to stay well under
    // Apple's geocoding rate limits. For ~15 locations this takes a couple
    // seconds; fine for now. Later you'd cache geocoded coordinates instead
    // of re-geocoding on every launch.
    private func geocodeAll() async {
        isLoading = true
        for index in locations.indices {
            let address = locations[index].address
            if let coordinate = await geocodingService.geocode(address: address) {
                locations[index].coordinate = coordinate
            }
        }
        isLoading = false
    }
}
