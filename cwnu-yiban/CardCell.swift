//
//  CardCell.swift
//  cwnu-yiban
//

import UIKit

class CardCell: UITableViewCell {

    static let reuseIdentifier = "CardCell"

    // 卡片之间的间距
    static let verticalMargin: CGFloat = 12
    static let labelWidth: CGFloat = 64

    private let cardView: UIView = {
        let view = UIView()

        // 设置cardView的.systemBackground: 白色
        view.backgroundColor = .systemBackground

        // 代码布局必加的
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // 创建label
    private static func makeLabel(text: String? = nil, textColor: UIColor, textSize: CGFloat = 16) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: textSize, weight: .light)
        label.textColor = textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    // Label
    private let studentIDLabel = CardCell.makeLabel(text: "学号", textColor: .label)
    private let nameLabel = CardCell.makeLabel(text: "姓名", textColor: .label)
    private let dateLabel = CardCell.makeLabel(text: "请假时间", textColor: .label)
    private let durationLabel = CardCell.makeLabel(text: "请假时长", textColor: .label)
    private let reasonLabel = CardCell.makeLabel(text: "请假原因", textColor: .label)
    private let locationLabel = CardCell.makeLabel(text: "外出地点", textColor: .label)

    // ValueLabel
    private let studentIDValueLabel = CardCell.makeLabel(textColor: .darkGray)
    private let nameValueLabel = CardCell.makeLabel(textColor: .darkGray)
    private let dateValueLabel = CardCell.makeLabel(textColor: .darkGray)
    private let durationValueLabel = CardCell.makeLabel(textColor: .darkGray)
    private let reasonValueLabel = CardCell.makeLabel(textColor: .darkGray)
    private let locationValueLabel = CardCell.makeLabel(textColor: .darkGray)

    // 查看详情
    private let detailButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.title = "查看详情"
    config.image = UIImage(systemName: "chevron.right")
    config.imagePlacement = .trailing 
    config.imagePadding = 2             // 文字和图标的间距
    config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
    config.contentInsets = .zero        // 去掉按钮默认内边距
    let cyan = UIColor(red: 101 / 255, green: 210 / 255, blue: 219 / 255, alpha: 1)
    config.baseForegroundColor = cyan

    // 改字体
    config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
        var attrs = attrs
        attrs.font = .systemFont(ofSize: 14, weight: .light)
        return attrs
    }

    let button = UIButton(configuration: config)
    button.translatesAutoresizingMaskIntoConstraints = false

    // 动画，按钮每次状态变化都会调用一次
    button.configurationUpdateHandler = { button in

        // 比.touchUpInside好用
        if button.isHighlighted {
            button.alpha = 0.2
        } else {
            UIView.animate(withDuration: 0.25) {
                button.alpha = 1
            }
        }
    }

    return button
    }()

    // 右下角的三角形
    private let ribbon = {
        let ribbonView = RibbonView(color: .systemBlue)

        return ribbonView
    }()
    // DONE：把画这两个三角形改为直接画一个Ribbon


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {

        // 设置self的.backgroundCloor：透明
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(cardView)

        // 每一行：标题 + 值，横向排列，间距为?
        let pairs = [
            (studentIDLabel, studentIDValueLabel),
            (nameLabel, nameValueLabel),
            (dateLabel, dateValueLabel),
            (durationLabel, durationValueLabel),
            (reasonLabel, reasonValueLabel),
            (locationLabel, locationValueLabel),
        ]
        
        let rows = pairs.map { title, value in
            // Label固定宽度
            title.widthAnchor.constraint(equalToConstant: Self.labelWidth).isActive = true
            let row = UIStackView(arrangedSubviews: [title, value])
            row.spacing = 10
            return row
        }

        // 所有行纵向排列，行间距为18，左对齐
        let stack = UIStackView(arrangedSubviews: rows)
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 18
        stack.translatesAutoresizingMaskIntoConstraints = false

        // 添加subview
        cardView.addSubview(stack)
        cardView.addSubview(detailButton)
        cardView.addSubview(ribbon)

        NSLayoutConstraint.activate([
            // 左、右（相对contentView）间距为0
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            // 卡片间的间距为12
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Self.verticalMargin),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            // stack左、上、下（相对cardView内部）的间距为16，下边距让card的高度由stack撑开
            stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            stack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),

            detailButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            detailButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),

            // 三角形
            ribbon.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            ribbon.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
        ])
    }

    // 刷新/初始化数据
    func configure(leaveRecord: LeaveRecord = LeaveRecord.example) {
        studentIDValueLabel.text = leaveRecord.studentID
        nameValueLabel.text = leaveRecord.name
        dateValueLabel.text = leaveRecord.date
        durationValueLabel.text = leaveRecord.duration
        reasonValueLabel.text = leaveRecord.reason
        locationValueLabel.text = leaveRecord.location
        // DONE: 根据leaveRecord.checked的值，设置三角形的颜色
        if leaveRecord.checked {
            ribbon.setColor(.systemPurple)
            ribbon.setText("已销假")
        } else {
            ribbon.setColor(.systemBlue)
            ribbon.setText("休假中")
        }
    }
}
