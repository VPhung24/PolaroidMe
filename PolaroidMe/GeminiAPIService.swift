//
//  GeminiAPIService.swift
//  PolaroidMe
//
//  Created by Vivian Phung on 9/17/25.
//

import Foundation
import UIKit
import FirebaseAI

class GeminiAPIService {
    private lazy var model: GenerativeModel = {
        let ai = FirebaseAI.firebaseAI(backend: .googleAI(), useLimitedUseAppCheckTokens: true)
        let config = GenerationConfig(responseModalities: [.text, .image])
        let modelName = "gemini-2.5-flash-image-preview"
        
        return ai.generativeModel(
            modelName: modelName,
            generationConfig: config
        )
    }()
    
    enum APIError: Error, LocalizedError {
        case imageProcessingError
        case generationError(String)
        case noImageInResponse
        
        var errorDescription: String? {
            switch self {
            case .imageProcessingError:
                return "Failed to process the image"
            case .generationError(let message):
                return "Generation failed: \(message)"
            case .noImageInResponse:
                return "No image was generated. Please try again."
            }
        }
    }
    
    func transformImage(_ image: UIImage, prompt: String) async throws -> UIImage {
        // Optimize image before sending
        let processedImage = ImageProcessor.orientationFixed(image)
        guard let resizedImage = ImageProcessor.resizeImage(processedImage, maxDimension: 1024) else {
            throw APIError.imageProcessingError
        }
        
        do {
            // Generate content with image and prompt
            let response = try await model.generateContent(resizedImage, prompt)
            
            // Extract the generated image from the response
            if let candidate = response.candidates.first {
                for part in candidate.content.parts {
                    // Check if this part contains image data
                    if let inlineDataPart = part as? InlineDataPart,
                       inlineDataPart.mimeType.starts(with: "image/"),
                       let generatedImage = UIImage(data: inlineDataPart.data) {
                        return generatedImage
                    }
                }
            }
            
            // If no image found in response, throw error
            throw APIError.noImageInResponse
        } catch {
            if let apiError = error as? APIError {
                throw apiError
            }
            throw APIError.generationError(error.localizedDescription)
        }
    }
}
