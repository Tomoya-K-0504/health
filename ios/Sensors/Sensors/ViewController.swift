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
import CoreLocation


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

private func postAccess(_ urlString: String, postString: String) {
//    print(urlString)
//    print(postString)
    let url = URL(string: urlString)!
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    request.httpBody = postString.data(using: .utf8)
//    let task = URLSession.shared.dataTask(with: request) { data, response, error in
//        guard let data = data, error == nil else {                                                 // check for fundamental networking error
//            print("error=\(error)")
//            return
//        }
//
//        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
//            print("statusCode should be 200, but is \(httpStatus.statusCode)")
//            print("response = \(response)")
//        }
//
//        let responseString = String(data: data, encoding: .utf8)
//        print("responseString = \(responseString)")
//    }
//    task.resume()
}


class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var labelText: UITextField!
    @IBOutlet weak var lightLabel: UILabel!
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var zLabel: UILabel!
    @IBOutlet weak var peakTextField: UITextField!
    @IBOutlet weak var averageTextField: UITextField!
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let data = ["睡眠","運動","食事","休憩","作業","家事","風呂","読書/文献調査", "移動"]
    var labelList: [String] = []
    var actDict: [String:Float] = ["latitude": 0.0, "longitude": 0.0, "altitude": 0.0]
    
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
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        initView()
        
        self.startUpdatingVolume()
        GetSensors()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if manager.isAccelerometerAvailable {
            manager.stopAccelerometerUpdates()
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.stopUpdatingLocation()
        }
        
        self.stopUpdatingVolume()
    }
    
    // MARK: - Internal methods
    
    @IBAction func ButtonTouchDown(_ sender: Any) {
        let labelString = labelList.joined(separator: ",")
        postAccess("http://35.236.167.20/api/label/", postString: labelString)
        
        do {
            // Dict -> JSON
            var jsonString: String = ""
            let jsonData = try JSONSerialization.data(withJSONObject: actDict)
            jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
            let actString = "{\"data_source\":\"iphone 8\",\"values\":" + jsonString + "}"
            postAccess("http://35.236.167.20/api/act/", postString: actString)
        } catch {
            print("Error!: \(error)")
        }
    }

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
                let urlString =
                let accelString = String(format: "[{\"data_source\": \"iphone 8\", \"values\": {\"x\": %.6f, \"y\": %.6f, \"z\": %.6f}}]", acceleration[0], acceleration[1], acceleration[2])
                postAccess("http://35.236.167.20/api/accel/", postString: accelString)
                
                
            }
            
            manager.startAccelerometerUpdates(to: OperationQueue.current!,
                                              withHandler: accelerometerHandler)
        }
        
        // 高度, 緯度経度
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
        
    }
    
    // Auth
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways, .authorizedWhenInUse:
            break
        }
    }
    
    // 高度, 緯度経度
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last,
            CLLocationCoordinate2DIsValid(newLocation.coordinate) else {
                print("Error")
                return
        }
        actDict["altitude"] = Float(newLocation.altitude)
        actDict["latitude"] = Float(newLocation.coordinate.latitude)
        actDict["longitude"] = Float(newLocation.coordinate.longitude)
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
        
        self.timer = Timer.scheduledTimer(timeInterval: 1,
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
        let urlString = "http://35.236.167.20/api/env/"
        let postString = String(format: "[{\"data_source\": \"iphone 8\", \"values\": {\"brightness\": %.6f, \"m_peak_power\": %.6f, \"m_average_power\": %.6f}}]", brightness, levelMeter.mPeakPower, levelMeter.mAveragePower)
        postAccess(urlString, postString: postString)
        // Show "LOUD!!" if mPeakPower is larger than -1.0
//        self.loudLabel.isHidden = (levelMeter.mPeakPower >= -1.0) ? false : true
    }
}

extension ViewController {
    private func initView() {
        tableView.delegate = self
        tableView.dataSource = self
        // 複数選択可にする
        tableView.allowsMultipleSelection = true
    }
}

extension ViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        labelList.append((cell?.textLabel?.text)!)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at:indexPath)
        cell?.accessoryType = .none
        let cellText = cell?.textLabel?.text
        let index = labelList.index(of: cellText!)
        labelList.remove(at: index!)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = data[indexPath.row]
        cell?.selectionStyle = .none
        return cell!
    }
}
