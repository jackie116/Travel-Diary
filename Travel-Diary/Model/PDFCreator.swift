//
//  PDFCreator.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/25.
//

import UIKit
import PDFKit
import Kingfisher

class PDFCreator: NSObject {
    let resource: PdfResource
    
    init(resource: PdfResource) {
        self.resource = resource
    }
    
    func createPDF() -> Data {
        // 1
        let pdfMetaData = [
            kCGPDFContextCreator: "Travel Diary",
            kCGPDFContextAuthor: "",
            kCGPDFContextTitle: resource.title
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        // 2
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        // 3
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        // custom
        let pages = Int(ceil(Double(resource.spots.count) / 3))
        // 4
        let data = renderer.pdfData { (context) in
            // 5
            context.beginPage()
            // 6
            let titleBottom = addTitle(pageRect: pageRect)
            let tripDateBottom = addTripDate(pageRect: pageRect, textTop: titleBottom + 18.0)
            _ = addCoverImage(image: resource.coverImage,
                                            pageRect: pageRect,
                                            imageTop: tripDateBottom + 18.0)
            addCornerImage(pageRect: pageRect)
            
            var pointer = 0
            var order = 0
            for _ in 1...pages {
                context.beginPage()
                for ratio in [0.1, 0.4, 0.7] {
                    if let spot = self.resource.spots[safe: pointer] {
                        if spot.isDay == false {
                            order += 1
                            addSpot(spot: spot, pointer: pointer, pageRect: pageRect, order: order, pageTop: ratio)
                        } else {
                            order = 0
                            addDayTitle(title: spot.name, pageRect: pageRect, textTop: ratio)
                        }
                    }
                    pointer += 1
                }
            }
        }
        
        return data
    }
    
    func addSpot(spot: PdfSpot, pointer: Int, pageRect: CGRect, order: Int, pageTop: CGFloat) {
        addSpotImage(image: spot.image, pageRect: pageRect, imageTop: pageRect.height * pageTop)
        addSpotTitle(title: spot.name, pageRect: pageRect, textTop: pageRect.height * pageTop + 20)
        addSpotAddress(address: spot.address, pageRect: pageRect, textTop: pageRect.height * (pageTop + 0.05) + 20)
        addSpotAnnotation(pageRect: pageRect, imageTop: pageRect.height * (pageTop + 0.05))
        addDayOrderText(order: order, pageRect: pageRect, textTop: pageRect.height * (pageTop + 0.05) + 10)
        addCornerImage(pageRect: pageRect)
    }
    
    func addCornerImage(pageRect: CGRect) {
        let image = UIImage(named: "gy_bike")
        let maxHeight = pageRect.height * 0.05
        let maxWidth = pageRect.height * 0.05
        
        let aspectWidth = maxWidth / image!.size.width
        let aspectHeight = maxHeight / image!.size.height

        let scaledWidth = image!.size.width * aspectWidth
        let scaledHeight = image!.size.height * aspectHeight

        let imageRect = CGRect(x: pageRect.width - pageRect.height * 0.05,
                               y: pageRect.height * 0.95,
                               width: scaledWidth, height: scaledHeight)

        image!.draw(in: imageRect)
    }
    
    func addTitle(pageRect: CGRect) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 36.0, weight: .bold)
        
