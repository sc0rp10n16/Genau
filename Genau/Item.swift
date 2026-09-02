//
//  Item.swift
//  Genau
//
//  Created by Akshith Mysa on 02.09.26.
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
