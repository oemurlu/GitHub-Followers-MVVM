//
//  FollowerListViewModel.swift
//  GithubFollowers
//
//  Created by Osman Emre Ömürlü on 22.03.2024.
//

import Foundation

protocol FollowerListViewModelDelegate: AnyObject {
    func showGFAlert(title: String, message: String, buttonTitle: String)
    func showLoadingView_()
    func dismissLoadingView_()
    func showEmptyStateView(with: String)
    func updateData(on followers: [Follower])
    func showDefaultError()
    func navigateToUserInfoVC(follower: Follower)
}

final class FollowerListViewModel {
    
    var username: String
    var followers: [Follower] = []
    var filteredFollowers: [Follower] = []
    var page = 1
    var hasMoreFollowers = true
    var isSearching: Bool = false
    var islLoadingMoreFollowers = false
    
    weak var delegate: FollowerListViewModelDelegate?
    
    init(username: String) {
        self.username = username
    }
    
    
    func getFollowers() {
        self.islLoadingMoreFollowers = true
        
        Task {
            do {
                let followers = try await NetworkManager.shared.getFollowers(for: username, page: page)
                handleFollowers(with: followers)
            } catch {
                if let gfError = error as? GFError { // Show specific error
                    delegate?.showGFAlert(title: "Bad Stuff Happened", message: gfError.rawValue, buttonTitle: "Ok")
                } else { // Show default error
                    delegate?.showDefaultError()
                }
            }
            self.islLoadingMoreFollowers = false
            delegate?.dismissLoadingView_()
        }
    }
    
    
    private func handleFollowers(with followers: [Follower]) {
        if followers.count < 100 { self.hasMoreFollowers = false }
        self.followers.append(contentsOf: followers)
        
        if self.followers.isEmpty {
            let message = "This user doesn't have any followers. Go follow them 😅"
            delegate?.showEmptyStateView(with: message)
            return
        }
        delegate?.updateData(on: self.followers)
    }
    
    
    func addToFavoriteButtonTapped() {
        delegate?.showLoadingView_()
        Task {
            do {
                let user = try await NetworkManager.shared.getUserInfo(for: username)
                addUserToFavorites(user: user)
            } catch {
                if let gfError = error as? GFError {
                    self.delegate?.showGFAlert(title: "Something went wrong", message: gfError.rawValue, buttonTitle: "Ok")
                } else {
                    self.delegate?.showDefaultError()
                }
            }
            delegate?.dismissLoadingView_()
        }
    }
    
    
    func addUserToFavorites(user: User) {
        let favorite = Follower(login: user.login, avatarUrl: user.avatarUrl)
        
        PersistenceManager.updateWith(favorite: favorite, actionType: .add) { [weak self] error in
            guard let self = self else { return }
            guard let error = error else { // if the error is nil; success
                DispatchQueue.main.async {
                    self.delegate?.showGFAlert(title: "Success!", message: "You have successfully favorited this user 🎉", buttonTitle: "Yeeyy")
                }
                return
            }
            delegate?.showGFAlert(title: "Something went wrong", message: error.rawValue, buttonTitle: "Ok")
        }
    }
    
    
    func checkFilteredFollowers(searchText: String) {
        if isSearching && filteredFollowers.isEmpty {
            let message = "No results for \(String(describing: searchText))"
            delegate?.showEmptyStateView(with: message)
        }
    }
    
    
    func didSelectItemFromCV(at indexPath: IndexPath) {
        let activeArray = isSearching ? filteredFollowers : followers
        let follower = activeArray[indexPath.item]
        
        delegate?.navigateToUserInfoVC(follower: follower)
    }
}


