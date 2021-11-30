//
//  Themes.swift
//  Chat
//
//  Created by Сергей on 10.10.2021.
//

import UIKit

enum Themes: Int {
	case light = 1
	case dark = 2
	case darkBlue = 3
	case pink = 4
}

struct Theme {
	
	static var theme: Themes = .light
	
}

struct ThemeColor {
	
	let dark: UIColor
	let light: UIColor
	let darkBlue: UIColor
	let pink: UIColor
	
	func uiColor() -> UIColor {
		return colorWith(theme: Theme.theme)
	}
	
	func cgColor() -> CGColor {
		return uiColor().cgColor
	}
	
	private func colorWith(theme: Themes) -> UIColor {
		switch theme {
		case .dark: return dark
		case .light: return light
		case .darkBlue: return darkBlue
		case .pink: return pink
		}
	}
	
}

enum TableViewAppearance {
	
	static let backgroundColor = ThemeColor(dark: Dark.backgroundColor, light: Light.backgroundColor, darkBlue: DarkBlue.backgroundColor, pink: Pink.backgroundColor)
	
	static let headerTitleColor = ThemeColor(dark: Dark.headerTitleColor, light: Light.headerTitleColor, darkBlue: DarkBlue.headerTitleColor, pink: Pink.headerTitleColor)
	
	private enum Light {
		static let backgroundColor = UIColor(red: 242 / 255, green: 242 / 255, blue: 243 / 255, alpha: 1.0)
		static let headerTitleColor = UIColor.darkGray
	}
	
	private enum Dark {
		static let backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
		static let headerTitleColor = UIColor.lightGray
	}
	
	private enum DarkBlue {
		static let backgroundColor = UIColor(red: 25 / 255, green: 35 / 255, blue: 49 / 255, alpha: 1.0)
		static let headerTitleColor = UIColor.lightGray
	}
	
	private enum Pink {
		static let backgroundColor = UIColor(red: 218 / 255, green: 185 / 255, blue: 227 / 255, alpha: 1.0)
		static let headerTitleColor = UIColor(red: 45 / 255, green: 115 / 255, blue: 114 / 255, alpha: 1.0)
	}
	
}

enum TableViewCellAppearance {
	
	static let backgroundColor = ThemeColor(dark: Dark.backgroundColor, light: Light.backgroundColor, darkBlue: DarkBlue.backgroundColor, pink: Pink.backgroundColor)
	
	static let textColor = ThemeColor(dark: Dark.textColor, light: Light.textColor, darkBlue: DarkBlue.textColor, pink: Pink.textColor)
	
	private enum Light {
		static let backgroundColor = UIColor.white
		static let textColor = UIColor.black
	}
	
	private enum Dark {
		static let backgroundColor = UIColor.black
		static let textColor = UIColor.white
	}
	
	private enum DarkBlue {
		static let backgroundColor = UIColor(red: 19 / 255, green: 25 / 255, blue: 34 / 255, alpha: 1.0)
		static let textColor = UIColor.white
	}
	
	private enum Pink {
		static let backgroundColor = UIColor(red: 223 / 255, green: 204 / 255, blue: 227 / 255, alpha: 1.0)
//		static let backgroundColor = UIColor(red: 218 / 255, green: 185 / 255, blue: 227 / 255, alpha: 1.0)
		static let textColor = UIColor(red: 45 / 255, green: 115 / 255, blue: 114 / 255, alpha: 1.0)
	}
	
}

enum NavigationBarAppearance {
	
	static let backgroundColor = ThemeColor(dark: Dark.backgroundColor, light: Light.backgroundColor, darkBlue: DarkBlue.backgroundColor, pink: Pink.backgroundColor)
	
	static let elementsColor = ThemeColor(dark: Dark.elementsColor, light: Light.elementsColor, darkBlue: DarkBlue.elementsColor, pink: Pink.elementsColor)
	
	private enum Light {
		static let backgroundColor = UIColor(red: 242 / 255, green: 242 / 255, blue: 243 / 255, alpha: 1)
		static let elementsColor = UIColor.black
	}
	
	private enum Dark {
		static let backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
		static let elementsColor = UIColor.white
	}
	
	private enum DarkBlue {
		static let backgroundColor = UIColor(red: 25 / 255, green: 35 / 255, blue: 49 / 255, alpha: 1)
		static let elementsColor = UIColor.white
	}
	
	private enum Pink {
		static let backgroundColor = UIColor(red: 218 / 255, green: 185 / 255, blue: 227 / 255, alpha: 1.0)
		static let elementsColor = UIColor(red: 87 / 255, green: 16 / 255, blue: 106 / 255, alpha: 1)
	}
	
}
