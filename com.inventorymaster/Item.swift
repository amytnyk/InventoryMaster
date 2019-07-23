//
//  Item.swift
//  com.inventorymaster
//
//  Created by Alex on 7/22/19.
//  Copyright © 2019 Alex Mytnyk. All rights reserved.
//

import Foundation

class Item {
    var art : String
    var bar : String
    var name : String
    var count : Int
    var time_groups : [TimeGroup]
    
    init(_art : String, _bar : String, _name : String, _count : Int) {
        art = _art
        bar = _bar
        name = _name
        count = _count
        time_groups = []
    }
    
    func toString() -> String {
        var str : String = """
        \("Name".localized): \(name.trimmingCharacters(in: (NSCharacterSet.whitespacesAndNewlines)))
        \("Article".localized): \(art)
        \("Barcode".localized): \(bar)
        """
        let index = ItemManager.findByArt(art: art, array: ItemManager.cloud_data)
        if index == nil {
            str += "\n\("Not yet in the database".localized)"
        } else {
            str += "\n\("Count".localized): " + String(ItemManager.cloud_data[index!].count)
        }
        
        let pre_index = ItemManager.findByArt(art: art, array: ItemManager.pre_items)
        if pre_index == nil {
            str += "\n\("Not yet in the pre-database".localized)"
        } else {
            str += "\n\("Expected count".localized): " + String(ItemManager.pre_items[pre_index!].count)
        }
        
        return str
    }
}

