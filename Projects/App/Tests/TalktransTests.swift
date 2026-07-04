import Testing
import Foundation
@testable import App

struct TalktransTests {

	@Test func translationExecutionGate_preventsDuplicateExecutionPerRequest() {
		var gate = TranslationExecutionGate()
		let requestID = gate.beginRequest()
		let firstExecution = gate.canExecute(requestID)
		let secondExecution = gate.canExecute(requestID)

		#expect(firstExecution)
		#expect(!secondExecution)
	}

	@Test func translationExecutionGate_ignoresStaleRequestAfterNewRequestBegins() {
		var gate = TranslationExecutionGate()
		let firstRequestID = gate.beginRequest()
		_ = gate.canExecute(firstRequestID)

		let secondRequestID = gate.beginRequest()
		let staleExecution = gate.canExecute(firstRequestID)
		let newExecution = gate.canExecute(secondRequestID)

		#expect(!staleExecution)
		#expect(newExecution)
	}

	@Test @MainActor func translationViewModel_manualTranslatedTextMutation_doesNotEmitTranslationCompletionEvent() {
		let viewModel = TranslationViewModel()
		viewModel.translatedText = "History value"

		#expect(viewModel.lastCompletedTranslationID == nil)
	}

	@Test @MainActor func speechRecognitionViewModel_resetSessionState_clearsRecognizedTextAndError() {
		let viewModel = SpeechRecognitionViewModel()
		viewModel.recognizedText = "stale transcript"
		viewModel.errorMessage = "stale error"

		viewModel.resetSessionState()

		#expect(viewModel.recognizedText.isEmpty)
		#expect(viewModel.errorMessage == nil)
	}

	@Test @MainActor func speechRecognitionViewModel_startRecognitionWhileRecognizing_keepsCurrentTranscriptAndError() {
		let viewModel = SpeechRecognitionViewModel()
		viewModel.isRecognizing = true
		viewModel.recognizedText = "in-progress transcript"
		viewModel.errorMessage = "in-progress error"

		viewModel.startRecognition(locale: Locale(identifier: "en_US")) { _ in }

		#expect(viewModel.recognizedText == "in-progress transcript")
		#expect(viewModel.errorMessage == "in-progress error")
	}

	@Test @MainActor func speechRecognitionViewModel_startRecognitionFailure_doesNotClearExistingTranscript() {
		let viewModel = SpeechRecognitionViewModel()
		viewModel.recognizedText = "existing transcript"

		viewModel.startRecognition(locale: Locale(identifier: "zz_ZZ")) { _ in }

		#expect(viewModel.recognizedText == "existing transcript")
	}

	@Test @MainActor func translationViewModel_translateWhileTranslating_doesNotResetErrorOrConfiguration() {
		let viewModel = TranslationViewModel()
		viewModel.nativeText = "Hello"
		viewModel.isTranslating = true
		viewModel.errorMessage = "existing error"

		viewModel.translate()

		#expect(viewModel.errorMessage == "existing error")
		#expect(viewModel.translationConfiguration == nil)
	}

	@Test @MainActor func translationViewModel_translate_createsSessionBindingRequestID() {
		let viewModel = TranslationViewModel()
		viewModel.nativeText = "Hello"

		viewModel.translate()

		#expect(viewModel.sessionBindingRequestID != nil)
	}

	@Test @MainActor func translationViewModel_sessionBindingRequestIDValidation_rejectsStaleIDs() {
		let viewModel = TranslationViewModel()
		viewModel.nativeText = "Hello"
		viewModel.translate()
		let activeRequestID = viewModel.sessionBindingRequestID

		#expect(viewModel.isValidSessionBindingRequestID(activeRequestID))
		#expect(!viewModel.isValidSessionBindingRequestID(UUID()))
		#expect(!viewModel.isValidSessionBindingRequestID(nil))
	}

}
