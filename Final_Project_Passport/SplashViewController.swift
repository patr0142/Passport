//
//  SplashViewController.swift
//  Final_Project_Passport
//
//  Created by Katelyn Patrick on 2020-12-06.
//  Copyright © 2020 Katelyn Patrick. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Delay start after 3 seconds the splash screen will segue to the Passport tableview page
        perform(#selector(startApp), with: nil, afterDelay: 3.0)
    }
    @objc func startApp () {
        performSegue(withIdentifier: "SegueToPassport", sender: self)
    }

}
