//
//  HomeVC.swift
//  DriverApp
//
//  Created by Harsh on 09/04/21.
//  Copyright © 2021 Harsh. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import AVFoundation
import Alamofire
import SwiftyJSON
import GooglePlaces
import SDWebImage
import CircleProgressView

enum TextType : String {
    case source = "Source"
    case destination = "Destination"
}

struct Destination {
    var address : String?
    var lat : String?
    var lng : String?
}

class PriceColVwCell : UICollectionViewCell {
    @IBOutlet weak var lblPriceLarge: UILabel!
    @IBOutlet weak var lblTitleLarge: UILabel!
    @IBOutlet weak var lblDescLarge: UILabel!
}

class HomeVC: UIViewController, CLLocationManagerDelegate,OnlineUpdate,UNUserNotificationCenterDelegate {
    func onlinestatus() {
        
    }
    
    
    
    var objOTPAuthResponse : OTPAuthResponse?
    var objLoginResponse : LoginResponse?
    var objApi = ApiManager()
    var locationManager = CLLocationManager()
    var objRoute : RouteModel?
    var objDriver : Driver?
    var textType = ""
    var objSocketResponse = [SocketModel]()
    var carListArray = [FindServiceResponse]()
    var autocompleteResults :[GApiResponse.Autocomplete] = []
    var sourceCoordinates : CLLocationCoordinate2D?
    var destinationCoordinates : CLLocationCoordinate2D?
    var destinationArray = NSMutableArray()
    
    @IBOutlet weak var vwStack: UIStackView!
    
    @IBOutlet weak var BtnMenu: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var vwBottomOnlineStatus: UIView!
    @IBOutlet weak var vwTopDirection: UIView!
    @IBOutlet weak var bottomPickupRideStackView: UIStackView!
    @IBOutlet weak var vwBottomPickUPinformation: UIView!
    @IBOutlet weak var vwBottomRiderInformation: UIView!
    @IBOutlet weak var vwTopHeight: NSLayoutConstraint!
    @IBOutlet weak var vwBottomOnlineHeight: NSLayoutConstraint!
    @IBOutlet weak var vwTopSearchLocation: UIView!
    
    @IBOutlet weak var lblReachTimeDistance: UILabel!
    @IBOutlet weak var lblPickUPAddress: UILabel!
    @IBOutlet weak var lblRiderName: UILabel!
    @IBOutlet weak var lblCurrentLocationName: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var imgVwRider: UIImageView!
    
    
    @IBOutlet weak var txtSource: UITextField!
    @IBOutlet weak var txtDestination: UITextField!
    @IBOutlet weak var tblCarList: UITableView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var vwProgress: CircleProgressView!
    
    @IBOutlet weak var vwFetchRide: UIView!
    @IBOutlet weak var vwDriverInfo: UIView!
    @IBOutlet weak var vwConfirmCancelTrip: UIView!
    @IBOutlet weak var vwDropOffInfo: UIView!
    @IBOutlet weak var vwCarlist: UIView!
    
    @IBOutlet weak var btnSelect: UIButton!
    @IBOutlet weak var btnSchedule: UIButton!
    @IBOutlet weak var imgVwProgress: UIImageView!
    
    @IBOutlet weak var lblOutSide: UILabel!
    @IBOutlet weak var lblDriverName: UILabel!
    @IBOutlet weak var lblCarType: UILabel!
    @IBOutlet weak var lblCarNumber: UILabel!
    @IBOutlet weak var lblCarName: UILabel!
    @IBOutlet weak var imgVwDriver: UIImageView!
    @IBOutlet weak var imgVwCar: UIImageView!
    
    @IBOutlet weak var vwWaitingTimer: UIView!
    @IBOutlet weak var lblWaitingTimer: UILabel!
    
    
    @IBOutlet weak var lblFirstStop: UILabel!
    @IBOutlet weak var lblEndStop: UILabel!
    
    
    var rightSide = false
    var leftSide = true
    var isRiderInfoExpand = false
    var isUserOnline = false
    var selectedRow = -1
    
    //MARK:- Audio
    var gameTimer: Timer?
    var audioPlayer = AVAudioPlayer()
    var waitingTimer: Timer?
    var waitTime = 0
    
