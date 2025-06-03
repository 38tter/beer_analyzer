//
//  CameraPicker.swift
//  beer_analyzer
//
//  Created by 宮田聖也 on 2025/06/04.
//


import SwiftUI
import UIKit // UIImagePickerController は UIKit の機能なのでインポート

// MARK: - CameraPicker: UIImagePickerController を SwiftUI で使うためのラッパー
struct CameraPicker: UIViewControllerRepresentable {
    // 撮影または選択された画像を受け取るための @Binding プロパティ
    @Binding var selectedImage: UIImage?
    // 環境変数からシート（ビューコントローラ）を閉じるための dismiss アクションを取得
    @Environment(\.dismiss) var dismiss

    // UIImagePickerController のソースタイプ (カメラまたはフォトライブラリ)
    var sourceType: UIImagePickerController.SourceType = .camera // デフォルトはカメラ

    // UIViewController を作成し、初期設定を行う
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator // デリゲートを設定して、イベントを受け取る
        picker.sourceType = sourceType       // ソースタイプを設定 (カメラまたはフォトライブラリ)
        picker.allowsEditing = false         // 撮影後に画像を編集させない (必要であれば true に)
        return picker
    }

    // UIViewController を更新する（この例では特別な更新は不要）
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // 更新処理はなし
    }

    // UIViewController のデリゲートイベントを処理するための Coordinator を作成
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Coordinator クラス
    // UIImagePickerController のデリゲートメソッドを処理する
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker // 親の CameraPicker ビューへの参照

        init(_ parent: CameraPicker) {
            self.parent = parent
        }

        // 写真の選択/撮影が完了したときに呼び出される
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // 元の画像を取得 (編集を許可しない場合は .originalImage を使用)
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image // 選択された画像を @Binding プロパティに設定
            }
            parent.dismiss() // ピッカーを閉じる
        }

        // ピッカーがキャンセルされたときに呼び出される
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss() // ピッカーを閉じる
        }
    }
}
