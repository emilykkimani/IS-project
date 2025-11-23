import SwiftUI
import MapKit

struct NearbyResourcesView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    var body: some View {
        VStack {
            // Map Section
            if let location = locationManager.currentLocation {
                Map(coordinateRegion: $region, annotationItems: locationManager.nearbyResources) { place in
                    MapMarker(coordinate: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude))
                }
                .frame(height: 250)
                .cornerRadius(10)
                .padding()
                .onAppear {
                    region.center = location.coordinate
                }
                .onChange(of: location) { newLocation in
                    region.center = newLocation.coordinate
                }
            } else if locationManager.isLoading {
                ProgressView("Fetching your location...")
                    .frame(height: 250)
                    .padding()
            } else if let error = locationManager.errorMessage {
                VStack {
                    Text(" \(error)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Retry") {
                        locationManager.requestLocation()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(height: 250)
            } else {
                VStack {
                    Text("Location not available.")
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)
                    Button("Enable Location") {
                        locationManager.requestLocation()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(height: 250)
            }

            // List Section
            if locationManager.nearbyResources.isEmpty && !locationManager.isLoading {
                VStack {
                    Spacer()
                    Text("No nearby help centers found.")
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                }
            } else {
                List(locationManager.nearbyResources) { place in
                    NavigationLink(destination: ResourceDetailView(resource: place)) {
                        HStack(spacing: 12) {
                            Image(systemName: place.typeIcon)
                                .foregroundColor(.blue)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(place.name)
                                    .font(.headline)
                                Text(String(format: "Distance: %.2f km", place.distance))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Nearby Help Centers")
        .onAppear {
            locationManager.requestLocation()
        }
    }
}

// This makes CLLocation Equatable so .onChange() can track it
extension CLLocation: Equatable {
    public static func == (lhs: CLLocation, rhs: CLLocation) -> Bool {
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude &&
        lhs.timestamp == rhs.timestamp
    }
}
