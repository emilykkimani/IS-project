import SwiftUI
import CoreLocation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentLocation: CLLocation?
    @Published var nearbyResources: [NearbyResource] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    func requestLocation() {
        isLoading = true
        errorMessage = nil
        
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            errorMessage = "Location access denied. Please enable it in Settings > NiaBot > Location."
            isLoading = false
        @unknown default:
            errorMessage = "Unable to determine location status."
            isLoading = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        DispatchQueue.main.async {
            self.currentLocation = location
            self.loadNearbyResources(for: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
    
    private func loadNearbyResources(for location: CLLocation) {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let radius = 10000 // 10km radius
        
        // Overpass API query to find hospitals, police, counseling centers, etc.
        let query = """
        [out:json][timeout:25];
        (
          node["amenity"="hospital"](around:\(radius),\(latitude),\(longitude));
          node["amenity"="clinic"](around:\(radius),\(latitude),\(longitude));
          node["amenity"="doctors"](around:\(radius),\(latitude),\(longitude));
          node["amenity"="police"](around:\(radius),\(latitude),\(longitude));
          node["amenity"="social_facility"](around:\(radius),\(latitude),\(longitude));
          node["healthcare"](around:\(radius),\(latitude),\(longitude));
          way["amenity"="hospital"](around:\(radius),\(latitude),\(longitude));
          way["amenity"="clinic"](around:\(radius),\(latitude),\(longitude));
          way["amenity"="police"](around:\(radius),\(latitude),\(longitude));
          way["amenity"="social_facility"](around:\(radius),\(latitude),\(longitude));
        );
        out center;
        """
        
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://overpass-api.de/api/interpreter?data=\(encodedQuery)") else {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to create search URL"
                self.isLoading = false
            }
            return
        }
        
        print("🔍 Fetching resources from OpenStreetMap...")
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            if let error = error {
                print("Network Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = "Network error. Please check your connection."
                }
                return
            }
            
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    self.errorMessage = "No data received from server"
                }
                return
            }
            
            do {
                let result = try JSONDecoder().decode(OverpassResponse.self, from: data)
                print("Found \(result.elements.count) facilities")
                
                let resources = result.elements.compactMap { element -> NearbyResource? in
                    // Get coordinates (handle both node and way types)
                    let lat = element.lat ?? element.center?.lat ?? 0
                    let lon = element.lon ?? element.center?.lon ?? 0
                    
                    guard lat != 0, lon != 0 else { return nil }
                    
                    let facilityLocation = CLLocation(latitude: lat, longitude: lon)
                    let distance = location.distance(from: facilityLocation) / 1000 // Convert to km
                    
                    let name = element.tags?.name ?? "Unnamed Facility"
                    let amenity = element.tags?.amenity ?? element.tags?.healthcare ?? "support"
                    
                    return NearbyResource(
                        id: element.id,
                        name: name,
                        type: self.getFacilityType(from: amenity),
                        description: self.getDescription(from: amenity),
                        services: self.getServices(from: amenity),
                        distance: distance,
                        latitude: lat,
                        longitude: lon,
                        phone: element.tags?.phone ?? element.tags?.contact_phone ?? "N/A"
                    )
                }
                
                DispatchQueue.main.async {
                    self.nearbyResources = resources.sorted { $0.distance < $1.distance }
                    print("Loaded \(resources.count) resources")
                }
            } catch {
                print("Parse Error: \(error)")
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to process location data"
                }
            }
        }.resume()
    }
    
    private func getFacilityType(from amenity: String) -> String {
        switch amenity.lowercased() {
        case "hospital": return "Medical Support"
        case "clinic": return "Medical Support"
        case "doctors": return "Medical Support"
        case "police": return "Legal Support"
        case "social_facility": return "Counseling & Support"
        case "counselling": return "Counseling & Support"
        default: return "Support Center"
        }
    }
    
    private func getDescription(from amenity: String) -> String {
        switch amenity.lowercased() {
        case "hospital": return "Comprehensive medical and emergency services."
        case "clinic": return "Medical consultation and treatment services."
        case "doctors": return "Professional medical care and consultation."
        case "police": return "Law enforcement and legal support services."
        case "social_facility": return "Social support and counseling services."
        default: return "Support and assistance services available."
        }
    }
    
    private func getServices(from amenity: String) -> [String] {
        switch amenity.lowercased() {
        case "hospital":
            return ["Emergency Care", "Medical Examination", "Mental Health Support", "24/7 Services"]
        case "clinic", "doctors":
            return ["Medical Consultation", "Treatment", "Health Assessment"]
        case "police":
            return ["Legal Aid", "Safety Support", "Emergency Response", "Report Filing"]
        case "social_facility":
            return ["Counseling", "Support Groups", "Resource Navigation", "Crisis Support"]
        default:
            return ["General Support", "Information"]
        }
    }
}

// MARK: - Overpass API Models
struct OverpassResponse: Codable {
    let elements: [OverpassElement]
}

struct OverpassElement: Codable {
    let type: String
    let id: Int
    let lat: Double?
    let lon: Double?
    let center: OverpassCenter?
    let tags: OverpassTags?
}

struct OverpassCenter: Codable {
    let lat: Double
    let lon: Double
}

struct OverpassTags: Codable {
    let name: String?
    let amenity: String?
    let healthcare: String?
    let phone: String?
    let contact_phone: String?
    let description: String?
    let website: String?
    
    enum CodingKeys: String, CodingKey {
        case name, amenity, healthcare, phone, description, website
        case contact_phone = "contact:phone"
    }
}
