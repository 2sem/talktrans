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
		case .korean: return "langs/korean"
		case .japanese: return "langs/japanese"
		case .english: return "langs/english"
		case .taiwan: return "langs/taiwanese"
		case .chinese: return "langs/chinese"
		case .vietnam: return "langs/vietnamese"
		case .indonesian: return "langs/indonesian"
		case .thai: return "langs/thai"
		case .german: return "langs/german"
		case .russian: return "langs/russian"
		case .spain: return "langs/spanish"
		case .italian: return "langs/italian"
		case .france: return "langs/french"
		}
	}
	
	var locale: Locale {
		return Locale(identifier: self.rawValue)
	}
	
	static func from(locale: Locale) -> TranslationLocale? {
		let identifier = locale.language.languageCode?.identifier ?? ""
		return TranslationLocale(rawValue: identifier)
	}
}

