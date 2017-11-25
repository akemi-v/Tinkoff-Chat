//
//  EmitterViewController.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 11/25/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import UIKit

class EmitterViewController: UIViewController {
    var emitterView : EmitterView? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(recognizer:)))
        gestureRecognizer.minimumPressDuration = 0.1
        gestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gestureRecognizer)


        emitterView = EmitterView(frame: self.view.frame)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        guard let emitterView = self.emitterView else {
            print("No EmitterView")
            return
        }
        
        let state = recognizer.state
        if state == .changed {
            emitterView.animate(position: recognizer.location(in: recognizer.view), birthRate: 1.0)
            self.view.layer.addSublayer(emitterView.emitterLayer)
        } else if state == .ended {
            emitterView.animate(position: recognizer.location(in: recognizer.view), birthRate: 0.0)
            self.view.layer.addSublayer(emitterView.emitterLayer)
        }
    }

}
