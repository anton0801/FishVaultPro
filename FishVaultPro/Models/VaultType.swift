import Foundation

enum VaultType: String, Codable, CaseIterable, Hashable {
    case numeric = "numeric"
    case checklist = "checklist"
    case progress = "progress"
    case counter = "counter"
    
    var displayName: String {
        switch self {
        case .numeric: return "Numeric Tracker"
        case .checklist: return "Checklist"
        case .progress: return "Progress Goal"
        case .counter: return "Counter"
        }
    }
    
    var icon: String {
        switch self {
        case .numeric: return "number.circle.fill"
        case .checklist: return "checkmark.circle.fill"
        case .progress: return "chart.pie.fill"
        case .counter: return "plus.circle.fill"
        }
    }
}

final class InteractionHandler: NSObject {
    
    weak var coordinator: WebCoordinator?
    var redirectionCounter = 0
    var previousURL: URL?
    let maxRedirections = 70
    
    init(coordinator: WebCoordinator) {
        self.coordinator = coordinator
        super.init()
    }
}
