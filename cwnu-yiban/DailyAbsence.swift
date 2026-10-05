//
//  DailyAbsence.swift
//  cwnu-yiban
//
//  Created by Ar2c on 2/9/2026.
//

import UIKit

class DailyAbsence: UITableViewController {

    // 启动时从文件读取；数组有任何变化（新增、删除、修改、复制）都自动保存
    private var items: [LeaveRecord] = LeaveRecordStore.load() {
        didSet {
            LeaveRecordStore.save(items)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "日常请假"

        // - MARK: - 导航栏

        // 撰写主标题
        let titleLabel = UILabel()
        titleLabel.text = "日常请假"
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.textColor = .white

        // 撰写副标题
        let subtitleLabel = UILabel()
        subtitleLabel.text = "xgyd.cwnu.edu.cn"
        subtitleLabel.font = .systemFont(ofSize: 10)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.8)

        // 将主标题和副标题，都注册到titleView中
        let titleStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        titleStack.axis = .vertical
        titleStack.alignment = .center
        navigationItem.titleView = titleStack

        // ”返回“按钮，暂不需要执行任何操作
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .white
        navigationItem.leftBarButtonItem = backButton

        // “更多”按钮，暂不需要执行任何操作
        let moreButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(moreButtonTapped))
        moreButton.tintColor = .white
        navigationItem.rightBarButtonItem = moreButton

        // 定义Titlebar的appearance和背景
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 124 / 255, green: 174 / 255, blue: 244 / 255, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]

        // 确保无论在滚动还是非滚动时，titlebar的背景都是蓝色
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance

        // - MARK: - 工具栏

        // 定义Toolbar的appearance和背景
        let toolbarAppearance = UIToolbarAppearance()
        toolbarAppearance.configureWithOpaqueBackground()

        // 画一张从左到右渐变的图片作为背景，系统会把它拉伸铺满toolbar
        let gradientColors = [
            UIColor(red: 129 / 255, green: 223 / 255, blue: 218 / 255, alpha: 1).cgColor,  // 左
            UIColor(red: 102 / 255, green: 180 / 255, blue: 243 / 255, alpha: 1).cgColor,  // 右
        ]
        let gradientSize = CGSize(width: 256, height: 1)
        toolbarAppearance.backgroundImage = UIGraphicsImageRenderer(size: gradientSize).image { context in
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors as CFArray, locations: [0, 1])!
            context.cgContext.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: gradientSize.width, y: 0), options: [])
        }
        navigationController?.setToolbarHidden(false, animated: false)

        // 确保无论在滚动还是非滚动时，toolbar的背景都是蓝色
        navigationController?.toolbar.standardAppearance = toolbarAppearance
        navigationController?.toolbar.compactAppearance = toolbarAppearance
        navigationController?.toolbar.scrollEdgeAppearance = toolbarAppearance


        // “添加”按钮。使得这个按钮居中
        let addButton = UIBarButtonItem(title: "提交请假", style: .plain, target: self, action: #selector(addButtonTapped))
        addButton.tintColor = .white
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [flexibleSpace, addButton, flexibleSpace]

        // tableView相关
        tableView.register(CardCell.self, forCellReuseIdentifier: CardCell.reuseIdentifier)

        // cell的高度由其内部约束自动计算
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.backgroundColor = .secondarySystemBackground
    }

    // 设置statusBarStyle为白色
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    // “返回”按钮按下后执行的动作
    @objc private func backButtonTapped() {
    }

    // “更多”按钮按下后执行的动作
    @objc private func moreButtonTapped() {
    }

    // “添加”按钮按下后执行的动作
    @objc private func addButtonTapped() {
        presentForm(record: nil) { [weak self] record in
            guard let self else { return }
            self.items.append(record)
            self.tableView.insertRows(at: [IndexPath(row: self.items.count - 1, section: 0)], with: .automatic)
        }
    }

    // 弹出请假表单。record为nil时是新增，否则是修改；用户点“完成”后调用onComplete
    private func presentForm(record: LeaveRecord?, onComplete: @escaping (LeaveRecord) -> Void) {
        let formVC = LeaveRecordFormViewController(record: record)
        formVC.onComplete = onComplete

        let navController = UINavigationController(rootViewController: formVC)
        if let sheet = navController.sheetPresentationController {
            // 7行表单加上键盘，半屏放不下，改为全屏
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        present(navController, animated: true)
    }

    // MARK: - Table view 
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CardCell.reuseIdentifier, for: indexPath) as! CardCell
        let item = items[indexPath.row]

        // 每次cell被滑出屏幕再滑回来时，都会执行一次
        cell.configure(leaveRecord: item)
        return cell
    }

    // 点击卡片，弹出表单修改这条记录
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        presentForm(record: items[indexPath.row]) { [weak self] record in
            guard let self else { return }
            // 先改数据，再通知tableView刷新这一行
            self.items[indexPath.row] = record
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }

    // 从右往左滑，露出“删除”和“复制”按钮
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "删除") { [weak self] _, _, completion in
            guard let self else { return }
            // 先删数据，再通知tableView删除这一行，两者数量必须对得上
            self.items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }

        let duplicateAction = UIContextualAction(style: .normal, title: "复制") { [weak self] _, _, completion in
            guard let self else { return }
            // LeaveRecord是结构体，插入时会自动复制一份，修改副本不会影响原记录
            let newIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
            self.items.insert(self.items[indexPath.row], at: newIndexPath.row)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            completion(true)
        }
        duplicateAction.backgroundColor = .systemBlue

        // 数组里第一个按钮在最右边，一直滑到底时执行的也是它
        return UISwipeActionsConfiguration(actions: [deleteAction, duplicateAction])
    }
}

extension UINavigationController {
    // 用于告诉navController：statusBarStyle去问最顶上的那个vc要(topVC)
    open override var childForStatusBarStyle: UIViewController? {
        topViewController
    }
}

