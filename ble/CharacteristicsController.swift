//
//  CharacteristicsTableViewController.swift
//  Example
//
//  Created by Kacper Harasim on 14.04.2016.
//  Copyright © 2016 Polidea. All rights reserved.
//

import UIKit
import RxBluetoothKit
import RxSwift

class CharacteristicsController: UIViewController {

    
    @IBOutlet weak var btnaa: UIButton!
    
    @IBOutlet weak var btndd: UIButton!
    var service: Service!
    static var shareCharacteristicsList: [Characteristic] = []
    private let disposeBag = DisposeBag()

    @IBOutlet weak var characteristicsTableView: UITableView!
    
    private var characteristicsList: [Characteristic] = []
    private let characteristicCellId = "CharacteristicCell"
    static let command:[String:[UInt32]] = ["打开1":[0xAA],"打开2":[0xBB],"打开3":[0xCC],"关闭":[0xDD]]
    class func performComond(to:String,commond:String){
        if  CharacteristicsController.shareCharacteristicsList.count < 1 {
            return
        }
        let characteristic = CharacteristicsController.shareCharacteristicsList[0]
        let arr = CharacteristicsController.command[commond]
        
        if arr != nil {
            characteristic.writeValue(NSData(bytes: arr!, length: arr!.count), type: .WithResponse).subscribe{event in
                
            }
        }
      
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        characteristicsTableView.delegate = self
        characteristicsTableView.dataSource = self
        characteristicsTableView.estimatedRowHeight = 40.0
        characteristicsTableView.rowHeight = UITableViewAutomaticDimension
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getCharacteristicsForService(service)
    }

    private func getCharacteristicsForService(service: Service) {
        service.discoverCharacteristics(nil)
            .subscribeNext { characteristics in
                self.characteristicsList = characteristics
               CharacteristicsController.shareCharacteristicsList = characteristics
                self.characteristicsTableView.reloadData()
            }.addDisposableTo(disposeBag)
    }

    private func setNotificationsState(enabled enabled: Bool, characteristic: Characteristic) {
        characteristic.setNotifyValue(enabled)
            .subscribeNext {
                self.refreshCharacteristic($0)
            }.addDisposableTo(disposeBag)
    }

    private func showWriteFieldForCharacteristic(characteristic: Characteristic) {
        let valueWriteController = UIAlertController(title: "Write value", message: "Specify value in HEX to write ",
                                                     preferredStyle: .Alert)
        valueWriteController.addTextFieldWithConfigurationHandler { textField in

        }
        valueWriteController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        valueWriteController.addAction(UIAlertAction(title: "Write", style: .Default) { _ in
            print("")
            })
    }

    private func triggerValueReadForCharacteristic(characteristic: Characteristic) {
        characteristic.readValue()
            .subscribeNext {
                self.refreshCharacteristic($0)
            }.addDisposableTo(disposeBag)
    }

    private func refreshCharacteristic(characteristic: Characteristic) {
        characteristicsTableView.reloadData()
    }
}

extension CharacteristicsController: UITableViewDataSource, UITableViewDelegate {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characteristicsList.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(characteristicCellId, forIndexPath: indexPath)
        let characteristic = characteristicsList[indexPath.row]
        if let cell = cell as? CharacteristicTableViewCell {
            cell.updateWithCharacteristic(characteristic)
        }
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let characteristic = characteristicsList[indexPath.row]
        let actionSheet = UIAlertController(title: "Choose action", message: nil, preferredStyle: .ActionSheet)

        if characteristic.properties.contains(.Notify) {
            let turnNotificationOffAction = UIAlertAction(title: "Turn OFF notifications", style: .Default) { _ in
                self.setNotificationsState(enabled: false, characteristic: characteristic)
            }
            let turnNotificationOnAction = UIAlertAction(title: "Turn ON notifications", style: .Default) { _ in
                self.setNotificationsState(enabled: true, characteristic: characteristic)
            }
            actionSheet.addAction(turnNotificationOffAction)
            actionSheet.addAction(turnNotificationOnAction)
        }
        if characteristic.properties.contains(.Read) {
            let readValueNotificationAction = UIAlertAction(title: "Trigger value read", style: .Default) { _ in
                self.triggerValueReadForCharacteristic(characteristic)
            }
            actionSheet.addAction(readValueNotificationAction)
        }
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }

    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "CHARACTERISTICS"
    }
    
    @IBAction func writeaa(sender: AnyObject) {
         let characteristic = characteristicsList[0]
        let arr: [UInt32] = [0xAA]
        characteristic.writeValue(NSData(bytes: arr, length: arr.count), type: .WithResponse).subscribe{event in
        
        }
    }
    
    @IBAction func writedd(sender: AnyObject) {
        let characteristic = characteristicsList[0]
        let arr: [UInt32] = [0xDD]
        characteristic.writeValue(NSData(bytes: arr, length: arr.count), type: .WithResponse).subscribe{event in
            
        }
    }
}

extension CharacteristicTableViewCell {
    func updateWithCharacteristic(characteristic: Characteristic) {
        self.UUIDLabel.text = characteristic.UUID.UUIDString
        self.isNotifyingLabel.text = characteristic.isNotifying ? "true" : "false"
        self.valueLabel.text = characteristic.value?.hexadecimalString ?? "Empty"
    }
}




