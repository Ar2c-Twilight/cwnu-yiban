//
//  LeaveRecordFormViewController.swift
//  cwnu-yiban
//

import UIKit

// 请假记录表单，新增和修改共用：创建时传入record就是修改，不传就是新增
class LeaveRecordFormViewController: UITableViewController {

    var onComplete: ((LeaveRecord) -> Void)?

    // 要修改的记录；为nil表示新增
    private let record: LeaveRecord?

    private let studentIDField = UITextField()
    private let nameField = UITextField()
    private let dateField = UITextField()
    private let durationField = UITextField()
    private let reasonField = UITextField()
    private let locationField = UITextField()
    private let checkedSwitch = UISwitch()

    // 每个输入框对应的标题
    private var fieldRows: [(title: String, field: UITextField)] {
        [
            ("学号", studentIDField),
            ("姓名", nameField),
            ("请假时间", dateField),
            ("请假时长", durationField),
            ("请假原因", reasonField),
            ("外出地点", locationField),
        ]
    }

    // 表单只有几行，cell在viewDidLoad里一次性建好，不复用，输入的内容就不会丢
    private var fieldCells: [UITableViewCell] = []
    private let checkedCell = UITableViewCell()

    init(record: LeaveRecord? = nil) {
        self.record = record
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = record == nil ? "新增请假" : "修改请假"

        // navigationBar
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(doneTapped))

        // 第一组：6个输入框
        fieldCells = fieldRows.map { title, field in
            Self.makeFieldCell(title: title, field: field)
        }

        // 第二组：“已销假”开关，放在cell右侧
        var content = checkedCell.defaultContentConfiguration()
        content.text = "已销假"
        checkedCell.contentConfiguration = content
        checkedCell.accessoryView = checkedSwitch
        checkedCell.selectionStyle = .none

        // 修改模式：用原记录填充表单
        if let record {
            studentIDField.text = record.studentID
            nameField.text = record.name
            dateField.text = record.date
            durationField.text = record.duration
            reasonField.text = record.reason
            locationField.text = record.location
            checkedSwitch.isOn = record.checked
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 只在新增时自动弹出键盘
        if record == nil {
            studentIDField.becomeFirstResponder()
        }
    }

    // 一行输入：标题作为placeholder，输入框为空时以灰色显示，有内容时自动隐去
    private static func makeFieldCell(title: String, field: UITextField) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none

        field.placeholder = title
        field.clearButtonMode = .whileEditing
        field.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(field)

        // layoutMarginsGuide：cell自带的内边距，和系统设置页的间距一致
        let margins = cell.contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            field.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            field.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            field.topAnchor.constraint(equalTo: margins.topAnchor),
            field.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
        ])
        return cell
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func doneTapped() {
        let record = LeaveRecord(
            studentID: studentIDField.text ?? "",
            name: nameField.text ?? "",
            date: dateField.text ?? "",
            duration: durationField.text ?? "",
            reason: reasonField.text ?? "",
            location: locationField.text ?? "",
            checked: checkedSwitch.isOn
        )
        guard !record.studentID.isEmpty else { return }

        onComplete?(record)
        dismiss(animated: true)
    }

    // MARK: - Table view
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? fieldCells.count : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        indexPath.section == 0 ? fieldCells[indexPath.row] : checkedCell
    }

    // 点击输入行的任意位置，都让输入框获得焦点
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            fieldRows[indexPath.row].field.becomeFirstResponder()
        }
    }
}
