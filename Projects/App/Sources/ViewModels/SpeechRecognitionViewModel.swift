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
	/// True once the first real audio buffer of the current engine session arrived (mic is live).
	@Published private(set) var isListeningReady = false
	
	private var audioEngine = AVAudioEngine()
	private let requestBox = RecognitionRequestBox()
	private var recognitionTask: SFSpeechRecognitionTask?
	private var sessionID = UUID()
	/// Identifies the current audio-engine run; unlike `sessionID` it survives in-place restarts.
	private var engineSessionID = UUID()

	func resetSessionState() {
		recognizedText = ""
		errorMessage = nil
	}
	
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
		
		// Token invalidated by stopRecognition() so a pending permission request won't start a session
		let pendingSession = UUID()
		sessionID = pendingSession
		
		// Request authorization
		SFSpeechRecognizer.requestAuthorization { [weak self] status in
			Task { @MainActor in
				guard self?.sessionID == pendingSession else { return }
				guard status == .authorized else {
					self?.errorMessage = "Speech recognition permission denied"
					return
				}
				
				// Request microphone permission
				let granted = await AVAudioApplication.requestRecordPermission()
				guard self?.sessionID == pendingSession else { return }
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
			
			let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
			recognitionRequest.shouldReportPartialResults = true
			requestBox.request = recognitionRequest
			
			let inputNode = audioEngine.inputNode
			let recordingFormat = inputNode.outputFormat(forBus: 0)
			let box = requestBox
			
			let engineSession = UUID()
			engineSessionID = engineSession
			isListeningReady = false
			box.resetFirstBuffer()
			let onFirstBuffer: @Sendable () -> Void = { [weak self] in
				Task { @MainActor in
					guard let self, self.engineSessionID == engineSession, self.audioEngine.isRunning else { return }
					self.isListeningReady = true
				}
			}

			inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
				box.append(buffer)
				if box.markFirstBuffer() {
					onFirstBuffer()
				}
			}
			
			audioEngine.prepare()
			try audioEngine.start()
			resetSessionState()
			
			isRecognizing = true
			errorMessage = nil
			
			guard startRecognitionTask(locale: locale, request: recognitionRequest, onResult: onResult) else {
				errorMessage = "Speech recognizer is not available"
				stopRecognition()
				return
			}
		} catch {
			errorMessage = error.localizedDescription
			stopRecognition()
		}
	}
	
	/// Restarts transcription from scratch. While the engine is running, the audio engine,
	/// input tap and audio session stay alive so no speech is lost to hardware warm-up;
	/// only the recognition request/task are swapped.
	func restartRecognition(locale: Locale, onResult: @escaping (String) -> Void) {
		guard isRecognizing, audioEngine.isRunning else {
			stopRecognition()
			resetSessionState()
			startRecognition(locale: locale, onResult: onResult)
			return
		}
		
		// Invalidate callbacks from the previous task
		sessionID = UUID()
		recognitionTask?.cancel()
		recognitionTask = nil
		requestBox.request?.endAudio()
		
		let newRequest = SFSpeechAudioBufferRecognitionRequest()
		newRequest.shouldReportPartialResults = true
		requestBox.request = newRequest
		resetSessionState()
		
		guard startRecognitionTask(locale: locale, request: newRequest, onResult: onResult) else {
			errorMessage = "Speech recognizer is not available"
			stopRecognition()
			return
		}
	}
	
	/// Creates the recognition task for `request` under the current `sessionID`.
	/// Returns false when no recognizer is available for `locale`.
	private func startRecognitionTask(
		locale: Locale,
		request: SFSpeechAudioBufferRecognitionRequest,
		onResult: @escaping (String) -> Void
	) -> Bool {
		guard let recognizer = SFSpeechRecognizer(locale: locale) else { return false }
		
		let currentSession = sessionID
		recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
			Task { @MainActor in
				guard let self, self.sessionID == currentSession else { return }
				if let error = error {
					self.errorMessage = error.localizedDescription
					self.stopRecognition()
					return
				}
				
				if let result = result {
					let text = result.bestTranscription.formattedString
					self.recognizedText = text
					onResult(text)
					
					if result.isFinal {
						self.stopRecognition()
					}
				}
			}
		}
		return true
	}
	
	func stopRecognition() {
		sessionID = UUID()
		engineSessionID = UUID()
		recognitionTask?.cancel()
		recognitionTask = nil
		
		requestBox.request?.endAudio()
		requestBox.request = nil
		
		audioEngine.stop()
		audioEngine.inputNode.removeTap(onBus: 0)
		
		do {
			try AVAudioSession.sharedInstance().setActive(false)
		} catch {
			print("Failed to deactivate audio session: \(error)")
		}
		
		isRecognizing = false
		isListeningReady = false
	}
}

/// Thread-safe holder so the audio-thread tap can feed whichever request is current.
private final class RecognitionRequestBox: @unchecked Sendable {
	private let lock = NSLock()
	private var _request: SFSpeechAudioBufferRecognitionRequest?
	
	var request: SFSpeechAudioBufferRecognitionRequest? {
		get { lock.lock(); defer { lock.unlock() }; return _request }
		set { lock.lock(); defer { lock.unlock() }; _request = newValue }
	}
	
	private var firstBufferDelivered = false
	
	/// Returns true exactly once per reset, on the first call.
	func markFirstBuffer() -> Bool {
		lock.lock(); defer { lock.unlock() }
		guard !firstBufferDelivered else { return false }
		firstBufferDelivered = true
		return true
	}
	
	func resetFirstBuffer() {
		lock.lock(); defer { lock.unlock() }
		firstBufferDelivered = false
	}
	
	func append(_ buffer: AVAudioPCMBuffer) {
		request?.append(buffer)
	}
}
