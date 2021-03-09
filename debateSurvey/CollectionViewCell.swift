//
//  CollectionViewCell.swift
//  ActivityLabeling
//
//  Created by 佐藤佑磨 on 2021/02/04.
//  Copyright © 2021 Wataru Sasaki. All rights reserved.
//

import Foundation
import UIKit
import EMTNeumorphicView

class CollectionViewCell: UICollectionViewCell {

//    ニューモーフィズムのボタン設定
    let eButton: EMTNeumorphicButton = {
        let button = EMTNeumorphicButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: SelectionControler.shareCellSize, height: SelectionControler.shareCellSize)
        button.neumorphicLayer?.lightShadowOpacity = 0.3
        button.neumorphicLayer?.darkShadowOpacity = 0.8
        button.neumorphicLayer?.elementDepth = 5
        button.neumorphicLayer?.edged = true
        button.neumorphicLayer?.elementColor = CGColor(red: 233/255, green: 241/255, blue: 249/255, alpha: 1)
//        button.neumorphicLayer?.edged = true
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setup() {
//        cellのレイヤの設定（ボタンの設定はsetupContentsでする）
        layer.cornerRadius = 8.0
        print("ssdfsdafngf")
//        addSubviewによって、セルの上にeButtonを配置している
        contentView.addSubview(eButton)
    }
    
    func setupContents(num: Int) {
//        セル上のボタンの設定
        eButton.setTitle(String(num), for: .normal)
        eButton.setTitleColor(.lightGray, for: .normal)
        eButton.setTitle(String(num), for: .selected)
        eButton.setTitleColor(.black, for: .selected)
        eButton.titleLabel?.font = UIFont.systemFont(ofSize: 50)
        eButton.titleLabel?.textAlignment = .center
        eButton.layer.cornerRadius = 8.0
        eButton.contentVerticalAlignment = .center

    }
    

}
