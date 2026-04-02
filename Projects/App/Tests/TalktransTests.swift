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

	@Test func feedbackIssueURL_usesHistoryScreenProductionValue() {
		let feedbackURL = URL(string: HistoryScreen.feedbackIssueURLString)

		#expect(feedbackURL?.scheme == "https")
		#expect(feedbackURL?.host == "github.com")
		#expect(feedbackURL?.path == "/2sem/talktrans/issues/new/choose")
		#expect(feedbackURL?.query == nil)
	}

	@Test func feedbackLocalizationValues_matchExpectedTranslations() throws {
		let expected: [String: [String: String]] = [
			"Base": [
				"Send Feedback": "Send Feedback",
				"Unable to Open Link": "Unable to Open Link",
				"Copy Link": "Copy Link",
				"Please copy and open the feedback link manually.": "Please copy and open the feedback link manually."
			],
			"ko": [
				"Send Feedback": "피드백 보내기",
				"Unable to Open Link": "링크를 열 수 없습니다",
				"Copy Link": "링크 복사",
				"Please copy and open the feedback link manually.": "피드백 링크를 복사해 직접 열어주세요."
			],
			"de": [
				"Send Feedback": "Feedback senden",
				"Unable to Open Link": "Link kann nicht geöffnet werden",
				"Copy Link": "Link kopieren",
				"Please copy and open the feedback link manually.": "Bitte kopieren Sie den Feedback-Link und öffnen Sie ihn manuell."
			],
			"es": [
				"Send Feedback": "Enviar comentarios",
				"Unable to Open Link": "No se puede abrir el enlace",
				"Copy Link": "Copiar enlace",
				"Please copy and open the feedback link manually.": "Copie y abra manualmente el enlace de comentarios."
			],
			"fr": [
				"Send Feedback": "Envoyer des commentaires",
				"Unable to Open Link": "Impossible d’ouvrir le lien",
				"Copy Link": "Copier le lien",
				"Please copy and open the feedback link manually.": "Veuillez copier et ouvrir manuellement le lien de commentaires."
			],
			"id": [
				"Send Feedback": "Kirim masukan",
				"Unable to Open Link": "Tidak dapat membuka tautan",
				"Copy Link": "Salin tautan",
				"Please copy and open the feedback link manually.": "Silakan salin dan buka tautan masukan secara manual."
			],
			"it": [
				"Send Feedback": "Invia feedback",
				"Unable to Open Link": "Impossibile aprire il link",
				"Copy Link": "Copia link",
				"Please copy and open the feedback link manually.": "Copia e apri manualmente il link di feedback."
			],
			"ja": [
				"Send Feedback": "フィードバックを送信",
				"Unable to Open Link": "リンクを開けません",
				"Copy Link": "リンクをコピー",
				"Please copy and open the feedback link manually.": "フィードバックリンクをコピーして手動で開いてください。"
			],
			"ru": [
				"Send Feedback": "Отправить отзыв",
				"Unable to Open Link": "Не удалось открыть ссылку",
				"Copy Link": "Копировать ссылку",
				"Please copy and open the feedback link manually.": "Скопируйте ссылку обратной связи и откройте ее вручную."
			],
			"th": [
				"Send Feedback": "ส่งข้อเสนอแนะ",
				"Unable to Open Link": "ไม่สามารถเปิดลิงก์ได้",
				"Copy Link": "คัดลอกลิงก์",
				"Please copy and open the feedback link manually.": "โปรดคัดลอกและเปิดลิงก์ข้อเสนอแนะด้วยตนเอง"
			],
			"vi": [
				"Send Feedback": "Gửi phản hồi",
				"Unable to Open Link": "Không thể mở liên kết",
				"Copy Link": "Sao chép liên kết",
				"Please copy and open the feedback link manually.": "Vui lòng sao chép và mở liên kết phản hồi theo cách thủ công."
			],
			"zh-Hans": [
				"Send Feedback": "发送反馈",
				"Unable to Open Link": "无法打开链接",
				"Copy Link": "复制链接",
				"Please copy and open the feedback link manually.": "请复制并手动打开反馈链接。"
			],
			"zh-Hant-TW": [
				"Send Feedback": "傳送回饋",
				"Unable to Open Link": "無法開啟連結",
				"Copy Link": "複製連結",
				"Please copy and open the feedback link manually.": "請複製並手動開啟回饋連結。"
			]
		]

		for (locale, localizedPairs) in expected {
			let strings = try #require(localizedStrings(locale: locale))
			for (key, expectedValue) in localizedPairs {
				#expect(strings[key] == expectedValue)
			}
		}
	}

	private func localizedStrings(locale: String) -> [String: String]? {
		let testsFileURL = URL(fileURLWithPath: #filePath)
		let repoRootURL = testsFileURL
			.deletingLastPathComponent()
			.deletingLastPathComponent()
			.deletingLastPathComponent()
			.deletingLastPathComponent()
		let stringsURL = repoRootURL
			.appendingPathComponent("Projects/App/Resources/Strings")
			.appendingPathComponent("\(locale).lproj")
			.appendingPathComponent("Localizable.strings")

		return NSDictionary(contentsOf: stringsURL) as? [String: String]
	}
}
