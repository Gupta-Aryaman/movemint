//
//  Item.swift
//  smooth-moves
//
//  Created by Vaibhav Sharma on 27/02/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
