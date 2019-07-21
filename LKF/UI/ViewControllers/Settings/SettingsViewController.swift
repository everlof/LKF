// MIT License
//
// Copyright (c) 2018 David Everlöf
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit


class SettingsViewController: UITableViewController {

    let notificationsKey = "se.everlof.LKF.notificationsEnabled"

    var notificationsEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: notificationsKey)
        }
        set {
            if notificationsEnabled != newValue {
                UserDefaults.standard.set(newValue, forKey: notificationsKey)

                if newValue {
                    tableView.insertSections(IndexSet(arrayLiteral: 1), with: .fade)
                } else {
                    tableView.deleteSections(IndexSet(arrayLiteral: 1), with: .fade)
                }
            }
        }
    }

    lazy var notificationSettingsCell: UITableViewCell = {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = "Notiser"
        let uiSwitch = UISwitch(frame: .zero)
        cell.accessoryView = uiSwitch
        uiSwitch.isOn = self.notificationsEnabled
        uiSwitch.addTarget(self, action: #selector(toggleNotifications), for: .valueChanged)
        return cell
    }()

    lazy var configureNotificationsCell: UITableViewCell = {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = "Filter"
        cell.accessoryType = .disclosureIndicator
        return cell
    }()

    lazy var footerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 200))
        let lbl = Label()

        lbl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lbl)

        lbl.text = "Skapad av David\n"
        lbl.textColor = .lightGreen
        lbl.textStyle = .body
        lbl.numberOfLines = 0

        lbl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        lbl.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        return view
    }()

    init() {
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Inställningar"
        tableView.tableFooterView = footerView
    }

    @objc func toggleNotifications() {
        notificationsEnabled.toggle()
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            return nil
        case (1, 0):
            return indexPath
        default:
            fatalError()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (1, 0):
            navigationController?.pushViewController(FiltersViewController(), animated: true)
        default:
            fatalError()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return notificationsEnabled ? 2 : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            return notificationSettingsCell
        case (1, 0):
            return configureNotificationsCell
        default:
            fatalError()
        }
    }

}
