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


class ViewController: UIViewController {

    @IBOutlet weak var displaySensorValues: UIButton!
    @IBOutlet weak var labelText: UITextField!
    @IBOutlet weak var lightLabel: UILabel!
    @IBOutlet weak var accerelometerLabel: UILabel!
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
        accerelometerLabel.text = "Accel.: "
        
        self.startUpdatingVolume()
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.stopUpdatingVolume()
    }
    
    // MARK: - Internal methods

    @IBAction func GetSensors(_ sender: Any) {
        // TODO 光センサーの値を取得
        let brightness = UIScreen.main.brightness
        lightLabel.text = String(format: "brightness: %.6f", brightness)
        
        // 加速度
        manager.accelerometerUpdateInterval = 1 / 2;
        
        let accelerometerHandler: CMAccelerometerHandler = {
            [weak self] data, error in
            // 加速度センサのx軸の値を表示
            self?.accerelometerLabel.text = String(format: "Accel.: %.6f", data!.acceleration.x)
        }
        
        // アップデートスタート
        manager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler:accelerometerHandler)
        
        sleep(1)
        
        if manager.isAccelerometerAvailable {
            // アップデートをストップ
            manager.stopAccelerometerUpdates()
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
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.5,
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
        
        // Show "LOUD!!" if mPeakPower is larger than -1.0
//        self.loudLabel.isHidden = (levelMeter.mPeakPower >= -1.0) ? false : true
    }
    
    
    
    
    
}

