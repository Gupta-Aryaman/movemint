//
//  Notification.swift
//  smooth-moves
//
//  Created by Vaibhav Sharma on 13/03/24.
//

import Foundation
import UIKit

class NotificationView: UIView {
    var message: String = ""
    
    convenience init(message: String, backgroundColor: UIColor) {
            self.init(frame: .zero)
            self.message = message
            self.backgroundColor = backgroundColor
            configureView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    private func configureView() {
        backgroundColor = self.backgroundColor 
        alpha = 0.3
        layer.cornerRadius = 10
        clipsToBounds = true
        
        let label = UILabel()
        label.text = message
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 50),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    static func showNotification(message: String, backgroundColor: UIColor) {
        let notificationView = NotificationView(message: message, backgroundColor: backgroundColor)
                notificationView.frame = CGRect(x: 0, y: -200, width: UIScreen.main.bounds.width, height: 110)
                UIApplication.shared.windows.first?.addSubview(notificationView)
        
        UIView.animate(withDuration: 0.5, animations: {
            notificationView.alpha = 1.0
            notificationView.frame.origin.y = 0
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIView.animate(withDuration: 0.5, animations: {
                    notificationView.alpha = 0.0
                    notificationView.frame.origin.y = -100
                }) { _ in
                    notificationView.removeFromSuperview()
                }
            }
        }
    }
}
