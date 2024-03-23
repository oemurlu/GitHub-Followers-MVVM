//
//  FollowerListVC.swift
//  GithubFollowers
//
//  Created by Osman Emre Ömürlü on 26.02.2024.
//

import UIKit

protocol FollowerListVCDelegate: AnyObject {
    func didRequestFollowers(for username: String)
}

final class FollowerListVC: GFDataLoadingVC {
    
    enum Section {
        case main // CV 1 tane section'a sahip oldugu icin sadece main yaptik
    }
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Follower>!
    
    var viewModel: FollowerListViewModel!
    
    init(username: String) {
        super.init(nibName: nil, bundle: nil)
        viewModel = FollowerListViewModel(username: username)
        title = username
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        configureViewController()
        configureSearchController()
        configureCollectionView()
        viewModel.getFollowers()
        configureDataSource()
        showLoadingView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    
    
    func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(view: view))
        view.addSubview(collectionView) // firstly initialize that and then u can add to subview
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(FollowerCell.self, forCellWithReuseIdentifier: FollowerCell.reuseID)
    }
    
    
    func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search for a username"
        searchController.obscuresBackgroundDuringPresentation = false // don't put black overlay to the screen
        navigationItem.searchController = searchController
    }
    
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, follower)  in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowerCell.reuseID, for: indexPath) as! FollowerCell
            cell.set(follower: follower)
            return cell
        })
    }
    

    @objc func addButtonTapped() {
        viewModel.addToFavoriteButtonTapped()
    }
}

extension FollowerListVC: UICollectionViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            guard viewModel.hasMoreFollowers, !viewModel.islLoadingMoreFollowers else { return }
            viewModel.page += 1
            viewModel.getFollowers()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItemFromCV(at: indexPath)
    }
}


extension FollowerListVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            viewModel.filteredFollowers.removeAll()
            updateData(on: viewModel.followers)
            viewModel.isSearching = false
            return
        }
        
        viewModel.isSearching = true
        viewModel.filteredFollowers = viewModel.followers.filter { $0.login.lowercased().contains(filter.lowercased()) }
        updateData(on: viewModel.filteredFollowers)
        
        if let searchText = searchController.searchBar.text {
            viewModel.checkFilteredFollowers(searchText: searchText)
            hideEmptyStateView()
        }
    }
}


extension FollowerListVC: FollowerListVCDelegate {
    func didRequestFollowers(for username: String) {
        viewModel.username = username
        self.title = username
        viewModel.page = 1
        
        viewModel.followers.removeAll()
        viewModel.filteredFollowers.removeAll()
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        viewModel.getFollowers()
    }
}


extension FollowerListVC: FollowerListViewModelDelegate {
    
    func showGFAlert(title: String, message: String, buttonTitle: String) {
        self.presentGFAlert(title: title, message: message, buttonTitle: buttonTitle)
    }
    
    func showDefaultError() {
        self.presentDefaultError()
    }
    
    
    func showEmptyStateView(with: String) {
        DispatchQueue.main.async {
            self.showEmptyStateView(with: with, in: self.view)
        }
    }
    
    
    func navigateToUserInfoVC(follower: Follower) {
        let destVC = UserInfoVC(username: follower.login)
        destVC.delegate = self
        let navController = UINavigationController(rootViewController: destVC)
        present(navController, animated: true)
    }
    
    
    func showLoadingView_() {
        DispatchQueue.main.async {
            self.showLoadingView()
        }
    }
    
    
    func dismissLoadingView_() {
        DispatchQueue.main.async {
            self.dismissLoadingView()
        }
    }
    
    
    func updateData(on followers: [Follower]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Follower>()
        snapshot.appendSections([.main])
        snapshot.appendItems(followers)
        
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
}

