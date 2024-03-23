//
//  GFAvatarImageView.swift
//  GithubFollowers
//
//  Created by Osman Emre Ömürlü on 1.03.2024.
//

import UIKit

final class GFAvatarImageView: UIImageView {
    
    let cache = NetworkManager.shared.cache
    let placeholderImage = Images.placeholder
    private var currentTask: Task<Void, Never>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        layer.cornerRadius = 10
        clipsToBounds = true
        image = placeholderImage
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    func downloadImage(fromURL url: String) {
        currentTask?.cancel() // Cancel any ongoing task before starting a new one
        
        currentTask = Task {
            let downloadedImage = await NetworkManager.shared.downloadImage(from: url)?.byPreparingForDisplay() ?? placeholderImage
            // Ensure UI updates happen on the main thread
            DispatchQueue.main.async {
                if !Task.isCancelled {
                    self.image = downloadedImage
                }
            }
        }
    }
    
    
    // Use this method to cancel the image download task when the cell is reused
    func cancelImageDownload() {
        currentTask?.cancel()
        image = placeholderImage // Reset the image to placeholder
    }
}
