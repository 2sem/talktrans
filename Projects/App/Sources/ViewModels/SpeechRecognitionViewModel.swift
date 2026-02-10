//
//  SpeechRecognitionViewModel.swift
//  talktrans
//
//  Created by 영준 이 on 11/9/25.
//  Copyright © 2025 leesam. All rights reserved.
//

import Foundation
import SwiftUI
import Speech
import AVFoundation

@MainActor
class SpeechRecognitionViewModel: ObservableObject {
	@Published var isRecognizing: Bool = false
	@Published var recognizedText: String = ""
	@Published var errorMessage: String?
	
	private var audioEngine = AVAudioEngine()
	private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
	private var recognitionTask: SFSpeechRecognitionTask?
	
	func startRecognition(locale: Locale, onResult: @escaping (String) -> Void) {
		guard !isRecognizing else { return }
		
		guard let recognizer = SFSpeechRecognizer(locale: locale) else {
			errorMessage = "Speech recognition is not available for this language"
			return
		}
		
		guard recognizer.isAvailable else {
			errorMessage = "Speech recognizer is not available"
			return
		}
		
		// Request authorization
		SFSpeechRecognizer.requestAuthorization { [weak self] status in
			Task { @MainActor in
				guard status == .authorized else {
					self?.errorMessage = "Speech recognition permission denied"
					return
				}
				
				// Request microphone permission
				let granted = await AVAudioApplication.requestRecordPermission()
				guard granted else {
					self?.errorMessage = "Microphone permission denied"
					return
				}

				self?.performRecognition(locale: locale, onResult: onResult)
			}
		}
	}
	
	private func performRecognition(locale: Locale, onResult: @escaping (String) -> Void) {
		do {
			let audioSession = AVAudioSession.sharedInstance()
			try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
			try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
			
			recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
			guard let recognitionRequest = recognitionRequest else {
				errorMessage = "Unable to create recognition request"
				return
			}
			
			recognitionRequest.shouldReportPartialResults = true
			
			let inputNode = audioEngine.inputNode
			let recordingFormat = inputNode.outputFormat(forBus: 0)
			
			inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
				recognitionRequest.append(buffer)
			}
			
			audioEngine.prepare()
			try audioEngine.start()
			
			isRecognizing = true
			errorMessage = nil
			
			guard let recognizer = SFSpeechRecognizer(locale: locale) else {
				errorMessage = "Speech recognizer is not available"
				stopRecognition()
				return
			}
			
			recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
				Task { @MainActor in
					if let error = error {
						self?.errorMessage = error.localizedDescription
						self?.stopRecognition()
						return
					}
					
					if let result = result {
						let text = result.bestTranscription.formattedString
						self?.recognizedText = text
						onResult(text)
						
						if result.isFinal {
							self?.stopRecognition()
						}
					}
				}
			}
		} catch {
			errorMessage = error.localizedDescription
			stopRecognition()
		}
	}
	
	func stopRecognition() {
		recognitionTask?.cancel()
		recognitionTask = nil
		
		recognitionRequest?.endAudio()
		recognitionRequest = nil
		
		audioEngine.stop()
		audioEngine.inputNode.removeTap(onBus: 0)
		
		do {
			try AVAudioSession.sharedInstance().setActive(false)
		} catch {
			print("Failed to deactivate audio session: \(error)")
		}
		
		isRecognizing = false
	}
}

