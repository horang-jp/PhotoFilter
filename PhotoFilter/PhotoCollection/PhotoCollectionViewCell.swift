//
//  PhotoCollectionViewCell.swift
//  PhotoFilter
//
//  Created by 김호중 on 2019/04/09.
//  Copyright © 2019 hojung. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Life Cycle
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
    }
}
