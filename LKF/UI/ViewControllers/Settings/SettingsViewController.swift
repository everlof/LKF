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
import UserNotifications
import MessageUI
import VTAcknowledgementsViewController

class SettingsViewController: UITableViewController {

    static let notificationsKey = "se.everlof.LKF.notificationsEnabled"

    var notificationsEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: SettingsViewController.notificationsKey)
        }
        set {
            if notificationsEnabled != newValue {
                UserDefaults.standard.set(newValue, forKey: SettingsViewController.notificationsKey)

                if newValue {
                    tableView.insertSections(IndexSet(arrayLiteral: 1), with: .fade)
                } else {
                    tableView.deleteSections(IndexSet(arrayLiteral: 1), with: .fade)
                }

                (notificationSettingsCell.accessoryView as! UISwitch).isOn = newValue
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

    lazy var sendMailCell: UITableViewCell = {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = "Kontakta utvecklaren via email"
        return cell
    }()

    lazy var licenseCell: UITableViewCell = {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = "Licenser"
        return cell
    }()

    lazy var footerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 200))
        let lbl = Label()

        lbl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lbl)

        let versionNumber: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let buildNumber: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String

        lbl.text = "Skapad av David\n\n\(versionNumber)-\(buildNumber)"
        lbl.textColor = .lightGreen
        lbl.textStyle = .body
        lbl.textAlignment = .center
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
        (self.notificationSettingsCell.accessoryView as! UISwitch).setOn(notificationsEnabled, animated: true)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appBecameActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    @objc func appBecameActive() {
        tableView.reloadData()
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional:
                    self.notificationsEnabled = true
                case .denied, .notDetermined:
                    self.notificationsEnabled = false
                @unknown default:
                    fatalError()
                }
            }
        }
    }

    @objc func toggleNotifications() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional:
                    self.notificationsEnabled.toggle()
                case .denied:
                    let alert = UIAlertController(title: "Inte tillåtet",
                                                  message: "Appen har inte tillgång till att posta notifikationer, gå in i inställningar för att ändra detta.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Avbryt", style: .cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "Öppna inställningar", style: .default, handler: { _ in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }))
                    alert.view.tintColor = .lightGreen
                    self.present(alert, animated: true, completion: nil)
                    (self.notificationSettingsCell.accessoryView as! UISwitch).setOn(false, animated: true)
                case .notDetermined:
                    var options: UNAuthorizationOptions = [.alert, .sound, .badge]
                    if #available(iOS 12.0, *) {
                        options.insert(.providesAppNotificationSettings)
                    }

                    UNUserNotificationCenter.current().requestAuthorization(options: options) { allow, error in
                        DispatchQueue.main.async {
                            if allow {
                                self.notificationsEnabled = true
                            } else {
                                (self.notificationSettingsCell.accessoryView as! UISwitch).setOn(false, animated: true)
                            }
                        }
                    }
                @unknown default:
                    fatalError()
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            return nil
        default:
            break
        }
        return indexPath
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if notificationsEnabled {
            switch (indexPath.section, indexPath.row) {
            case (0, 0):
                break
            case (1, 0):
                navigationController?.pushViewController(FiltersViewController(), animated: true)
            case (2, 0):
                sendMail()
            case (3, 0):
                showLicenses()
            default:
                fatalError()
            }
        } else {
            switch (indexPath.section, indexPath.row) {
            case (0, 0):
                break
            case (1, 0):
                sendMail()
            case (2, 0):
                showLicenses()
            default:
                fatalError()
            }
        }
    }

    func showLicenses() {
        let path = Bundle.main.path(forResource: "Pods-LKF-acknowledgements", ofType: "plist")!
        navigationController?.pushViewController(VTAcknowledgementsViewController(path: path)!, animated: true)
    }

    func sendMail() {
        guard MFMailComposeViewController.canSendMail() else {
            let alert = UIAlertController(title: "Kan ej skicka mail",
                                          message: "Din klient stödjer inte att skicka email",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            alert.view.tintColor = UIColor.lightGreen
            present(alert, animated: true, completion: nil)
            return
        }

        let compose = MFMailComposeViewController()
        compose.view.tintColor = UIColor.lightGreen
        compose.mailComposeDelegate = self
        compose.setToRecipients(["everlof@gmail.com"])
        compose.setSubject("Ang. LKF app")

        present(compose, animated: true, completion: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return notificationsEnabled ? 4 : 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            switch UIApplication.shared.backgroundRefreshStatus {
            case .available:
                return nil
            case .denied, .restricted:
                return "Appen saknar tillåtelse att hämta objekt i bakgrunden. På grund av detta kan inga notiser om nya objekt levereras."
            @unknown default:
                fatalError()
            }

        }
        return nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if notificationsEnabled {
            switch (indexPath.section, indexPath.row) {
            case (0, 0):
                return notificationSettingsCell
            case (1, 0):
                return configureNotificationsCell
            case (2, 0):
                return sendMailCell
            case (3, 0):
                return licenseCell
            default:
                fatalError()
            }
        } else {
            switch (indexPath.section, indexPath.row) {
            case (0, 0):
                return notificationSettingsCell
            case (1, 0):
                return sendMailCell
            case (2, 0):
                return licenseCell
            default:
                fatalError()
            }
        }
    }

}

extension SettingsViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        switch result {
        case .sent:
            let alert = UIAlertController(title: "Tack!",
                                          message: "Tack för att du tog dig tiden 😊",
                                          preferredStyle: .alert)
            alert.view.tintColor = UIColor.lightGreen
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        default:
            return
        }
    }

}
