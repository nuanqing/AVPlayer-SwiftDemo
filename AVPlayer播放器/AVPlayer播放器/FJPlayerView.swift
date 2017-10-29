//
//  FJPlayerView.swift
//  AVPlayer播放器
//
//  Created by webplus on 17/10/26.
//  Copyright © 2017年 sanyi. All rights reserved.
//

import UIKit
import AVFoundation

class FJPlayerView: UIView {
    
    let FJWidth:CGFloat = UIScreen.main.bounds.size.width
    let FJHeight:CGFloat = UIScreen.main.bounds.size.height
    var totalSeconds:Float?
    var currentTime:Float?
    
    var player:AVPlayer!
    var playerItem:AVPlayerItem!
    var urlAsset:AVURLAsset!
    var playerLayer:AVPlayerLayer!
    var isSliderSliping:Bool = false//是否要滑动
    var isShowView:Bool = true
    var isFullScreen:Bool = false
    let KAppDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    
    //放大
    lazy var operationButton:UIButton = {
        let operationButton = UIButton.init()
        operationButton.frame = CGRect.init(x: self.frame.size.width - 40, y: self.frame.size.height - 30, width: 40, height: 30)
        operationButton.backgroundColor = UIColor.clear
        operationButton.setImage(UIImage.init(named: "chuangkou_icon"), for: .normal)
        return operationButton
    }()
    
    //重新播放
    lazy var rePlayButton:UIButton = {
        let rePlayButton = UIButton.init()
        rePlayButton.frame = CGRect.init(x: (self.frame.size.width - 60) / 2, y: (self.frame.size.height - 60) / 2, width: 60, height: 60)
        rePlayButton.backgroundColor = UIColor.clear
        rePlayButton.setImage(UIImage.init(named: "chongxin_icon"), for: .normal)
        return rePlayButton
    }()
    //播放
    lazy var playButton:UIButton = {
        let playButton = UIButton.init()
        playButton.frame = CGRect.init(x: (self.frame.size.width - 60) / 2, y: (self.frame.size.height - 60) / 2, width: 60, height: 60)
        playButton.backgroundColor = UIColor.clear
        playButton.setImage(UIImage.init(named: "bofang_icon"), for: .normal)
        playButton.setImage(UIImage.init(named: "zanting_icon"), for: .selected)
        return playButton
    }()
    
    lazy var currentSlider:UISlider = {
        let currentSlider = UISlider.init()
        currentSlider.frame = self.progressView.frame
        currentSlider.maximumValue = 1
        currentSlider.minimumValue = 0
        currentSlider.value = 0
        currentSlider.isContinuous = true
        currentSlider.minimumTrackTintColor = UIColor.blue
        currentSlider.maximumTrackTintColor = UIColor.clear
        currentSlider.setThumbImage(UIImage.init(named: "slider_icon"), for: UIControlState.normal)
        
        return currentSlider
    }()
    
    lazy var progressView:UIProgressView = {
        let progressView = UIProgressView.init()
        progressView.frame = CGRect.init(x: 60, y: self.frame.size.height - 14, width: self.frame.size.width - 150, height: 2)
        progressView.backgroundColor = UIColor.white
        progressView.tintColor = UIColor.darkGray
        return progressView
    }()
    
    lazy var totleTimeLabel:UILabel = {
        let totleTimeLabel = UILabel.init()
        totleTimeLabel.frame = CGRect.init(x:self.frame.size.width - 80, y: self.frame.size.height - 25, width: 40, height: 20)
        totleTimeLabel.textAlignment = NSTextAlignment.center
        totleTimeLabel.textColor = UIColor.white
        totleTimeLabel.font = UIFont.systemFont(ofSize: 12)
        return totleTimeLabel
    }()
    
    lazy var currentTimeLabel:UILabel = {
        let currentTimeLabel = UILabel.init()
        currentTimeLabel.frame = CGRect.init(x: 10, y: self.frame.size.height - 25, width: 40, height: 20)
        currentTimeLabel.textAlignment = NSTextAlignment.center
        currentTimeLabel.textColor = UIColor.white
        currentTimeLabel.font = UIFont.systemFont(ofSize: 12)
        return currentTimeLabel
    }()
    
