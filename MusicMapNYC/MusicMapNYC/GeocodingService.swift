import Foundation
import CoreLocation

// Wraps CLGeocoder so we can turn "315 Bowery, New York, NY" into a coordinate.
// Apple rate-limits geocoding, so this is only meant to run once per location,
// not repeatedly — LocationStore caches the result on the Location itself.
struct GeocodingService {
    private let geocoder = CLGeocoder()

    func geocode(address: String) async -> CLLocationCoordinate2D? {
        do {
            let placemarks = try await geocoder.geocodeAddressString(address)
            return placemarks.first?.location?.coordinate
        } catch {
            print("Geocoding failed for '\(address)': \(error)")
            return nil
        }
    }
}