    //MARK:- Count Down Progress
    let timeLeftShapeLayer = CAShapeLayer()
    let bgShapeLayer = CAShapeLayer()
    var timeLeft = 0
    var endTime: Date?
    var timer = Timer()
    // here you create your basic animation object to animate the strokeEnd
    let strokeIt = CABasicAnimation(keyPath: "strokeEnd")
    
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CLLocationManager.locationServicesEnabled() {
            switch (CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                print("No access")
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
            }
        } else {
            print("Location services are not enabled")
        }
        
        setOnline()
        
        UDManager.set(true, forKey: UDKeys.IS_LOGGED_IN)
        txtSource.delegate = self
        txtDestination.delegate = self
        
        NotificationCenter.default.addObserver(self,selector: #selector(getCarlistfromServer(_:)),name: .showDriverCar,object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(removeCarfromServer(_:)),name: .removeCar,object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(carlists(_:)),name: .carLists,object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(acceptRide(_:)),name: .acceptRide,object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(declineRide(_:)),name: .declineRide, object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(outSideDriver(_:)),name: .outSideDriver, object: nil)
        
        
        NotificationCenter.default.addObserver(self,selector: #selector(showndRideCars(_:)),name: .showndRideCars, object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(startWaiting(_:)),name: .startWaiting,object: nil)
        
        
        NotificationCenter.default.addObserver(self,selector: #selector(startDestination(_:)),name: .startDestination,object: nil)
        
        
        NotificationCenter.default.addObserver(self,selector: #selector(endWaiting(_:)),name: .endWaiting,object: nil)
        
        
        NotificationCenter.default.addObserver(self,selector: #selector(endDestination(_:)),name: .endDestination,object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(endTrip(_:)),name: .endTrip,object: nil)
        
        
        NotificationCenter.default.addObserver(self,selector: #selector(cancelRyd(_:)),name: .cancelRyd,object: nil)
        
        vwBottomOnlineStatus.isHidden = true
        vwBottomOnlineHeight.constant = 0
        
        self.userNotificationCenter.delegate = self
        
        requestNotificationAuthorization()
       
    }
    
    
    
    
    func requestNotificationAuthorization() {
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
        
        self.userNotificationCenter.requestAuthorization(options: authOptions) { (success, error) in
            if let error = error {
                print("Error: ", error)
            }
        }
        
        
    }
    
    
    @objc func startDestination(_ notification: Notification){
        
        let dataArray = notification.userInfo?["userInfo"] as? [Any]
        if /dataArray?.count > 0 {
            
            
            print(" Start Destination ",dataArray as Any)
            
            
            
            self.waitingTimer?.invalidate()
            self.vwWaitingTimer.removeFromSuperview()
            
            UIView.animate(withDuration: 0.5,
                           delay: 0, usingSpringWithDamping: 1.0,
                           initialSpringVelocity: 1.0,
                           options: .curveEaseIn, animations: {
                            self.vwDropOffInfo.frame = CGRect(x: 0, y: self.view.frame.height - 260 , width: self.view.frame.width, height: 250)
                            self.view?.addSubview(self.vwDropOffInfo)
                           }, completion: nil)
        
            
            let dict = dataArray?[0] as? NSDictionary
            
            let driverLat = dict?.value(forKey: "lat") as? String
            let driverLong = dict?.value(forKey: "lng") as? String
            var firstStop = dict?.value(forKey: "address") as? String
            
            let source = CLLocationCoordinate2D(latitude: /self.locationManager.location?.coordinate.latitude, longitude: /self.locationManager.location?.coordinate.longitude)
            let destination = CLLocationCoordinate2D(latitude: CLLocationDegrees(/driverLat) ?? CLLocationDegrees(), longitude: CLLocationDegrees(/driverLong) ?? CLLocationDegrees())
            self.fetchRoute(from: source, to: destination)
            
            lblFirstStop.text = "First Stop : " + /firstStop
            lblEndStop.text = "End : " + /firstStop
            
            
        }
        
       
    }

    
    @objc func endDestination(_ notification: Notification){
        print("END Destination")
        let dataArray = notification.userInfo?["userInfo"] as? [Any]
        if /dataArray?.count > 0 {
        
//            var dict = NSDictionary()
//            dict = dataArray?[0] as? NSDictionary ?? ["":""]
//
//            vwDriverInfo.removeFromSuperview()
//            let vc = FinishTripVC.getVC(.tripDetails)
//            vc.modalPresentationStyle = .fullScreen
//            vc.dict = dict
//            vc.objDriver = self.objDriver
//            self.navigationController?.present(vc, animated: true, completion: nil)
            

        }
    }

    @objc func startWaiting(_ notification: Notification){
        print("Start Waiting")
        let dataArray = notification.userInfo?["userInfo"] as? [Any]
        if /dataArray?.count > 0 {

            
        }
    }
    
    
    @objc func endWaiting(_ notification: Notification){
        print("END Waiting")
        let dataArray = notification.userInfo?["userInfo"] as? [Any]
        if /dataArray?.count > 0 {
            //self.btnStartTrip.setTitle(DriverReachStatus.Destination.rawValue, for: .normal)
            
        }
    }
    
    @objc func cancelRyd(_ notification: Notification){
        print("cancelRyd TRIP")
        let dataArray = notification.userInfo?["userInfo"] as? [Any]
        
        if /dataArray?.count > 0 {
            print("cancelRyd TRIP dataArray ",dataArray)
        }
    }

    @objc func endTrip(_ notification: Notification){
        print("END TRIP")
        
        vwDriverInfo.removeFromSuperview()
        
        let dataArray = notification.userInfo?["userInfo"] as? [Any]
        if /dataArray?.count > 0 {

            var dict = NSDictionary()
            dict = dataArray?[0] as? NSDictionary ?? ["":""]

            let vc = FinishTripVC.getVC(.tripDetails)
            vc.modalPresentationStyle = .fullScreen
            vc.dict = dict
            vc.objDriver = self.objDriver
            self.navigationController?.present(vc, animated: true, completion: nil)
            
//            let vc = FinishTripVC.getVC(.tripDetails)
//            self.navigationController?.present(vc, animated: true, completion: nil)
            
        }
    }
    
    
    func sendNotification() {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Ryd"
        notificationContent.body = "Your driver is coming outside"
        //notificationContent.badge = NSNumber(value: 3)
        
        if let url = Bundle.main.url(forResource: "dune",
                                     withExtension: "png") {
            if let attachment = try? UNNotificationAttachment(identifier: "dune",
                                                              url: url,
                                                              options: nil) {
                notificationContent.attachments = [attachment]
            }
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1,
                                                        repeats: false)
        let request = UNNotificationRequest(identifier: "testNotification",
                                            content: notificationContent,
                                            trigger: trigger)
        
        userNotificationCenter.add(request) { (error) in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
    }
    
    
    @objc func getCarlistfromServer(_ notification: Notification){
        //print(notification.userInfo?["userInfo"] as Any)
        self.objSocketResponse.removeAll()
        let dataArray = notification.userInfo?["userInfo"] as? [Any]
        for indexx in 0..<dataArray!.count {
            let objArray = dataArray?[indexx] as? NSArray
            for obj in 0..<objArray!.count {
                let dict = objArray?[obj] as? NSDictionary
                let id = dict?["id"] as? String
                let lat = dict?["lat"] as? String
                let lng = dict?["lng"] as? String
                let distance = dict?["distance"] as? Double
                let socketMode = SocketModel(lng: lng, socketID: "", id: id, lat: lat, busy: false, distance: distance)
                self.objSocketResponse.append(socketMode)
            }
        }
        self.showDriverCars()
        
    }
    
    @objc func removeCarfromServer(_ notification: Notification){
        
        print(notification.userInfo?["userInfo"] as Any)
        
        let dataArray = notification.userInfo?["userInfo"] as? [Any]
        for indexx in 0..<dataArray!.count {
            let objArray = dataArray?[indexx] as? NSArray
            for obj in 0..<objArray!.count {
                let driverID = objArray?[obj] as? String
                self.objSocketResponse.removeAll(where: {$0.id == driverID})
            }
        }
        
        self.showDriverCars()
        
    }
    
    
    @objc func carlists(_ notification: Notification){
        let arrayCarlist = notification.userInfo?["userInfo"] as? NSArray
        self.carListArray.removeAll()
        if arrayCarlist!.count > 0 {
            vwBottomOnlineHeight.constant = 90
            vwBottomOnlineStatus.isHidden = false
            for indexx in 0..<arrayCarlist!.count {
                let objArray = arrayCarlist?[indexx] as? NSArray
                for obj in 0..<objArray!.count {
                    let dict = objArray?[obj] as? NSDictionary
                    let amountStr = dict?["amount"] as? Double
                    let distanceStr = dict?["distance"] as? Double
                    let driverIdStr = dict?["driver_id"] as? Int
                    let idStr = dict?["id"] as? Int
                    let minutesStr = dict?["minutes"] as? Double
                    let seatsStr = dict?["seats"] as? Int
                    let titleStr = dict?["title"] as? String
                    let imageStr = dict?["image"] as? String
                    
                    let objDict = FindServiceResponse(amount: amountStr, distance: distanceStr, minutes: minutesStr, driverID: driverIdStr, id: idStr, image: imageStr, seats: seatsStr, title: titleStr)
                   // print("objDict ",objDict)
                    self.carListArray.append(objDict)
                }
            }
            self.vwFetchRide.removeFromSuperview()
            self.showCarlist()
            self.tblCarList.reloadData()
        }
        
        
    }
    
    @objc func showndRideCars(_ notification: Notification){
        let arrayCarlist = notification.userInfo?["userInfo"] as? NSArray
      //  print("showndRideCars CarliSt => ", arrayCarlist)
        if arrayCarlist!.count > 0 {
            let dict = arrayCarlist?[0] as? NSDictionary
            self.dictToData(dictionaryExample: dict ?? ["":""])
        }
    }
    
    
    @objc func acceptRide(_ notification: Notification){
        let dataArray = notification.userInfo?["userInfo"] as? [Any]
        if /dataArray?.count > 0 {
            let dict = dataArray?[0] as? NSDictionary
            let driverDict = dict?.value(forKey: "driver") as? NSDictionary
            let driverLat = driverDict?.value(forKey: "lat") as? String
            let driverLong = driverDict?.value(forKey: "lng") as? String
            _ = driverDict?.value(forKey: "id") as? Int
            let source = CLLocationCoordinate2D(latitude: /self.locationManager.location?.coordinate.latitude, longitude: /self.locationManager.location?.coordinate.longitude)
            let destination = CLLocationCoordinate2D(latitude: CLLocationDegrees(/driverLat) ?? CLLocationDegrees(), longitude: CLLocationDegrees(/driverLong) ?? CLLocationDegrees())
            self.fetchRoute(from: source, to: destination)
            self.vwTopSearchLocation.isHidden = true
            self.vwCarlist.removeFromSuperview()
            self.vwBottomOnlineStatus.isHidden = true
            self.vwBottomOnlineHeight.constant = 0
            self.showDriverInfoPopup()
        }
        
        
    }
    
    @objc func declineRide(_ notification: Notification){
        self.destinationArray.removeAllObjects()
        self.txtSource.text = ""
        self.txtDestination.text = ""
        self.sourceCoordinates = nil
        self.destinationCoordinates = nil
        let dataArray = notification.userInfo?["userInfo"] as? [Any]
        if /dataArray?.count > 0 {
            self.vwCarlist.removeFromSuperview()
            self.mapView.clear()
            locationManager.startUpdatingLocation()
        }
        
        
    }
    
    @objc func outSideDriver(_ notification: Notification){
        let dataArray = notification.userInfo?["userInfo"] as? [Any]
        if /dataArray?.count > 0 {
            sendNotification()
            
          //  vwDriverInfo.removeFromSuperview()
            
            self.lblOutSide.text = "Outside"
            
            
//            UIView.animate(withDuration: 1.5, delay: 0, options: [UIView.AnimationOptions.autoreverse], animations: {
//                self.vwWaitingTimer.frame = CGRect(x: 20, y: 230 , width: self.view.frame.width - 40, height: 210)
//                self.vwWaitingTimer.alpha = 1
//                self.view?.addSubview(self.vwWaitingTimer)
//            }, completion: nil)r
            
            UIView.animate(withDuration: 0.5,
                           delay: 0, usingSpringWithDamping: 1.0,
                           initialSpringVelocity: 1.0,
                           options: .curveEaseIn, animations: {
                            self.vwWaitingTimer.frame = CGRect(x: 20, y: 230 , width: self.view.frame.width - 40, height: 210)
                            self.view?.addSubview(self.vwWaitingTimer)
                           }, completion: nil)
            
            waitingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
        }
    }
    
    @objc func onTimerFires() {
        waitTime += 1
        print("waitTime ",waitTime)
        lblWaitingTimer.text = stringFromTimeInterval(interval: TimeInterval(waitTime))
    }
    
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        //let hours = (interval / 3600)
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func setOnline(){
        mapView.mapType = .terrain
        mapView.isMyLocationEnabled = true
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
    }
    
    func setUpCountDownProgress(){
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    
    func initialSetup(){
        if let savedPerson = UDManager.object(forKey: UDKeys.LOGIN_INFO) as? Data {
            let decoder = JSONDecoder()
            if let loadedPerson = try? decoder.decode(LoginResponse.self, from: savedPerson) {
                print("loadedPerson ",loadedPerson)
                // print("loadedPerson ID ",/loadedPerson.user?.id)
                self.objLoginResponse = loadedPerson
            }
        }
    }
    
    func refreshHomeVC(){
        self.vwTopSearchLocation.isHidden = false
        self.vwBottomOnlineStatus.isHidden = false
        self.vwTopDirection.isHidden = true
        self.vwTopHeight.constant = 0
        self.bottomPickupRideStackView.isHidden = true
        self.vwBottomPickUPinformation.isHidden = true
        self.mapView.clear()
    }
    
    @IBAction func menuBtn(_ sender: Any) {
        let vc = MenuVC.getVC(.main)
        vc.objLoginResponse = self.objLoginResponse
        /*let transition = CATransition()
         transition.duration = 0.5
         transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
         transition.type = CATransitionType.push
         transition.subtype = CATransitionSubtype.fromLeft
         self.view.window?.layer.add(transition, forKey: nil)*/
        //self.view.window!.layer.add(transition, forKey: nil)
        self.navigationController?.pushViewController(vc, animated: false)
        
    }
    
    @IBAction func addMoreStopAction(_ sender: Any) {
        
        print("Count SUB VIEW => ",vwStack.subviews.count)
        for _ in 0...0 {
            UIView.animate(withDuration: 0.5,
                           delay: 0.0,
                           usingSpringWithDamping: 0.9,
                           initialSpringVelocity: 1,
                           options: [],
                           animations: {
                            let textField = UITextField()
                            textField.backgroundColor = UIColor.white
                            textField.borderStyle = .roundedRect
                            textField.tag = self.vwStack.subviews.count + 1
                            textField.delegate = self
                            //self.vwStack.addArrangedSubview(textField)
                            
                            print("textField.tag => ",textField.tag)
                           },
                           completion: nil)
            
        }
    }
    
    
    @IBAction func prefrenceBtnAction(_ sender: Any) {
        
    }
    
    func showDriverInfoPopup() {
        print("objDriver ",objDriver)
        lblDriverName.text = /objDriver?.driverFirstName
        lblCarType.text = /objDriver?.vehicleColor
        lblCarName.text = /objDriver?.vehicleBrand + " " + /objDriver?.vehicleModel
        let minStr: String = String(format: "%.2f", /objDriver?.minutes)
        lblOutSide.text = " Arriving in  \(minStr) mins"
        
//        let imgUrl = self.objApi.BASE_URL + /self.objDriver?.vehicleImage?.medium
//        imgVwCar.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: Asset.IcDummyUser.rawValue))
        
        let imgUrll = self.objApi.BASE_URL + /self.objDriver?.driverImage?.medium
        imgVwDriver.sd_setImage(with: URL(string: imgUrll), placeholderImage: UIImage(named: Asset.IcDummyUser.rawValue))
        
//        UIView.animate(withDuration: 0.5,
//                       delay: 0, usingSpringWithDamping: 1.0,
//                       initialSpringVelocity: 1.0,
//                       options: .curveEaseOut, animations: {
//                        self.vwDriverInfo.frame = CGRect(x: 0, y: self.view.frame.height - 180 , width: self.view.frame.width, height: 180)
//                        self.view?.addSubview(self.vwDriverInfo)
//                       }, completion: nil)
    
        
        vwDriverInfo.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 250)

        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: { [self] in
            self.vwDriverInfo.frame = CGRect(x: 0, y: self.view.frame.height - 250 , width: self.view.frame.width, height: 250)
        }) { finished in
            
            }
        self.view?.addSubview(self.vwDriverInfo)

    
    }
    
    
    func showFetchRidePopup(){
        
//        vwFetchRide.isHidden = false
        
        imgVwProgress.layer.cornerRadius = imgVwProgress.frame.size.height/2
        imgVwProgress.layer.masksToBounds = true
        
        vwFetchRide.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 250)
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: { [self] in
            vwFetchRide.frame = CGRect(x: 0, y: self.view.frame.height - 250, width: self.view.frame.width, height: 250)
        }) { finished in
            
            UIView.animate(withDuration: 1.5, delay: 0, options: [UIView.AnimationOptions.autoreverse, UIView.AnimationOptions.repeat], animations: {
                self.imgVwProgress.alpha = 0.5
            }, completion: nil)
            
        }
        self.view.addSubview(vwFetchRide)
        
    }
    
    
    @IBAction func destinationBtnAction(_ sender: Any) {
        
        if selectedRow != -1 {
            self.getAddress { (address) in
                SocketIOManager.sharedInstance.findRide(userId: "\(/self.objLoginResponse?.user?.id)", userLat: "\(/self.locationManager.location?.coordinate.latitude)", userLong: "\(/self.locationManager.location?.coordinate.longitude)",serviceID: self.selectedRow,destination: self.destinationArray, address: address)
            }
        }
        else {
            self.view.makeToast(AlertMessage.noSelectCar.localized, duration: 3.0, position: .bottom)
        }
        
        
        
        
    }
    
    @IBAction func cancelConfirmAction(_ sender: Any) {
        print("cancelConfirmAction")
        
        self.getAddress { (address) in
            print("address ",address)
         
            SocketIOManager.sharedInstance.cancelRyd2(tripId: "\(String(describing: /self.objDriver?.tripID))", cancelBy: "customer", lat: "\(String(describing: /self.locationManager.location?.coordinate.latitude))", lng: "\(String(describing: /self.locationManager.location?.coordinate.longitude))", location: address)
            
        }

        self.mapView.clear()
        self.vwTopSearchLocation.isHidden = false
        self.destinationArray.removeAllObjects()
        self.txtSource.text = ""
        self.txtDestination.text = ""
        self.sourceCoordinates = nil
        self.destinationCoordinates = nil
        self.vwConfirmCancelTrip.removeFromSuperview()
        self.showDriverCars()
        self.createGoogleMap()
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func cancelFetchRideBtn(_ sender: Any) {
        print("cancelFetchRideBtn")
        self.txtDestination.text = ""
        vwFetchRide.removeFromSuperview()
        self.mapView.clear()
        self.createGoogleMap()
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func cancelRideBtn(_ sender: Any) {
        print("cancelRideBtn")
        self.vwDriverInfo.removeFromSuperview()
        self.vwConfirmCancelTrip.frame = CGRect(x: 0, y: 0 , width: self.view.frame.width - 60, height: self.view.frame.height - 100)
        self.vwConfirmCancelTrip.center = self.view.center
        self.view.addSubview(vwConfirmCancelTrip)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createGoogleMap()
        initialSetup()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    
    
    @IBAction func showRiderInfoAction(_ sender: Any) {
        // self.vwBottomRiderInformation.isHidden = false
        
        self.openNavigationMap(lat: /self.objRoute?.routes?.first?.legs?.first?.endLocation?.lat, long: /self.objRoute?.routes?.first?.legs?.first?.endLocation?.lng)
    }
    
    @IBAction func cancelRiderAction(_ sender: Any) {
        print("cancelRiderActionnnn")
        let vc = CancelRIdeVC.getVC(.activity)
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func chattingRiderAction(_ sender: Any) {
        let vc = ChattingVC.getVC(.activity)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        socketUserId = "\(/self.objLoginResponse?.user?.id)"
        let lat = "\(/locationManager.location?.coordinate.latitude)"
        let long = "\(/locationManager.location?.coordinate.longitude)"
        socketUserLat = lat
        socketUserLong = long

        SocketIOManager.sharedInstance.establishConnection()
        
        SocketIOManager.sharedInstance.emitCall(userId: "\(/objLoginResponse?.user?.id)", userLat: "\(/locationManager.location?.coordinate.latitude)", userLong: "\(/locationManager.location?.coordinate.longitude)")
        
        
        SocketIOManager.sharedInstance.getDriverList()
        
        SocketIOManager.sharedInstance.getOfflineDriver()
        
        SocketIOManager.sharedInstance.findServices()
        
        SocketIOManager.sharedInstance.findRides()
        
        SocketIOManager.sharedInstance.acceptRide()
        
        SocketIOManager.sharedInstance.declineRide()
        
        SocketIOManager.sharedInstance.driverOutSide()
        
        SocketIOManager.sharedInstance.cancelRyd2()
        
        SocketIOManager.sharedInstance.updateLocation()
        
        SocketIOManager.sharedInstance.startDestination()
        
        
        SocketIOManager.sharedInstance.endDestination()
        
        
        SocketIOManager.sharedInstance.endTrip()
        
        self.getAddress { (address) in
            print("address ",address)
            self.txtSource.text = /address
            self.sourceCoordinates = CLLocationCoordinate2D(latitude: /self.locationManager.location?.coordinate.latitude, longitude: /self.locationManager.location?.coordinate.longitude)
        }
        
    }
    
}
extension HomeVC {
    func createGoogleMap(){
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 30)
        
        locationManager.delegate = self;
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.distanceFilter = kCLDistanceFilterNone
        if #available(iOS 11.0, *) {
            locationManager.showsBackgroundLocationIndicator = true
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    func showCovidPopUP(){
        let vc = CovidVC.getVC(.main)
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        self.navigationController?.present(vc, animated: true, completion: nil)
    }

    
    
    @objc func updateTime() {
        if timeLeft <= 10 {
            print("TIME LEFTttttt => ",timeLeft)
            self.vwProgress.progress =  Double(timeLeft / 100)
            print("TIME LEFT => ",Double(timeLeft / 100))
            timeLeft = timeLeft + 1
        } else {
            
            vwFetchRide.removeFromSuperview()
            timer.invalidate()
            self.gameTimer?.invalidate()
            self.audioPlayer.stop()
            
        }
    }
    
    @IBAction func sourceTextTapped(_ sender: Any) {
        txtSource.resignFirstResponder()
        textType = TextType.source.rawValue
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        present(acController, animated: true, completion: nil)
    }
    
    @IBAction func destinationTextTapped(_ sender: Any) {
        txtDestination.resignFirstResponder()
        textType = TextType.destination.rawValue
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        present(acController, animated: true, completion: nil)
    }
}


extension HomeVC : RideCancelDelegate {
    
    func cancelRide() {
        print("cancel Rideeee")
        refreshHomeVC()
        self.vwTopDirection.isHidden = true
        self.mapView.isMyLocationEnabled = true
        gameTimer?.invalidate()
    }
    
    
}

extension HomeVC : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing")
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("shouldChangeCharactersIn")
        return true
    }
    
}



extension HomeVC: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        // print(place)
        let arrrayDestination = NSMutableArray()
        if textType == TextType.source.rawValue {
            txtSource.text = place.formattedAddress
            self.sourceCoordinates = place.coordinate
            
            if sourceCoordinates != nil && destinationCoordinates != nil {
                
                // MARK:- Draw Polyline
                
                fetchRoute(from: self.sourceCoordinates!, to: self.destinationCoordinates!)
                

                let objDestination = setDestinationAddress(address: /txtDestination.text, lat: "\(/destinationCoordinates?.latitude)", long: "\(/destinationCoordinates?.longitude)")
                arrrayDestination.add(objDestination)
                
                if objSocketResponse.count > 0 {
                    SocketIOManager.sharedInstance.sendServiceData(userId: "\(/objLoginResponse?.user?.id)", userLat: "\(/locationManager.location?.coordinate.latitude)", userLong: "\(/locationManager.location?.coordinate.longitude)",address: /txtSource.text,destinations: arrrayDestination)
                    self.showFetchRidePopup()
                } else {
                    self.view.makeToast(AlertMessage.noDriverFound.localized, duration: 3.0, position: .bottom)
                    
                }
            }
            let destination = self.setSourceAddress(address: /place.formattedAddress, lat: "\(/self.sourceCoordinates?.latitude)", long: "\(/self.sourceCoordinates?.longitude)")
            self.destinationArray.insert(destination, at: 0)
            
        } else if textType == TextType.destination.rawValue  {
            txtDestination.text = place.formattedAddress
            self.destinationCoordinates = place.coordinate
            if sourceCoordinates != nil && destinationCoordinates != nil {
                fetchRoute(from: self.sourceCoordinates!, to: self.destinationCoordinates!)
                print("objSocketResponse ",objSocketResponse)
                
                let objDestination = setDestinationAddress(address: /txtDestination.text, lat: "\(/destinationCoordinates?.latitude)", long: "\(/destinationCoordinates?.longitude)")
                arrrayDestination.add(objDestination)
                
                print("arrrayDestination ",arrrayDestination)
                
                if objSocketResponse.count > 0 {
                    SocketIOManager.sharedInstance.sendServiceData(userId: "\(/objLoginResponse?.user?.id)", userLat: "\(/locationManager.location?.coordinate.latitude)", userLong: "\(/locationManager.location?.coordinate.longitude)",address: /txtSource.text,destinations: arrrayDestination)
                    self.showFetchRidePopup()
                }
                else {
                    self.view.makeToast(AlertMessage.noDriverFound.localized, duration: 3.0, position: .bottom)
                }
                
            }
            let destination = self.setDestinationAddress(address: /place.formattedAddress, lat: "\(/self.destinationCoordinates?.latitude)", long: "\(/self.destinationCoordinates?.longitude)")
            self.destinationArray.add(destination)
        
            
        }
        
        
        
        dismiss(animated: true, completion: nil)
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // Handle the error
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func showCarlist() {
        
        //        UIView.animate(withDuration: 0.5,
        //                       delay: 0, usingSpringWithDamping: 1.0,
        //                       initialSpringVelocity: 1.0,
        //                       options: .overrideInheritedCurve, animations: {
        //
        //                        self.view?.addSubview(self.vwCarlist)
        //
        //                        self.vwCarlist.frame = CGRect(x: 0, y: self.view.frame.height - 300 , width: self.view.frame.width, height: 220)
        //
        //
        //                       }, completion: nil)
        
        self.vwFetchRide.removeFromSuperview()

        vwCarlist.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 280)
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: { [self] in
            vwCarlist.frame = CGRect(x: 0, y: self.view.frame.height - 340, width: self.view.frame.width, height: 220)
        }) { finished in
        }
        self.view.addSubview(vwCarlist)
    
    }
    
    
}

extension HomeVC : CarSelected {
    func selectCar(serviceId: Int) {
        
        SocketIOManager.sharedInstance.findRide(userId: "\(/objLoginResponse?.user?.id)", userLat: "\(/locationManager.location?.coordinate.latitude)", userLong: "\(/locationManager.location?.coordinate.longitude)",serviceID: serviceId,destination: [], address: "Sunam")
    }
    
    
}


//MARK:- Car List Table View

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return carListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CarListTbCell?
        cell = tableView.dequeueReusableCell(withIdentifier: "CarListTbCell", for: indexPath) as? CarListTbCell
        let imgUrl = carListArray[indexPath.row].image
        print("carListArray ",carListArray)
        cell?.imgVw.sd_setImage(with: URL(string: /imgUrl), placeholderImage: #imageLiteral(resourceName: "car_XS"))
        cell?.lblCarName.text =  /carListArray[indexPath.row].title
        let tipText: String = String(format: "%.2f", /carListArray[indexPath.row].amount)
        cell?.lblPrice.text = "$ \(tipText)"
        let timeStr: String = String(format: "%.2f", /carListArray[indexPath.row].minutes)
        cell?.lblAwayTime.text = "\(timeStr)" + " minutes away"
        cell?.lblNumberPerson.text = "\(/carListArray[indexPath.row].seats)"
        
        if selectedRow == /carListArray[indexPath.row].id {
            cell?.vwChild.layer.borderColor = UIColor.appColor.cgColor
            cell?.vwChild.layer.borderWidth = 1
        }
        else {
            cell?.vwChild.layer.borderColor = UIColor.clear.cgColor
            cell?.vwChild.layer.borderWidth = 0
        }
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = /carListArray[indexPath.row].id
        btnSelect.layer.borderColor = UIColor.appColor.cgColor
        btnSelect.setTitleColor(UIColor.appColor, for: .normal)
        btnSelect.isUserInteractionEnabled = true
        tblCarList.reloadData()
    }
    
    func setSourceAddress(address: String, lat: String, long: String) -> [String:Any] {
        let sourceParam = [
            "address" : address,
            "lat" : lat,
            "lng" : long,
        ] as [String : Any]
        
        return sourceParam
    }
    
    func setDestinationAddress(address: String, lat: String, long: String) -> [String:Any] {
        let destinationParam = [
            "address" : address,
            "lat" : lat,
            "lng" : long,
        ] as [String : Any]
        
        return destinationParam
    }

    
    func dictToData(dictionaryExample:NSDictionary){
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionaryExample, options: JSONSerialization.WritingOptions.prettyPrinted)
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
            print("jsonString ",jsonString)
            let data = jsonString.data(using: .utf8)!
            let driverData = try! JSONDecoder().decode(Driver.self, from: data)
            //  print("successDataaaa ",driverData)
            self.objDriver = driverData
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        
        
    }
    
}

extension HomeVC {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}
