import XCTest

final class ScreenshotTests: XCTestCase {
    
    let app = XCUIApplication()
    let screenshotDir = "/tmp/DirectorDeck/screenshots"
    
    override func setUp() {
        continueAfterFailure = true
        app.launch()
    }
    
    func testTakeAllScreenshots() throws {
        let fm = FileManager.default
        try? fm.createDirectory(atPath: screenshotDir, withIntermediateDirectories: true)
        
        sleep(2)
        
        // 1. Sidebar with project list
        saveScreenshot("01_sidebar")
        
        // 2. Tap on "The Last Light" project
        let projectCell = app.staticTexts["The Last Light"]
        if projectCell.waitForExistence(timeout: 5) {
            projectCell.tap()
            sleep(1)
            saveScreenshot("02_project_overview")
        }
        
        // 3. Creative Briefs
        let briefsCell = app.staticTexts["Creative Briefs"]
        if briefsCell.waitForExistence(timeout: 3) {
            briefsCell.tap()
            sleep(1)
            
            // Select the brief
            let briefTitle = app.staticTexts["Creative Vision — The Last Light"]
            if briefTitle.waitForExistence(timeout: 3) {
                briefTitle.tap()
                sleep(1)
            }
            saveScreenshot("03_creative_brief")
        }
        
        // 4. Navigate back and go to Interviews  
        // Tap Interviews in the sections list
        let interviewsCell = app.staticTexts["Interviews"]
        if interviewsCell.waitForExistence(timeout: 3) {
            interviewsCell.tap()
            sleep(1)
            
            // Select Thomas Hargrove
            let thomas = app.staticTexts["Thomas Hargrove"]
            if thomas.waitForExistence(timeout: 3) {
                thomas.tap()
                sleep(1)
            }
            saveScreenshot("04_interview_questions")
        }
        
        // 5. Storyboards
        let storyboardsCell = app.staticTexts["Storyboards"]
        if storyboardsCell.waitForExistence(timeout: 3) {
            storyboardsCell.tap()
            sleep(1)
            saveScreenshot("05_storyboard_grid")
        }
        
        // 6. Shot List
        let shotListCell = app.staticTexts["Shot List"]
        if shotListCell.waitForExistence(timeout: 3) {
            shotListCell.tap()
            sleep(1)
            saveScreenshot("06_shot_list")
        }
        
        // 7. Shoot Day Mode
        let shootDayCell = app.staticTexts["Shoot Day Mode"]
        if shootDayCell.waitForExistence(timeout: 3) {
            shootDayCell.tap()
            sleep(1)
            saveScreenshot("07_shoot_day_mode")
        }
        
        // 8. Documents
        let docsCell = app.staticTexts["All Documents"]
        if docsCell.waitForExistence(timeout: 3) {
            docsCell.tap()
            sleep(1)
            saveScreenshot("08_documents")
        }
    }
    
    private func saveScreenshot(_ name: String) {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        
        // Also save to disk
        let data = screenshot.pngRepresentation
        let path = "\(screenshotDir)/\(name).png"
        try? data.write(to: URL(fileURLWithPath: path))
    }
}
