import Foundation
import CoreLocation

enum LocationCategory: String, Codable, CaseIterable {
    case venue
    case album_cover
    case landmark
    case museum
    case event

    var displayName: String {
        switch self {
        case .venue: return "Venue"
        case .album_cover: return "Album Cover Site"
        case .landmark: return "Landmark"
        case .museum: return "Museum"
        case .event: return "Event"
        }
    }

}

// Matches the fields in locations_seed.json exactly.
struct Location: Identifiable, Codable {
    let id: String
    let name: String
    let category: LocationCategory
    let address: String
    let yearRange: String
    let description: String

    // Only set on album_cover locations — used to look up official
    // artwork via MusicKit. Optional and left out of most JSON entries.
    let artist: String?
    let albumTitle: String?

    // Not in the JSON — filled in later by geocoding. Optional because
    // a location starts with no coordinate until GeocodingService resolves it.
    var coordinate: CLLocationCoordinate2D?

    enum CodingKeys: String, CodingKey {
        case id, name, category, address, yearRange, description, artist, albumTitle
        // coordinate intentionally omitted — it's not decoded from JSON
    }
}

// CLLocationCoordinate2D isn't Equatable/Hashable by default, so Location
// can't auto-synthesize those conformances. Map's selection binding needs
// Location to be Hashable, so we implement it manually using just `id`,
// which is already unique per location.
extension Location: Hashable {
    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
