import SwiftUI
import MapKit

struct ContentView: View {
    @EnvironmentObject var store: LocationStore
    @State private var selectedLocation: Location?
    @State private var activeSheet: ActiveSheet?

    // Centered roughly on Greenwich Village / East Village.
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.7295, longitude: -73.9905),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    )

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Map(position: $cameraPosition, selection: $selectedLocation) {
                    ForEach(store.locations) { location in
                        if let coordinate = location.coordinate {
                            Marker(location.name, systemImage: markerIcon(for: location.category), coordinate: coordinate)
                                .tag(location)
                        }
                    }
                }
                // Forces MapKit's own dark tile set so the map matches the
                // new dark toolbar/background instead of clashing with a
                // default light map underneath.
                .colorScheme(.dark)
                .onChange(of: selectedLocation) { _, newValue in
                    if let location = newValue {
                        activeSheet = .detail(location)
                    }
                }

                if store.isLoading {
                    ProgressView("Locating spots…")
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                        .padding(.bottom, 24)
                }
            }
            .navigationTitle("NYC Music Map")
            .toolbarBackground(Theme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("List") {
                        activeSheet = .list
                    }
                }
            }
            .sheet(item: $activeSheet, onDismiss: { selectedLocation = nil }) { sheet in
                switch sheet {
                case .list:
                    LocationListView(locations: store.locations) { location in
                        activeSheet = .detail(location)
                    }
                case .detail(let location):
                    LocationDetailView(location: location)
                        .presentationDetents([.medium, .large])
                }
            }
        }
    }

    private func markerIcon(for category: LocationCategory) -> String {
        switch category {
        case .venue: return "music.mic"
        case .album_cover: return "camera"
        case .landmark: return "mappin"
        case .museum: return "building.columns"
        case .event: return "ticket"
        }
    }
}

enum ActiveSheet: Identifiable {
    case list
    case detail(Location)

    var id: String {
        switch self {
        case .list: return "list"
        case .detail(let location): return location.id
        }
    }
}

struct LocationListView: View {
    let locations: [Location]
    let onSelect: (Location) -> Void

    var body: some View {
        NavigationStack {
            List(locations) { location in
                Button {
                    onSelect(location)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(location.name)
                            .font(.headline)
                        Text(location.category.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(location.address)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("All Locations")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LocationStore())
}
