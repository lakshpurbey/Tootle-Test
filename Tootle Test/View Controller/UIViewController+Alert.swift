//
//  UIViewController+Alert.swift
//  Tootle Test
//
//  Created by Laksh Purbey on 26/09/2021.
//

import UIKit
import Apollo

extension UIViewController {
    
    /// Shows an alert with the given title and message and an "OK" button to dismiss
    ///
    /// - Parameters:
    ///   - title: The title to display
    ///   - message: The message to display
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    /// Shows an error alert for the given GraphQL errors
    ///
    /// - Parameter errors: The error(s) to display
    func showAlertForErrors(_ errors: [GraphQLError]) {
        let message = errors
            .map { $0.localizedDescription }
            .joined(separator: "\n")
        self.showAlert(title: "GraphQL Error(s)",
                       message: message)
    }
}
