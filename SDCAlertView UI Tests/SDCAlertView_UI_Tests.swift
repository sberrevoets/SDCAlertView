import XCTest

class SDCAlertView_UI_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false

        let app = XCUIApplication()
        app.launch()
        app.navigationBars["Example.DemoView"].buttons["Tests"].tap()
    }

    // MARK: - Helpers

    private func currentAlert() -> XCUIElement {
        return XCUIApplication().children(matching: .window)
                                .element(boundBy: 0)
                                .children(matching: .other)
                                .element(boundBy: 1)
                                .children(matching: .other)
                                .element(boundBy: 1)
    }

    private func buttonAtIndex(_ index: UInt) -> XCUIElement {
        return XCUIApplication().collectionViews.children(matching: .cell).element(boundBy: index)
    }

    private func buttonWithIdentifier(_ identifier: String) -> XCUIElement {
        let cell = XCUIApplication().collectionViews.cells.matching(identifier: identifier).element(boundBy: 0)
        if !cell.exists {
            return XCUIApplication().buttons.matching(identifier: identifier).element(boundBy: 0)
        }
        return cell
    }

    @discardableResult
    private func showAlertAtIndex(_ index: UInt) -> XCUIApplication {
        let app = XCUIApplication()
        app.tables.children(matching: .cell).element(boundBy: index).tap()
        return app
    }

    private func tapButtonAtIndex(_ index: UInt, expectDismissal: Bool = true) {
        self.buttonAtIndex(index).tap()
        XCTAssertNotEqual(currentAlert().exists, expectDismissal)
    }

    private func tapButtonWithIdentifier(_ identifier: String, expectDismissal: Bool = true) {
        self.buttonWithIdentifier(identifier).tap()
        XCTAssertNotEqual(currentAlert().exists, expectDismissal)
    }

    // MARK: - Tests

    func testAlertWithTitleAndMessageAnd1ButtonThatDismisses() {
        let app = showAlertAtIndex(0)

        XCTAssertTrue(app.staticTexts["Title"].exists)
        XCTAssertTrue(app.staticTexts["Message"].exists)

        self.tapButtonAtIndex(0)
    }

    func testAlertWith2ButtonsThatBothDismiss() {
        self.showAlertAtIndex(1)
        self.tapButtonAtIndex(0)
        self.showAlertAtIndex(1)
        self.tapButtonAtIndex(1)
    }

    func testAlertWith2ButtonsOnly1Dismisses() {
        self.showAlertAtIndex(2)
        self.tapButtonAtIndex(0, expectDismissal: false)
        self.tapButtonAtIndex(1)
    }

    func testAlertWith2ButtonsHasHorizontalButtonLayout() {
        self.showAlertAtIndex(3)

        let firstButton = buttonAtIndex(0)
        let secondButton = buttonAtIndex(1)

        XCTAssertEqual(firstButton.frame.minY, secondButton.frame.minY)
    }

    func testAlertWith3ButtonsHasVerticalButtonLayout() {
        self.showAlertAtIndex(4)

        let firstButton = buttonAtIndex(0)
        let secondButton = buttonAtIndex(1)
        let thirdButton = buttonAtIndex(2)

        XCTAssertLessThan(firstButton.frame.minY, secondButton.frame.minY)
        XCTAssertLessThan(secondButton.frame.minY, thirdButton.frame.minY)
    }

    func testAlertWith2ButtonsForcedVertically() {
        self.showAlertAtIndex(5)

        let firstButton = buttonAtIndex(0)
        let secondButton = buttonAtIndex(1)

        XCTAssertLessThan(firstButton.frame.minY, secondButton.frame.minY)
    }

    func testAlertWith3ButtonsForcedHorizontally() {
        self.showAlertAtIndex(6)

        let firstButton = buttonAtIndex(0)
        let secondButton = buttonAtIndex(1)
        let thirdButton = buttonAtIndex(2)

        XCTAssertEqual(firstButton.frame.minY, secondButton.frame.minY)
        XCTAssertEqual(firstButton.frame.minY, thirdButton.frame.minY)
    }

    func testAlertWithTextField() {
        self.showAlertAtIndex(7)

        let textField = XCUIApplication().textFields["Sample text"]
        XCTAssertGreaterThan(textField.frame.height, 0)
    }

    func testAlertWithSpinnerContent() {
        self.showAlertAtIndex(8)
        XCTAssertTrue(XCUIApplication().activityIndicators["In progress"].exists)
    }

    func testAlertWithAcessibilityIdentifiers() {
        self.showAlertAtIndex(9)
        XCTAssertTrue(buttonWithIdentifier("button").exists)
        self.tapButtonWithIdentifier("button")
    }

    func testActionSheetWithAcessibilityIdentifiers() {
        self.showAlertAtIndex(10)
        XCTAssertTrue(buttonWithIdentifier("button").exists)
        self.tapButtonWithIdentifier("button")
    }

    func testActionSheetWithCustomView() {
        self.showAlertAtIndex(11)
        XCTAssertTrue(XCUIApplication().activityIndicators["In progress"].exists)
        XCTAssertTrue(buttonWithIdentifier("button").exists)
        self.tapButtonWithIdentifier("cancel")
    }
}
