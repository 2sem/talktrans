//
//  Color+App.swift
//  talktrans
//
//  Created by 영준 이 on 11/17/25.
//  Copyright © 2025 leesam. All rights reserved.
//

import SwiftUI
import UIKit

extension Color {
	// MARK: - Duo Design Tokens

	/// Duo source-speaker accent: "you".
	static var duoYouAccent: Color {
		Color.dynamic(light: 0xE58A00, dark: 0xFFB443)
	}

	/// Duo source-speaker deeper accent for labels and gradients.
	static var duoYouAccentDeep: Color {
		Color.dynamic(light: 0xC67600, dark: 0xFF7A59)
	}

	/// Duo translated-reader accent: "them".
	static var duoThemAccent: Color {
		Color.dynamic(light: 0x0FB5A0, dark: 0x34E0C4)
	}

	/// Duo translated-reader deeper accent for labels and gradients.
	static var duoThemAccentDeep: Color {
		Color.dynamic(light: 0x0C9585, dark: 0x22B8A6)
	}

	static var duoBackground: Color {
		Color.dynamic(light: 0xEEF1F5, dark: 0x0C0E14)
	}

	static var duoSurface: Color {
		Color.dynamic(light: 0xFFFFFF, dark: 0x12151D)
	}

	static var duoElevatedSurface: Color {
		Color.dynamic(light: 0xFFFFFF, dark: 0x161A24)
	}

	static var duoControlSurface: Color {
		Color.dynamic(light: 0xE2E6EC, dark: 0x242A36)
	}

	static var duoTextPrimary: Color {
		Color.dynamic(light: 0x131720, dark: 0xF2F4F8)
	}

	static var duoTextSecondary: Color {
		Color.dynamic(light: 0x3E4453, dark: 0xC5CAD6)
	}

	static var duoTextMuted: Color {
		Color.dynamic(light: 0xA3AAB6, dark: 0x5A6072)
	}

	static var duoDivider: Color {
		Color.dynamic(light: 0xD2D8E0, dark: 0x2A303C)
	}

	static var duoTableThemBackground: Color {
		Color.dynamic(light: 0xDDF7F2, dark: 0x0E3D37)
	}

	static var duoTableThemBackgroundDeep: Color {
		Color.dynamic(light: 0xC9F0E9, dark: 0x0C2E2A)
	}

	static var duoTableYouBackground: Color {
		Color.dynamic(light: 0xFDEFD6, dark: 0x2E2410)
	}

	static var duoTableYouBackgroundDeep: Color {
		Color.dynamic(light: 0xFCE4BE, dark: 0x191007)
	}

	static var duoTableThemText: Color {
		Color.dynamic(light: 0x093E38, dark: 0xEAFBF7)
	}

	static var duoTableYouText: Color {
		Color.dynamic(light: 0x4A3208, dark: 0xFBF3E6)
	}

	private static func dynamic(light: UInt, dark: UInt) -> Color {
		Color(uiColor: UIColor { traitCollection in
			uiColor(hex: traitCollection.userInterfaceStyle == .dark ? dark : light)
		})
	}

	private static func uiColor(hex: UInt) -> UIColor {
		let red = CGFloat((hex >> 16) & 0xFF) / 255
		let green = CGFloat((hex >> 8) & 0xFF) / 255
		let blue = CGFloat(hex & 0xFF) / 255
		return UIColor(red: red, green: green, blue: blue, alpha: 1)
	}

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
