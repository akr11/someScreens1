//
//  NoInternetConnectionViewController.swift
//  someScreens1
//
//  Created by andriy kruglyanko on 23.04.2025.
//

import UIKit

class NoInternetConnectionViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var tryConnectionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tryConnectionButton.setTitleColor(UIColor.black, for: .normal)
    }
    
    @IBAction func tryAgainClicked(_ sender: Any) {
        NoInternetConnectionViewController.isConnectedToInternet() { connected in
            if connected {
                self.dismiss(animated: true)
            }
        }
    }

    static func isConnectedToInternet(completion: @escaping (Bool) -> Void) {
            let url = URL(string: "https://www.apple.com")!
            let task = URLSession.shared.dataTask(with: url) { _, response, error in
                let connected = error == nil && (response as? HTTPURLResponse)?.statusCode == 200
                completion(connected)
            }
            task.resume()
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
