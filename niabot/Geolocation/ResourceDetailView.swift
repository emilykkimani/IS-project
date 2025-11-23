import SwiftUI
import MapKit

struct ResourceDetailView: View {
    let resource: NearbyResource
    @State private var region: MKCoordinateRegion

    init(resource: NearbyResource) {
        self.resource = resource
        self._region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: resource.latitude, longitude: resource.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title
                Text(resource.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                // Map View
                Map(coordinateRegion: $region, annotationItems: [resource]) { place in
                    MapMarker(coordinate: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude))
                }
                .frame(height: 300)
                .cornerRadius(12)
                .shadow(radius: 4)

                // Details
                VStack(alignment: .leading, spacing: 10) {
                    Text("Details")
                        .font(.title2)
                        .fontWeight(.semibold)

                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                        Text("Lat: \(resource.latitude), Lon: \(resource.longitude)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top)

                // Animated Buttons
                ActionButtons(resource: resource)
                    .padding(.top)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Resource Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Animated Action Buttons
struct ActionButtons: View {
    let resource: NearbyResource
    @State private var pressedButton: String?

    var body: some View {
        VStack(spacing: 12) {
            AnimatedButton(
                title: "Call Now",
                icon: "phone.fill",
                background: resource.phone == "N/A" ? .gray : .blue,
                disabled: resource.phone == "N/A",
                id: "call"
            ) {
                resource.callFacility()
            }

            AnimatedButton(
                title: "Get Directions",
                icon: "map.fill",
                background: .purple,
                id: "directions"
            ) {
                resource.getDirections()
            }

            AnimatedButton(
                title: "View on OpenStreetMap",
                icon: "location.fill",
                background: .green,
                id: "osm"
            ) {
                resource.openInOSM()
            }
        }
    }
}

// MARK: - Reusable Animated Button Component
struct AnimatedButton: View {
    let title: String
    let icon: String
    let background: Color
    var disabled: Bool = false
    let id: String
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            guard !disabled else { return }
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPressed = false
            }
            
            action()
        }) {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(disabled ? Color.gray : background)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isPressed)
        }
        .disabled(disabled)
    }
}
