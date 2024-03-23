//
//  FavoriteListVC.swift
//  GithubFollowers
//
//  Created by Osman Emre Ömürlü on 26.02.2024.
//

import UIKit

final class FavoriteListVC: GFDataLoadingVC {

    let viewModel = FavoriteListViewModel()
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        viewModel.delegate = self
        configureViewController()
        configureTableView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.getFavorites()
    }

    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    
    func configureTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.rowHeight = 80
        tableView.delegate = self
        tableView.dataSource = self
        tableView.removeExcessCells()
        
        tableView.register(FavoriteCell.self, forCellReuseIdentifier: FavoriteCell.reuseID)
    }
}


extension FavoriteListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.favorites.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCell.reuseID, for: indexPath) as! FavoriteCell
        cell.set(favorite: viewModel.favorites[indexPath.row])
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favorite = viewModel.favorites[indexPath.row]
        let destVC = FollowerListVC(username: favorite.login)
        
        navigationController?.pushViewController(destVC, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        viewModel.deleteCell(indexPath: indexPath)
    }
}


extension FavoriteListVC: FavoriteListViewModelDelegate {
    func deleteFavoritedItem(at indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    func didReceiveError(title: String, message: String, buttonTitle: String) {
        self.presentGFAlert(title: title, message: message, buttonTitle: buttonTitle)
    }
    
    
    func showEmptyStateView(with: String) {
        DispatchQueue.main.async {
            self.showEmptyStateView(with: with, in: self.view)
        }
    }
    
    
    func reloadTableViewOnMainThread() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.view.bringSubviewToFront(self.tableView)
        }
    }
}
