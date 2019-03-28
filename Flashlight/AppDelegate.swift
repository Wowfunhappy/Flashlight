//
//  AppDelegate.swift
//  Flashlight
//
//  Created by Jonathan Alland on 3/27/19.
//  Copyright © 2019 Jonathan Alland. All rights reserved.
//

import UIKit
import AVFoundation
var timer = Timer()

var prevBrightness: CGFloat = 0.5

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        application.isIdleTimerDisabled = true
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        timer.invalidate()
        toggleTorch(on: false)
        UIScreen.main.setBrightness(prevBrightness, animated: true)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { timer in
            // putting this in a timer seems to prevent odd behavior...
            prevBrightness = UIScreen.main.brightness
            UIScreen.main.setBrightness(0, animated: true)
            toggleTorch(on: true)
        })
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
