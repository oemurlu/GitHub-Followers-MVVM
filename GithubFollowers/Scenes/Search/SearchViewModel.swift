//
//  SearchViewModel.swift
//  GithubFollowers
//
//  Created by Osman Emre Ömürlü on 22.03.2024.
//

import Foundation

protocol SearchViewModelDelegate: AnyObject {
    func didReceiveError(title: String, message: String, buttonTitle: String)
    func shouldNavigateToFollowerList(withUsername username: String)
}

final class SearchViewModel {
    
    weak var delegate: SearchViewModelDelegate?
    
    func searchForUser(username: String?) {
        guard let username = username, !username.isEmpty else {
            self.delegate?.didReceiveError(title: "Empty username", message: "Please enter a username. We need to know who to look for 😅", buttonTitle: "Ok")
            return
        }
        
        delegate?.shouldNavigateToFollowerList(withUsername: username)
    }
}


