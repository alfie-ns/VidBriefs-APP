import SwiftUI
import UIKit

// A custom UIViewRepresentable that wraps a custom loading view

struct CustomLoadingSwiftUIView: UIViewRepresentable {
    
    // Creates the initial UIView instance
    func makeUIView(context: UIViewRepresentableContext<CustomLoadingSwiftUIView>) -> CustomLoadingView {
        let customLoadingView = CustomLoadingView()
        // Set the frame of the loading view to a 50x50 square
        customLoadingView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        // Start animating the loading view immediately
        customLoadingView.startAnimating()
        return customLoadingView
    }
    
    // Updates the UIView instance when the SwiftUI view updates
    func updateUIView(_ uiView: CustomLoadingView, context: UIViewRepresentableContext<CustomLoadingSwiftUIView>) {
        // Add code here to update the UIView based on changes in the SwiftUI view
    }
}

class CustomLoadingView: UIView {
    
    // The layer that draws the circular loading animation
    private var circleLayer = CAShapeLayer()
    
    // Initializes the loading view with a given frame
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    // Initializes the loading view from a decoder (required for Interface Builder)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // Sets up the loading view by creating and configuring the circular loading animation
    private func setupView() {
        // Calculate the center point of the view
        let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)
        // Define the radius of the circular loading animation
        let radius: CGFloat = 50.0
        
        // Create a circular path for the loading animation
        let circlePath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: 0.0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
        
        // Configure the circle layer's path, colors, and line width
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor.red.cgColor
        circleLayer.lineWidth = 5.0
        circleLayer.strokeEnd = 0.5
        
        // Add the circle layer to the view's layer hierarchy
        layer.addSublayer(circleLayer)
        
        // Create a rotation animation for the circle layer
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0
        rotateAnimation.toValue = CGFloat.pi * 2
        rotateAnimation.duration = 1
        rotateAnimation.repeatCount = Float.infinity
        
        // Add the rotation animation to the circle layer
        circleLayer.add(rotateAnimation, forKey: nil)
    }
    
    // Starts animating the loading view by showing it
    func startAnimating() {
        isHidden = false
    }
    
    // Stops animating the loading view by hiding it
    func stopAnimating() {
        isHidden = true
    }
}