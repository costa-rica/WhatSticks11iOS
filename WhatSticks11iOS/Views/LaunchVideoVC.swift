//
//  LaunchVideoVC.swift
//  WhatSticks11iOS
//
//  Created by Nick Rodriguez on 10/01/2024.
//

import UIKit
import AVFoundation

class LaunchVideoVC: UIViewController {

    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var skipButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideoPlayer()
        setupSkipButton()
    }

    private func setupVideoPlayer() {
        guard let path = Bundle.main.path(forResource: "wsLaunchVideo", ofType:"mp4") else {
            debugPrint("video.mp4 not found")
            return
        }
        player = AVPlayer(url: URL(fileURLWithPath: path))
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(playerLayer)
        player.play()

        // Automatically transition to LoginVC after 20 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) { [weak self] in
            self?.showLoginVC()
        }
    }

    private func setupSkipButton() {
        skipButton = UIButton()
        skipButton.setTitle("X", for: .normal)
        skipButton.translatesAutoresizingMaskIntoConstraints=false
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        view.addSubview(skipButton)
        NSLayoutConstraint.activate([
        skipButton.topAnchor.constraint(equalTo: view.topAnchor, constant: heightFromPct(percent: 10)),
        skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: widthFromPct(percent: -4))
        ])
    }

    @objc private func skipTapped() {
        showLoginVC()
    }

    // Inside LaunchVideoVC
    private func showLoginVC() {
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    
    
}

