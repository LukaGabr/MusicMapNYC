import Foundation

private struct DiscogsSearchResponse: Codable {
    let results: [DiscogsResult]
}

private struct DiscogsResult: Codable {
    let cover_image: String?
}

// Searches Discogs' catalog and returns a cover art URL. Free API, no paid
// developer account needed — replaces MusicKitArtworkService, which required
// an Apple Developer Program membership to actually authorize.
struct DiscogsArtworkService {
    // Discogs requires a descriptive User-Agent on every request or it
    // returns 403 — this string doesn't need to be secret, unlike the token.
    private let userAgent = "MusicMapNYC/1.0"

    func fetchArtworkURL(artist: String, album: String) async -> URL? {
        var components = URLComponents(string: "https://api.discogs.com/database/search")!
        components.queryItems = [
            URLQueryItem(name: "artist", value: artist),
            URLQueryItem(name: "release_title", value: album),
            URLQueryItem(name: "type", value: "release"),
            URLQueryItem(name: "token", value: Secrets.discogsToken)
        ]

        guard let url = components.url else { return nil }
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode(DiscogsSearchResponse.self, from: data)
            guard let imageURLString = decoded.results.first?.cover_image,
                  let imageURL = URL(string: imageURLString) else {
                print("No Discogs artwork found for '\(artist) - \(album)'")
                return nil
            }
            return imageURL
        } catch {
            print("Discogs search failed for '\(artist) - \(album)': \(error)")
            return nil
        }
    }
}
