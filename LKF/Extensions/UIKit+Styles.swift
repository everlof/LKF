import UIKit

// Some commonly reused components

class RoundCornerButton: UIButton {

    static let textAndImageSpacing: CGFloat = 10

    override var intrinsicContentSize: CGSize {
        let parent = super.intrinsicContentSize
        return CGSize(width: parent.width + (RoundCornerButton.textAndImageSpacing * 2), height: parent.height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }

    /// Main action in `FilterViewController`
    static var primaryFilterButton: RoundCornerButton {
        let btn = RoundCornerButton(type: .system)
        btn.setTitle("Stäng", for: .normal)
        btn.layer.borderColor = UIColor.lightGreen.cgColor
        btn.layer.borderWidth = 1
        btn.backgroundColor = UIColor.lightGreen
        btn.setTitleColor(.white, for: .normal)
        btn.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        return btn
    }

    /// Secondary action in `FilterViewController`
    static var secondaryFilterButton: RoundCornerButton {
        let btn = RoundCornerButton(type: .system)
        btn.setTitle("Återställ", for: .normal)
        btn.layer.borderColor = UIColor.lightGreen.cgColor
        btn.layer.borderWidth = 1
        btn.setTitleColor(UIColor.lightGreen, for: .normal)
        btn.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        return btn
    }

}

class TogglableRoundButton: RoundButton {

    var isActive: Bool {
        didSet {
            tintColor = __tintColor()
            backgroundColor = __backgroundColor()
        }
    }

    init(isActive: Bool, text: String, style: Style) {
        self.isActive = isActive
        super.init(text: text, style: style)
        tintColor = __tintColor()
        backgroundColor = __backgroundColor()
    }

    private func __backgroundColor() -> UIColor {
        switch isActive {
        case true:
            return style.backgroundColor
        case false:
            return style.backgroundColor.withAlphaComponent(0.2)
        }
    }

    private func __tintColor() -> UIColor {
        switch isActive {
        case true:
            return style.tintColor
        case false:
            return style.tintColor.withAlphaComponent(0.2)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func animateTouchInactive() {
        super.animateTouchInactive()
        isActive = !isActive
    }

    override func animateTouchActive() {
        super.animateTouchActive()
        isActive = !isActive
    }

}

class RoundButton: UIButton {

    static let scaleOnActive: CGFloat = 1.05

    static let animationDurationWhileActivating: TimeInterval = 0.1

    typealias DelayedAnimationApplicanceBlock = ((CFTimeInterval) -> Void)

    enum Style {
        case prominent
        case discreet

        var backgroundColor: UIColor {
            switch self {
            case .discreet:
                return .white
            case .prominent:
                return .lightGreen
            }
        }

        var tintColor: UIColor {
            switch self {
            case .discreet:
                return .lightGreen
            case .prominent:
                return .white
            }
        }
    }

    fileprivate var style: Style = .prominent

    private let feedback = UISelectionFeedbackGenerator()

    init(text: String, style: Style) {
        self.style = style
        super.init(frame: .zero)

        tintColor = style.tintColor
        backgroundColor = style.backgroundColor
        adjustsImageWhenHighlighted = false

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 2.0
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)

        setTitle(text, for: .normal)
        addTarget(self, action: #selector(animateTouchActive), for: .touchDown)
        addTarget(self, action: #selector(toggled), for: .touchUpInside)
        addTarget(self, action: #selector(animateTouchInactive), for: .touchUpOutside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 56, height: 56)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }

    @objc fileprivate func animateTouchActive() {
        feedback.prepare()
        feedback.selectionChanged()

        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
        animation.duration = RoundButton.animationDurationWhileActivating
        transform = CGAffineTransform.identity.scaledBy(x: RoundButton.scaleOnActive, y: RoundButton.scaleOnActive).translatedBy(x: 0, y: -2)
        layer.add(animation, forKey: "scaleUp")

        let cornerRadiusAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.cornerRadius))
        cornerRadiusAnimation.duration = RoundButton.animationDurationWhileActivating
        layer.cornerRadius = (bounds.height / 2) * RoundButton.scaleOnActive
        layer.add(cornerRadiusAnimation, forKey: "radius")

        let shadowOffsetAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.shadowOffset))
        shadowOffsetAnimation.duration = RoundButton.animationDurationWhileActivating
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.add(shadowOffsetAnimation, forKey: "offset")
    }

    @objc fileprivate func toggled() {
        feedback.prepare()
        feedback.selectionChanged()

        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
        animation.duration = RoundButton.animationDurationWhileActivating
        transform = CGAffineTransform.identity
        layer.add(animation, forKey: "scaleUp")

        let cornerRadiusAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.cornerRadius))
        cornerRadiusAnimation.duration = RoundButton.animationDurationWhileActivating
        layer.cornerRadius = bounds.height / 2
        layer.add(cornerRadiusAnimation, forKey: "radius")

