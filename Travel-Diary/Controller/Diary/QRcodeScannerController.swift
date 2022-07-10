//
//  QRcodeViewerController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/22.
//

import UIKit
import AVFoundation

class QRcodeScannerController: UIViewController {
    
    var barAppearance = UINavigationBarAppearance()
    let camView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var closeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "xmark"),
                                     style: .done,
                                     target: self,
                                     action: #selector(closeScanner))
        button.tintColor = .customBlue
        return button
    }()
    
    lazy var albumButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.background.image = UIImage(systemName: "photo.on.rectangle.angled")
        config.background.imageContentMode = .scaleAspectFill
        button.configuration = config
        button.addTarget(self, action: #selector(scanAlbumQR), for: .touchUpInside)
        button.tintColor = .customBlue
        return button
    }()
    
    let directionLabel: UILabel = {
        let label = UILabel()
        label.text = "Scan a QR code for quick join other journey"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let qrStringLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        
        // 透明Navigation Bar
        barAppearance.configureWithTransparentBackground()
        navigationController?.navigationBar.scrollEdgeAppearance = barAppearance
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        qrcodeScanner()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        barAppearance.configureWithDefaultBackground()
        navigationController?.navigationBar.scrollEdgeAppearance = barAppearance
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func configureUI() {
        navigationItem.leftBarButtonItem = closeButton
        view.backgroundColor = .white
        view.addSubview(camView)
        camView.addSubview(albumButton)
        view.addSubview(directionLabel)
        view.addSubview(qrStringLabel)
        configureConstraint()
    }
    
    func configureConstraint() {
        camView.anchor(top: view.topAnchor,
                       left: view.leftAnchor,
                       right: view.rightAnchor,
                       height: UIScreen.height * 0.7)
        
        albumButton.anchor(bottom: camView.bottomAnchor,
                           right: camView.rightAnchor,
                           paddingBottom: UIScreen.width * 0.05,
                           paddingRight: UIScreen.width * 0.05,
                           width: UIScreen.width * 0.1,
                           height: UIScreen.width * 0.1)
        
        directionLabel.anchor(top: camView.bottomAnchor,
                              left: view.leftAnchor,
                              right: view.rightAnchor,
                              paddingTop: UIScreen.height * 0.05,
                              paddingLeft: UIScreen.width * 0.1,
                              paddingRight: UIScreen.width * 0.1)
        
        qrStringLabel.anchor(top: directionLabel.bottomAnchor,
                             left: view.leftAnchor,
                             bottom: view.safeAreaLayoutGuide.bottomAnchor,
                             right: view.rightAnchor,
                             paddingTop: UIScreen.height * 0.05,
                             paddingLeft: UIScreen.width * 0.1,
                             paddingBottom: UIScreen.width * 0.1,
                             paddingRight: UIScreen.height * 0.05)
    }
    
    func qrcodeScanner() {
        // 取得後置鏡頭來擷取影片
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            qrStringLabel.text = "Failed to get the camera device"
            return
        }

        do {
            // 使用前一個裝置物件來取得 AVCaptureDeviceInput 類別的實例
            let input = try AVCaptureDeviceInput(device: captureDevice)

            // 在擷取 session 設定輸入裝置
            captureSession.addInput(input)
            
            // 初始化一個 AVCaptureMetadataOutput 物件並將其設定做為擷取 session 的輸出裝置
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // 設定委派並使用預設的調度佇列來執行回呼（call back）
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            // 初始化影片預覽層，並將其作為子層加入 viewPreview 視圖的圖層中
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = camView.layer.bounds
            camView.layer.addSublayer(videoPreviewLayer!)
            camView.bringSubviewToFront(albumButton)
            
            // 開始影片的擷取
            captureSession.startRunning()
            
            // 初始化 QR Code 框來突顯 QR code
            qrCodeFrameView = UIView()

            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 4
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }

        } catch {
            // 假如有錯誤產生、單純輸出其狀況不再繼續執行
            print(error)
            return
        }
    }
    
    @objc func closeScanner() {
        navigationController?.dismiss(animated: true)
    }
    
    @objc func scanAlbumQR() {
        let photoController = UIImagePickerController()
        photoController.delegate = self
        photoController.sourceType = .photoLibrary
        present(photoController, animated: true, completion: nil)
    }
}

extension QRcodeScannerController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        // 檢查  metadataObjects 陣列為非空值，它至少需包含一個物件
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            qrStringLabel.text = "No QR code is detected"
            return
        }

        // 取得元資料（metadata）物件
        guard let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else { return }

        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            // 倘若發現的元資料與 QR code 元資料相同，便更新狀態標籤的文字並設定邊界
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds

            if metadataObj.stringValue != nil {
                qrStringLabel.text = metadataObj.stringValue
                let qrSplit = metadataObj.stringValue?.split(separator: ":")
                if qrSplit?[0] == "Travel-Diary" {
                    guard let id = qrSplit?[1] else { return }
                    JourneyManager.shared.fetchSpecificJourney(id: String(id)) { [weak self] result in
                        switch result {
                        case .success(let journey):
                            let vc = JoinGroupController()
                            vc.journey = journey
                            vc.modalPresentationStyle = .overFullScreen
                            let presentingVC = self?.presentingViewController
                            self?.navigationController?.dismiss(animated: false, completion: {
                                presentingVC?.present(vc, animated: true)
                            })
                        case .failure(let error):
                            self?.qrStringLabel.text = "Can't find the journey: \(error)"
                        }
                    }
                }
            }
        }
    }
}

extension QRcodeScannerController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        guard let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
              let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                        context: nil,
                                        options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]),
              let ciImage = CIImage(image: pickedImage),
              let features = detector.features(in: ciImage) as? [CIQRCodeFeature] else { return }
        
        let qrCodeLink = features.reduce("") { $0 + ($1.messageString ?? "")}
        
        qrStringLabel.text = qrCodeLink
        let qrSplit = qrCodeLink.split(separator: ":")
        if qrSplit[safe: 0] == "Travel-Diary" {
            JourneyManager.shared.fetchSpecificJourney(id: String(qrSplit[1])) { [weak self] result in
                switch result {
                case .success(let journey):
                    let vc = JoinGroupController()
                    vc.journey = journey
                    vc.modalPresentationStyle = .overFullScreen
                    let presentingVC = self?.presentingViewController
                    self?.navigationController?.dismiss(animated: false, completion: {
                        presentingVC?.present(vc, animated: true)
                    })
                case .failure(let error):
                    self?.qrStringLabel.text = "Can't find the journey: \(error)"
                }
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}

extension QRcodeScannerController: UINavigationControllerDelegate {
    
}
