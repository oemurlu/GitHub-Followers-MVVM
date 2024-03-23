//
//  UserInfoViewModel.swift
//  GithubFollowers
//
//  Created by Osman Emre Ömürlü on 22.03.2024.
//

import Foundation

protocol UserInfoViewModelDelegate: AnyObject {
    func showGFAlert(title: String, message: String, buttonTitle: String)
    func showDefaultError()
    func configureUIElements(with user: User)
}

class UserInfoViewModel {
    
    weak var delegate: UserInfoViewModelDelegate?
    var username: String!
    
    init(username: String) {
        self.username = username
    }
    
    
    func getUserInfo() {
        Task {
            do {
                let user = try await NetworkManager.shared.getUserInfo(for: username)
                delegate?.configureUIElements(with: user)
            
            } catch {
                if let gfError = error as? GFError {
                    delegate?.showGFAlert(title: "Something went wrong", message: gfError.rawValue, buttonTitle: "Ok")
                } else {
                    delegate?.showDefaultError()
                }
            }
        }
    }
}
