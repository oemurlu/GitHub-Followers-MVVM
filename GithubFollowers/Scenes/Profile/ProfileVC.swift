//
//  ProfileVC.swift
//  GithubFollowers
//
//  Created by Osman Emre Ömürlü on 22.03.2024.
//

import UIKit

final class ProfileVC: GFDataLoadingVC {
    
    // added scrollView for iPhoneSE
    let scrollView = UIScrollView()
    let contentView = UIView()
    let searchController = UISearchController()
    
    let headerView = UIView()
    let itemViewOne = UIView()
    let itemViewTwo = UIView()
    let dateLabel = GFBodyLabel(textAlignment: .center)
    var itemViews: [UIView] = []
    
    let viewModel = ProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        configureViewController()
        configureScrollView()
        configureSearchController()
        layoutUI()
    }
    
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        showEmptyStateView(with: "Please search for a username!", in: view.self)
    }
    
    
    func configureSearchController() {
        searchController.searchBar.autocapitalizationType = .none
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search for a username"
        searchController.obscuresBackgroundDuringPresentation = false // don't put black overlay to the screen
        navigationItem.searchController = searchController
    }
    
    func configureScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.pinToEdgesOfSafeArea(of: view)
        contentView.pinToEdgesOf(of: scrollView)
        
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 600),
        ])
    }
    
    
    func add(childVC: UIViewController, to containerView: UIView) {
        DispatchQueue.main.async {
            self.addChild(childVC)
            containerView.addSubview(childVC.view)
            childVC.view.frame = containerView.bounds
            childVC.didMove(toParent: self)
        }
    }
    
    
    func resetUI() {
        children.forEach { childVC in
            childVC.willMove(toParent: nil)
            childVC.view.removeFromSuperview()
            childVC.removeFromParent()
        }
        
        dateLabel.text = ""
    }
    
    
    func layoutUI() {
        let padding: CGFloat = 20
        let itemHeight: CGFloat = 140
        itemViews = [headerView, itemViewOne, itemViewTwo, dateLabel]
        
        for itemView in itemViews {
            contentView.addSubview(itemView)
            itemView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                itemView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
                itemView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            ])
        }
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 210),
            
            itemViewOne.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: padding),
            itemViewOne.heightAnchor.constraint(equalToConstant: itemHeight),
            
            itemViewTwo.topAnchor.constraint(equalTo: itemViewOne.bottomAnchor, constant: padding),
            itemViewTwo.heightAnchor.constraint(equalToConstant: itemHeight),
            
            dateLabel.topAnchor.constraint(equalTo: itemViewTwo.bottomAnchor, constant: padding),
            dateLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}


extension ProfileVC: ProfileViewModelDelegate {
    func showEmptyStateView(with: String) {
        DispatchQueue.main.async {
            self.showEmptyStateView(with: with, in: self.view)
        }
    }
    
    func hideEmptyStateView_() {
        DispatchQueue.main.async { self.hideEmptyStateView() }
    }
    
    func showGFAlert(title: String, message: String, buttonTitle: String) {
        self.presentGFAlert(title: title, message: message, buttonTitle: buttonTitle)
    }
    
    func showDefaultError() { self.presentDefaultError() }
    
    func configureUIElements(with user: User) {
        DispatchQueue.main.async {
            let repoItemVC = GFRepoItemVC(user: user, delegate: self)
            let followerItemVC = GFFollowerItemVC(user: user, delegate: self)
            
            self.add(childVC: GFUserInfoHeaderVC(user: user), to: self.headerView)
            self.add(childVC: repoItemVC, to: self.itemViewOne)
            self.add(childVC: followerItemVC, to: self.itemViewTwo)
            self.dateLabel.text = "Github since \(user.createdAt.convertToMonthYearFormat())"
        }
    }
    
    func showLoadingView_() {
        DispatchQueue.main.async { self.showLoadingView() }
    }
    
    func dismissLoadingView_() {
        DispatchQueue.main.async { self.dismissLoadingView() }
    }
}


extension ProfileVC: UISearchControllerDelegate, UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        resetUI()
        viewModel.getUserInfo(username: searchText)
        searchController.isActive = false
        searchController.dismiss(animated: true)
    }
}



extension ProfileVC: GFRepoItemVCDelegate {
    func didtapGitHubProfile(for user: User) {
        guard let url = URL(string: user.htmlUrl) else {
            presentGFAlert(title: "Invalid URL", message: "The url attached to this user is invalid.", buttonTitle: "Ok")
            return
        }
        
        presentSafariVC(with: url)
    }
}



extension ProfileVC: GFFollowerItemVCDelegate {
    func didTapGetFollowers(for user: User) {
        DispatchQueue.main.async {
            let vc = FollowerListVC(username: user.login)
            let navController = UINavigationController(rootViewController: vc)
            self.present(navController, animated: true)
        }
    }
}



