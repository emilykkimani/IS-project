import SwiftUI
import MapKit
import CoreLocation

struct NearbyResource: Identifiable {
    let id: Int
    let name: String
    let type: String
    let description: String
    let services: [String]
    let distance: Double
    let latitude: Double
    let longitude: Double
    let phone: String
    
    var typeIcon: String {
        switch type {
        case "Medical Support": return "cross.fill"
        case "Legal Support": return "shield.fill"
        case "Counseling & Support": return "heart.fill"
        default: return "building.2.fill"
        }
    }
}

// MARK: - Actions for OpenStreetMap and Phone
extension NearbyResource {
    func openInOSM() {
        let urlString = "https://www.openstreetmap.org/?mlat=\(latitude)&mlon=\(longitude)#map=16/\(latitude)/\(longitude)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Enhanced Directions Methods
    
    /// Method 1: Simple - Open Maps with directions (reliable)
    func getDirections() {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = name
        
        let launchOptions: [String: Any] = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
    
    /// Method 2: Advanced - Include current location as starting point
    func getDirectionsFromCurrentLocation() {
        let currentLocMapItem = MKMapItem.forCurrentLocation()
        
        let destinationCoordinate = CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
        let destMapItem = MKMapItem(
            placemark: MKPlacemark(coordinate: destinationCoordinate)
        )
        destMapItem.name = name
        
        let launchOptions: [String: Any] = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ]
        
        MKMapItem.openMaps(
            with: [currentLocMapItem, destMapItem],
            launchOptions: launchOptions
        )
    }
    
    /// Method 3: With custom transport type
    func getDirections(transportType: MKDirectionsTransportType = .automobile) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = name
        
        let modeString = getModeString(for: transportType)
        let launchOptions: [String: Any] = [
            MKLaunchOptionsDirectionsModeKey: modeString
        ]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
    
    /// Helper: Convert transport type to Maps mode string
    private func getModeString(for transportType: MKDirectionsTransportType) -> String {
        switch transportType {
        case .automobile:
            return MKLaunchOptionsDirectionsModeDriving
        case .walking:
            return MKLaunchOptionsDirectionsModeWalking
        case .transit:
            return MKLaunchOptionsDirectionsModeTransit
        case .any:
            return MKLaunchOptionsDirectionsModeDriving
        default:
            return MKLaunchOptionsDirectionsModeDriving
        }
    }
    
    func callFacility() {
        guard phone != "N/A", !phone.isEmpty else { return }
        let cleanedPhone = phone.replacingOccurrences(of: " ", with: "")
        if let url = URL(string: "tel://\(cleanedPhone)") {
            UIApplication.shared.open(url)
        }
    }
}
