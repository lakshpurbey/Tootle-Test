//
//  DetailViewController.swift
//  Tootle Test
//
//  Created by Laksh Purbey on 26/09/2021.
//

import UIKit
import Apollo
import KeychainSwift

class DetailViewController: UIViewController {
    
    @IBOutlet private var missionPatchImageView: UIImageView!
    @IBOutlet private var missionNameLabel: UILabel!
    @IBOutlet private var rocketNameLabel: UILabel!
    @IBOutlet private var launchSiteLabel: UILabel!
    @IBOutlet private var bookCancelButton: UIBarButtonItem!
    
    private var launch: LaunchDetailsQuery.Data.Launch? {
        didSet {
            self.configureView()
        }
    }
    
    var launchID: GraphQLID? {
      didSet {
        self.loadLaunchDetails()
      }
    }
    
    func configureView() {
        guard
            self.missionNameLabel != nil,
            let launch = self.launch else {
                return
        }
        
        self.missionNameLabel.text = launch.mission?.name
        self.title = launch.mission?.name
        
        let placeholder = UIImage(named: "placeholder")!
        
        if let missionPatch = launch.mission?.missionPatch {
            self.missionPatchImageView.sd_setImage(with: URL(string: missionPatch)!, placeholderImage: placeholder)
        } else {
            self.missionPatchImageView.image = placeholder
        }
        
        if let site = launch.site {
            self.launchSiteLabel.text = "Launching from \(site)"
        } else {
            self.launchSiteLabel.text = nil
        }
        
        if
            let rocketName = launch.rocket?.name ,
            let rocketType = launch.rocket?.type {
                self.rocketNameLabel.text = "🚀 \(rocketName) (\(rocketType))"
        } else {
            self.rocketNameLabel.text = nil
        }
        
        if launch.isBooked {
            self.bookCancelButton.title = "Cancel trip"
            self.bookCancelButton.tintColor = .red
        } else {
            self.bookCancelButton.title = "Book now!"
            self.bookCancelButton.tintColor = self.view.tintColor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.missionNameLabel.text = "Loading..."
        self.launchSiteLabel.text = nil
        self.rocketNameLabel.text = nil
        self.configureView()
    }
    
    private func loadLaunchDetails(forceReload: Bool = false) {
        guard
            let launchID = self.launchID,
            (forceReload || launchID != self.launch?.id) else {
                // This is the launch we're already displaying, or the ID is nil.
                return
        }
        
        let cachePolicy: CachePolicy
        if forceReload {
            cachePolicy = .fetchIgnoringCacheCompletely
        } else {
            cachePolicy = .returnCacheDataElseFetch
        }
        
        Network.shared.apollo.fetch(query: LaunchDetailsQuery(id: launchID), cachePolicy: cachePolicy) { [weak self] result in
            
            guard let self = self else {
                return
            }
            
            switch result {
            case .failure(let error):
                self.showAlert(title: "Network Error",
                               message: error.localizedDescription)
            case .success(let graphQLResult):
                if let launch = graphQLResult.data?.launch {
                    self.launch = launch
                }
                
                if let errors = graphQLResult.errors {
                    self.showAlertForErrors(errors)
                }
            }
        }
    }
    
    @IBAction private func bookOrCancelTapped() {
        guard self.isLoggedIn() else {
            self.performSegue(withIdentifier: "showLogin", sender: self)
            return
        }
        
        guard let launch = self.launch else {
            // We don't have enough information yet to know
            // if we're booking or cancelling, bail.
            return
        }
        
        if launch.isBooked {
            self.cancelTrip(with: launch.id)
        } else {
            self.bookTrip(with: launch.id)
        }
    }
    
    private func bookTrip(with id: GraphQLID) {
        Network.shared.apollo.perform(mutation: BookTripMutation(id: id)) { [weak self] result in
            guard let self = self else {
                return 
            }
            
            switch result {
            case .success(let graphQLResult):
                if let bookingResult = graphQLResult.data?.bookTrips {
                    if bookingResult.success {
                        self.showAlert(title: "Success!", message: bookingResult.message ?? "Trip booked successfully")
                        self.loadLaunchDetails(forceReload: true)
                    } else {
                        self.showAlert(title: "Could not book trip", message: bookingResult.message ?? "Unknown failure.")
                    }
                }
                
                if let errors = graphQLResult.errors {
                    self.showAlertForErrors(errors)
                }
            case .failure(let error):
                self.showAlert(title: "Network Error",
                               message: error.localizedDescription)
            }
        }
    }
    
    private func cancelTrip(with id: GraphQLID) {
        Network.shared.apollo.perform(mutation: CancelTripMutation(id: id)) { result in
            switch result {
            case .success(let graphQLResult):
                if let cancelResult = graphQLResult.data?.cancelTrip {
                    if cancelResult.success {
                        self.showAlert(title: "Trip cancelled", message: cancelResult.message ?? "Your trip has been officially cancelled.")
                        self.loadLaunchDetails(forceReload: true)
                    } else {
                        self.showAlert(title: "Could not cancel trip", message: cancelResult.message ?? "Unknown failure.")
                    }
                }
                
                if let errors = graphQLResult.errors {
                    self.showAlertForErrors(errors)
                }
            case .failure(let error):
                self.showAlert(title: "Network Error",
                               message: error.localizedDescription)
            }
        }
    }
    
    private func isLoggedIn() -> Bool {
        let keychain = KeychainSwift()
        return keychain.get(LoginViewController.loginKeychainKey) != nil
    }
}

