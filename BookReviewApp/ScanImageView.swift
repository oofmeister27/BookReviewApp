//
//  ScanImageView.swift
//  BookReviewApp
//
//  Created by Aarav Navani on 6/27/20.
//  Copyright © 2020 ESUHSD. All rights reserved.
//

import UIKit

class ScanImageView: UIImageView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        
        self.isHidden = true
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 7.0
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.systemIndigo.cgColor
        backgroundColor = UIColor.init(white: 1.0, alpha: 0.1)
        clipsToBounds = true
    }
}
