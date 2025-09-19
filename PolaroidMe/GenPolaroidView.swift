//
//  GenPolaroidView.swift
//  PolaroidMe
//
//  Created by Vivian Phung on 9/17/25.
//

import SwiftUI
import PhotosUI

struct GenPolaroidView: View {
    @State private var viewModel = PolaroidViewModel()
    
    private func photoPickerLabel() -> some View {
        VStack {
            if let selectedImage = viewModel.selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("Tap to select a photo")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
        }
    }

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Photo Picker Section
                    PhotosPicker(
                        selection: $viewModel.selectedItem,
                        matching: .images,
                        label: { photoPickerLabel() }
                    )
                    .onChange(of: viewModel.selectedItem) { _, _ in
                        Task { @MainActor in
                            await viewModel.loadSelectedPhoto()
                        }
                    }
                    
                    // Style Picker
                    if viewModel.selectedImage != nil {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Polaroid Style")
                                .font(.headline)
                            
                            Picker("Frame", selection: $viewModel.includeFrame) {
                                Text("Framed").tag(true)
                                Text("Unframed").tag(false)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            
                            Picker("Style", selection: $viewModel.selectedPromptKey) {
                                Text("Aged").tag("aged")
                                Text("Retro").tag("vibrant")
                                Text("Dreamy").tag("dreamy")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }
                    
                    // Transform Button
                    if viewModel.selectedImage != nil && !viewModel.isProcessing {
                        Button(action: {
                            Task {
                                await viewModel.transformImage()
                            }
                        }) {
                            Label("Transform to Polaroid", systemImage: "wand.and.stars")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(
                                    gradient: Gradient(colors: [Color.orange, Color.pink]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .cornerRadius(10)
                        }
                    }
                    
                    // Loading Indicator
                    if viewModel.isProcessing {
                        VStack(spacing: 12) {
                            Spacer(minLength: 20)

                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Creating your Polaroid magic...")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                    
                    // Transformed Image Display
                    if let transformedImage = viewModel.transformedImage {
                        VStack(spacing: 12) {
                            Text("Your Polaroid")
                                .font(.headline)
                            
                            Image(uiImage: transformedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 400)
                                .shadow(radius: 10)
                            
                            HStack(spacing: 20) {
                                Button(action: viewModel.saveToPhotos) {
                                    Label("Save", systemImage: "square.and.arrow.down")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                }
                                
                                ShareLink(
                                    item: Image(uiImage: transformedImage),
                                    preview: SharePreview("Polaroid Photo", image: Image(uiImage: transformedImage))
                                ) {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.green)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("Polaroid Me")
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

#Preview {
    GenPolaroidView()
}
