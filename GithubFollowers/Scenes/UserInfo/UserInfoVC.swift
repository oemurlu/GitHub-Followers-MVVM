//
//  UserInfoVC.swift
//  GithubFollowers
//
//  Created by Osman Emre Ömürlü on 4.03.2024.
//

import UIKit

final class UserInfoVC: GFDataLoadingVC {
    
    // added scrollView for iPhoneSE
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    let headerView = UIView()
    let itemViewOne = UIView()
    let itemViewTwo = UIView()
    let dateLabel = GFBodyLabel(textAlignment: .center)
    var itemViews: [UIView] = []
    
    weak var delegate: FollowerListVCDelegate?
    var viewModel: UserInfoViewModel!
    
    init(username: String) {
        super.init(nibName: nil, bundle: nil)
        viewModel = UserInfoViewModel(username: username)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        configureViewController()
        configureScrollView()
        layoutUI()
        viewModel.getUserInfo()
    }
    
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    
    func configureScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.pinToEdgesOf(of: view)
        contentView.pinToEdgesOf(of: scrollView)
        
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 600),
        ])
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
    
    
    func add(childVC: UIViewController, to containerView: UIView) {
        DispatchQueue.main.async {
            self.addChild(childVC)
            containerView.addSubview(childVC.view)
            childVC.view.frame = containerView.bounds
            childVC.didMove(toParent: self)
        }
    }
    
    @objc func dismissVC() {
        dismiss(animated: true)
    }
}


extension UserInfoVC: GFRepoItemVCDelegate {
    func didtapGitHubProfile(for user: User) {
        guard let url = URL(string: user.htmlUrl) else {
            presentGFAlert(title: "Invalid URL", message: "The url attached to this user is invalid.", buttonTitle: "Ok")
            return
        }
        
        presentSafariVC(with: url)
    }
}


extension UserInfoVC: GFFollowerItemVCDelegate {
    func didTapGetFollowers(for user: User) {
        guard user.followers != 0 else {
            presentGFAlert(title: "No followers", message: "This user has no followers. What a shame 😕.", buttonTitle: "So sad")
            return
        }
        
        delegate?.didRequestFollowers(for: user.login)
        dismissVC()
    }
}


extension UserInfoVC: UserInfoViewModelDelegate {
    func showGFAlert(title: String, message: String, buttonTitle: String) {
        self.presentGFAlert(title: title, message: message, buttonTitle: buttonTitle)
    }
    
    func showDefaultError() {
        self.presentDefaultError()
    }
    
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
}
