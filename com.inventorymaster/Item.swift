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
        Name: \(name)
        Article: \(art)
        Barcode: \(bar)
        """
        let index = ItemManager.findByArt(art: art, array: ItemManager.cloud_data)
        if index == nil {
            str += "\nNot yet in the database"
        } else {
            str += "\nCount: " + String(ItemManager.cloud_data[index!].count)
        }
        
        let pre_index = ItemManager.findByArt(art: art, array: ItemManager.pre_items)
        if pre_index == nil {
            str += "\nNot yet in the pre-database"
        } else {
            str += "\nExpected count: " + String(ItemManager.pre_items[pre_index!].count)
        }
        
        return str
    }
}

