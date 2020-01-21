//
//  AlbumCollectionViewCell.swift
//  PhotoFilter
//
//  Created by 김호중 on 2019/04/09.
//  Copyright © 2019 hojung. All rights reserved.
//

import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView.layer.cornerRadius = 5.0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
        countLabel.text = nil
    }
    
}
