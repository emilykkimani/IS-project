import Foundation

struct NominatimPlace: Decodable {
    let displayName: String
    let lat: String
    let lon: String
    let type: String?

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case lat, lon, type
    }
}

final class NominatimService {
    static let shared = NominatimService()
    private init() {}

    func searchNearby(query: String, lat: Double, lon: Double, completion: @escaping ([NominatimPlace]) -> Void) {
        let urlString = "https://nominatim.openstreetmap.org/search?format=json&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&addressdetails=1&limit=15&viewbox=\(lon-0.1),\(lat+0.1),\(lon+0.1),\(lat-0.1)&bounded=1"

        guard let url = URL(string: urlString) else {
            completion([])
            return
        }

        var request = URLRequest(url: url)
        request.setValue("MyApp (your_email@example.com)", forHTTPHeaderField: "User-Agent")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else {
                completion([])
                return
            }

            do {
                let places = try JSONDecoder().decode([NominatimPlace].self, from: data)
                completion(places)
            } catch {
                print("Nominatim decode error:", error)
                completion([])
            }
        }.resume()
    }
}
