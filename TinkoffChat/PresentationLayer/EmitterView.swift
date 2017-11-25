//
//  EmitterView.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 11/25/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import UIKit

class EmitterView: UIView {
    let emitterLayer = CAEmitterLayer()
    var position : CGPoint? = nil
    var birthRate : Float? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let cell = CAEmitterCell()
        cell.birthRate = 5.0
        cell.lifetime = 2.0
        cell.velocity = 150
        cell.velocityRange = 25
        cell.emissionLongitude = 0
        cell.emissionRange = CGFloat.pi / 6
        cell.spinRange = 5
        cell.scale = 0.15
        cell.scaleRange = 0
        cell.alphaSpeed = -0.35
        cell.contents = UIImage(named: "logo")?.cgImage
        
        emitterLayer.emitterCells = [cell]
        layer.addSublayer(emitterLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let position = self.position, let birthRate = self.birthRate else {
            print("No Emmiter view position/size")
            return
        }
        
        emitterLayer.birthRate = birthRate
        emitterLayer.emitterPosition = position
        emitterLayer.emitterSize = CGSize(width: 1, height: 1)
        emitterLayer.emitterShape = kCAEmitterLayerLine
        emitterLayer.renderMode = kCAEmitterLayerAdditive
    }
    
    func animate(position: CGPoint, birthRate: Float) {
        self.position = position
        self.birthRate = birthRate
        layoutSubviews()
    }
}
