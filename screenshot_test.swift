import XCTest

final class ScreenshotTests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = true
        app.launch()
    }
    
    func testTakeAllScreenshots() throws {
        let screenshotDir = "/tmp/DirectorDeck/screenshots"
        
        // Wait for app to load
        sleep(2)
        
        // 1. Tap on "The Last Light" project
        let projectCell = app.staticTexts["The Last Light"]
        if projectCell.waitForExistence(timeout: 5) {
            projectCell.tap()
            sleep(1)
            saveScreenshot("02-project-sections", dir: screenshotDir)
        }
        
        // 2. Tap Creative Briefs
        let briefsButton = app.staticTexts["Creative Briefs"]
        if briefsButton.waitForExistence(timeout: 3) {
            briefsButton.tap()
            sleep(1)
            saveScreenshot("03-creative-briefs", dir: screenshotDir)
        }
        
        // 3. Interviews
        let interviewsButton = app.staticTexts["Interviews"]
        if interviewsButton.waitForExistence(timeout: 3) {
            interviewsButton.tap()
            sleep(1)
            saveScreenshot("04-interviews", dir: screenshotDir)
        }
        
        // 4. Storyboards
        let storyboardsButton = app.staticTexts["Storyboards"]
        if storyboardsButton.waitForExistence(timeout: 3) {
            storyboardsButton.tap()
            sleep(1)
            saveScreenshot("05-storyboards", dir: screenshotDir)
        }
        
        // 5. Shot List
        let shotListButton = app.staticTexts["Shot List"]
        if shotListButton.waitForExistence(timeout: 3) {
            shotListButton.tap()
            sleep(1)
            saveScreenshot("06-shot-list", dir: screenshotDir)
        }
        
        // 6. Shoot Day
        let shootDayButton = app.staticTexts["Shoot Day"]
        if shootDayButton.waitForExistence(timeout: 3) {
            shootDayButton.tap()
            sleep(1)
            saveScreenshot("07-shoot-day", dir: screenshotDir)
        }
        
        // 7. Documents
        let docsButton = app.staticTexts["Documents"]
        if docsButton.waitForExistence(timeout: 3) {
            docsButton.tap()
            sleep(1)
            saveScreenshot("08-documents", dir: screenshotDir)
        }
    }
    
    private func saveScreenshot(_ name: String, dir: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        
        // Also save directly
        let data = screenshot.pngRepresentation
        let url = URL(fileURLWithPath: "\(dir)/\(name).png")
        try? data.write(to: url)
    }
}
