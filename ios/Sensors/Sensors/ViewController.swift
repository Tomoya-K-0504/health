//
//  ViewController.swift
//  Sensors
//
//  Created by 小池智哉 on 2018/12/31.
//  Copyright © 2018 小池智哉. All rights reserved.
//

import UIKit
import CoreMotion //CoreMotionをインポート

class ViewController: UIViewController {

    @IBOutlet weak var displaySensorValues: UIButton!
    @IBOutlet weak var labelText: UITextField!
    @IBOutlet weak var lightLabel: UILabel!
    @IBOutlet weak var accerelometerLabel: UILabel!
    
    let manager = CMMotionManager() //CoreMotionManagerのインスタンス生成
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        lightLabel.text = ""
        accerelometerLabel.text = ""
        
    }

    @IBAction func GetSensors(_ sender: Any) {
        // TODO 光センサーの値を取得
        let brightness = UIScreen.main.brightness
        lightLabel.text = String(format: "%.6f", brightness)
        
        // 加速度
        manager.accelerometerUpdateInterval = 1 / 2;
        
        let accelerometerHandler: CMAccelerometerHandler = {
            [weak self] data, error in
            // 加速度センサのx軸の値を表示
            self?.accerelometerLabel.text = String(format: "%.6f", data!.acceleration.x)
        }
        
        // アップデートスタート
        manager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler:accelerometerHandler)
        
        sleep(1)
        
        if manager.isAccelerometerAvailable {
            // アップデートをストップ
            manager.stopAccelerometerUpdates()
        }
    }
    
    // 画面を消したときに実行される関数
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(Bool)
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }
    
    
}

