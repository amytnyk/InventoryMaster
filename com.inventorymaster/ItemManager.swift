//
//  ItemManager.swift
//  com.inventorymaster
//
//  Created by Alex on 7/22/19.
//  Copyright © 2019 Alex Mytnyk. All rights reserved.
//

import Foundation
import Firebase

class ItemManager {
    static var items : Array<Item> = Array()
    static var pre_items : Array<Item> = Array()
    static var non_scannable_items : Array<Item> = Array()
    static var cloud_data : Array<Item> = Array()
    static var ref : DatabaseReference!
    static var current_item : Item?
    static var viewController : ViewController?
    
    static func addCurrentItem(_ count : Int) {
        if current_item != nil {
            ref.child("data").observeSingleEvent(of: .value, with: { (_snapshot) in
                if _snapshot.hasChild((current_item?.art)!) {
                    let post = [ "count": _snapshot.childSnapshot(forPath: (current_item?.art)!).childSnapshot(forPath: "count").value as! Int + count ]
                    let snapshot = _snapshot.childSnapshot(forPath: (current_item?.art)!)
                    snapshot.ref.updateChildValues(post)
                    let time_snapshot : DataSnapshot = snapshot.childSnapshot(forPath: "time_groups")
                    
                    time_snapshot.ref.child(String(Int64(NSDate().timeIntervalSince1970 * 1000))).setValue(count)
                } else {
                    let key = Int64(NSDate().timeIntervalSince1970 * 1000)
                    let value = count
                    var dictionary : [String: Any] = [:]
                    dictionary[String(key)] = value as Any
                    _snapshot.ref.child((current_item?.art)!).setValue(["barcode": current_item!.bar as Any, "name": current_item!.name as Any, "count": count, "time_groups": dictionary])
                }
            })
        } else {
            print("ERROR")
        }
    }
    
    static func removeCurrentItem() {
        if current_item != nil {
            ref.child("data").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild((current_item?.art)!) {
                    if (snapshot.childSnapshot(forPath: (current_item?.art)!).childSnapshot(forPath: "count").value as! Int == 1) {
                        snapshot.childSnapshot(forPath: (current_item?.art)!).ref.removeValue()
                    } else {
                        let post = [ "count": snapshot.childSnapshot(forPath: (current_item?.art)!).childSnapshot(forPath: "count").value as! Int - 1 ]
                        snapshot.childSnapshot(forPath: (current_item?.art)!).ref.updateChildValues(post)
                        let time_snapshot : DataSnapshot = snapshot.childSnapshot(forPath: (current_item?.art)!).childSnapshot(forPath: "time_groups")
                        
                        let values = time_snapshot.value as? NSDictionary
                        
                        var last_time : String?
                        var last_count : Int?
                        
                        for _item in values! {
                            if (last_time == nil || Int64((_item.key as! String)) ?? 0 > Int64(last_time!) ?? 0) {
                                last_time = _item.key as? String
                                last_count = _item.value as? Int
                            }
                        }
                        
                        if last_time != nil {
                            if last_count == 1 {
                                time_snapshot.ref.child(last_time!).removeValue()
                            } else {
                                time_snapshot.ref.child(last_time!).setValue(last_count! - 1)
                            }
                        }
                    }
                }
            })
        } else {
            print("ERROR")
        }
    }
    
    static func setCurrentItemByIndex(_ _index : Int) {
        let index = findByArt(art: non_scannable_items[_index].art, array: items)
        
        if (index != nil) {
            setCurrentItemByBar(bar: items[index!].bar)
            viewController?.setDisplayItem(current_item!)
        }
    }
    
    static func setCurrentItemByBar(bar: String) {
        let index = findByBar(bar: bar, array: items)
        if index == nil {
            print("ERROR")
        } else {
            current_item = items[index!]
        }
    }
    
    static func findByArt(art: String, array: Array<Item>) -> Int? {
        for (index, value) in array.enumerated() {
            if value.art == art {
                return index
            }
        }
        return nil
    }
    
    static func findByBar(bar: String, array: Array<Item>) -> Int? {
        for (index, value) in array.enumerated() {
            if value.bar == bar {
                return index
            }
        }
        return nil
    }
    
    static func LoadData(_ref : DatabaseReference!) {
        self.ref = _ref
        
        _ref.child("json").observeSingleEvent(of: .value, with: { (snapshot) in
            print("Received json data")
            let values = snapshot.value as? NSArray
            if (values == nil) {
                return
            }
            for _item in values! {
                let item : NSDictionary = _item as! NSDictionary
                items.append(Item(_art: item.value(forKey: "art") as! String, _bar: item.value(forKey: "barcode") as! String, _name: item.value(forKey: "name") as! String, _count: 0))
            }
        })
        
        _ref.child("pre_data").observeSingleEvent(of: .value, with: { (snapshot) in
            let values = snapshot.value as? NSArray
            if (values == nil) {
                return
            }
            for _item in values! {
                let item : NSDictionary = _item as! NSDictionary
                pre_items.append(Item(_art: item.value(forKey: "art") as! String, _bar: "", _name: "", _count: item.value(forKey: "count") as! Int))
            }
        })
        
        _ref.child("non_scannable_items").observeSingleEvent(of: .value, with: { (snapshot) in
            let values = snapshot.value as? NSArray
            if (values == nil) {
                return
            }
            for _item in values! {
                let item : NSDictionary = _item as! NSDictionary
                non_scannable_items.append(Item(_art: item.value(forKey: "art") as! String, _bar: "", _name: item.value(forKey: "name") as! String, _count: 0))
            }
        })
        _ref.child("data").observe(DataEventType.value, with: { (snapshot) in
            var new_cloud_data = Array<Item>()
            
            let values = snapshot.value as? NSDictionary
            if values == nil {
                return
            }
            for _item in values! {
                let item : NSDictionary = _item.value as! NSDictionary
                new_cloud_data.append(Item(_art: _item.key as! String, _bar: item.value(forKey: "barcode") as! String, _name: item.value(forKey: "name") as! String, _count: item.value(forKey: "count") as! Int))
            }
            
            cloud_data = new_cloud_data
            if (viewController != nil && current_item != nil) {
                viewController?.setDisplayItem(current_item!)
            }
        })
    }
}
