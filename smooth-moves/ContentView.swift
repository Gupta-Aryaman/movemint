import UIKit
import FirebaseDatabaseInternal
import SwiftUI
import Supabase
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import Foundation
import SwiftData

struct MyViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ViewController {
        
        return ViewController()
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
    }
}

struct ContentView: View {
    
    @Environment(\.modelContext) private var context
    
    @Query private var items:  [Data]
    
    var body: some View {
        MyViewControllerWrapper()
    }
}

struct ButtonShortcut {
    var shortcutName: String
}

var buttonOptions = [String: Set<String>]()

class CustomDropdownButton: UIButton {
    var parentButtonObj: UIButton = UIButton()
    
}
struct shortcutTable: Decodable {
    let shortcut_list: [String]
}

class removedShortcutButton: UIButton{
    var dropDownButtonObj: CustomDropdownButton = CustomDropdownButton()
}

//var supabaseURI: String = {
//    if let uri = ProcessInfo.processInfo.environment["SUPABASE_URI"] {
//        return uri
//    } else {
//        return "URI Not Found"
//    }
//}()
//
//var supabaseKEY: String = {
//    if let key = ProcessInfo.processInfo.environment["SUPABASE_KEY"] {
//        return key
//    } else {
//        return "Key Not Found"
//    }
//}()
//
//
//
//let client = SupabaseClient(supabaseURL: URL(string: supabaseURI)!, supabaseKey: supabaseKEY)
//


