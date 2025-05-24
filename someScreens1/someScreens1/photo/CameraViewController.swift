//
//  CameraViewController.swift
//  someScreens1
//
//  Created by andriy kruglyanko on 05.05.2025.
//


import UIKit
import AVFoundation
import SwiftyBeaver

// MARK: - Protocol for Image Selection
protocol CameraViewControllerDelegate: AnyObject {
    func didSelectedImage(_ image: UIImage)
}

class CameraViewController: UIViewController {

//    weak var delegate: ImageSelectionDelegate?
    weak var delegateToPrevious: CameraViewControllerDelegate?


//    private var capturedImage: UIImage

    // Camera capture properties
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var photoOutput: AVCapturePhotoOutput?
    
    // UI Elements
    private let previewView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let captureButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.tintColor = .white
        button.layer.cornerRadius = 35
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let flipCameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.rotate"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Track which camera is active
    private var currentCameraPosition: AVCaptureDevice.Position = .back
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkCameraPermissions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Start the camera when the view appears if the session is not running
        SwiftyBeaver.debug(" self.navigationController.viewControllers = \(self.navigationController?.viewControllers ?? [])")
        SwiftyBeaver.debug(" self.presentationController = \(String(describing: self.presentationController))")
        if let captureSession = captureSession, !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Stop the session when the view disappears
        if let captureSession = captureSession, captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Add subviews
        view.addSubview(previewView)
        view.addSubview(captureButton)
        view.addSubview(flipCameraButton)
        