        let titleAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: titleFont]
        
        let attributedTitle = NSAttributedString(string: resource.title, attributes: titleAttributes)
        
        let titleStringSize = attributedTitle.size()

        let titleStringRect = CGRect(x: (pageRect.width - titleStringSize.width) / 2.0,
                                     y: UIScreen.height * 0.2, width: titleStringSize.width,
                                     height: titleStringSize.height)

        attributedTitle.draw(in: titleStringRect)

        return titleStringRect.origin.y + titleStringRect.size.height
    }
    
    func addDayTitle(title: String, pageRect: CGRect, textTop: CGFloat) {
        let titleFont = UIFont.systemFont(ofSize: 36, weight: .bold)
        let tilteColor = UIColor.customBlue
        
        let titleAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: titleFont,
                                                              NSAttributedString.Key.foregroundColor: tilteColor]
        
        let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
        
        let titleStringSize = attributedTitle.size()

        let titleStringRect = CGRect(x: (pageRect.width - titleStringSize.width) / 2.0,
                                     y: pageRect.height * (textTop + 0.1), width: titleStringSize.width,
                                     height: titleStringSize.height)

        attributedTitle.draw(in: titleStringRect)
    }
    
    func addTripDate(pageRect: CGRect, textTop: CGFloat) -> CGFloat {
        let textFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: textFont]
        let attributedText = NSAttributedString(string: resource.tripDate, attributes: textAttributes)
        let textStringSize = attributedText.size()
        let textStringRect = CGRect(x: (pageRect.width - textStringSize.width) / 2.0,
                                    y: textTop,
                                    width: textStringSize.width,
                                    height: textStringSize.height)
        attributedText.draw(in: textStringRect)
        return textStringRect.origin.y + textStringRect.size.height
    }
    
    func addSpotTitle(title: String, pageRect: CGRect, textTop: CGFloat) {
        let textFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: textFont]
        let attributedText = NSAttributedString(string: title, attributes: textAttributes)
        let textStringSize = attributedText.size()
        let textStringRect = CGRect(x: (pageRect.width * 0.8 - textStringSize.width / 2),
                                    y: textTop,
                                    width: textStringSize.width,
                                    height: textStringSize.height)
        attributedText.draw(in: textStringRect)
    }
    
    func addSpotAddress(address: String, pageRect: CGRect, textTop: CGFloat) {
        let textFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .natural
        paragraphStyle.lineBreakMode = .byWordWrapping

        let textAttributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: textFont
        ]
        let attributedText = NSAttributedString(string: address, attributes: textAttributes)

        let textRect = CGRect(x: pageRect.width * 0.65, y: textTop, width: pageRect.width * 0.3,
                              height: pageRect.height - textTop - pageRect.height / 5.0)
        attributedText.draw(in: textRect)
    }
    
    func addDayOrderText(order: Int, pageRect: CGRect, textTop: CGFloat) {
        let textFont = UIFont.systemFont(ofSize: 20, weight: .medium)
        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: textFont]
        let attributedText = NSAttributedString(string: "\(order)", attributes: textAttributes)
        let textStringSize = attributedText.size()
        let textStringRect = CGRect(x: pageRect.width * 0.085,
                                    y: textTop,
                                    width: textStringSize.width,
                                    height: textStringSize.height)
        attributedText.draw(in: textStringRect)
    }
    
    func addSpotAnnotation(pageRect: CGRect, imageTop: CGFloat) {
        if let image = UIImage(named: "pin") {
            let maxHeight = 60.0
            let maxWidth = 60.0

            let aspectWidth = maxWidth / image.size.width
            let aspectHeight = maxHeight / image.size.height

            let scaledWidth = image.size.width * aspectWidth
            let scaledHeight = image.size.height * aspectHeight

            let imageRect = CGRect(x: pageRect.width * 0.05, y: imageTop,
                                   width: scaledWidth, height: scaledHeight)

            image.draw(in: imageRect)
        }
    }
    
    func addSpotImage(image: UIImage?, pageRect: CGRect, imageTop: CGFloat) {
        guard let image = image else { return }

        let maxHeight = pageRect.height * 0.2
        let maxWidth = pageRect.width * 0.4
        
        let aspectWidth = maxWidth / image.size.width
        let aspectHeight = maxHeight / image.size.height

        let scaledWidth = image.size.width * aspectWidth
        let scaledHeight = image.size.height * aspectHeight

        let imageRect = CGRect(x: pageRect.width * 0.2, y: imageTop,
                               width: scaledWidth, height: scaledHeight)

        image.draw(in: imageRect)
    }
    
    func addCoverImage(image: UIImage?, pageRect: CGRect, imageTop: CGFloat) -> CGFloat {
        guard let image = image else { return imageTop }

        let maxHeight = pageRect.height * 0.4
        let maxWidth = pageRect.width * 0.8

        let aspectWidth = maxWidth / image.size.width
        let aspectHeight = maxHeight / image.size.height
        // let aspectRatio = min(aspectWidth, aspectHeight)

        let scaledWidth = image.size.width * aspectWidth
        let scaledHeight = image.size.height * aspectHeight

        let imageX = (pageRect.width - scaledWidth) / 2.0
        let imageRect = CGRect(x: imageX, y: imageTop,
                               width: scaledWidth, height: scaledHeight)

        image.draw(in: imageRect)
        return imageRect.origin.y + imageRect.size.height
    }
}
