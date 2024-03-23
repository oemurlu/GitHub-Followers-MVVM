//
//  ProfileViewModel.swift
//  GithubFollowers
//
//  Created by Osman Emre Ömürlü on 22.03.2024.
//

import Foundation

protocol ProfileViewModelDelegate: AnyObject {
    func showGFAlert(title: String, message: String, buttonTitle: String)
    func showDefaultError()
    func configureUIElements(with user: User)
    func showLoadingView_()
    func dismissLoadingView_()
    func showEmptyStateView(with: String)
    func hideEmptyStateView_()
}

final class ProfileViewModel {
    
    weak var delegate: ProfileViewModelDelegate?
    
    func getUserInfo(username: String) {
        delegate?.showLoadingView_()
        Task {
            defer { delegate?.dismissLoadingView_() } // execute for both case.
            
            do {
                let user = try await NetworkManager.shared.getUserInfo(for: username)
                delegate?.configureUIElements(with: user)
                delegate?.hideEmptyStateView_()
            } catch {
                if let gfError = error as? GFError {
                    delegate?.showGFAlert(title: "Something went wrong", message: gfError.rawValue, buttonTitle: "Ok")
                } else {
                    delegate?.showDefaultError()
                }
                delegate?.showEmptyStateView(with: "Please search for a valid username!")
            }
        }
    }
}
