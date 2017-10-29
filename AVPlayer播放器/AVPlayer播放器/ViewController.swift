//
//  ViewController.swift
//  AVPlayer播放器
//
//  Created by webplus on 17/10/26.
//  Copyright © 2017年 sanyi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var player:FJPlayerView!
    let FJWidth:CGFloat = UIScreen.main.bounds.size.width
    let FJHeight:CGFloat = UIScreen.main.bounds.size.height
    let layerHeight:CGFloat = 168
    let KAppDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "导航"
        self.navigationController?.navigationBar.isTranslucent = false
        
        player = FJPlayerView.init(frame: CGRect.init(x: 0, y: 0, width: FJWidth, height: layerHeight), videoArray: ["http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4"])
        player.backgroundColor = UIColor.black
        self.view.addSubview(player)
    }
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.portrait, UIInterfaceOrientationMask.landscapeLeft]
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            self.navigationController?.navigationBar.isHidden = true
            player.frame = CGRect.init(x: 0, y: 0, width: FJHeight, height: FJWidth)
        
        }else{
            self.navigationController?.navigationBar.isHidden = false
            player.frame = CGRect.init(x: 0, y: 0, width: FJWidth, height: layerHeight)
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.player.setOrientationConstraint()
        }
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

