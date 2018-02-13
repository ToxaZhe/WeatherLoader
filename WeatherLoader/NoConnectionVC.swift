//
//  NoConnectionVC.swift
//  WeatherLoader
//
//  Created by user on 2/12/18.
//  Copyright © 2018 Toxa. All rights reserved.
//

import UIKit

class NoConnectionVC: UIViewController {
    weak var delegate: NoConnectionVCDelegate?
    @IBAction func okButtonPressedAction(_ sender: Any) {
        guard Connectivity.isConnectedToNetwork() == true else {
            DialogHelper.showAlert(title: "Sorry", message: "You are not connected", controller: self, handleAction: {
                self.dismiss(animated: true, completion: nil)
            })
            return
        }
        delegate?.isConnectedToNetwork()
        dismiss(animated: true, completion: nil)
    }
}