        let shadowOffsetAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.shadowOffset))
        shadowOffsetAnimation.duration = RoundButton.animationDurationWhileActivating
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.add(shadowOffsetAnimation, forKey: "offset")
    }

    @objc fileprivate func animateTouchInactive() {
        feedback.prepare()
        feedback.selectionChanged()

        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
        animation.duration = RoundButton.animationDurationWhileActivating
        transform = CGAffineTransform.identity
        layer.add(animation, forKey: "scaleUp")

        let cornerRadiusAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.cornerRadius))
        cornerRadiusAnimation.duration = RoundButton.animationDurationWhileActivating
        layer.cornerRadius = bounds.height / 2
        layer.add(cornerRadiusAnimation, forKey: "radius")

        let shadowOffsetAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.shadowOffset))
        shadowOffsetAnimation.duration = RoundButton.animationDurationWhileActivating
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.add(shadowOffsetAnimation, forKey: "offset")
    }

    @discardableResult
    public func visible(_ isVisible: Bool, animated: Bool) -> DelayedAnimationApplicanceBlock? {
        let nextTransform = isVisible ?
            CGAffineTransform.identity :
            CGAffineTransform.identity.translatedBy(x: 100, y: 0).rotated(by: -CGFloat.pi/2)

        // Don't do anything if current transform is expected one
        guard nextTransform != transform else {
            // Nothing to do
            return nil
        }

        guard animated else {
            // Ah, not animated, just change
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            transform = nextTransform
            CATransaction.commit()
            return nil
        }

        // Give a block back that will perform the animation, with a delayed execution
        return { delay in
            self.transform = nextTransform
            let animation = CASpringAnimation(keyPath: #keyPath(CALayer.transform))
            animation.mass = 0.5
            animation.fillMode = .backwards // Need since we modify `beginTime`
            animation.beginTime = CACurrentMediaTime() + delay
            animation.duration = animation.settlingDuration
            self.layer.add(animation, forKey: "visibility")
        }
    }

}

extension UILabel {

    static var distanceLabel: UILabel {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 12)
        lbl.textColor = .lightGreen
        return lbl
    }

}

class FilterButton: RoundButton {

    let badgeRadius: CGFloat = 6

    lazy var shapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        self.layer.addSublayer(layer)
        return layer
    }()

    var hasFilter: Bool = false {
        didSet {
            update()
        }
    }

    var size: CGSize = .zero {
        didSet {
            guard oldValue != size else { return }
            update()
        }
    }

    override init(text: String, style: Style) {
        super.init(text: text, style: style)
        update()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update() {
        shapeLayer.frame = bounds
        shapeLayer.fillColor = hasFilter ? UIColor.red.cgColor : nil
        shapeLayer.strokeColor = hasFilter ? UIColor.white.cgColor : nil
        shapeLayer.lineWidth = 1

        let radius = shapeLayer.frame.maxX / 2
        var mid = CGPoint(x: radius, y: radius)

        // Move it to π/4 on the circle
        mid.x += (CGFloat(cos(Double.pi / 4)) * radius) - badgeRadius
        mid.y -= (CGFloat(sin(Double.pi / 4)) * radius) + badgeRadius
        shapeLayer.path = UIBezierPath(ovalIn: CGRect(origin: mid, size: CGSize(width: 2 * badgeRadius, height: 2 * badgeRadius))).cgPath
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        size = frame.size
    }

}
