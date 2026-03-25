//
//  TranslationEntry.swift
//  talktrans
//
//  Created by 영준 이 on 3/25/26.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftData
import Foundation

@Model final class TranslationEntry {
	var id: UUID
	var sourceText: String
	var translatedText: String
	var sourceLang: String
	var targetLang: String
	var timestamp: Date
	var isFavorited: Bool

	init(sourceText: String, translatedText: String, sourceLang: String, targetLang: String) {
		self.id = UUID()
		self.sourceText = sourceText
		self.translatedText = translatedText
		self.sourceLang = sourceLang
		self.targetLang = targetLang
		self.timestamp = Date()
		self.isFavorited = false
	}
}
