import ActivityKit
import Foundation

// live_activities plugin의 generic 방식을 사용
// 실제 데이터는 App Groups UserDefaults에서 읽음 (prefixedKey 패턴)
struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
    public typealias LiveDeliveryData = ContentState

    public struct ContentState: Codable, Hashable { }

    var id = UUID()
}

extension LiveActivitiesAppAttributes {
    func prefixedKey(_ key: String) -> String {
        return "\(id)_\(key)"
    }
}