let client = SupabaseClient(supabaseURL: URL(string: "https://sdnughqozcihjgayznuf.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkbnVnaHFvemNpaGpnYXl6bnVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDk4MDE1MTEsImV4cCI6MjAyNTM3NzUxMX0.KQWPMpj-CWPAVExhwJ6yDG_17lAKkNAizmNvMmHytWs")



var forbiddenOptionsList = [String]()
var options = [String]()
var buttonMappingDict = [String: String]()

var commandButtonList = [UIButton]()



class ViewController: UIViewController, NSUserActivityDelegate, UIApplicationDelegate {

    let defaults = UserDefaults.standard
    let buttonX: CGFloat = 50
    var buttonY: CGFloat = 150
    let buttonWidth: CGFloat = 250
    let buttonHeight: CGFloat = 50
    let spacing: CGFloat = 15
    var vert: CGFloat = 150
    var buttonTypes = ["push", "pull", "smile", "blink left eye", "blink right eye"]
    var ref: DatabaseReference!
    var UUID: String = ""
    let uuidKey = "vaibhav.smooth-moves"
//    self.UUID = NSUUID().uuidString
//    cache.setObject(UUID, forKey: "UUID")
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        FirebaseApp.configure()
//        if let databaseURL = ProcessInfo.processInfo.environment["ref"] {
//            self.ref = Database.database(url: databaseURL).reference()
//        } else {
//
//            print("Error: Environment variable 'ref' not found.")
//        }
        self.getUUID()
        ref = Database.database(url: "https://smooth-moves-7b7a2-default-rtdb.firebaseio.com/").reference()
        Task {
            await monitorFirebase()
        }
        
        view.backgroundColor = UIColor.black
        
        let titleLabel = UILabel()
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let attributedText = NSMutableAttributedString(string: "Smooth Moves")
        let regularFont = UIFont.systemFont(ofSize: 32, weight: .thin)
        let biggerFont = UIFont.systemFont(ofSize: 32, weight: .bold)
        attributedText.addAttribute(.font, value: regularFont, range: NSRange(location: 0, length: 6))
        attributedText.addAttribute(.font, value: biggerFont, range: NSRange(location: 7, length: 5))
        titleLabel.attributedText = attributedText
        
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25).isActive = true
        titleLabel.widthAnchor.constraint(equalToConstant: 250).isActive = true
        
        titleLabel.transform = CGAffineTransform(translationX: -view.bounds.width, y: 0)
        UIView.animate(withDuration: 1.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.4, options: [], animations: {
            titleLabel.transform = .identity
            titleLabel.alpha = 1
        }, completion: nil)
        
        let plusButton = UIButton(type: .system)
        plusButton.setTitle("+", for: .normal)
        plusButton.setTitleColor(.systemBlue, for: .normal)
        plusButton.titleLabel?.font = UIFont.systemFont(ofSize: 48, weight: .light)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.addTarget(self, action: #selector(createSiriShortcut(_:)), for: .touchUpInside)
        view.addSubview(plusButton)
        
        plusButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        plusButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25).isActive = true
        plusButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        plusButton.transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
        UIView.animate(withDuration: 1.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.4, options: [], animations: {
            plusButton.transform = .identity
            plusButton.alpha = 1
        }, completion: nil)
        
        let runSiriShortcutButton = UIButton(type: .system)
        runSiriShortcutButton.setTitle("Run Siri Shortcut", for: .normal)
        runSiriShortcutButton.setTitleColor(.systemBlue, for: .normal)
        runSiriShortcutButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        runSiriShortcutButton.titleLabel?.numberOfLines = 0
        runSiriShortcutButton.titleLabel?.lineBreakMode = .byWordWrapping
        runSiriShortcutButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        runSiriShortcutButton.layer.cornerRadius = 28
        runSiriShortcutButton.translatesAutoresizingMaskIntoConstraints = false
        runSiriShortcutButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        runSiriShortcutButton.addTarget(self, action: #selector(runSiriShortcutButton(_:)), for: .touchUpInside)
        view.addSubview(runSiriShortcutButton)
        
        NSLayoutConstraint.activate([
            runSiriShortcutButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            runSiriShortcutButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            runSiriShortcutButton.widthAnchor.constraint(equalToConstant: 175),
            runSiriShortcutButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 55)
        ])
        
        runSiriShortcutButton.transform = CGAffineTransform(translationX: -50, y: 0)
        runSiriShortcutButton.alpha = 0
        
        UIView.animate(withDuration: 1.5, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            runSiriShortcutButton.transform = .identity
            runSiriShortcutButton.alpha = 1
        }, completion: nil)
        
        let importButton = UIButton(type: .system)
        importButton.setTitle("Import Shortcuts", for: .normal)
        importButton.setTitleColor(.systemBlue, for: .normal)
        importButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        importButton.titleLabel?.numberOfLines = 0
        importButton.titleLabel?.lineBreakMode = .byWordWrapping
        importButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        importButton.layer.cornerRadius = 28
        importButton.translatesAutoresizingMaskIntoConstraints = false
        importButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        importButton.addTarget(self, action: #selector(importButtonPressed(_:)), for: .touchUpInside)
        view.addSubview(importButton)
        
        NSLayoutConstraint.activate([
            importButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            importButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            importButton.widthAnchor.constraint(equalToConstant: 175),
            importButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 55),
            importButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        importButton.transform = CGAffineTransform(translationX: 50, y: 0)
        importButton.alpha = 0
        
        UIView.animate(withDuration: 1.5, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            importButton.transform = .identity
            importButton.alpha = 1
        }, completion: nil)
        
        let actionsButton = UIButton(type: .system)
        actionsButton.setTitle("Actions  ▼", for: .normal)
        actionsButton.setTitleColor(.systemBlue, for: .normal)
        actionsButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        actionsButton.titleLabel?.numberOfLines = 0
        actionsButton.titleLabel?.lineBreakMode = .byWordWrapping
        actionsButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        actionsButton.layer.cornerRadius = 28
        actionsButton.translatesAutoresizingMaskIntoConstraints = false
        actionsButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        actionsButton.addTarget(self, action: #selector(actionsButtonPressed(_:)), for: .touchUpInside)
        view.addSubview(actionsButton)
        
        actionsButton.transform = CGAffineTransform(translationX: 0, y: 50)
        actionsButton.alpha = 0
        
        NSLayoutConstraint.activate([
            actionsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            actionsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            actionsButton.widthAnchor.constraint(equalToConstant: 120),
            actionsButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        UIView.animate(withDuration: 1.2, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            actionsButton.transform = .identity
            actionsButton.alpha = 1
        }, completion: nil)
    }
    
    
    @objc func importButtonPressed(_ sender: UIButton) {
        Task {
            await getShortcutsList()
        }
        NotificationView.showNotification(message: "Shortcuts imported successfully!", backgroundColor: UIColor.systemYellow)
    }
    
    @objc func createSiriShortcut(_ sender: UIButton) {
        print("Button \(sender.title(for: .normal) ?? "") tapped.")
        
        guard let buttonName = sender.title(for: .normal) else { return }
            if let shortcutURL = URL(string: "https://www.icloud.com/shortcuts/b60a3dd6ffec438a9ea3f4dbfe1b3ec6") {
                UIApplication.shared.open(shortcutURL, options: [:], completionHandler: nil)
        }
    }
    
    @objc func runSiriShortcutButton(_ sender: UIButton) {
        print("Button \(sender.title(for: .normal) ?? "") tapped.")
        
        guard let buttonName = sender.title(for: .normal) else { return }
        if let shortcutURL = URL(string: "shortcuts://run-shortcut?name=Export Shortcuts&input=\(self.UUID)") {
                UIApplication.shared.open(shortcutURL, options: [:], completionHandler: nil)
            }
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        print("Button \(sender.title(for: .normal) ?? "") tapped.")
        guard let buttonName = sender.title(for: .normal) else { return }
        if let title = buttonMappingDict[buttonName] {
            if let shortcutURL = URL(string: "shortcuts://run-shortcut?name=\(title)") {
                UIApplication.shared.open(shortcutURL, options: [:], completionHandler: nil)
            }
        }
        
        if let appURL = URL(string: "smoothmoves://") {
            if UIApplication.shared.canOpenURL(appURL) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
                print("running")
            } else {
                // Handle if the app is not installed or cannot be opened
                print("The app is not installed or cannot be opened.")
            }
        }
    }
    
    @objc func actionsButtonPressed(_ sender: UIButton) {
        let dropdownMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for option in buttonTypes {
            dropdownMenu.addAction(UIAlertAction(title: option, style: .default, handler: { (_) in
                print("Selected option: \(option)")
                self.updateAvailableButtonOptions(selectedOption: option)
                let buttonHeight: CGFloat = 50
                let spacing: CGFloat = 15
                self.createButton(name: option, atYPosition: self.buttonY)
                self.buttonY += buttonHeight + spacing
                
            }))
        }
        
        dropdownMenu.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let popoverController = dropdownMenu.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        self.present(dropdownMenu, animated: true, completion: nil)
        
    }
    
    @objc func dropdownTapped(_ sender: CustomDropdownButton)  {
        
        let dropdownMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for option in options {
            if(forbiddenOptionsList.contains(option)){
                continue
            }
            dropdownMenu.addAction(UIAlertAction(title: option, style: .default, handler: { (_) in
                print("Selected option: \(option)")
                self.updateAvailableOptions(selectedOption: option)
                sender.isEnabled = false
                
                let parentButtonObj = sender.parentButtonObj
                let newWidth = parentButtonObj.frame.width / 2
                let newX = dropdownMenu.view.frame.origin.x - newWidth
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                    parentButtonObj.frame = CGRect(x: newX + 167, y: sender.frame.origin.y, width: newWidth, height: sender.frame.height)
                }, completion: nil)
                
                let verticalSpacing: CGFloat = 10
                let buttonWidth = newWidth - 10
                let buttonX = parentButtonObj.frame.origin.x + parentButtonObj.frame.width + verticalSpacing
                let buttonY = parentButtonObj.frame.origin.y
                let buttonHeight = sender.frame.height
                
                let button = removedShortcutButton(type: .custom)
                button.frame = CGRect(
                    x: buttonX, y: buttonY,
                    width: buttonWidth, height: buttonHeight)
                button.setTitle(option, for: .normal)
                button.setTitleColor(.systemBlue, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .light)
                button.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
                button.layer.cornerRadius = 10
                button.addTarget(self, action: #selector(self.removeShortcutButton(_:)), for: .touchUpInside)
                button.transform = CGAffineTransform(scaleX: 1, y: 1.5)
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                    button.transform = .identity
                }, completion: nil)
                button.dropDownButtonObj = sender
                self.view.addSubview(button)
                
                forbiddenOptionsList.append(option)
                
                buttonMappingDict[parentButtonObj.title(for: .normal)!] = option
            }))
        }
        
        dropdownMenu.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let popoverController = dropdownMenu.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        self.present(dropdownMenu, animated: true, completion: nil)
    }
    
    @objc func removeShortcutButton(_ button: removedShortcutButton) {
        button.dropDownButtonObj.isEnabled = true
        if let name = button.title(for: .normal) {
            forbiddenOptionsList.removeAll { $0 == name }
            for (key, value) in buttonMappingDict{
                if value == name {
                    for obj in commandButtonList {
                        if obj.title(for: .normal) == key {
                            obj.setTitle(key, for: .normal)
                            obj.setTitleColor(.systemBlue, for: .normal)
                            obj.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .light)
                            obj.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
                            obj.layer.cornerRadius = 10
                            let newWidth = min(buttonWidth, obj.frame.width + buttonWidth)
                            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                                obj.frame.size.width = newWidth
                            }, completion: nil)
                            buttonMappingDict.removeValue(forKey: key)
                        }
                    }
                }
            }
        }
        button.removeFromSuperview()
    }
    
    func findDropdownButton(from view: UIView) -> CustomDropdownButton? {
        var currentView: UIView? = view.superview
        while currentView != nil {
            if let dropdownButton = currentView as? CustomDropdownButton {
                return dropdownButton
            }
            currentView = currentView?.superview
        }
        return nil
    }
    
    func createButton(name: String, atYPosition yPos: CGFloat) {
        
        let button = UIButton(type: .system)
        button.frame = CGRect(x: buttonX, y: yPos+20, width: buttonWidth, height: buttonHeight)
        button.setTitle(name, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .light)
        button.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        view.addSubview(button)
        
        let dropdownButton = CustomDropdownButton(type: .custom)
        dropdownButton.frame = CGRect(x: button.frame.maxX + 10, y: yPos+20, width: 30, height: buttonHeight)
        dropdownButton.setTitle("▼", for: .normal)
        dropdownButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        dropdownButton.backgroundColor = UIColor.black //
        dropdownButton.layer.cornerRadius = 5 // Rounded corners
        dropdownButton.layer.borderColor = UIColor.white.cgColor
        dropdownButton.layer.borderWidth = 0
        dropdownButton.addTarget(self, action: #selector(dropdownTapped(_:)), for: .touchUpInside)
        dropdownButton.parentButtonObj = button
        view.addSubview(dropdownButton)
        buttonOptions[name] = Set(options)
        
        commandButtonList.append(button)
        
        
        button.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        dropdownButton.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: [], animations: {
            button.alpha = 1 // Fade-in animation
            dropdownButton.alpha = 1 // Fade-in animation
            button.transform = .identity
            dropdownButton.transform = .identity
        }, completion: nil)
        NotificationView.showNotification(message: "Button created successfully!", backgroundColor: UIColor.systemGreen)
        
    }
    
    func getShortcutsList() async {
        do {
            let shorties: [shortcutTable] = try await client.database
                .from("smooth-moves")
                .select("shortcut_list")
                .eq("UUID", value: self.UUID) // Add your where clause here
                .execute()
                .value

            options = []
            
            if let lastShortcutTable = shorties.last {
                lastShortcutTable.shortcut_list.forEach { element in
                    options.append(element)
                }
                
            } else {
                print("The array is empty.")
            }
        } catch{
            debugPrint(error)
        }
    }
    
    func updateAvailableOptions(selectedOption: String) {
        for buttonName in buttonOptions.keys {
            buttonOptions[buttonName]?.remove(selectedOption)
            print(selectedOption )
        }
    }
    
    func updateAvailableButtonOptions(selectedOption: String) {
        buttonTypes.removeAll { $0 == selectedOption }
        print("Removed option: \(selectedOption)")
    }
    
    func userActivity(_ activity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) {
        if activity.activityType == "vaibhav.smooth-moves" {
            if let output = activity.userInfo?["yourOutputKey"] as? String {
                print("Received output from shortcut: \(output)")
            }
        }
    }
    
    func monitorFirebase() async {
        ref.child("blink left eye").observe(.value, with: {snapshot in
            if let value = snapshot.value as? NSDictionary,
               let enabled = value["enabled"] as? Int {
                if(enabled == 1){
                    
                    if let title = buttonMappingDict["blink left eye"] {
                        if let shortcutURL = URL(string: "shortcuts://run-shortcut?name=\(title)") {
                            UIApplication.shared.open(shortcutURL, options: [:], completionHandler: nil)
                        }
                        
                        self.ref.child("blink left eye").updateChildValues(["enabled": false])
                    }
                }
            }})
        
        ref.child("blink right eye").observe(.value, with: {snapshot in
            if let value = snapshot.value as? NSDictionary,
               let enabled = value["enabled"] as? Int {
                if(enabled == 1){
                    
                    if let title = buttonMappingDict["blink right eye"] {
                        if let shortcutURL = URL(string: "shortcuts://run-shortcut?name=\(title)") {
                            UIApplication.shared.open(shortcutURL, options: [:], completionHandler: nil)
                        }
                    }
                    
                    self.ref.child("blink right eye").updateChildValues(["enabled": false])
                }
            }
        })
        
        ref.child("smile").observe(.value, with: {snapshot in
            if let value = snapshot.value as? NSDictionary,
               let enabled = value["enabled"] as? Int {
                if(enabled == 1){
                    
                    if let title = buttonMappingDict["smile"] {
                        if let shortcutURL = URL(string: "shortcuts://run-shortcut?name=\(title)") {
                            UIApplication.shared.open(shortcutURL, options: [:], completionHandler: nil)
                        }
                    }
                    
                    self.ref.child("smile").updateChildValues(["enabled": false])
                }
            }
        })
        
        ref.child("push").observe(.value, with: {snapshot in
            if let value = snapshot.value as? NSDictionary,
               let enabled = value["enabled"] as? Int {
                if(enabled == 1){
                    
                    if let title = buttonMappingDict["push"] {
                        if let shortcutURL = URL(string: "shortcuts://run-shortcut?name=\(title)") {
                            UIApplication.shared.open(shortcutURL, options: [:], completionHandler: nil)
                        }
                    }
                    
                    self.ref.child("push").updateChildValues(["enabled": false])
                }
            }
        })
        
        ref.child("pull").observe(.value, with: {snapshot in
            if let value = snapshot.value as? NSDictionary,
               let enabled = value["enabled"] as? Int {
                if(enabled == 1){
                    
                    if let title = buttonMappingDict["pull"] {
                        if let shortcutURL = URL(string: "shortcuts://run-shortcut?name=\(title)") {
                            UIApplication.shared.open(shortcutURL, options: [:], completionHandler: nil)
                        }
                    }
                    
                    self.ref.child("pull").updateChildValues(["enabled": false])
                }
            }
        })
    }
        
    func cacheUUID(_ uuid: UUID, forKey key: String) {
            UserDefaults.standard.set(uuid.uuidString, forKey: key)
    }

    func getCachedUUID(forKey key: String) -> UUID? {
            if let uuidString = UserDefaults.standard.string(forKey: key) {
                return Foundation.UUID(uuidString: uuidString)
            }
        let uuid = Foundation.UUID()
        if let uuidString = UserDefaults.standard.string(forKey: key) {
            return Foundation.UUID(uuidString: uuidString)
        }
        return nil
    }
        
    func getUUID() {
        if let uuid = defaults.string(forKey: "uuid") {
            self.UUID = uuid
        } else {
            self.UUID = Foundation.UUID().uuidString
            defaults.set(self.UUID, forKey: "uuid")
        }
        print(self.UUID)
    }
}
