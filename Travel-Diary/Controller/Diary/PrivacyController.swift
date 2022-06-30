//
//  PrivacyController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/23.
//

import UIKit
import PDFKit
import Kingfisher

struct PdfSpot {
    let name: String
    let image: UIImage?
    let address: String
    var isDay: Bool = false
}

struct PdfResource {
    let title: String
    let coverImage: UIImage?
    let tripDate: String
    let spots: [PdfSpot]
}

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
        
        downloadAllResource { [weak self] resource in
            DispatchQueue.main.async {
                let pdfCreator = PDFCreator(resource: resource)
                self?.documentData = pdfCreator.createPDF()
                if let documentData = self?.documentData {
                    self?.pdfView.document = PDFDocument(data: documentData)
                    self?.pdfView.autoScales = true
                }
            }
        }
    }
    
    func downloadAllResource(completion: @escaping (PdfResource) -> Void) {
        guard let journey = journey else { return }
        
        let title = journey.title
        let tripDate = Date.dateFormatter.string(from: Date.init(milliseconds: journey.start))
        + " - " + Date.dateFormatter.string(from: Date.init(milliseconds: journey.end))
        var coverImage: UIImage?
        var spots = [PdfSpot]()
        
        DispatchQueue.global().async {
            let semaphore = DispatchSemaphore(value: 0)
            self.downloadImage(urlString: journey.coverPhoto) { result in
                switch result {
                case .success(let image):
                    coverImage = image
                    semaphore.signal()
                case .failure(let error):
                    print(error)
                    semaphore.signal()
                }
            }
            semaphore.wait()
            var days: Int = 0
            for day in journey.data {
                days += 1
                spots.append(PdfSpot(name: "Day \(days)", image: nil, address: "", isDay: true))
                for spot in day.spot {
                    var spotImage: UIImage?
                    self.downloadImage(urlString: spot.photo) { result in
                        switch result {
                        case .success(let image):
                            spotImage = image
                            semaphore.signal()
                        case .failure(let error):
                            print(error)
                            semaphore.signal()
                        }
                    }
                    semaphore.wait()
                    spots.append(PdfSpot(name: spot.name, image: spotImage, address: spot.address))
                }
            }
            completion(PdfResource(title: title, coverImage: coverImage, tripDate: tripDate, spots: spots))
        }
        
    }
    
    func downloadImage(urlString: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        if let url = URL(string: urlString) {
            let resource = ImageResource(downloadURL: url)
            KingfisherManager.shared.retrieveImage(with: resource) { result in
                switch result {
                case .success(let result):
                    completion(.success(result.image))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
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
        downloadAllResource { [weak self] resource in
            DispatchQueue.main.async {
                let pdfCreator = PDFCreator(resource: resource)
                let pdfData = pdfCreator.createPDF()
                let vc = UIActivityViewController(activityItems: [pdfData], applicationActivities: [])
                vc.popoverPresentationController?.sourceView = self?.view
                self?.present(vc, animated: true, completion: nil)
            }
        }
    }
}
