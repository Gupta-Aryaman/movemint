import UIKit
import SwiftUI

struct MyViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ViewController {
        return ViewController()
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        // Update the view controller if needed
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


class ViewController: UIViewController, NSUserActivityDelegate, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            return true
        }

        func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
            return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        }

        func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        }

    
    var dropdownMenus = [UIButton: [String]]()
    var availableOptions = [String: ButtonShortcut]()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        NSUserActivity.current?.delegate = self
        view.backgroundColor = UIColor.white // Background color
        
        // Title Label
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 50, width: view.frame.width, height: 50))
        titleLabel.text = "Smooth Moves"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 40)
        view.addSubview(titleLabel)
        
        // Button Names
        let buttonNames = ["A", "B", "C", "D", "E", "F", "G", "H"]
        
        // Button Positions
        let buttonX: CGFloat = 50
        var buttonY: CGFloat = 150
        let buttonWidth: CGFloat = 250 // Increased width
        let buttonHeight: CGFloat = 50 // Increased height
        let spacing: CGFloat = 15
        
        // Dropdown Options
        let options = ["Shortcut A", "Shortcut B", "Shortcut C", "Shortcut D", "Shortcut E", "Shortcut F", "Shortcut G", "Shortcut H"]
        
        for name in buttonNames {
            // Create Button
            let button = UIButton(type: .system)
            button.frame = CGRect(x: buttonX, y: buttonY, width: buttonWidth, height: buttonHeight)
            button.setTitle(name, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24) // Larger font
            button.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3) // Button color
            button.layer.cornerRadius = 10 // Rounded corners
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            view.addSubview(button)
            
            // Create Dropdown Button
            let dropdownButton = CustomDropdownButton(type: .custom)
            dropdownButton.frame = CGRect(x: button.frame.maxX + 10, y: buttonY, width: 30, height: buttonHeight)
            dropdownButton.setTitle("▼", for: .normal)
            dropdownButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24) // Larger font
            //dropdownButton.tintColor = UIColor.black
            dropdownButton.backgroundColor = UIColor.black // Dropdown button color
            
            // Dropdown button background color
            dropdownButton.layer.cornerRadius = 5 // Rounded corners
            dropdownButton.layer.borderColor = UIColor.black.cgColor
            dropdownButton.layer.borderWidth = 5
            dropdownButton.addTarget(self, action: #selector(dropdownTapped(_:)), for: .touchUpInside)
            dropdownButton.parentButtonObj = button
            
            view.addSubview(dropdownButton)
            // Store Dropdown Options for each button
            buttonOptions[name] = Set(options) // Mapping button titles to options
            availableOptions[name] = ButtonShortcut(shortcutName: "Shortcut \(name)")
            buttonY += buttonHeight + spacing
        }
        
        // Make the view scrollable
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        scrollView.contentSize = CGSize(width: view.frame.width, height: buttonY + spacing) // Adjust content size
        scrollView.addSubview(view)
        view = scrollView
        
    }

    @objc func buttonTapped(_ sender: UIButton) {
        print("Button \(sender.title(for: .normal) ?? "") tapped.")
        
        guard let buttonName = sender.title(for: .normal) else { return }
        guard let buttonShortcut = availableOptions[buttonName] else { return }
        
        // Execute the shortcut with the corresponding name
        if let shortcutURL = URL(string: "shortcuts://run-shortcut?name=\(buttonShortcut.shortcutName)") {
            UIApplication.shared.open(shortcutURL, options: [:], completionHandler: nil)
        }
        
        if let shortCutNames = UIPasteboard.general.string {
            //print(string)
            //buttonOptions[name] = shortCutNames
            sender.setTitle(shortCutNames, for: .normal)
        }
    }
    
    @objc func dropdownTapped(_ sender: CustomDropdownButton) {
        guard let button = sender.superview?.subviews.compactMap({ $0 as? UIButton }).first(where: { $0.title(for: .normal) != nil }) else { return }
        
        guard let buttonName = button.title(for: .normal) else { return }
        
        let dropdownMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for option in (buttonOptions[buttonName]?.sorted() ?? []) {
            dropdownMenu.addAction(UIAlertAction(title: option, style: .default, handler: { (_) in
                print("Selected option: \(option)")
                self.updateAvailableOptions(selectedOption: option)
                sender.isEnabled = false
                
                // Adjusting parentButtonObj position and size
                let parentButtonObj = sender.parentButtonObj
                let newWidth = parentButtonObj.frame.width / 2
                let newX = dropdownMenu.view.frame.origin.x - newWidth// Subtract newWidth from sender's minX
                parentButtonObj.frame = CGRect(
                    x: newX+167, y: sender.frame.origin.y,
                    width: newWidth, height: sender.frame.height)
                
                let verticalSpacing: CGFloat = 10
                    
                    // Positioning the new button relative to parentButtonObj
                let buttonWidth = newWidth - 10  // Reducing button width
                let buttonX = parentButtonObj.frame.origin.x + parentButtonObj.frame.width + verticalSpacing // Adjusting button X position
                let buttonY = parentButtonObj.frame.origin.y
                let buttonHeight = sender.frame.height
                let button = UIButton(type: .system)
                    button.frame = CGRect(
                        x: buttonX, y: buttonY,
                        width: buttonWidth, height: buttonHeight)
                    button.setTitle(option, for: .normal)
                    button.setTitleColor(.black, for: .normal)
                    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24) // Larger font
                    button.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3) // Button color
                    button.layer.cornerRadius = 10 // Rounded corners
                    // button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
                    self.view.addSubview(button)
            }))
                                                
        }
        
        dropdownMenu.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let popoverController = dropdownMenu.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(dropdownMenu, animated: true, completion: nil)
    
    }

    func updateAvailableOptions(selectedOption: String) {
        for buttonName in buttonOptions.keys {
            buttonOptions[buttonName]?.remove(selectedOption)
            print(selectedOption )
        }
    }
    
    func userActivity(_ activity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) {
        if activity.activityType == "vaibhav.smooth-moves" {
            // Extract output or relevant information
            if let output = activity.userInfo?["yourOutputKey"] as? String {
                print("Received output from shortcut: \(output)")
                // Now you can use the output as needed in your app
            }
        }
    }
}
