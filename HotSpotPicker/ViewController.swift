//
//  ViewController.swift
//  HotSpotPicker
//
//  Created by Chandrachudh on 02/04/18.
//  Copyright © 2018 F22Labs. All rights reserved.
//

import UIKit
import NetworkExtension

class ViewController: UIViewController {

    @IBOutlet weak var txtHotspotName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnConnect: UIButton!
    
    var isConnected = false
    var connectedSSID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnConnect.layer.borderColor = btnConnect.titleLabel?.textColor.cgColor
        btnConnect.layer.borderWidth = 1.0
        btnConnect.layer.cornerRadius = 6.0
        
        txtHotspotName.delegate = self
        txtPassword.delegate = self
        
        txtHotspotName.text = "Penguin"
        txtPassword.text = "giveme500bucks!"
        
        disconnectAllSSIDConfigs()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    @IBAction func didTapbuttonConnect(_ sender: Any) {
        
        if isConnected {
            disConnect()
        }
        else {
            
            guard let SSID = txtHotspotName.text else {
                showAlert(message: "Please enter a valid hotspot name", cancelTitle: "OK")
                return
            }
            
            if SSID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                showAlert(message: "Please enter a valid hotspot name", cancelTitle: "OK")
                return
            }
            
            guard let password = txtPassword.text else {
                connectUnsecured(SSID: SSID)
                return
            }
            
            if password.isEmpty {
                connectUnsecured(SSID: SSID)
            }
            else {
                connectSecured(SSID: SSID, passphrase: password)
            }
        }
    }
    
    func connectUnsecured(SSID:String) {
        let hotspotConfig = NEHotspotConfiguration(ssid: SSID)
        connect(hotspotConfig: hotspotConfig)
    }
    
    func connectSecured(SSID:String, passphrase:String) {
        let hotspotConfig = NEHotspotConfiguration(ssid: SSID, passphrase: passphrase, isWEP: false)
        connect(hotspotConfig: hotspotConfig)
    }
    
    func connect(hotspotConfig:NEHotspotConfiguration) {
        isConnected = false
        NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: hotspotConfig.ssid)
        
        NEHotspotConfigurationManager.shared.apply(hotspotConfig) {[unowned self] (error) in

            if let error = error {
                print("error = ",error)
                self.isConnected = false
                self.showAlert(message: error.localizedDescription, cancelTitle: "OK")
            }
            else {
                print("Success!")
                self.isConnected = true
                self.connectedSSID = hotspotConfig.ssid
                self.txtPassword.text = ""
                self.txtHotspotName.text = ""
            }
        }
    }
    
    func disConnect() {
        isConnected = false
        NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: connectedSSID)
        self.connectedSSID = ""
    }
    
    func disconnectAllSSIDConfigs() {
        
        NEHotspotConfigurationManager.shared.getConfiguredSSIDs { (ssids) in
            
            for ssid in ssids {
                print("ssid = ",ssid)
                NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: ssid)
            }
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtHotspotName {
            txtPassword.becomeFirstResponder()
        }
        else {
            view.endEditing(true)
            didTapbuttonConnect(self.btnConnect)
        }
        return true;
    }
}

extension UIViewController {
    func showAlert(message:String, cancelTitle:String) {
        let alertController = UIAlertController.init(title: "Error", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction.init(title: cancelTitle, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}
