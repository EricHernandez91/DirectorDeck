import SwiftUI

class ScreenshotNavigator: ObservableObject {
    static let shared = ScreenshotNavigator()
    @Published var autoNavigate = false
}
