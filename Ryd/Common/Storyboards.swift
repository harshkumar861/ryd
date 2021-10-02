//
//  Storyboards.swift
//  WePrep
//
//  Created by Prepladder on 15/02/20.
//  Copyright © 2020 Prepladder. All rights reserved.
//
import UIKit

enum Stortyboad:String {
    case main = "Main"
    case home = "Home"
    case tripDetails = "TripDetails"
    case payment = "Payment"
    case help = "Help"
    case activity = "Activity"
}

extension NSObject {
    class var identifier: String {
        return String(describing: self)
    }
}


//MARK:- ======== ViewController Identifiers ========
extension UIViewController {
    
    static func getVC(_ storyBoard: Stortyboad) -> Self {
        
        func instanceFromNib<T: UIViewController>(_ storyBoard: Stortyboad) -> T {
            guard let vc = controller(storyBoard: storyBoard, controller: T.identifier) as? T else {
                fatalError("Not ViewController")
            }
            return vc
        }
        return instanceFromNib(storyBoard)
    }
    
    static func controller(storyBoard: Stortyboad, controller: String) -> UIViewController {
      
        let storyBoard = UIStoryboard(name: storyBoard.rawValue, bundle: Bundle.main)
        let vc = storyBoard.instantiateViewController(withIdentifier: controller)
        return vc
    }
}

