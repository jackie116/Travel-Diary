//
//  AlertHelper.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/7/19.
//

import Foundation
import UIKit

class AlertHelper {
    static let shared = AlertHelper()
    typealias Action = () -> Void
    
    func showErrorAlert(message: String = "Something error", over viewController: UIViewController?) {
        guard let viewController = viewController else {
            return
        }
        
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        viewController.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            viewController.dismiss(animated: true)
        }
    }
    
    func showAlert(title: String, message: String, over viewController: UIViewController?) {
        guard let viewController = viewController else {
            return
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction().ok)
        viewController.present(alert, animated: true)
    }
    
    func showTFAlert(title: String,
                     message: String,
                     over viewController: UIViewController?,
                     onConfirm: @escaping Action) {
        
        guard let viewController = viewController else {
            return
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = .customBlue
        
        let okAction = UIAlertAction(title: "Yes", style: .default) { _ in
            onConfirm()
        }
        alert.addAction(okAction)
        
        alert.addAction(UIAlertAction().cancel)
        viewController.present(alert, animated: true)
    }
    
    func showPhotoAlert(over viewController: UIViewController?) {
        
        guard let viewController = viewController else {
            return
        }
        
        let actionSheet = UIAlertController(title: "Select a Photo",
                                            message: nil,
                                            preferredStyle: .actionSheet)
        actionSheet.view.tintColor = .customBlue
        
        let libraryAction = UIAlertAction(title: "Choose from library", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
                let photoPicker = UIImagePickerController()
                photoPicker.delegate = viewController as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
                photoPicker.sourceType = .photoLibrary
                photoPicker.allowsEditing = true
                
                viewController.present(photoPicker, animated: true, completion: nil)
            }
        }
        libraryAction.setValue(UIImage(systemName: "photo"), forKey: "image")
        actionSheet.addAction(libraryAction)
        
        let cameraAction = UIAlertAction(title: "Take photo", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let cameraPicker = UIImagePickerController()
                cameraPicker.delegate = viewController as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
                cameraPicker.sourceType = .camera
                cameraPicker.allowsEditing = true
                
                viewController.present(cameraPicker, animated: true, completion: nil)
            }
        }
        cameraAction.setValue(UIImage(systemName: "camera"), forKey: "image")
        actionSheet.addAction(cameraAction)
        
        actionSheet.addAction(UIAlertAction().sheetCancel)
        
        viewController.present(actionSheet, animated: true)
    }
    
    func showReportAlert(id: String, over viewController: UIViewController?) {
        
        guard let viewController = viewController else {
            return
        }
        
        let alert = UIAlertController(title: "Please select a problem",
                                      message: "If someone is in immediate danger, get help before report to us",
                                      preferredStyle: .alert)
        
        alert.view.tintColor = .customBlue

        alert.addAction(UIAlertAction(title: "Nudity", style: .default, handler: { [weak self] _ in
            self?.sendReport(journeyId: id, message: "Nudity", over: viewController)
        }))
        
        alert.addAction(UIAlertAction(title: "Violence", style: .default, handler: { [weak self] _ in
            self?.sendReport(journeyId: id, message: "Violence", over: viewController)
        }))
        
        alert.addAction(UIAlertAction(title: "Harassment", style: .default, handler: { [weak self] _ in
            self?.sendReport(journeyId: id, message: "Harassment", over: viewController)
        }))
        
        alert.addAction(UIAlertAction(title: "Suicide or self-injury", style: .default, handler: { [weak self] _ in
            self?.sendReport(journeyId: id, message: "Suicide or self-injury", over: viewController)
        }))
        
        alert.addAction(UIAlertAction(title: "False information", style: .default,
                                      handler: { [weak self] _ in
            self?.sendReport(journeyId: id, message: "False information", over: viewController)
        }))
        
        alert.addAction(UIAlertAction(title: "Spam", style: .default, handler: { [weak self] _ in
            self?.sendReport(journeyId: id, message: "Spam", over: viewController)
        }))
        
        alert.addAction(UIAlertAction(title: "Hate speech", style: .default, handler: { [weak self] _ in
            self?.sendReport(journeyId: id, message: "Hate speech", over: viewController)
        }))
        
        alert.addAction(UIAlertAction(title: "Terrorism", style: .default, handler: { [weak self] _ in
            self?.sendReport(journeyId: id, message: "Terrorism", over: viewController)
        }))
        
        alert.addAction(UIAlertAction(title: "Something else", style: .default, handler: { [weak self] _ in
            self?.sendReport(journeyId: id, message: "Something else", over: viewController)
        }))
        
        alert.addAction(UIAlertAction().cancel)
        
        viewController.present(alert, animated: true)
    }
    
    func sendReport(journeyId: String, message: String, over viewController: UIViewController?) {
        guard let viewController = viewController else {
            return
        }
        
        ReportManager.shared.sendReport(journeyId: journeyId, message: message) { [weak self] result in
            switch result {
            case .success:
                self?.showReportSuccessAlert(over: viewController)
            case .failure(let error):
                self?.showErrorAlert(message: error.localizedDescription, over: viewController)
            }
        }
    }
    
    func showReportSuccessAlert(over viewController: UIViewController?) {
        guard let viewController = viewController else {
            return
        }
        
        showAlert(title: "Thanks for reporting this journey",
                  message: "We will review this journey and remove anything that doesn't follow our standards as quickly as possible",
                  over: viewController)
    }
}
