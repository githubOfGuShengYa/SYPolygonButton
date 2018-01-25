//
//  NavViewController.swift
//  SYPolygonButton
//
//  Created by 谷胜亚 on 2017/9/26.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//

import UIKit

class NavViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        // 添加pop手势
        guard let targets = interactivePopGestureRecognizer!.value(forKey:  "_targets") as? [NSObject] else { return }
        let targetObjc = targets[0]
        let target = targetObjc.value(forKey: "target")
        let action = Selector(("handleNavigationTransition:"))
//        let panGes = UIScreenEdgePanGestureRecognizer(target: target, action: action)
        let panGes = UIPanGestureRecognizer(target: target, action: action)
//        panGes.edges = .left
        view.addGestureRecognizer(panGes)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
