//
//  FavoriteListViewModel.swift
//  GithubFollowers
//
//  Created by Osman Emre Ömürlü on 22.03.2024.
//

import Foundation

protocol FavoriteListViewModelDelegate: AnyObject {
    func didReceiveError(title: String, message: String, buttonTitle: String)
    func showEmptyStateView(with: String)
    func reloadTableViewOnMainThread()
    func deleteFavoritedItem(at indexPath: IndexPath)
}

final class FavoriteListViewModel {
    
    var favorites: [Follower] = []
    weak var delegate: FavoriteListViewModelDelegate?
    
    func getFavorites() {
        PersistenceManager.retrieveFavorites { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let favorites):
                self.handleFavorites(with: favorites)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.didReceiveError(title: "Something went wrong", message: error.rawValue, buttonTitle: "Ok")
                }
            }
        }
    }
    
    
    private func handleFavorites(with favorites: [Follower]) {
        if favorites.isEmpty {
            delegate?.showEmptyStateView(with: "No Favorites?\nAdd one on the follower screen.")
        } else {
            self.favorites = favorites
            self.delegate?.reloadTableViewOnMainThread()
        }
    }
    
    
    func deleteCell(indexPath: IndexPath) {
        PersistenceManager.updateWith(favorite: favorites[indexPath.row], actionType: .remove) { [weak self] error in
            
            guard let self = self else { return }
            guard let error = error else {
                self.favorites.remove(at: indexPath.row)
                delegate?.deleteFavoritedItem(at: indexPath)
                
                if self.favorites.isEmpty {
                    delegate?.showEmptyStateView(with: "No Favorites?\nAdd one on the follower screen.")
                }
                
                return
            }
            delegate?.didReceiveError(title: "Unable to remove", message: error.rawValue, buttonTitle: "Ok")
        }
    }
}


