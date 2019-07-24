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
    static var state : State = .Undefined
    static var viewController : ViewController?
    static var was_not_connected = false
    static var background_mode = false {
        willSet {
            if !newValue {
                switch state {
                case .Connected:
                    if was_not_connected {
                        viewController?.showConnectionAlert(connected: true)
                    }
                case .NotConnected:
                    if !was_not_connected {
                        viewController?.showConnectionAlert(connected: false)
                    }
                case .Undefined:
                    break
                }
            }
        }
    }
    static func startObserving() {
        let connectedRef = Database.database().reference(withPath: ".info/connected") // path for connected inforamtion
        connectedRef.observe(.value, with: { snapshot in
            if snapshot.value as? Bool ?? false {
                state = .Connected
                if !background_mode {
                    if was_not_connected {
                        viewController?.showConnectionAlert(connected: true)
                        was_not_connected = false
                    }
                }
                
            } else {
                state = .NotConnected
                if !background_mode {
                    let queue = DispatchQueue(label: "label")
                    queue.async {
                        usleep(1500000) // 1500 millis
                        if state == .NotConnected {
                            was_not_connected = true
                            if !background_mode {
                                viewController?.showConnectionAlert(connected: false)
                            }
                        }
                    }
                }
            }
        })
    }
}
