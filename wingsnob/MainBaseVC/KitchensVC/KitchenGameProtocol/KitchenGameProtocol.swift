
import UIKit
import SnapKit

// MARK: - Game Protocol
protocol BaseKitchenGameProtocol: UIViewController {
    var levelNumber: Int { get }
    var difficulty: String { get }
    var onGameCompleted: (() -> Void)? { get set }
}

enum KitchenGameType: Int {
    case game1 = 1
    case game2 = 2
    case game3 = 3
    case game4 = 4
    
    func makeViewController(levelNumber: Int, difficulty: String) -> BaseKitchenGameProtocol {
        switch self {
        case .game1: return KitchenGame1VC(levelNumber: levelNumber, difficulty: difficulty)
        case .game2: return KitchenGame2VC(levelNumber: levelNumber, difficulty: difficulty)
        case .game3: return KitchenGame3VC(levelNumber: levelNumber, difficulty: difficulty)
        case .game4: return KitchenGame4VC(levelNumber: levelNumber, difficulty: difficulty)
        }
    }
}
