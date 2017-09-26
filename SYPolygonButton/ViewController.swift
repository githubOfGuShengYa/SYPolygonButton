//
//  ViewController.swift
//  SYPolygonButton
//
//  Created by 谷胜亚 on 2017/9/18.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let style = SYPolygonStyle()
        style.borderWidth = 10
        style.borderColor = .red
        let btn = SYPolygonButton(frame: CGRect.init(x: 50, y: 50, width: 100, height: 200), style: style)
        btn.setImage(UIImage.init(named: "zhbd_weixin_icon"), for: .normal)
        view.addSubview(btn)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

