//
//  PhotoCollectionViewController.swift
//  PhotoFilter
//
//  Created by 김호중 on 2019/04/09.
//  Copyright © 2019 hojung. All rights reserved.
//

import UIKit
import Photos


class PhotoCollectionViewController: UICollectionViewController {

    // MARK: - Properties
    var fetchResult: PHFetchResult<PHAsset>? {
        didSet {
            OperationQueue.main.addOperation {
                self.collectionView?.reloadSections(IndexSet(0...0))
            }
        }
    }
    var assetCollection: PHAssetCollection?
    
    // MARK: - Privates
    private let cellReuseIdentifier: String = "photoCell"
    private lazy var cachingImageManager: PHCachingImageManager = {
        return PHCachingImageManager()
    }()
    
    // MARK: - LifeCycle
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
}

extension PhotoCollectionViewController {
    
    private func configureCell(_ cell: PhotoCollectionViewCell,
                               collectionView: UICollectionView,
                               indexPath: IndexPath) {
        guard let asset: PHAsset = self.fetchResult?.object(at: indexPath.item) else {
            return
        }
        
        let manager: PHCachingImageManager = self.cachingImageManager
        let handler: (UIImage?, [AnyHashable: Any]?) -> Void = { image, _ in
            
            let cellAtIndex: UICollectionViewCell? = collectionView.cellForItem(at: indexPath)
            
            guard let cell: PhotoCollectionViewCell = cellAtIndex as? PhotoCollectionViewCell else {
                return
            }
            
            cell.imageView.image = image
        }
        
        manager.requestImage(for: asset,
                             targetSize: CGSize(width: 100, height: 100),
                             contentMode: PHImageContentMode.aspectFill,
                             options: nil,
                             resultHandler: handler)
    }
}

// MARK: - UICollectionViewDataSource
extension PhotoCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchResult?.count ?? 0
    }
}

extension PhotoCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: PhotoCollectionViewCell
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellReuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cell: PhotoCollectionViewCell = cell as? PhotoCollectionViewCell else {
            return
        }
        
        self.configureCell(cell, collectionView: collectionView, indexPath: indexPath)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayout: UICollectionViewFlowLayout = self.collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize.zero
        }
        
        let numberOfCellsInRow: CGFloat = 4
        let viewSize: CGSize = self.view.frame.size
        let sectionInset: UIEdgeInsets = flowLayout.sectionInset
        
        let interitemSpace: CGFloat = flowLayout.minimumInteritemSpacing * (numberOfCellsInRow - 1)
        
        var itemWidth: CGFloat
        itemWidth = viewSize.width - sectionInset.left - sectionInset.right - interitemSpace
        itemWidth /= numberOfCellsInRow
        
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        return itemSize
    }
}

extension PhotoCollectionViewController {
    private func updateCollectionView(with changes: PHFetchResultChangeDetails<PHAsset>) {
        guard let collectionView = self.collectionView else {
            return
        }
        
        // 업데이트는 삭제, 삽입, 다시 불러오기, 이동 순으로 진행합니다.
        if let removed: IndexSet = changes.removedIndexes, removed.count > 0 {
            collectionView.deleteItems(at: removed.map({
                IndexPath(item: $0, section: 0)
            }))
        }
        
        if let inserted: IndexSet = changes.insertedIndexes, inserted.count > 0 {
            collectionView.insertItems(at: inserted.map({
                IndexPath(item: $0, section: 0)
            }))
        }
        
        if let changed: IndexSet = changes.changedIndexes, changed.count > 0 {
            collectionView.reloadItems(at: changed.map({
                IndexPath(item: $0, section: 0)
            }))
        }
        
        changes.enumerateMoves { fromIndex, toIndex in
            collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                    to: IndexPath(item: toIndex, section: 0))
        }
    }
}

// MARK: - PHPhotoLibraryChangeObserver
extension PhotoCollectionViewController: PHPhotoLibraryChangeObserver {
    
    private func resetCachedAssets() {
        self.cachingImageManager.stopCachingImagesForAllAssets()
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let fetchResult: PHFetchResult<PHAsset> = self.fetchResult else {
            return
        }
        
        guard let changes: PHFetchResultChangeDetails<PHAsset> = changeInstance.changeDetails(for: fetchResult) else {
            return
        }
        
        DispatchQueue.main.sync {
            self.resetCachedAssets()
            self.fetchResult = changes.fetchResultAfterChanges
            
            if changes.hasIncrementalChanges {
                self.updateCollectionView(with: changes)
            } else {
                self.collectionView?.reloadSections(IndexSet(0...0))
            }
        }
    }
}

extension PhotoCollectionViewController {
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 사진 라이브러리 변겨을 감지할 수 있도록 등록
        PHPhotoLibrary.shared().register(self)
    }
}

extension PhotoCollectionViewController {
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let destination = segue.destination as? PhotoViewController,
            let cell: PhotoCollectionViewCell = sender as? PhotoCollectionViewCell,
            let indexPath: IndexPath = collectionView?.indexPath(for: cell) else {
                return
        }
        
        destination.asset = fetchResult?.object(at: indexPath.item)
        destination.assetCollection = self.assetCollection
    }
}
