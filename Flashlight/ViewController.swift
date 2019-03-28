//
//  ViewController.swift
//  Flashlight
//
//  Created by Jonathan Alland on 3/27/19.
//  Copyright © 2019 Jonathan Alland. All rights reserved.
//

import UIKit
import AVFoundation
var timer = Timer()
var prevBrightness: CGFloat = 0.5

class ViewController: UIViewController {
    @IBOutlet weak var Image: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { (notification) in
            UIView.transition(with: self.Image,
                              duration:0.1,
                              options: .transitionCrossDissolve,
                              animations: { self.Image.image = UIImage(named:"On.png") },
                              completion: nil)
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { timer in
                // putting this in a timer seems to prevent odd behavior...
                prevBrightness = UIScreen.main.brightness
                UIScreen.main.setBrightness(0, animated: true)
                toggleTorch(on: true)
            })
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil) { (notification) in
            UIView.transition(with: self.Image,
                              duration:0.1,
                              options: .transitionCrossDissolve,
                              animations: { self.Image.image = UIImage(named:"Off.png") },
                              completion: nil)
            timer.invalidate()
            toggleTorch(on: false)
            UIScreen.main.setBrightness(prevBrightness, animated: true)
        }
    }
}

func toggleTorch(on: Bool) {
    guard let device = AVCaptureDevice.default(for: .video) else { return }
    if device.hasTorch {
        do {
            try device.lockForConfiguration()
            
            if on == true {
                device.torchMode = .on
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used")
        }
    } else {
        print("Torch is not available")
    }
}

extension UIScreen {
    func setBrightness(_ value: CGFloat, animated: Bool) {
        if animated {
            _screenBrightnessQueue.cancelAllOperations()
            let step: CGFloat = 0.03 * ((value > brightness) ? 1 : -1)
            _screenBrightnessQueue.addOperations(stride(from: brightness, through: value, by: step).map({ [weak self] value -> Operation in
                let blockOperation = BlockOperation()
                unowned let _unownedOperation = blockOperation
                blockOperation.addExecutionBlock({
                    if !_unownedOperation.isCancelled {
                        Thread.sleep(forTimeInterval: 1 / 120.0)
                        self?.brightness = value
                    }
                })
                return blockOperation
            }), waitUntilFinished: false)
        } else {
            brightness = value
        }
    }
}

private let _screenBrightnessQueue: OperationQueue = {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 1
    return queue
}()
