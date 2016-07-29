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
                                .elementBound(by: 0)
                                .children(matching: .other)
                                .elementBound(by: 1)
                                .children(matching: .other)
                                .elementBound(by: 1)
    }

    private func buttonAtIndex(_ index: UInt) -> XCUIElement {
        return XCUIApplication().collectionViews.children(matching: .cell).elementBound(by: index)
    }

    private func showAlertAtIndex(_ index: UInt) -> XCUIApplication {
        let app = XCUIApplication()
        app.tables.children(matching: .cell).elementBound(by: index).tap()
        return app
    }

    private func tapButtonAtIndex(_ index: UInt, expectDismissal: Bool = true) {
        buttonAtIndex(index).tap()
        XCTAssertNotEqual(currentAlert().exists, expectDismissal)
    }

    // MARK: - Tests

    func testAlertWithTitleAndMessageAnd1ButtonThatDismisses() {
        let app = showAlertAtIndex(0)

        XCTAssertTrue(app.staticTexts["Title"].exists)
        XCTAssertTrue(app.staticTexts["Message"].exists)

        tapButtonAtIndex(0)
    }

    func testAlertWith2ButtonsThatBothDismiss() {
        showAlertAtIndex(1)
        tapButtonAtIndex(0)
        showAlertAtIndex(1)
        tapButtonAtIndex(1)
    }

    func testAlertWith2ButtonsOnly1Dismisses() {
        showAlertAtIndex(2)
        tapButtonAtIndex(0, expectDismissal: false)
        tapButtonAtIndex(1)
    }

    func testAlertWith2ButtonsHasHorizontalButtonLayout() {
        showAlertAtIndex(3)

        let firstButton = buttonAtIndex(0)
        let secondButton = buttonAtIndex(1)

        XCTAssertEqual(firstButton.frame.minY, secondButton.frame.minY)
    }

    func testAlertWith3ButtonsHasVerticalButtonLayout() {
        showAlertAtIndex(4)

        let firstButton = buttonAtIndex(0)
        let secondButton = buttonAtIndex(1)
        let thirdButton = buttonAtIndex(2)

        XCTAssertLessThan(firstButton.frame.minY, secondButton.frame.minY)
        XCTAssertLessThan(secondButton.frame.minY, thirdButton.frame.minY)
    }

    func testAlertWith2ButtonsForcedVertically() {
        showAlertAtIndex(5)

        let firstButton = buttonAtIndex(0)
        let secondButton = buttonAtIndex(1)

        XCTAssertLessThan(firstButton.frame.minY, secondButton.frame.minY)
    }

    func testAlertWith3ButtonsForcedHorizontally() {
        showAlertAtIndex(6)

        let firstButton = buttonAtIndex(0)
        let secondButton = buttonAtIndex(1)
        let thirdButton = buttonAtIndex(2)

        XCTAssertEqual(firstButton.frame.minY, secondButton.frame.minY)
        XCTAssertEqual(firstButton.frame.minY, thirdButton.frame.minY)
    }

    func testAlertWithTextField() {
        showAlertAtIndex(7)

        let textField = XCUIApplication().textFields["Sample text"]
        XCTAssertGreaterThan(textField.frame.height, 0)
    }

    func testAlertWithSpinnerContent() {
        showAlertAtIndex(8)
        XCTAssertTrue(XCUIApplication().activityIndicators["In progress"].exists)
    }
}
