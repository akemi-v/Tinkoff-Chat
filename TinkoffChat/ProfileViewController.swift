//
//  ProfileViewController.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 9/20/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var gcdSaveDataButton: UIButton!
    @IBOutlet weak var operationSaveDataButton: UIButton!
    @IBOutlet weak var chooseProfilePicButton: UIButton!
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var savingDataActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var aboutTextView: UITextView!
    
    var activeTextField : UITextField?
    var activeTextView : UITextView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let setLoadedData : ([String: String]) -> () = {[weak self] data in
            self?.nameTextField.text = data["name"]
            self?.aboutTextView.text = data["about"]
            
            guard let profilePicStrBase64 = data["pic"] else { return }
            guard let dataDecoded : Data = Data(base64Encoded: profilePicStrBase64, options: .ignoreUnknownCharacters) else { return }
            let decodedimage = UIImage(data: dataDecoded)
            self?.profilePicImageView.image = decodedimage
        }
        GCDDataManager(url: urlForProfileData()).loadProfileData(setLoadedData: setLoadedData)
//        OperationDataManager(url: urlForProfileData()).loadProfileData(setLoadedData: setLoadedData)
        disableSaveButtons()
        
        savingDataActivityIndicator.isHidden = true
        
        chooseProfilePicButton.layer.cornerRadius = chooseProfilePicButton.frame.width / 2
        chooseProfilePicButton.layer.masksToBounds = true;
        
        profilePicImageView.layer.cornerRadius = chooseProfilePicButton.layer.cornerRadius
        profilePicImageView.layer.masksToBounds = true

        gcdSaveDataButton.layer.borderColor = UIColor.black.cgColor
        gcdSaveDataButton.layer.borderWidth = 1
        gcdSaveDataButton.layer.cornerRadius = 10
        
        operationSaveDataButton.layer.borderColor = UIColor.black.cgColor
        operationSaveDataButton.layer.borderWidth = 1
        operationSaveDataButton.layer.cornerRadius = 10
        
        let backButton = UIBarButtonItem(title: "Закрыть", style: UIBarButtonItemStyle.plain, target: self, action: #selector(goBack))
        navigationItem.leftBarButtonItem = backButton
        
        
        self.scrollView.isScrollEnabled = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        
        self.nameTextField.delegate = self
        self.aboutTextView.delegate = self
        
//        self.activeTextView?.delegate = self
//        self.activeTextField?.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
//        self.scrollView.keyboardDismissMode = .onDrag
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChange), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidChange, object: nil)

        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
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
            enableSaveButtons()
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Saving data
    
    @IBAction func generalSaveData(_ sender: UIButton) {
        self.savingDataActivityIndicator.startAnimating()
        disableSaveButtons()
        
        guard let image = self.profilePicImageView.image else { return }
        guard let profilePicData : NSData = UIImagePNGRepresentation(image) as NSData? else { return }
        let profilePicStrBase64 : String = profilePicData.base64EncodedString(options: .lineLength64Characters)
        let profileData : [String: String] = ["name": self.nameTextField.text ?? "", "about": self.aboutTextView.text, "pic": profilePicStrBase64]
        
        let success = { [weak self] in
            self?.savingDataActivityIndicator.stopAnimating()
            let alertMessageController = UIAlertController(title: "Данные сохранены", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ок", style: .default, handler: nil)
            alertMessageController.addAction(okAction)
            self?.present(alertMessageController, animated: true, completion: nil)
        }
        
        let failure = { [ weak self] in
            self?.savingDataActivityIndicator.stopAnimating()
            let alertMessageController = UIAlertController(title: "Ошибка", message: "Не удалось сохранить данные", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ок", style: .default, handler: nil)
            let retryAction = UIAlertAction(title: "Повторить", style: .default, handler: { [weak self] _ in
                self?.generalSaveData(sender)
            })
            alertMessageController.addAction(okAction)
            alertMessageController.addAction(retryAction)
            self?.present(alertMessageController, animated: true, completion: nil)
        }
        
        guard let method : String = sender.titleLabel?.text else { return }
        switch method {
        case "GCD":
            GCDDataManager(url: urlForProfileData()).saveProfileData(profileData: profileData, success: success, failure: failure)
        case "Operation":
            OperationDataManager(url: urlForProfileData()).saveProfileData(profileData: profileData, success: success, failure: failure)
        default:
            return
        }
    }
    
    // MARK: - Keyboard related
    
    @objc func keyboardWillShow(notification: NSNotification) {
        self.scrollView.isScrollEnabled = true
        guard let info = notification.userInfo else { return }
        guard let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size else { return }
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var viewFrame : CGRect = self.view.frame
        viewFrame.size.height -= keyboardSize.height
        if let activeTextField = self.activeTextField {
            if (!viewFrame.contains(activeTextField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeTextField.frame, animated: true)
            }
        } else if let activeTextView = self.activeTextView {
            if (!viewFrame.contains(activeTextView.frame.origin)){
                self.scrollView.scrollRectToVisible(activeTextView.frame, animated: true)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        guard let info = notification.userInfo else { return }
        guard let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size else { return }
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.scrollView.isScrollEnabled = false
    }
    
    // MARK: - UITextField delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        enableSaveButtons()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        activeTextField = nil
    }
    
    
    
    // MARK: - UITextView delegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextView = textView
    }
    
    @objc func textViewDidChange(_ textView: UITextView) {
        enableSaveButtons()
    }
        
    func textViewDidEndEditing(_ textView: UITextView) {
        activeTextView = nil
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // MARK: - Buttons enabling/disabling
    
    func enableSaveButtons() {
        self.gcdSaveDataButton.isEnabled = true
        self.gcdSaveDataButton.alpha = 1.0
        self.operationSaveDataButton.isEnabled = true
        self.operationSaveDataButton.alpha = 1.0
    }
    
    func disableSaveButtons() {
        self.gcdSaveDataButton.isEnabled = false
        self.gcdSaveDataButton.alpha = 0.3
        self.operationSaveDataButton.isEnabled = false
        self.operationSaveDataButton.alpha = 0.3
    }
    
    // MARK: - Auxiliary
    func urlForProfileData() -> URL? {
        let fileName = "profile.json"
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let url = URL(fileURLWithPath: documents).appendingPathComponent(fileName)
        return url
    }
}

