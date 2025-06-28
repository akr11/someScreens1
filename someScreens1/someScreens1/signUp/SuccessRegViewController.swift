//
//  SuccessRegViewController.swift
//  someScreens1
//
//  Created by andriy kruglyanko on 03.06.2025.
//

import UIKit

class SuccessRegViewController: UIViewController {
    @IBOutlet weak var textLabel: UILabel!
    var text: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textLabel.text = text
    }
    
    @IBAction func clickedButton(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
