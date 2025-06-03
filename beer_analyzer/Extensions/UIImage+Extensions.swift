
//
//  UIImage+Extensions.swift
//  beer_analyzer
//

import UIKit

extension UIImage {
    func toBase64() -> String? {
        guard let imageData = self.jpegData(compressionQuality: 0.8) else { return nil }
        return imageData.base64EncodedString()
    }

    func toMimeType() -> String {
        if let _ = self.pngData() {
            return "image/png"
        } else {
            return "image/jpeg"
        }
    }
}
