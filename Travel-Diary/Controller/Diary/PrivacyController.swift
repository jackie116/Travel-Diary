//
//  PrivacyController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/23.
//

import UIKit
import PDFKit

class PrivacyController: UIViewController {
    let publicLabel: UILabel = {
        let label = UILabel()
        label.text = "Public"
        return label
    }()
    
    private lazy var shareButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"),
                                         style: .plain, target: self,
                                         action: #selector(shareAlert))
        button.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return button
    }()
    
    lazy var publicSwitch: UISwitch = {
        let mySwitch = UISwitch()
        mySwitch.addTarget(self, action: #selector(switchPublic), for: .valueChanged)
        return mySwitch
    }()
    
    let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.alpha = 0.5
        return view
    }()
    
    let pdfView: PDFView = {
        let view = PDFView()
        return view
    }()
    
    var journey: Journey?
    var documentData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureData()
    }
    
    func configureUI() {
        navigationItem.rightBarButtonItem = shareButton
        view.backgroundColor = .white
        view.addSubview(publicLabel)
        view.addSubview(publicSwitch)
        view.addSubview(underlineView)
        view.addSubview(pdfView)
        configureConstraint()
    }
    
    func configureConstraint() {
        publicLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                           left: view.leftAnchor,
                           paddingTop: 16, paddingLeft: 16)
        publicSwitch.anchor(right: view.rightAnchor, paddingRight: 16)
        publicSwitch.centerYAnchor.constraint(equalTo: publicLabel.centerYAnchor).isActive = true
        underlineView.anchor(top: publicLabel.bottomAnchor,
                             left: view.leftAnchor,
                             right: view.rightAnchor,
                             paddingTop: 16, height: 1)
        pdfView.anchor(top: underlineView.bottomAnchor,
                       left: view.leftAnchor,
                       bottom: view.safeAreaLayoutGuide.bottomAnchor,
                       right: view.rightAnchor,
                       paddingTop: 8, paddingLeft: 16,
                       paddingBottom: 8, paddingRight: 16)
    }
    
    func configureData() {
        guard let journey = journey else { return }
        publicSwitch.isOn = journey.isPublic
        let pdfCreator = PDFCreator(journey: journey)
        documentData = pdfCreator.createPDF()
        if let documentData = documentData {
            pdfView.document = PDFDocument(data: documentData)
            pdfView.autoScales = true
        }
    }
    
    @objc func switchPublic(sender: UISwitch) {
        guard let journey = journey else { return }
        JourneyManager.shared.switchPublic(id: journey.id!, isPublic: sender.isOn) { result in
            switch result {
            case .success:
                print("Success")
            case .failure(let error):
                print("Change public state failed. \(error)")
            }
        }

    }
    
    @objc func shareAlert() {
        guard let journey = journey else { return }
        let pdfCreator = PDFCreator(journey: journey)
        let pdfData = pdfCreator.createPDF()
        let vc = UIActivityViewController(activityItems: [pdfData], applicationActivities: [])
        vc.popoverPresentationController?.sourceView = self.view
        present(vc, animated: true, completion: nil)
    }
}
