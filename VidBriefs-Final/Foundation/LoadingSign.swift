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
        let customLoadingView = CustomLoadingView()
        customLoadingView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        customLoadingView.startAnimating()
        return customLoadingView
    }
    
    func updateUIView(_ uiView: CustomLoadingView, context: UIViewRepresentableContext<CustomLoadingSwiftUIView>) {
        // The code to update your UIView
    }
}


class CustomLoadingView: UIView {

    private var circleLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        // Explicitly set the center point
        let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)
        // Change this radius to control the size of the circle
        let radius: CGFloat = 50.0

        let circlePath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: 0.0, endAngle: CGFloat(Double.pi * 2), clockwise: true)

        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor.gray.cgColor
        circleLayer.lineWidth = 5.0
        circleLayer.strokeEnd = 0.5
        layer.addSublayer(circleLayer)

        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0
        rotateAnimation.toValue = CGFloat.pi * 2
        rotateAnimation.duration = 1
        rotateAnimation.repeatCount = Float.infinity
        circleLayer.add(rotateAnimation, forKey: nil)
    }



    func startAnimating() {
        isHidden = false
    }

    func stopAnimating() {
        isHidden = true
    }
}
