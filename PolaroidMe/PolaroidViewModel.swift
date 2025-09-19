//
//  PolaroidViewModel.swift
//  PolaroidMe
//
//  Created by Vivian Phung on 9/17/25.
//

import SwiftUI
import PhotosUI
import Observation

@Observable
@MainActor
final class PolaroidViewModel {
    var selectedImage: UIImage?
    var transformedImage: UIImage?
    var selectedItem: PhotosPickerItem?
    var isProcessing = false
    var showError = false
    var errorMessage = ""
    var selectedPromptKey = "aged"
    var includeFrame = true

    private let apiService = GeminiAPIService()

    let polaroidFramePrompts = [
        "frame": "Transform this photo into a vintage Polaroid instant photograph. IMPORTANT: Create a thick white Polaroid frame border around the ENTIRE image. The photo content must be completely contained INSIDE the white frame - absolutely nothing should extend beyond or outside the white borders. Make the frame thick and prominent like a real Polaroid instant photo, with the characteristic wider bottom border. The image should be scaled down to fit entirely within the frame boundaries",
        "unframed": "Apply vintage Polaroid film effects directly to the image without adding any frame or border"
    ]

    let polaroidStylePrompts = [
        "aged": "Make this look like an old, weathered Polaroid that's been sitting in a shoebox for 40 years. Add yellowing, slight color shifts, dust spots, fading around edges, and authentic wear marks. Include subtle light leaks and film grain.",
        "vibrant": "Create a well-preserved vintage Polaroid from the 1980s with slightly faded but still vibrant colors, warm tones, minimal aging, subtle film grain, and that characteristic Polaroid color palette.",
        "dreamy": "Create a dreamy, romantic Polaroid with rich, saturated colors enhanced by soft golden hour lighting. Add subtle rainbow light leaks, a gentle vignette, and a touch of film grain. Keep colors vibrant but with a soft, magical quality - not washed out or faded. Include warm pink and amber tones with preserved detail and contrast."
    ]

    var combinedPrompt: String {
        let framePrompt = includeFrame ? polaroidFramePrompts["frame"]! : polaroidFramePrompts["unframed"]!
        let stylePrompt = polaroidStylePrompts[selectedPromptKey] ?? polaroidStylePrompts["aged"]!
        return "\(framePrompt). \(stylePrompt)"
    }

    func loadSelectedPhoto() async {
        guard let selectedItem = selectedItem else { return }

        do {
            if let data = try await selectedItem.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                selectedImage = uiImage
                transformedImage = nil
            }
        } catch {
            errorMessage = "Failed to load image"
            showError = true
        }
    }

    func transformImage() async {
        guard let image = selectedImage else { return }

        isProcessing = true

        do {
            let prompt = combinedPrompt
            transformedImage = try await apiService.transformImage(image, prompt: prompt)
            isProcessing = false
        } catch {
            isProcessing = false
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func saveToPhotos() {
        guard let image = transformedImage else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}
