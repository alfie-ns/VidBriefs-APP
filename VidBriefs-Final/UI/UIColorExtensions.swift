//
//  UIColourExtensions.swift
//  VidBriefs-Final
//
//  Created by Alfie Nurse  on 16/11/2023.
//

import Foundation
import UIKit
import SwiftUI

extension Color {
    static let customCoral = Color(UIColor.gray)
    static let customTeal = Color(UIColor.customTeal)
}

extension UIColor {
    
    static let customCoral = UIColor { traitCollection in
        if traitCollection.userInterfaceStyle == .dark {
            // Darker shade for dark mode
            return UIColor(red: 205/255, green: 92/255, blue: 52/255, alpha: 1)
        } else {
            // Regular coral color
            return UIColor(red: 255/255, green: 127/255, blue: 80/255, alpha: 1)
        }
    }

    static let customTeal = UIColor { traitCollection in
        if traitCollection.userInterfaceStyle == .dark {
            // Darker shade for dark mode
            return UIColor(red: 0/255, green: 98/255, blue: 98/255, alpha: 1)
        } else {
            // Regular teal color
            return UIColor(red: 0/255, green: 128/255, blue: 128/255, alpha: 1)
        }
    }
}
