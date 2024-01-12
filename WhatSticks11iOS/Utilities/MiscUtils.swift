//
//  MiscUtils.swift
//  WhatSticks11iOS
//
//  Created by Nick Rodriguez on 07/12/2023.
//

import UIKit

extension UIImage {
    func scaleImage(toSize newSize: CGSize) -> UIImage? {
        var newImage: UIImage?
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        if let context = UIGraphicsGetCurrentContext(), let cgImage = self.cgImage {
            context.interpolationQuality = .high
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
            context.concatenate(flipVertical)
            context.draw(cgImage, in: newRect)
            if let img = context.makeImage() {
                newImage = UIImage(cgImage: img)
            }
            UIGraphicsEndImageContext()
        }
        return newImage
    }
}


func widthFromPct(percent:Float) -> CGFloat {
    let screenWidth = UIScreen.main.bounds.width
    let width = screenWidth * CGFloat(percent/100)
    return width
}

func heightFromPct(percent:Float) -> CGFloat {
    let screenHeight = UIScreen.main.bounds.height
    let height = screenHeight * CGFloat(percent/100)
    return height
}


class PaddedTextField: UITextField {
    var textPadding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10) // Adjust padding as needed

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }
}

func formatWithCommas(number: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
}


extension UIColor {
    static func wsBlueFromDecimal(_ value: CGFloat) -> UIColor {
        // Clamp the value between 0 and 1
        let clampedValue = min(max(value, 0), 1)
        // Define the start and end colors
        let startColor = UIColor.lightGray
        let endColor = UIColor(red: 89/255.0, green: 135/255.0, blue: 224/255.0, alpha: 1)// Blue hex: 5987E0
        // Interpolate between the colors
        let redValue = interpolate(start: startColor.components.red, end: endColor.components.red, value: clampedValue)
        let greenValue = interpolate(start: startColor.components.green, end: endColor.components.green, value: clampedValue)
        let blueValue = interpolate(start: startColor.components.blue, end: endColor.components.blue, value: clampedValue)
        return UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1)
    }
    static func wsYellowFromDecimal(_ value: CGFloat) -> UIColor {
        let valueInverse = value * -1// expected to make value positive
        // Clamp the value between 0 and 1
        let clampedValue = min(max(valueInverse, 0), 1)
        // Define the start and end colors
        let startColor = UIColor.lightGray
        let endColor = UIColor(red: 241/255.0, green: 181/255.0, blue: 14/255.0, alpha: 1)// Yellow hex: F1B50E
        // Interpolate between the colors
        let redValue = interpolate(start: startColor.components.red, end: endColor.components.red, value: clampedValue)
        let greenValue = interpolate(start: startColor.components.green, end: endColor.components.green, value: clampedValue)
        let blueValue = interpolate(start: startColor.components.blue, end: endColor.components.blue, value: clampedValue)
        return UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1)
    }
    private static func interpolate(start: CGFloat, end: CGFloat, value: CGFloat) -> CGFloat {
        return start + (end - start) * value
    }
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }
}


func timeStampsForFileNames() -> String {
    let currentDate = Date()
    let dateFormatter = DateFormatter()
    // Set the date format
    dateFormatter.dateFormat = "yyyyMMdd-HHmm"
    // Get the date string
    let dateString = dateFormatter.string(from: currentDate)
    return dateString
}


func loadTimezones() -> [String] {
    var timezones: [String] = []
    // Assuming you've added timezones.txt to your project
    if let path = Bundle.main.path(forResource: "timezones", ofType: "txt") {
        do {
            let data = try String(contentsOfFile: path, encoding: .utf8)
            timezones = data.components(separatedBy: .newlines)
        } catch {
            print(error)
        }
    }
    return timezones
}



