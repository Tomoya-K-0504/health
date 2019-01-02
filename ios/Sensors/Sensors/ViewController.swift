//
//  ViewController.swift
//  Sensors
//
//  Created by 小池智哉 on 2018/12/31.
//  Copyright © 2018 小池智哉. All rights reserved.
//
import AudioToolbox
import UIKit
import CoreMotion //CoreMotionをインポート


private func AudioQueueInputCallback(
    _ inUserData: UnsafeMutableRawPointer?,
    inAQ: AudioQueueRef,
    inBuffer: AudioQueueBufferRef,
    inStartTime: UnsafePointer<AudioTimeStamp>,
    inNumberPacketDescriptions: UInt32,
    inPacketDescs: UnsafePointer<AudioStreamPacketDescription>?)
{
    // Do nothing, because not recoding.
}

private func postAccess(_ acceleration: [Double]) {
    let url = URL(string: "http://35.236.167.20/api/accel/")!
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    let postString = String(format: "[{\"data_source\": \"iphone 8\", \"values\": {\"x\": %.6f, \"y\": %.6f, \"z\": %.6f}}]", acceleration[0], acceleration[1], acceleration[2])
    request.httpBody = postString.data(using: .utf8)
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {                                                 // check for fundamental networking error
            print("error=\(error)")
            return
        }
        
        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
            print("statusCode should be 200, but is \(httpStatus.statusCode)")
            print("response = \(response)")
        }
        
        let responseString = String(data: data, encoding: .utf8)
        print("responseString = \(responseString)")
    }
    task.resume()
}


class ViewController: UIViewController {

    @IBOutlet weak var displaySensorValues: UIButton!
    @IBOutlet weak var labelText: UITextField!
    @IBOutlet weak var lightLabel: UILabel!
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var zLabel: UILabel!
    @IBOutlet weak var peakTextField: UITextField!
    @IBOutlet weak var averageTextField: UITextField!
    
    // 音声入力用
    var queue: AudioQueueRef!
    var timer: Timer!
    var dataFormat = AudioStreamBasicDescription(
        mSampleRate: 44100.0,
        mFormatID: kAudioFormatLinearPCM,
        mFormatFlags: AudioFormatFlags(kLinearPCMFormatFlagIsBigEndian |
            kLinearPCMFormatFlagIsSignedInteger |
            kLinearPCMFormatFlagIsPacked),
        mBytesPerPacket: 2,
        mFramesPerPacket: 1,
        mBytesPerFrame: 2,
        mChannelsPerFrame: 1,
        mBitsPerChannel: 16,
        mReserved: 0)
    
    let manager = CMMotionManager() //CoreMotionManagerのインスタンス生成
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        lightLabel.text = "brightness: "
        
        self.startUpdatingVolume()
        
        GetSensors()
        
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if manager.isAccelerometerAvailable {
            manager.stopAccelerometerUpdates()
        }
        
        self.stopUpdatingVolume()
    }
    
    // MARK: - Internal methods

    func GetSensors() {
        
        // 加速度
        if manager.isAccelerometerAvailable {
            manager.accelerometerUpdateInterval = 1; // 1Hz
            
            let accelerometerHandler: CMAccelerometerHandler = {
                [weak self] data, error in
                
                self?.xLabel.text = "".appendingFormat("x %.4f", data!.acceleration.x)
                self?.yLabel.text = "".appendingFormat("y %.4f", data!.acceleration.y)
                self?.zLabel.text = "".appendingFormat("z %.4f", data!.acceleration.z)
                
                var acceleration: [Double] = [data!.acceleration.x, data!.acceleration.y, data!.acceleration.z]
                postAccess(acceleration)
                
                print("x: \(data!.acceleration.x) y: \(data!.acceleration.y) z: \(data!.acceleration.z)")
            }
            
            manager.startAccelerometerUpdates(to: OperationQueue.current!,
                                              withHandler: accelerometerHandler)
        }
        
    }
    
    func startUpdatingVolume() {
        // Set data format
        var dataFormat = AudioStreamBasicDescription(
            mSampleRate: 44100.0,
            mFormatID: kAudioFormatLinearPCM,
            mFormatFlags: AudioFormatFlags(kLinearPCMFormatFlagIsBigEndian | kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked),
            mBytesPerPacket: 2,
            mFramesPerPacket: 1,
            mBytesPerFrame: 2,
            mChannelsPerFrame: 1,
            mBitsPerChannel: 16,
            mReserved: 0)
        
        // Observe input level
        var audioQueue: AudioQueueRef? = nil
        var error = noErr
        error = AudioQueueNewInput(
            &dataFormat,
            AudioQueueInputCallback,
            UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
            .none,
            .none,
            0,
            &audioQueue)
        if error == noErr {
            self.queue = audioQueue
        }
        AudioQueueStart(self.queue, nil)
        
        // Enable level meter
        var enabledLevelMeter: UInt32 = 1
        AudioQueueSetProperty(self.queue, kAudioQueueProperty_EnableLevelMetering, &enabledLevelMeter, UInt32(MemoryLayout<UInt32>.size))
        
        self.timer = Timer.scheduledTimer(timeInterval: 30,
                                          target: self,
                                          selector: #selector(self.detectVolume(_:)),
                                          userInfo: nil,
                                          repeats: true)
        self.timer?.fire()
    }
    
    func stopUpdatingVolume()
    {
        // Finish observation
        self.timer.invalidate()
        self.timer = nil
        AudioQueueFlush(self.queue)
        AudioQueueStop(self.queue, false)
        AudioQueueDispose(self.queue, true)
    }
    
    @objc func detectVolume(_ timer: Timer)
    {
        // Get level
        var levelMeter = AudioQueueLevelMeterState()
        var propertySize = UInt32(MemoryLayout<AudioQueueLevelMeterState>.size)
        
        AudioQueueGetProperty(
            self.queue,
            kAudioQueueProperty_CurrentLevelMeterDB,
            &levelMeter,
            &propertySize)
        
        // Show the audio channel's peak and average RMS power.
        self.peakTextField.text = "".appendingFormat("%.2f", levelMeter.mPeakPower)
        self.averageTextField.text = "".appendingFormat("%.2f", levelMeter.mAveragePower)
        
        // 光センサーの値を取得
        let brightness = UIScreen.main.brightness
        self.lightLabel.text = String(format: "brightness: %.6f", brightness)
        
        // サーバーに送信
//        let url = URL(string: "http://35.236.167.20/api/env/")!
        let url = URL(string: "http://localhost/api/env/")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = String(format: "[{\"data_source\": \"iphone 8\", \"values\": {\"brightness\": %.6f, \"m_peak_power\": %.6f, \"m_average_power\": %.6f}}]", brightness, levelMeter.mPeakPower, levelMeter.mAveragePower)
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
        }
        task.resume()
        
        // Show "LOUD!!" if mPeakPower is larger than -1.0
//        self.loudLabel.isHidden = (levelMeter.mPeakPower >= -1.0) ? false : true
    }
    
    
    
    
    
}

