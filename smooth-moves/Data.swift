//
//  Data.swift
//  smooth-moves
//
//  Created by Vaibhav Sharma on 17/03/24.
//

import Foundation
import SwiftData

@Model
final class Data: Identifiable {

    //TODO icon, state caching, loading screen, button text wrap
    
    @Attribute(.unique) var id: String = UUID().uuidString
    var uuid: String 
    
    init(id: String = UUID().uuidString, name: String) {
        self.id = id
        self.uuid = name
    }
}
