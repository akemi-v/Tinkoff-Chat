//
//  ProfileViewController.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 9/20/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var chooseProfilePicButton: UIButton!
    @IBOutlet weak var profilePicImageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //        print("Method: \(#function) editButton.frame: \(editButton.frame)")
        /* fatal error: unexpectedly found nil while unwrapping an Optional value
         editButton еще не была создана */
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
//        print("Method: \(#function) editButton.frame: \(editButton.frame)")
        
        chooseProfilePicButton.layer.cornerRadius = chooseProfilePicButton.frame.width / 2
        chooseProfilePicButton.layer.masksToBounds = true;
        
        profilePicImageView.layer.cornerRadius = chooseProfilePicButton.layer.cornerRadius
        profilePicImageView.layer.masksToBounds = true

        editButton.layer.borderColor = UIColor.black.cgColor
        editButton.layer.borderWidth = 1
        editButton.layer.cornerRadius = 10
        
        let backButton = UIBarButtonItem(title: "Закрыть", style: UIBarButtonItemStyle.plain, target: self, action: #selector(goBack))
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func goBack(){
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        print("Method: \(#function) editButton.frame: \(editButton.frame)")
        /* Метод вызывается перед тем, как view будет добавлен в иерархию,
         поэтому параметры фрейма editButton те же, что и в viewDidLoad.
         Параметры берутся из storyboard*/
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        print("Method: \(#function) editButton.frame: \(editButton.frame)")
        /* view был добавлен в иерархию, а параметры subviews были настроены с учетом constraints
         Девайсы storyboard'а и симулятора отличаются, поэтому параметры фрейма editButton во viewDidAppear отличается */
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    @IBAction func editAction(_ sender: Any) {
//        guard let button = sender as? UIButton else {
//            return
//        }
        
//        button!.titleLabel?.text = "11" //forced unwrap
        
//        let button : UIButton = (sender as? UIButton) ?? UIButton()
    }
    
    //MARK: - Choose profile picture
    
    @IBAction func chooseProfilePic(_ sender: UIButton) {
        print("Выберите изображение профиля")
        
        let alertController = UIAlertController(title: "Выберите действие", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let choosePicFromGalleryAction = UIAlertAction(title: "Установить из галереи", style: .default) { action -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true
                
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                let alertMessageController = UIAlertController(title: "Ошибка!", message: "Нет доступа к галерее", preferredStyle: .alert)
                let alertBackAction = UIAlertAction(title: "Назад", style: .default, handler: nil)
                alertMessageController.addAction(alertBackAction)
                
                self.present(alertMessageController, animated: true, completion: nil)
                
            }
        }
        
        let takePicWithCameraAction = UIAlertAction(title: "Сделать фото", style: .default) { action -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                
                self.present(imagePicker, animated: true, completion: nil)
                
            } else {
                let alertMessageController = UIAlertController(title: "Ошибка!", message: "Нет доступа к камере", preferredStyle: .alert)
                let alertBackAction = UIAlertAction(title: "Назад", style: .default, handler: nil)
                alertMessageController.addAction(alertBackAction)
                
                self.present(alertMessageController, animated: true, completion: nil)
                
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(choosePicFromGalleryAction)
        alertController.addAction(takePicWithCameraAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - UIImagePickerControllerDelegate methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            profilePicImageView.contentMode = .scaleAspectFit
            profilePicImageView.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

