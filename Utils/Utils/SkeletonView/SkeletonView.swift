//
//  SkeletonView.swift
//  Utils
//
//  Created by Александр Чаусов on 21/02/2019.
//  Copyright © 2019 Surf. All rights reserved.
//

import UIKit

/// View for skeleton loaders
open class SkeletonView: UIView {

    // MARK: - Enum

    /// Left or right
    enum ShimmeringDirection {
        case left
        case right
    }

    // MARK: - Properties

    // MARK: Masking

    /// ## Note: Only subviews of current SkeletonView can be added to maskingViews
    var maskingViews: [UIView] = [] {
        didSet {
            setMaskingViews(maskingViews)
        }
    }

    // MARK: Animation time

    var movingAnimationDuration: CFTimeInterval = 0.5
    var delayBetweenAnimationLoops: CFTimeInterval = 1.0

    // MARK: Animation Logic

    /// Property is set to .right by default
    var direction: ShimmeringDirection = .right {
        didSet {
            gradientLayer?.locations = startLocations
        }
    }
    /// Set this property to true to start shimmering
    var shimmering = false {
        didSet {
            if shimmering {
                startAnimating()
            } else {
                stopAnimating()
            }
        }
    }
    /// Ratio of the width of the shimmer to the width of the view (from 0.0 to 1.0)
    var shimmerRatio: Double = 1.0 {
        didSet {
            shimmerRatio = min(max(shimmerRatio, 0.0), 1.0)
            (leftLocations, rightLocations) = configureGradientLocations(for: shimmerRatio)
        }
    }

    // MARK: Colors

    var gradientBackgroundColor: UIColor = UIColor.lightGray.withAlphaComponent(0.7) {
        didSet {
            updateColors()
        }
    }

    var gradientMovingColor: UIColor = UIColor.lightGray.withAlphaComponent(0.1) {
        didSet {
            updateColors()
        }
    }

    // MARK: - Private Properties

    private var leftLocations: [NSNumber] = []
    private var rightLocations: [NSNumber] = []
    private var gradientLayer: CAGradientLayer?

    // MARK: - UIView

    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        configureGradientLayer()
        updateColors()
        maskingViews = subviews
        shimmerRatio = 1.0
        if shimmering {
            startAnimating()
        }
    }

}

// MARK: - Private Methods and Computed Properties

private extension SkeletonView {

    var startLocations: [NSNumber] {
        switch direction {
        case .right:
            return leftLocations
        case .left:
            return rightLocations
        }
    }

    var endLocations: [NSNumber] {
        switch direction {
        case .right:
            return rightLocations
        case .left:
            return leftLocations
        }
    }

    func startAnimating() {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = startLocations
        animation.toValue = endLocations
        animation.duration = movingAnimationDuration
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)

        let animationGroup = CAAnimationGroup()
        animationGroup.duration = movingAnimationDuration + delayBetweenAnimationLoops
        animationGroup.animations = [animation]
        animationGroup.repeatCount = .infinity
        gradientLayer?.add(animationGroup, forKey: animation.keyPath)
    }

    func stopAnimating() {
        gradientLayer?.removeAllAnimations()
    }

    func updateColors() {
        gradientLayer?.colors = [
            gradientBackgroundColor.cgColor,
            gradientMovingColor.cgColor,
            gradientBackgroundColor.cgColor
        ]
    }

    func configureGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.locations = startLocations
        layer.addSublayer(gradientLayer)
        self.gradientLayer = gradientLayer
    }

    func configureGradientLocations(for ratio: Double) -> (left: [NSNumber], right: [NSNumber]) {
        let leftLocations  = [0 - ratio, 0 - ratio / 2.0, 0] as [NSNumber]
        let rightLocations = [1, 1 + ratio / 2.0, 1 + ratio] as [NSNumber]
        return (left: leftLocations, right: rightLocations)
    }

}
