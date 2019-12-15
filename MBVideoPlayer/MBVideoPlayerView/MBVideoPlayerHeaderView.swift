//
//  MBVideoPlayerHeaderView.swift
//  MBVideoPlayer
//
//  Created by macadmin on 12/15/19.
//  Copyright © 2019 Muhammad Waqas. All rights reserved.
//

import UIKit

class MBVideoPlayerHeaderView: UIView {
    
    var configuration: MBConfiguration
    var theme: MBTheme

    // MARK: - Instance Variables
    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .blue
        label.textAlignment = .natural
        label.numberOfLines = 0
        return label
    }()
    
    lazy private var optionsButton: UIButton! = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(Controls.options.image, for: .normal)
        button.addTarget(self, action: #selector(self.optionsBtnPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy private var controlsStackView: UIStackView  = {
       let stackView = UIStackView()
       stackView.axis = .horizontal
       stackView.translatesAutoresizingMaskIntoConstraints = false
       return stackView
    }()
    
    private lazy var backgroundView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black
        view.alpha = 0.3
        return view
    }()
    
    // MARK: - View Initializers
    required init(configuration: MBConfiguration, theme: MBTheme) {
        self.configuration = configuration
        self.theme = theme
        super.init(frame: .zero)
        createHeaderView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    private func createHeaderView() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(controlsStackView)
        controlsStackView.pinEdges(to: self)
        controlsStackView.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)
        backgroundView.pinEdges(to: controlsStackView)
        
        if configuration.canShowHeaderTitle {
            addTitleLabel()
        }
        if configuration.canShowHeaderOption {
            addOptions()
        }
    }
    
    private func addTitleLabel() {
        controlsStackView.addArrangedSubview(titleLabel)
    }
    private func addOptions() {
        controlsStackView.addArrangedSubview(optionsButton)
        optionsButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        optionsButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    @objc func optionsBtnPressed(_ sender: UIButton) {
        
    }
}
