import UIKit
import SwiftUI
import Supabase
      
struct MyViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ViewController {
        
        return ViewController()
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
    }
}

struct ContentView: View {
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

var forbiddenOptionsList = [String]()
var options = [String]()
var buttonMappingDict = [String: String]()

var commandButtonList = [UIButton]()

class ViewController: UIViewController, NSUserActivityDelegate, UIApplicationDelegate {

    let buttonX: CGFloat = 50
    var buttonY: CGFloat = 150
    let buttonWidth: CGFloat = 250
    let buttonHeight: CGFloat = 50
    let spacing: CGFloat = 15
    var vert: CGFloat = 150
    var buttonTypes = ["push", "pull", "smile", "blink left eye", "blink right eye"]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        let titleLabel = UILabel()
        titleLabel.text = "Smooth Moves"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 32)
        titleLabel.textColor = UIColor.systemBlue
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(titleLabel)
                
        NSLayoutConstraint.activate([titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10), titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),     titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15)])
        
        let button = UIButton(type: .system)
        button.setTitle("Import Shortcuts", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.titleLabel?.numberOfLines = 0 // Allow multiline
        button.titleLabel?.lineBreakMode = .byWordWrapping // Word wrapping
        button.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        button.layer.cornerRadius = 28
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) // Add padding
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 55)
        ])


        let addButton = UIButton(type: .system)
        addButton.setTitle("+", for: .normal)
        addButton.setTitleColor(.systemBlue, for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 60, weight: .light)
        addButton.layer.cornerRadius = 30
        addButton.layer.borderWidth = 0
        addButton.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        addButton.layer.borderColor = UIColor.white.cgColor
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 10, right: 5)
        addButton.layer.shadowColor = UIColor.white.cgColor
        addButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        addButton.layer.shadowRadius = 20
        addButton.layer.shadowOpacity = 0.5
        addButton.layer.masksToBounds = false

        addButton.addTarget(self, action: #selector(plusButtonPressed(_:)), for: .touchUpInside)
            view.addSubview(addButton)
            
        NSLayoutConstraint.activate([
                addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
                addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
                addButton.widthAnchor.constraint(equalToConstant: 60),
                addButton.heightAnchor.constraint(equalToConstant: 60)
            ])
        
    }
    
    @objc func buttonPressed(_ sender: UIButton) {
        Task {
                await getShortcutsList()
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
    }
    
    @objc func plusButtonPressed(_ sender: UIButton) {
        let dropdownMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for option in buttonTypes {
            dropdownMenu.addAction(UIAlertAction(title: option, style: .default, handler: { (_) in
                print("Selected option: \(option)")
                self.updateAvailableButtonOptions(selectedOption: option)
                let buttonX: CGFloat = 50
                let buttonWidth: CGFloat = 250
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
                
        guard let button = sender.superview?.subviews.compactMap({ $0 as? UIButton }).first(where: { $0.title(for: .normal) != nil }) else { return }
        
        guard let buttonName = button.title(for: .normal) else { return }
                
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
                parentButtonObj.frame = CGRect(
                    x: newX+167, y: sender.frame.origin.y,
                    width: newWidth, height: sender.frame.height)
                
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
            
            // Iterate through buttonMappingDict to find the button corresponding to the removed shortcut
            for (key, value) in buttonMappingDict{
                if value == name {
                    for obj in commandButtonList {
                        if obj.title(for: .normal) == key {
                            // Update button properties
                            obj.setTitle(key, for: .normal)
                            obj.setTitleColor(.systemBlue, for: .normal)
                            obj.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .light)
                            obj.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
                            obj.layer.cornerRadius = 10
                            let newWidth = min(buttonWidth, obj.frame.width + buttonWidth)
                                                    obj.frame.size.width = newWidth
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
        button.frame = CGRect(x: buttonX, y: yPos, width: buttonWidth, height: buttonHeight)
        button.setTitle(name, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .light)
        button.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        view.addSubview(button)
        
        let dropdownButton = CustomDropdownButton(type: .custom)
        dropdownButton.frame = CGRect(x: button.frame.maxX + 10, y: yPos, width: 30, height: buttonHeight)
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
    }
    
    func getShortcutsList() async {
        do {
            let shorties: [shortcutTable] = try await client.database.from("smooth-moves").select("shortcut_list").execute().value
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
}
