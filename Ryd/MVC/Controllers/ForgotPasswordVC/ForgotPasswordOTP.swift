//
//  ForgotPasswordOTP.swift
//  Ryd
//
//  Created by Harsh on 08/08/21.
//

import UIKit

class ForgotPasswordOTP: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var lblDate: UIButton!
    @IBOutlet weak var btnReset: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addBackButton(str: "")
    }
    
    @IBAction func btnResetAction(_ sender: Any) {
        let vc = UpdatePasswordVC.getVC(.home)
        vc.comesFrom = "ForgotPasswordOTP"
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
