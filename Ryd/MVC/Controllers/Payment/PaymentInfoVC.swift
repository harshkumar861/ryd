//
//  PaymentInfoVC.swift
//  DriverApp
//
//  Created by Prepladder on 22/04/21.
//  Copyright © 2021 Harsh. All rights reserved.
//

import UIKit
import SDWebImage

class PaymentTBCell : UITableViewCell {

    @IBOutlet weak var imgRadio: UIImageView!
    @IBOutlet weak var lblAccountNo: UILabel!
    @IBOutlet weak var imgATMType: UIImageView!
    
}

class PaymentInfoVC: UIViewController {
    
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var tbl: UITableView!
    var objLoginResponse : LoginResponse?
    var objApiManager = ApiManager()
    @IBOutlet weak var vwNoDataFound: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("objLoginResponse ",objLoginResponse?.user?.cards)
        addBackButton(str: "")
        setData()
        tbl.delegate = self
        tbl.dataSource = self
    }
    
    func setData() {
    
        if self.objLoginResponse?.user?.cards == nil {
            self.vwNoDataFound.isHidden = false
        }else{
            self.vwNoDataFound.isHidden = true
        }
        
        let imgUrl = objApiManager.BASE_URL + /self.objLoginResponse?.user?.image?.original
        imgVw.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: Asset.IcDummyUser.rawValue))
    }
       
    @IBAction func applyBtnAction(_ sender: Any) {
        
    }
    
    @IBAction func addNewPaymentMethod(_ sender: Any) {
        let vc = AddDebitCardVC.getVC(.payment)
        vc.objLoginResponse = self.objLoginResponse
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

extension PaymentInfoVC : UITableViewDelegate ,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  : PaymentTBCell?
        cell = tableView.dequeueReusableCell(withIdentifier: "PaymentTBCell", for: indexPath) as? PaymentTBCell
        
        let lastDigit = objLoginResponse?.user?.cards?.cardNumber?.suffix(4)
    
        cell?.lblAccountNo.text = "*" + String(lastDigit ?? "0000")
        
        if objLoginResponse?.user?.cards?.cardType == "Visa" {
            cell?.imgATMType?.image = #imageLiteral(resourceName: "Ic_VisaCard")
        } else if objLoginResponse?.user?.cards?.cardType == "Master Card" {
            cell?.imgATMType?.image = #imageLiteral(resourceName: "Ic_MasterCard")
        } else if objLoginResponse?.user?.cards?.cardType == "Amex" {
            cell?.imgATMType?.image = #imageLiteral(resourceName: "Ic_AMEX")
        
        }else if objLoginResponse?.user?.cards?.cardType == "Discover" {
            cell?.imgATMType?.image = #imageLiteral(resourceName: "Ic_Discover")
        }
        
        return cell ?? UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
