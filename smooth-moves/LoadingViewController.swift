import Foundation
import UIKit

class LoadingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a UIActivityIndicatorView
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .gray
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        
        view.addSubview(activityIndicator)
    }
}
