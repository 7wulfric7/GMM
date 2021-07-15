//
//  ResetPasswordInfoViewController.swift
//  GMM
//
//  Created by Deniz Adil on 15.7.21.
//

import UIKit

class ResetPasswordInfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func backToLogin(_ sender: UIButton) {
        presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }

}
