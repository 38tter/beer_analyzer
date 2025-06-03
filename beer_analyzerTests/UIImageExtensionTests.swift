
//
//  UIImageExtensionTests.swift
//  beer_analyzerTests
//

import Testing
import UIKit
@testable import beer_analyzer

struct UIImageExtensionTests {
    
    @Test func testImageToBase64Conversion() async throws {
        // 1x1ピクセルの白い画像を作成
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let base64String = image.toBase64()
        #expect(base64String != nil)
        #expect(!base64String!.isEmpty)
    }
    
    @Test func testImageMimeType() async throws {
        // 1x1ピクセルの画像を作成
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.red.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let mimeType = image.toMimeType()
        #expect(mimeType == "image/jpeg")
    }
    
    @Test func testNilImageHandling() async throws {
        // UIImageの拡張メソッドが適切にnilを処理することをテスト
        let emptyImage = UIImage()
        let base64 = emptyImage.toBase64()
        
        // 空の画像でもnilにならずに何らかの値を返すことを確認
        #expect(base64 != nil)
    }
}
