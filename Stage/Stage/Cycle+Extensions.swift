//
//  Cycle+Extensions.swift
//  Stage
//
//  Created by Artem Menshikov on 01.01.2026.
//

import Foundation
import CoreData

extension Cycle {
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        if id == nil {
            id = UUID()
        }
        if createdAt == nil {
            createdAt = Date()
        }
        if startDate == nil {
            startDate = Date()
        }
    }
}

extension CycleSettings {
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        if id == nil {
            id = UUID()
        }
    }
}

