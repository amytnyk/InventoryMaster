//
//  ConnectionManager.swift
//  com.inventorymaster
//
//  Created by Alex on 7/23/19.
//  Copyright © 2019 Alex Mytnyk. All rights reserved.
//

import Foundation
import Firebase

class ConnectionManager {
    enum State {
        case Connected
        case NotConnected
        case Undefined
    }
    static var _state : State = .Undefined
    static var viewController : ViewController?
    static var was_not_connected = false
    static func startObserving() {
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if snapshot.value as? Bool ?? false {
                if was_not_connected {
                    viewController?.showConnectedAlert()
                }
                _state = .Connected
            } else {
                _state = .NotConnected
                let queue = DispatchQueue(label: "label")
                queue.async {
                    usleep(1500000)
                    if _state == .NotConnected {
                        was_not_connected = true
                        viewController?.showNotConnectedWarning()
                    }
                }
                
            }
        })
    }
}
