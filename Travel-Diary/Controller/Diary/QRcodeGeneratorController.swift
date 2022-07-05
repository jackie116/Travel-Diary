//
//  QRcodeGeneratorController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/27.
//

import UIKit

class QRcodeGeneratorController: UIViewController {
    
    var qrcodeImage: CIImage?
    var id: String?
    
    private lazy var shareButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"),
                                         style: .plain, target: self,
                                         action: #selector(shareAlert))
        button.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return button
    }()
    
    let hintLabel: UILabel = {
        let label = UILabel()
        label.text = "Show your code to invite other to your journey"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let qrcodeView: UIImageView = {
        let view = UIImageView()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let qrcodeImage = generateQRcode() {
            displayQRCodeImage(qrcodeImage: qrcodeImage)
        }
    }
    
    func configureUI() {
        navigationItem.rightBarButtonItem = shareButton
        view.backgroundColor = .white
        view.addSubview(hintLabel)
        view.addSubview(qrcodeView)
        configureConstraint()
    }
    
    func configureConstraint() {
        qrcodeView.center(inView: view)
        qrcodeView.setDimensions(width: UIScreen.width * 0.6, height: UIScreen.width * 0.6)
        
        hintLabel.centerX(inView: view)
        NSLayoutConstraint.activate([
            hintLabel.bottomAnchor.constraint(equalTo: qrcodeView.topAnchor, constant: -UIScreen.width * 0.1)
        ])
    }
    
    func generateQRcode() -> CIImage? {
        if let id = id {
            let data = "Travel-Diary:\(id)".data(using: .isoLatin1)

            let filter = CIFilter(name: "CIQRCodeGenerator")

            filter?.setValue(data, forKey: "inputMessage")
            filter?.setValue("H", forKey: "inputCorrectionLevel")

            qrcodeImage = filter?.outputImage
        }
        return qrcodeImage
    }
    
    func displayQRCodeImage(qrcodeImage: CIImage) {
        let scaleX = qrcodeView.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = qrcodeView.frame.size.height / qrcodeImage.extent.size.height
        
        let transformedImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        qrcodeView.image = UIImage(ciImage: transformedImage)
    }
    
    @objc func shareAlert() {
        guard let image = qrcodeView.image?.pngData() else { return }
        
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
        present(vc, animated: true, completion: nil)
    }
}
