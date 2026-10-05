//
//  RibbonView.swift
//  cwnu-yiban
//

import UIKit

// 右下角45°斜向的彩带
class RibbonView: UIView {

    // class var: 可以被重写的静态变量
    override class var layerClass: AnyClass { CAShapeLayer.self }

    var width: CGFloat
    var height: CGFloat

    // 切点
    private let cutRatio: CGFloat = 36 / 50

    // Transform效果永远发生在Auto Layout之后，因此文字的frame不会发生变化
    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = "已销假"
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = false   // 放不下时自动缩小字号
        label.minimumScaleFactor = 0.5
        label.translatesAutoresizingMaskIntoConstraints = false

        // 默认绕着中心旋转
        label.transform = CGAffineTransform(rotationAngle: -.pi / 4)
        return label
    }()

    init(color: UIColor, width: CGFloat = 50, height: CGFloat = 50) {
        self.width = width
        self.height = height

        super.init(frame: .zero)
        (layer as! CAShapeLayer).fillColor = color.cgColor
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(textLabel)

        // 这么一堆是为了计算旋转后，文字如何与Ribbon对齐
        // ribbon的宽度：width * cutRatio / 1.4142
        // 要向右下角移动的直线距离： width * cutRatio / 1.4142 / 2
        // 拆解成左右各移动： width * cutRatio / 1.4142 / 2 / 1.4142
        let offset = width * cutRatio / 2 / 2
        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: offset),
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: offset),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 尺寸确定后再画路径
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath()

        // 画Ribbon
        let midX = bounds.minX + bounds.width * cutRatio
        let midY = bounds.minY + bounds.height * cutRatio
        path.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))     // 左下角
        path.addLine(to: CGPoint(x: midX, y: bounds.maxY))         // 底边上的切点
        path.addLine(to: CGPoint(x: bounds.maxX, y: midY))         // 右边上的切点
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))  // 右上角
        path.close()                                               // 连回左下角
        (layer as! CAShapeLayer).path = path.cgPath

    }

    // 确定自己的大小
    override var intrinsicContentSize: CGSize {
    CGSize(width: width, height: height)
    }

    func setColor(_ color: UIColor) {
        (layer as! CAShapeLayer).fillColor = color.cgColor
    }

    func setText(_ text: String) {
        textLabel.text = text
    }
}
