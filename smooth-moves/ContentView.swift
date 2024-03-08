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

let client = SupabaseClient(supabaseURL: URL(string:  ProcessInfo.processInfo.environment["SUPABASE_KEY"])!, supabaseKey:  ProcessInfo.processInfo.environment["SUPABASE_KEY"])


class ViewController: UIViewController, NSUserActivityDelegate, UIApplicationDelegate {

    var dropdownMenus = [UIButton: [String]]()
    var availableOptions = [String: ButtonShortcut]()
    var options = [String]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        
        view.backgroundColor = UIColor.white
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 50, width: view.frame.width, height: 50))
        titleLabel.text = "Smooth Moves"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 40)
        view.addSubview(titleLabel)
        
        let buttonNames = ["A", "B", "C", "D", "E", "F", "G", "H"]
        
        let buttonX: CGFloat = 50
        var buttonY: CGFloat = 150
        let buttonWidth: CGFloat = 250
        let buttonHeight: CGFloat = 50
        let spacing: CGFloat = 15
        
        let button = UIButton(type: .system)
        button.frame = CGRect(x: buttonX, y: buttonY-50, width: buttonWidth, height: buttonHeight)
        button.setTitle("name", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        button.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3) // Button color
        button.layer.cornerRadius = 10 // Rounded corners
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        view.addSubview(button)
        
        
        for name in buttonNames {
            let button = UIButton(type: .system)
            button.frame = CGRect(x: buttonX, y: buttonY, width: buttonWidth, height: buttonHeight)
            button.setTitle(name, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
            button.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            button.layer.cornerRadius = 10 // Rounded corners
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            view.addSubview(button)
            
            let dropdownButton = CustomDropdownButton(type: .custom)
            dropdownButton.frame = CGRect(x: button.frame.maxX + 10, y: buttonY, width: 30, height: buttonHeight)
            dropdownButton.setTitle("▼", for: .normal)
            dropdownButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
            dropdownButton.backgroundColor = UIColor.black //
            dropdownButton.layer.cornerRadius = 5 // Rounded corners
            dropdownButton.layer.borderColor = UIColor.black.cgColor
            dropdownButton.layer.borderWidth = 5
            dropdownButton.addTarget(self, action: #selector(dropdownTapped(_:)), for: .touchUpInside)
            dropdownButton.parentButtonObj = button
            view.addSubview(dropdownButton)
            buttonOptions[name] = Set(options)
            availableOptions[name] = ButtonShortcut(shortcutName: "Shortcut \(name)")
            buttonY += buttonHeight + spacing
        }
        
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        scrollView.contentSize = CGSize(width: view.frame.width, height: buttonY + spacing)
        scrollView.addSubview(view)
        view = scrollView
        
    }

    @objc func buttonPressed(_ sender: UIButton) {
        Task {
                    await getShortcutsList()
            }
    }
        
    
    @objc func buttonTapped(_ sender: UIButton) {
        print("Button \(sender.title(for: .normal) ?? "") tapped.")
        
        guard let buttonName = sender.title(for: .normal) else { return }
        guard let buttonShortcut = availableOptions[buttonName] else { return }
        
        if let shortcutURL = URL(string: "shortcuts://run-shortcut?name=\(buttonShortcut.shortcutName)") {
            UIApplication.shared.open(shortcutURL, options: [:], completionHandler: nil)
        }
        
    }
    
    @objc func dropdownTapped(_ sender: CustomDropdownButton)  {
        
        //print(options)
        
        guard let button = sender.superview?.subviews.compactMap({ $0 as? UIButton }).first(where: { $0.title(for: .normal) != nil }) else { return }
        
        guard let buttonName = button.title(for: .normal) else { return }
                
        let dropdownMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for option in options {
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
                let button = UIButton(type: .system)
                    button.frame = CGRect(
                        x: buttonX, y: buttonY,
                        width: buttonWidth, height: buttonHeight)
                    button.setTitle(option, for: .normal)
                    button.setTitleColor(.black, for: .normal)
                    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
                    button.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
                    button.layer.cornerRadius = 10
                    self.view.addSubview(button)
            }))
                                                
        }
        
        dropdownMenu.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let popoverController = dropdownMenu.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        self.present(dropdownMenu, animated: true, completion: nil)
    
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
    
    func userActivity(_ activity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) {
        if activity.activityType == "vaibhav.smooth-moves" {
            // Extract output or relevant information
            if let output = activity.userInfo?["yourOutputKey"] as? String {
                print("Received output from shortcut: \(output)")
            }
        }
    }
}
