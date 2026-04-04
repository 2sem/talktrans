//
//  TranslationLocale+Extension.swift
//  talktrans
//
//  Created by 영준 이 on 11/9/25.
//  Copyright © 2025 leesam. All rights reserved.
//

import Foundation

extension TranslationLocale {
	var displayName: String {
		switch self {
		case .korean: return "Korean"
		case .japanese: return "Japanese"
		case .english: return "English"
		case .taiwan: return "Taiwanese"
		case .chinese: return "Chinese"
		case .vietnam: return "Vietnamese"
		case .indonesian: return "Indonesian"
		case .thai: return "Thai"
		case .german: return "German"
		case .russian: return "Russian"
		case .spain: return "Spanish"
		case .italian: return "Italian"
		case .france: return "French"
		}
	}
	
	var flagImageName: String {
		switch self {
		case .korean: return "korean"
		case .japanese: return "japanese"
		case .english: return "english"
		case .taiwan: return "taiwanese"
		case .chinese: return "chinese"
		case .vietnam: return "vietnamese"
		case .indonesian: return "indonesian"
		case .thai: return "thai"
		case .german: return "german"
		case .russian: return "russian"
		case .spain: return "spanish"
		case .italian: return "italian"
		case .france: return "french"
		}
	}
	
	var locale: Locale {
		return Locale(identifier: self.rawValue)
	}
	
	static func from(locale: Locale) -> TranslationLocale? {
		let languageCode = locale.language.languageCode?.identifier.lowercased() ?? ""
		let scriptCode = locale.language.script?.identifier.lowercased()
		
		switch languageCode {
		case "zh":
			if scriptCode == "hant" {
				return .taiwan
			}
			if scriptCode == "hans" {
				return .chinese
			}
			
			let normalizedIdentifier = locale.identifier.lowercased().replacingOccurrences(of: "_", with: "-")
			if normalizedIdentifier.contains("hant") || normalizedIdentifier.contains("zh-tw") {
				return .taiwan
			}
			return .chinese
		default:
			return TranslationLocale(rawValue: languageCode)
		}
	}
}

