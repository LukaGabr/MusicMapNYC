import Foundation
import MusicKit

// Wraps MusicKit's catalog search so we can turn (artist, album) into an
// official Apple Music artwork URL — the legitimate way to display album
// art, since it's licensed through Apple rather than scraped from elsewhere.
struct MusicKitArtworkService {
    func fetchArtworkURL(artist: String, album: String, size: Int = 400) async -> URL? {
        let searchTerm = "\(artist) \(album)"
        var request = MusicCatalogSearchRequest(term: searchTerm, types: [MusicKit.Album.self])
        request.limit = 1

        do {
            let response = try await request.response()
            guard let matchedAlbum = response.albums.first else {
                print("No MusicKit match found for '\(searchTerm)'")
                return nil
            }
            return matchedAlbum.artwork?.url(width: size, height: size)
        } catch {
            print("MusicKit search failed for '\(searchTerm)': \(error)")
            return nil
        }
    }
}
