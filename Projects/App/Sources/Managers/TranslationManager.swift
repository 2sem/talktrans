//
//  TranslationManager.swift
//  talktrans
//
//  Created by 영준 이 on 11/9/25.
//  Copyright © 2025 leesam. All rights reserved.
//

import Foundation
import Translation

class TranslationManager {
    static let shared = TranslationManager()
    
    var _supportedTranslations = TranslationLocale.allCases
        .reduce(into: [TranslationLocale : [TranslationLocale]](), { values, locale in
            values[locale] = TranslationLocale.allCases
                .filter{ $0 != locale }
        })
    
    var languageAvailability = LanguageAvailability()
    
    func supportedTranslations(from sourceLocale: TranslationLocale) -> [TranslationLocale] {
        return self._supportedTranslations[sourceLocale] ?? []
    }
    
    /**
     Returns the indication to able to translate by given locale of source/target
     - parameter source: locale of native text
     - parameter target: locale of translated text
     - returns: the indication to able to translate by given locale of source/target
     */
    public func canSupportTranslate(source : Locale, target : Locale) -> Bool{
        guard let sourceTransLocale = TranslationLocale(rawValue: source.language.languageCode?.identifier ?? "") else{
            return false;
        }
        
        guard let targetTransLocale = TranslationLocale(rawValue: target.language.languageCode?.identifier  ?? "") else{
            return false;
        }
        
        guard let transLocales = self._supportedTranslations[sourceTransLocale] else{
            return false;
        }
        
        return transLocales.contains(targetTransLocale);
    }
    
    /**
     Get target locales can be translated from source locale
     - parameter source: locale of native text
     - returns: target locales can be translated from given source locale
     */
    public func supportedTargetLangs(source: Locale) -> [TranslationLocale]{
        let sourceLangCode = source.language.languageCode?.identifier ?? "";
        guard let sourceLang = TranslationLocale(rawValue: sourceLangCode) else{
            return [];
        }
        
        return TranslationLocale.allCases.filter{ $0 != sourceLang };
    }
    
    /**
     Create TranslationSession.Configuration for use with translationTask modifier
     - parameter source: locale of native text
     - parameter target: locale of translated text
     - returns: TranslationSession.Configuration
     */
    public func createConfiguration(from sourceLocale: Locale, to targetLocale: Locale) -> TranslationSession.Configuration {
        var configuration = TranslationSession.Configuration()
        configuration.source = sourceLocale.language
        configuration.target = targetLocale.language
        return configuration
    }
    
    /**
     Translate text using TranslationSession
     - parameter text: text to translate
     - parameter session: TranslationSession to use for translation
     - returns: Translated text
     - throws: Error if translation fails
     */
    public func translate(text: String, session: TranslationSession) async throws -> String {
        let response = try await session.translate(text)
        return response.targetText
    }
}
