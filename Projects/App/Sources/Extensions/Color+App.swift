//
//  Color+App.swift
//  talktrans
//
//  Created by 영준 이 on 11/17/25.
//  Copyright © 2025 leesam. All rights reserved.
//

import SwiftUI

extension Color {
	// MARK: - Background Colors
	
	/// 배경 그라데이션 시작 색상
	static var appBackgroundGradientStart: Color {
		Color("BackgroundGradientStart")
	}
	
	/// 배경 그라데이션 중간 색상
	static var appBackgroundGradientMid: Color {
		Color("BackgroundGradientMid")
	}
	
	/// 배경 그라데이션 끝 색상
	static var appBackgroundGradientEnd: Color {
		Color("BackgroundGradientEnd")
	}
	
	/// 입력/출력 영역 배경 색상
	static var appInputOutputBackground: Color {
		Color("InputOutputBackground")
	}
	
	// MARK: - Text Colors
	
	/// 주요 텍스트 색상
	static var appTextPrimary: Color {
		Color("TextPrimary")
	}
	
	/// 플레이스홀더 텍스트 색상
	static var appTextPlaceholder: Color {
		Color("TextPlaceholder")
	}
	
	// MARK: - Accent Colors
	
	/// 액센트 색상 (라이트 모드용 단색)
	static var appAccent: Color {
		Color("AccentPrimary")
	}
	
	/// 액센트 그라데이션 시작 색상
	static var appAccentGradientStart: Color {
		Color("AccentGradientStart")
	}
	
	/// 액센트 그라데이션 끝 색상
	static var appAccentGradientEnd: Color {
		Color("AccentGradientEnd")
	}
	
	/// 보조 색상
	static var appSecondary: Color {
		Color("Secondary")
	}
	
	// MARK: - Button Colors
	
	/// 음성 인식 버튼 배경 색상
	static var appSpeechButtonBackground: Color {
		Color("SpeechButtonBackground")
	}
	
	/// 보조 버튼 배경 색상
	static var appSecondaryButton: Color {
		Color("SecondaryButton")
	}
}

