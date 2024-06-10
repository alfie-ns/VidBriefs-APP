//
//  CustomLoadingView.swift
//  Youtube-Summarizer
//
//  Created by Alfie Nurse  on 30/09/2023.
//

import UIKit
import SwiftUI

struct CustomLoadingSwiftUIView: UIViewRepresentable {
    
    func makeUIView(context: UIViewRepresentableContext<CustomLoadingSwiftUIView>) -> CustomLoadingView {
        let customLoadingView = CustomLoadingView() // Create an instance of your UIView
        customLoadingView.frame = CGRect(x: 0, y: 0, width: 50, height: 50) // Set the frame of the UIView
        customLoadingView.startAnimating() // Start animating
        return customLoadingView // Return the instance
    }
    
    func updateUIView(_ uiView: CustomLoadingView, context: UIViewRepresentableContext<CustomLoadingSwiftUIView>) {
        // The code to update your UIView
    }
}


class CustomLoadingView: UIView {

    private var circleLayer = CAShapeLayer() // The layer that will display the circle, private so it can't be accessed outside of this class

    override init(frame: CGRect) { // the initialiser for the UIView, override so we can customise it.
        super.init(frame: frame) // Call the superclass initialiser (UIView) to inherit its properties.
        setupView() // Call the setupView function.
    }

    required init?(coder: NSCoder) { // Initialiser for the UIView when created from a storyboard or XIB, required to conform to NSCoder protocol. '?' indicates that it can return nil.
        super.init(coder: coder) // Call the superclass initialiser (UIView) to inherit its properties.
        setupView() // Call the setupView function to initialise custom view properties.
    }

    private func setupView() { // Function to setup the view
        // Explicitly set the center point
        let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)
        
        let radius: CGFloat = 50.0 // Set the radius of the circle

        let circlePath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: 0.0, endAngle: CGFloat(Double.pi * 2), clockwise: true) // Create a circle path using UIBezierPath

        circleLayer.path = circlePath.cgPath // Set the path of the circleLayer to the circlePath
        circleLayer.fillColor = UIColor.clear.cgColor // Set the fill color of the circleLayer to clear
        circleLayer.strokeColor = UIColor.gray.cgColor // Set the stroke color of the circleLayer to gray
        circleLayer.lineWidth = 5.0 // Set the line width of the circleLayer to 5
        circleLayer.strokeEnd = 0.5 // Set the stroke end of the circleLayer to 0.5
        layer.addSublayer(circleLayer) // Add the circleLayer to the layer of the UIView

        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation") // Create a rotation animation
        rotateAnimation.fromValue = 0 // Set the from value of the rotation animation to start at 0
        rotateAnimation.toValue = CGFloat.pi * 2 // Set the to value of the rotation animation to 2*pi
        rotateAnimation.duration = 1 // Set the duration of the rotation animation to 1 second
        rotateAnimation.repeatCount = Float.infinity // Set the repeat count of the rotation animation to infinity(keep rotating forever)
        circleLayer.add(rotateAnimation, forKey: nil) // Add the rotation animation to the circleLayer
    }



    func startAnimating() { // Function to start animating the circle
        isHidden = false
    }

    func stopAnimating() { // Function to stop animating the circle
        isHidden = true
    }
}
