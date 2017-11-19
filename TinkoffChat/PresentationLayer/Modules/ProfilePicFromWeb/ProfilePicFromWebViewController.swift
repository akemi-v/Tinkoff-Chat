//
//  ProfilePicFromWebViewController.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 11/18/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import UIKit

class ProfilePicFromWebViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let sectionInsets = UIEdgeInsets(top: 3.0, left: 3.0, bottom: 3.0, right: 3.0)
    let itemsPerRow = 3
    
    var previewPicModels : [PicUrlModel] = []
    
    var model : IPicFromWebModel?
    
    var setProfilePic : ((UIImage?) -> Void)?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setCloseButton()
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let vcCompletionHandler: ([PicUrlModel]?, String?) -> Void = getCompletionHandlerForCurrentVC()
                
        DispatchQueue.global(qos: .userInitiated).async {
            self.model?.fetchPicUrls(vcCompletionHandler: vcCompletionHandler)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private methods
    
    @objc private func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setCloseButton() {
        let closeButton = UIBarButtonItem(title: "Закрыть", style: .done, target: self, action: #selector(closeButtonTapped))
        self.navigationItem.leftBarButtonItem = closeButton
        self.navigationItem.title = "pixabay"
    }
    
    private func getCompletionHandlerForCurrentVC() -> ([PicUrlModel]?, String?) -> Void {
        return { [weak self] (picModels, error) in
            DispatchQueue.main.async {
                if let picModels = picModels {
                    self?.previewPicModels = picModels
                    self?.collectionView.reloadData()
                    self?.activityIndicator.stopAnimating()
                } else {
                    print(error ?? "Error during fetching")
                }
            }
        }
    }

}

// MARK: - UICollectionView

extension ProfilePicFromWebViewController : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return previewPicModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = "PicCellIdentifier"
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? PicCollectionViewCell else {
            return PicCollectionViewCell()
        }
        
        cell.configure(image: UIImage(named: "placeholder-pic"))
        
        let url = previewPicModels[indexPath.row].previewUrl
        let vcCompletionHandler = { (picModel: PicModel?, error: String?) in

            DispatchQueue.main.async {
                cell.configure(image: picModel?.image)
            }
        }

        DispatchQueue.global(qos: .utility).async {
            self.model?.loadPicFromUrl(url: url, vcCompletionHandler: vcCompletionHandler)
        }
        
        return cell
    }
}

extension ProfilePicFromWebViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let url = previewPicModels[indexPath.row].webformatUrl
        
        let vcCompletionHandler = { [weak self] (picModel: PicModel?, error: String?) in
            
            if let setProfilePic = self?.setProfilePic {
                DispatchQueue.main.async {
                    setProfilePic(picModel?.image)
                }
            }
        }
        
        DispatchQueue.global(qos: .utility).async {
            self.model?.loadPicFromUrl(url: url, vcCompletionHandler: vcCompletionHandler)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}

extension ProfilePicFromWebViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * CGFloat(itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace;
        let widthPerItem = availableWidth / CGFloat(itemsPerRow)
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
}