        // Set constraints
        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: view.topAnchor),
            previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            captureButton.widthAnchor.constraint(equalToConstant: 70),
            captureButton.heightAnchor.constraint(equalToConstant: 70),
            
            flipCameraButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            flipCameraButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            flipCameraButton.widthAnchor.constraint(equalToConstant: 44),
            flipCameraButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Add button actions
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        flipCameraButton.addTarget(self, action: #selector(flipCamera), for: .touchUpInside)
    }
    
    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // Permission already granted, set up the camera
            setupCamera()
        case .notDetermined:
            // Request permission
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCamera()
                    }
                } else {
                    self?.handleDeniedPermission()
                }
            }
        case .denied, .restricted:
            handleDeniedPermission()
        @unknown default:
            SwiftyBeaver.debug("Unknown authorization status")
        }
    }
    
    private func handleDeniedPermission() {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(
                title: "Camera Access Required",
                message: "Please allow camera access in Settings to use this feature.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            })
            
            self?.present(alert, animated: true)
        }
    }
    
    private func setupCamera() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Initialize the capture session
            self.captureSession = AVCaptureSession()
            self.captureSession?.sessionPreset = .photo
            
            // Set up the device input
            guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: backCamera) else {
                SwiftyBeaver.debug("Unable to access back camera")
                return
            }
            
            // Add input to the session
            if self.captureSession?.canAddInput(input) == true {
                self.captureSession?.addInput(input)
                self.currentCameraPosition = .back
            }
            
            // Set up the photo output
            self.photoOutput = AVCapturePhotoOutput()
            if let photoOutput = self.photoOutput,
               self.captureSession?.canAddOutput(photoOutput) == true {
                self.captureSession?.addOutput(photoOutput)
            }
            
            // Start the session
            self.captureSession?.startRunning()
            
            // Set up the preview layer
            DispatchQueue.main.async { [weak self] in
                guard let self = self, let captureSession = self.captureSession else { return }
                
                self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                self.videoPreviewLayer?.videoGravity = .resizeAspectFill
                self.videoPreviewLayer?.frame = self.previewView.bounds
                
                if let previewLayer = self.videoPreviewLayer {
                    self.previewView.layer.addSublayer(previewLayer)
                }
            }
        }
    }
    
    @objc private func capturePhoto() {
        guard let photoOutput = photoOutput else { return }
        
        // Configure photo settings
        let photoSettings = AVCapturePhotoSettings()
        if let photoPreviewPixelType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewPixelType]
        }
        
        // Capture the photo
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    @objc private func flipCamera() {
        guard let session = captureSession else { return }
        
        // Begin configuration
        session.beginConfiguration()
        
        // Remove existing input
        if let existingInput = session.inputs.first as? AVCaptureDeviceInput {
            session.removeInput(existingInput)
        }
        
        // Get new camera position
        let newPosition: AVCaptureDevice.Position = (currentCameraPosition == .back) ? .front : .back
        
        // Get the appropriate camera for the new position
        guard let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition),
              let newInput = try? AVCaptureDeviceInput(device: newCamera) else {
            // If failed, try to add back the original camera
            if let existingInput = session.inputs.first as? AVCaptureDeviceInput {
                session.addInput(existingInput)
            }
            session.commitConfiguration()
            return
        }
        
        // Add new input
        if session.canAddInput(newInput) {
            session.addInput(newInput)
            currentCameraPosition = newPosition
        }
        
        // Commit configuration
        session.commitConfiguration()
    }
    
    // Function to handle the captured photo for upload
    private func uploadCapturedImage(_ image: UIImage) {
        // API endpoint
        let uploadURL = "https://api.example.com/upload"
        
        // Upload the image
        uploadPhoto(image: image, to: uploadURL) { result in
            switch result {
            case .success(let responseData):
                if let responseString = String(data: responseData, encoding: .utf8) {
                    SwiftyBeaver.debug("Upload successful! Response: \(responseString)")
                } else {
                    SwiftyBeaver.debug("Upload successful! Received binary response.")
                }
            case .failure(let error):
                SwiftyBeaver.debug("Upload failed: \(error.localizedDescription)")
            }
        }
    }
    
    // Image upload function (from previous example)
    func uploadPhoto(image: UIImage, to urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
        // Convert UIImage to binary Data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageConversionError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }
        
        // Create URL and request
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "URLError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.httpBody = imageData
        
        // Create and start URLSession task
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "ResponseError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            
            // Check status code
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "ServerError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server returned status code \(httpResponse.statusCode)"])))
                return
            }
            
            if let data = data {
                completion(.success(data))
            } else {
                completion(.failure(NSError(domain: "DataError", code: 4, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            }
        }
        
        task.resume()
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            SwiftyBeaver.debug("Error capturing photo: \(error.localizedDescription)")
            return
        }
        
        // Get the image data
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            SwiftyBeaver.debug("Unable to convert photo to image")
            return
        }
        self.navigationController?.popToViewController(ofClass: UITabBarController.self)
        dismiss(animated: true) {
            //            // Example: You could upload the photo here
            //            // self.uploadCapturedImage(self.capturedImage)
            //
            // Or notify a delegate that the photo was selected
            DispatchQueue.main.async {
                SwiftyBeaver.debug(" self.delegateToPrevious = \(String(describing: self.delegateToPrevious))")
                self.delegateToPrevious?.didSelectedImage(image)
            }
        }

        // Here you have the captured image
        // You can either present it for preview, save it, or upload it
        
        // Example: Present a preview controller
//        DispatchQueue.main.async { [weak self] in
//            SwiftyBeaver.debug("CameraViewController didFinishProcessingPhoto self.navigationController.viewControllers = \(self?.navigationController?.viewControllers ?? [])")
//            SwiftyBeaver.debug(" self.presentationController = \(String(describing: self?.presentationController))")
//            let previewVC = ImagePreviewViewController(image: image)
////            DispatchQueue.main.async {
////                SwiftyBeaver.debug(" self.delegate = \(String(describing: self?.delegate))")
//                SwiftyBeaver.debug(" self.delegateToPrevious = \(String(describing: self?.delegateToPrevious))")
//                //self?.delegateToPrevious? = self //as! any CameraViewControllerDelegate
//                self?.delegateToPrevious?.didSelectedImage(image)
//                //self?.delegate?.didSelectImage(image)
////            }
//
////            (self?.navigationController?.viewControllers[0] as? UITabBarController)?.navigationController?.pushViewController(previewVC, animated: true)
////            present(previewVC, animated: true)
////            self?.present(previewVC, animated: true)
//
//            // Example: Upload the image
//            // self?.uploadCapturedImage(image)
//        }
    }
}

// MARK: - Image Selection Delegate Implementation
extension CameraViewController: ImageSelectionDelegate {
    func didSelectImage(_ image: UIImage) {
        SwiftyBeaver.debug(" image= \(String(describing: image))")
//        capturedImage = image
    }
}
