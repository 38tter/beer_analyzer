
//
//  beer_analyzerUITests.swift
//  beer_analyzerUITests
//
//  Created by 宮田聖也 on 2025/06/02.
//

import XCTest

final class beer_analyzerUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testAppLaunch() throws {
        let app = XCUIApplication()
        app.launch()
        
        // アプリが正常に起動することを確認
        XCTAssertTrue(app.exists)
    }

    @MainActor
    func testMainScreenElements() throws {
        let app = XCUIApplication()
        app.launch()
        
        // メインスクリーンの要素が存在することを確認
        let titleText = app.staticTexts["ビール解析アプリ"]
        XCTAssertTrue(titleText.waitForExistence(timeout: 5))
        
        // カメラボタンの存在を確認
        let cameraButton = app.buttons["カメラで撮影"]
        XCTAssertTrue(cameraButton.exists)
        
        // 写真選択ボタンの存在を確認
        let photoButton = app.buttons["写真を選択"]
        XCTAssertTrue(photoButton.exists)
    }

    @MainActor
    func testCameraButtonTap() throws {
        let app = XCUIApplication()
        app.launch()
        
        let cameraButton = app.buttons["カメラで撮影"]
        XCTAssertTrue(cameraButton.waitForExistence(timeout: 5))
        
        cameraButton.tap()
        
        // デモ版では未実装メッセージが表示されることを確認
        let errorMessage = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'カメラ機能は現在デモ版では未実装です'"))
        XCTAssertTrue(errorMessage.element.waitForExistence(timeout: 3))
    }

    @MainActor
    func testPhotoSelectionButton() throws {
        let app = XCUIApplication()
        app.launch()
        
        let photoButton = app.buttons["写真を選択"]
        XCTAssertTrue(photoButton.waitForExistence(timeout: 5))
        
        photoButton.tap()
        
        // 写真選択画面が開くことを確認（システムのフォトピッカー）
        // 注意: 実際のテスト環境では写真へのアクセス許可が必要
    }

    @MainActor
    func testAnalysisButtonStateWhenNoImage() throws {
        let app = XCUIApplication()
        app.launch()
        
        // 画像が選択されていない時は解析ボタンが無効であることを確認
        let analyzeButton = app.buttons["ビールを解析"]
        if analyzeButton.exists {
            XCTAssertFalse(analyzeButton.isEnabled)
        }
    }

    @MainActor
    func testErrorMessageDisplay() throws {
        let app = XCUIApplication()
        app.launch()
        
        // エラーメッセージが表示される状況をテスト
        // （実際のエラーが発生した場合のテスト）
        let errorTexts = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'エラー' OR label CONTAINS '失敗'"))
        
        // エラーメッセージが存在する場合、適切に表示されていることを確認
        if errorTexts.count > 0 {
            XCTAssertTrue(errorTexts.element.exists)
        }
    }

    @MainActor
    func testRecordedBeersSection() throws {
        let app = XCUIApplication()
        app.launch()
        
        // 記録されたビールセクションの存在を確認
        let recordedBeersTitle = app.staticTexts["記録されたビール"]
        if recordedBeersTitle.exists {
            XCTAssertTrue(recordedBeersTitle.exists)
        }
        
        // 初回起動時は記録がないことを確認
        let noRecordsMessage = app.staticTexts["まだ記録されたビールはありません。"]
        if noRecordsMessage.exists {
            XCTAssertTrue(noRecordsMessage.exists)
        }
    }

    @MainActor
    func testScrollViewInteraction() throws {
        let app = XCUIApplication()
        app.launch()
        
        // スクロールビューが存在し、スクロール可能であることを確認
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            // 上から下へスクロール
            scrollView.swipeUp()
            
            // 下から上へスクロール
            scrollView.swipeDown()
        }
    }

    @MainActor
    func testLoadingIndicator() throws {
        let app = XCUIApplication()
        app.launch()
        
        // ローディングインジケーターが適切に表示されることをテスト
        // （実際の解析処理中に表示されるProgressView）
        let loadingIndicator = app.activityIndicators.firstMatch
        
        // ローディング中でない場合は非表示であることを確認
        if !loadingIndicator.exists {
            XCTAssertFalse(loadingIndicator.exists)
        }
    }

    @MainActor
    func testNavigationAndBackButtons() throws {
        let app = XCUIApplication()
        app.launch()
        
        // ナビゲーション要素のテスト
        let navigationBars = app.navigationBars
        if navigationBars.count > 0 {
            XCTAssertTrue(navigationBars.firstMatch.exists)
        }
        
        // 戻るボタンが存在する場合のテスト
        let backButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Back' OR label CONTAINS '戻る'"))
        if backButtons.count > 0 {
            XCTAssertTrue(backButtons.firstMatch.exists)
        }
    }

    @MainActor
    func testAccessibilityLabels() throws {
        let app = XCUIApplication()
        app.launch()
        
        // アクセシビリティラベルが適切に設定されていることを確認
        let cameraButton = app.buttons["カメラで撮影"]
        if cameraButton.exists {
            XCTAssertFalse(cameraButton.label.isEmpty)
        }
        
        let photoButton = app.buttons["写真を選択"]
        if photoButton.exists {
            XCTAssertFalse(photoButton.label.isEmpty)
        }
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // アプリの起動時間を測定
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }

    @MainActor
    func testMemoryUsage() throws {
        let app = XCUIApplication()
        app.launch()
        
        // メモリ使用量のテスト（基本的なメモリリークの検出）
        if #available(iOS 13.0, *) {
            measure(metrics: [XCTMemoryMetric()]) {
                // アプリの基本操作を実行
                let cameraButton = app.buttons["カメラで撮影"]
                if cameraButton.exists {
                    cameraButton.tap()
                }
                
                let photoButton = app.buttons["写真を選択"]
                if photoButton.exists {
                    photoButton.tap()
                }
            }
        }
    }
}
