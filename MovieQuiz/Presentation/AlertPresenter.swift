//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Konstantin Penzin on 14.04.2023.
//

import UIKit

class AlertPresenter: AlertPresenterProtocol {
    weak var delegate: UIViewController?
    
    init(delegate: UIViewController? = nil) {
        self.delegate = delegate
    }
    
    func showAlert(model: AlertModel) {
        guard let delegate = delegate else {
            return
        }
        
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)
        
        alert.view.accessibilityIdentifier = "QuizAlert"
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        
        alert.addAction(action)
        
        delegate.present(alert, animated: true, completion: nil)
    }
}