    lazy var indicatorView:UIActivityIndicatorView = {
        
        let indicatorView = UIActivityIndicatorView.init()
        indicatorView.center = CGPoint.init(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        indicatorView.backgroundColor = UIColor.white
        indicatorView.color = UIColor.white
        
        return indicatorView
    }()
    
    
    
    init(frame: CGRect, videoArray:[String]) {
        super.init(frame: frame)
        self.urlAsset = AVURLAsset.init(url: NSURL.init(string: videoArray[0])! as URL)
        self.playerItem = AVPlayerItem.init(asset: self.urlAsset)
        self.player = AVPlayer.init(playerItem: self.playerItem)
        self.playerLayer = AVPlayerLayer.init(player: self.player)
        stupUI()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension FJPlayerView{
    
    func stupUI() -> Void {
        playerLayer.frame = self.frame
        layer.addSublayer(self.playerLayer)
        
        totleTimeLabel.text = "00:00"
        currentTimeLabel.text = "00:00"
        addSubview(totleTimeLabel)
        addSubview(currentTimeLabel)
        addSubview(progressView)
        addSubview(indicatorView)
        addSubview(currentSlider)
        addSubview(playButton)
        addSubview(rePlayButton)
        addSubview(operationButton)
        
        //放大窗口
        operationButton.addTarget(self, action: #selector(operationButtonClick(_:)), for: UIControlEvents.touchUpInside)
        
        rePlayButton.isHidden = true
        rePlayButton.addTarget(self, action:#selector(rePlayButtonClick), for: .touchUpInside)
        playButton.isHidden = true
        playButton.addTarget(self, action:#selector(playButtonClick), for: .touchUpInside)
        
        //滑动中
        currentSlider.isUserInteractionEnabled = false
        currentSlider.addTarget(self, action: #selector(valueChanged(_:)), for: UIControlEvents.valueChanged)
        //滑动结束，事件抬起
        currentSlider.addTarget(self, action: #selector(touchEnd(_:)), for: UIControlEvents.touchUpInside)
        currentSlider.addTarget(self, action: #selector(touchEnd(_:)), for: UIControlEvents.touchCancel)
        currentSlider.addTarget(self, action: #selector(touchEnd(_:)), for: UIControlEvents.touchUpOutside)
        
        let sliderTap = UITapGestureRecognizer.init(target: self, action: #selector(sliderTaped(_:)))
        currentSlider.addGestureRecognizer(sliderTap)
        
        indicatorView.startAnimating()
        addObeserverPlayerItem(self.playerItem)
        
        let playerViewTap = UITapGestureRecognizer.init(target: self, action: #selector(playerViewTaped))
        addGestureRecognizer(playerViewTap)
        addEndNofication()
        
    }
    
    //结束通知
    func addEndNofication() -> Void {
        NotificationCenter.default.addObserver(self, selector: #selector(playbackFinished(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime , object: player.currentItem)
    }
    
    func addObeserverPlayerItem(_ playerItem:AVPlayerItem) -> Void {
        playerItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        
        playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.new, context: nil)
        
        self.player.addPeriodicTimeObserver(forInterval: CMTime.init(value: CMTimeValue(1.0), timescale: CMTimeScale(1.0)), queue: DispatchQueue.main) { (time) in
            let current:CGFloat = CGFloat(CMTimeGetSeconds(time))
            let total:CGFloat = CGFloat(CMTimeGetSeconds(playerItem.duration))
            let percent = current / total
            if self.isSliderSliping == false{
                //不滑动的时候更新
                self.currentSlider.setValue(Float(percent), animated: true)
            }
            self.currentTimeLabel.text = self.caculateTime(seconds: Double(current))
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let playerItem = object
        if keyPath == "status" {
            if change?[NSKeyValueChangeKey.newKey] as! Int == 1 {
                self.indicatorView.stopAnimating()
                self.playButton.isHidden = false
                currentSlider.isUserInteractionEnabled = true
                let timeString = caculateTime(seconds: CMTimeGetSeconds((playerItem! as AnyObject).asset.duration))
                self.totleTimeLabel.text = timeString
            }
        }
        if keyPath == "loadedTimeRanges" {
            let array = (playerItem! as AnyObject).loadedTimeRanges
            let timeRange = array?.first as! CMTimeRange
            let startSeconds = CMTimeGetSeconds(timeRange.start)
            let durationSeconds = CMTimeGetSeconds(timeRange.duration)
            let buffSeconds = startSeconds + durationSeconds
            let totalSeconds = CMTimeGetSeconds((playerItem! as AnyObject).asset.duration)
            self.totalSeconds = Float(totalSeconds)
            self.progressView.setProgress(Float(buffSeconds / totalSeconds), animated: true)
            
        }
        
    }
    
    
    func caculateTime(seconds:Double) -> String {
        
        let hours = Int(seconds / 3600.0)
        var minute:Int!
        var second:Int!
        var timeString:String!
        if hours > 0 {
            minute = Int(seconds / 3600.0 - Double(hours)) * 60
            second = Int((seconds / 60.0 - Double(minute)) * 60)
            timeString = String.init(format: "%02d:%02d:%02d", hours,minute,second)
        }
        if hours <= 0 {
            minute = Int(seconds / 60.0)
            second = Int((seconds / 60.0 - Double(minute)) * 60)
            timeString = String.init(format: "%02d:%02d", minute,second)
        }
        
        return timeString
    }
    //结束通知
    func playbackFinished(_ nofication:NSNotification) -> Void {
        playButton.isHidden = true
        currentSlider.setValue(Float(0), animated: true)
        player.seek(to: CMTime.init(value: CMTimeValue(0), timescale: CMTimeScale(1.0)), toleranceBefore: CMTime.init(value: CMTimeValue(1.0), timescale: CMTimeScale(1.0)), toleranceAfter: CMTime.init(value: CMTimeValue(1.0), timescale: CMTimeScale(1.0))) { (finished) in
            self.player.pause()
            self.rePlayButton.isHidden = false
        }
    }
    
}

//手势
extension FJPlayerView{
    
    //放大窗口
    func operationButtonClick(_ button:UIButton) -> Void {
        if isFullScreen == false {
            KAppDelegate.isLandscape = true
            let value = UIInterfaceOrientation.landscapeLeft.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            isFullScreen = true
        }else{
            KAppDelegate.isLandscape = false
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            isFullScreen = false
        }
    }
    
    func playerViewTaped() -> Void {
        if isShowView == true {
            UIView.animate(withDuration: 0.28, animations: {
                self.currentTimeLabel.alpha = 0
                self.totleTimeLabel.alpha = 0
                self.progressView.alpha = 0
                self.currentSlider.alpha = 0
                self.playButton.alpha = 0
                self.operationButton.alpha = 0
            }, completion: { (isEnd) in
                self.isShowView = false
            })
            
        }else{
            UIView.animate(withDuration: 0.28, animations: {
                self.currentTimeLabel.alpha = 1
                self.totleTimeLabel.alpha = 1
                self.progressView.alpha = 1
                self.currentSlider.alpha = 1
                self.playButton.alpha = 1
                self.operationButton.alpha = 1
            }, completion: { (isEnd) in
                self.isShowView = true
            })
        }
    }
    
    
    func playButtonClick() -> Void {
        if self.player.rate == 0 {
            self.player.play()
            self.playButton.isSelected = true
        }else if self.player.rate == 1{
            self.player.pause()
            self.playButton.isSelected = false
        }
    }
    
    func rePlayButtonClick() -> Void {
        currentSlider.setValue(Float(0), animated: true)
        player.seek(to: CMTime.init(value: CMTimeValue(0), timescale: CMTimeScale(1.0)), toleranceBefore: CMTime.init(value: CMTimeValue(1.0), timescale: CMTimeScale(1.0)), toleranceAfter: CMTime.init(value: CMTimeValue(1.0), timescale: CMTimeScale(1.0))) { (finished) in
            self.player.play()
            self.rePlayButton.isHidden = true
            self.playButton.isHidden = false
            self.playButton.isSelected = true
        }
    }
    
    //滑动改变
    func valueChanged(_ slider:UISlider) -> Void {
        if totalSeconds == nil {
            return
        }
        isSliderSliping = true
        //TODO:计算滑动的值
        currentTime = currentSlider.value * totalSeconds!
        
    }
    //滑动结束，事件抬起
    func touchEnd(_ slider:UISlider) -> Void {
        if currentTime == nil {
            return
        }
        isSliderSliping = false
        //TODO:事件结束跳转
        player.pause()
        player.seek(to: CMTime.init(value: CMTimeValue(currentTime!), timescale: CMTimeScale(1.0)), toleranceBefore: CMTime.init(value: CMTimeValue(1.0), timescale: CMTimeScale(1.0)), toleranceAfter: CMTime.init(value: CMTimeValue(1.0), timescale: CMTimeScale(1.0))) { (finished) in
            self.player.play()
            self.playButton.isSelected = true
        }
    }
    
    func sliderTaped(_ tap:UITapGestureRecognizer) -> Void {
        let point = tap.location(in: currentSlider)
        let percent = point.x / currentSlider.frame.size.width
        currentSlider.setValue(Float(percent), animated: true)
        currentTime = currentSlider.value * totalSeconds!
        player.pause()
        player.seek(to: CMTime.init(value: CMTimeValue(currentTime!), timescale: CMTimeScale(1.0)), toleranceBefore: CMTime.init(value: CMTimeValue(1.0), timescale: CMTimeScale(1.0)), toleranceAfter: CMTime.init(value: CMTimeValue(1.0), timescale: CMTimeScale(1.0))) { (finished) in
            self.player.play()
            self.playButton.isSelected = true
        }
    }
    func setOrientationConstraint() -> Void {
        playerLayer.frame = self.frame
        progressView.frame = CGRect.init(x: 60, y: self.frame.size.height - 14, width: self.frame.size.width - 150, height: 2)
       currentSlider.frame = progressView.frame
        playButton.frame = CGRect.init(x: (self.frame.size.width - 60) / 2, y: (self.frame.size.height - 60) / 2, width: 60, height: 60)
        rePlayButton.frame = playButton.frame
        currentTimeLabel.frame = CGRect.init(x: 10, y: self.frame.size.height - 25, width: 40, height: 20)
        totleTimeLabel.frame = CGRect.init(x:self.frame.size.width - 80, y: self.frame.size.height - 25, width: 40, height: 20)
        indicatorView.center = CGPoint.init(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        operationButton.frame = CGRect.init(x: self.frame.size.width - 40, y: self.frame.size.height - 30, width: 40, height: 30)
    }
    
/*    func setOrientationPortraitConstraint() -> Void {
        playerLayer.frame = self.frame
        progressView.frame = CGRect.init(x: 60, y: self.frame.size.height - 14, width: self.frame.size.width - 150, height: 2)
        currentSlider.frame = progressView.frame
         playButton.frame = CGRect.init(x: (self.frame.size.width - 60) / 2, y: (self.frame.size.height - 60) / 2, width: 60, height: 60)
        rePlayButton.frame = playButton.frame
        currentTimeLabel.frame = CGRect.init(x: 10, y: self.frame.size.height - 25, width: 40, height: 20)
        totleTimeLabel.frame = CGRect.init(x:self.frame.size.width - 80, y: self.frame.size.height - 25, width: 40, height: 20)
        indicatorView.center = CGPoint.init(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        operationButton.frame = CGRect.init(x: self.frame.size.width - 40, y: self.frame.size.height - 30, width: 40, height: 30)
    }
 */
    
    
    
    
}














