//
//  SpeechRecognitionScreen.swift
//  App
//
//  Created by 영준 이 on 11/17/25.
//
import SwiftUI

struct SpeechRecognitionScreen: View {
    @ObservedObject var viewModel: SpeechRecognitionViewModel
    @Binding var text: String
    @Environment(\.dismiss) private var dismiss
    let locale: Locale
    var processTitle: String?
    var onProcess: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Recognizing...")
                .font(.system(size: 20, weight: .semibold))
                .padding(.top, 20)
            
            Text("Please say sentence to be recognized")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
            
            if viewModel.isRecognizing {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding()
            }
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .padding(.horizontal, 20)
            }
            
            HStack(spacing: 12) {
                Button(action: {
                    if !viewModel.recognizedText.isEmpty {
                        text = viewModel.recognizedText
                    }
                    viewModel.stopRecognition()
                    dismiss()
                }) {
                    Text("Done")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                }
                
                if let onProcess, let processTitle {
                    Button(action: {
                        if !viewModel.recognizedText.isEmpty {
                            text = viewModel.recognizedText
                        }
                        viewModel.stopRecognition()
                        onProcess()
                        dismiss()
                    }) {
                        Text(processTitle)
                            .font(.system(size: 17, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                LinearGradient(
                                    colors: [
                                        .appAccentGradientStart,
                                        .appAccentGradientEnd
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .presentationDetents([.height(250)])
        .onChange(of: viewModel.recognizedText) { _, newValue in
            if !newValue.isEmpty {
                text = newValue
            }
        }
        .onAppear {
            viewModel.startRecognition(locale: locale) { _ in
                // Text will be updated via recognizedText in viewModel
            }
        }
        .onDisappear {
            viewModel.stopRecognition()
        }
    }
}
