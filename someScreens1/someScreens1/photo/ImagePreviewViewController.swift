//
//  ImagePreviewViewController.swift
//  someScreens1
//
//  Created by andriy kruglyanko on 05.05.2025.
//

import UIKit
import SwiftyBeaver


// MARK: - Protocol for Image Selection
protocol ImageSelectionDelegate: AnyObject {
    func didSelectImage(_ image: UIImage)
}

class ImagePreviewViewController: UIViewController {

    weak var delegate: ImageSelectionDelegate?

    private let capturedImage: UIImage
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .black
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let useButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Use Photo", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let retakeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Retake", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(image: UIImage) {
        self.capturedImage = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Set the image
        imageView.image = capturedImage
        
        // Add subviews
        view.addSubview(imageView)
        view.addSubview(useButton)
        view.addSubview(retakeButton)
        
        // Set constraints
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            useButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            useButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            useButton.widthAnchor.constraint(equalToConstant: 120),
            useButton.heightAnchor.constraint(equalToConstant: 50),
            
            retakeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            retakeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            retakeButton.widthAnchor.constraint(equalToConstant: 120),
            retakeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Add button actions
        useButton.addTarget(self, action: #selector(usePhoto), for: .touchUpInside)
        retakeButton.addTarget(self, action: #selector(retakePhoto), for: .touchUpInside)
    }
    
    @objc private func usePhoto() {
        // Here you can implement what to do with the photo
        // For example, upload it or pass it back to the parent view controller
        SwiftyBeaver.debug(" self.navigationController.viewControllers = \(self.navigationController?.viewControllers ?? [])")
        SwiftyBeaver.debug(" self.presentationController = \(String(describing: self.presentationController))")
//        self.navigationController?.popToViewController(<#T##viewController: UIViewController##UIViewController#>, animated: <#T##Bool#>)
        DispatchQueue.main.async {
            SwiftyBeaver.debug(" self.delegate = \(String(describing: self.delegate))")
            self.delegate?.didSelectImage(self.capturedImage)
        }
        self.navigationController?.popToViewController(ofClass: UITabBarController.self)
//        popToRootViewController(animated: true)
        dismiss(animated: true) {
            //            // Example: You could upload the photo here
            //            // self.uploadCapturedImage(self.capturedImage)
            //
            //            // Or notify a delegate that the photo was selected
            DispatchQueue.main.async {
                SwiftyBeaver.debug(" self.delegate = \(String(describing: self.delegate))")
                self.delegate?.didSelectImage(self.capturedImage)
            }
        }
    }
    
    @objc private func retakePhoto() {
        SwiftyBeaver.debug(" self.navigationController.viewControllers = \(self.navigationController?.viewControllers ?? [])")
        SwiftyBeaver.debug(" self.presentationController = \(String(describing: self.presentationController))")
        dismiss(animated: true)
    }
}
