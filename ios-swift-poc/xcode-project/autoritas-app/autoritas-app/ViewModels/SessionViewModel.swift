import Foundation
import Combine

/// Holds arbitrary session metadata sent by the agent via `final_structured_data` packets.
class SessionViewModel: ObservableObject {
    @Published var data: [String: Any] = [:]

    func updateData(_ newData: [String: Any]) {
        DispatchQueue.main.async {
            for (key, value) in newData {
                self.data[key] = value
            }
        }
    }

    func clearData() {
        DispatchQueue.main.async { self.data = [:] }
    }

    // Convenience typed accessors
    func string(for key: String) -> String? { data[key] as? String }
    func int(for key: String) -> Int? { data[key] as? Int }
    func bool(for key: String) -> Bool? { data[key] as? Bool }
}
