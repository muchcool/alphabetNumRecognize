//
//  ViewController.swift
//  NumRecoDemo
//
//  Created by lano on 2020/9/14.
//  Copyright © 2020 SCS. All rights reserved.
//
import SwiftOCR
import UIKit
import AVFoundation
class ViewController: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate//是用于AVCaptureVideoDataOutput的,可以触发func captureOutput
{
    let captureSession = AVCaptureSession()
    var captureDevice : AVCaptureDevice?
    var previewLayer : AVCaptureVideoPreviewLayer?//预览界面，可以设置为想要的扫描效果界面
    var pickUIImager : UIImageView = UIImageView(image: UIImage(named: "pick_bg"))
    var line : UIImageView = UIImageView(image: UIImage(named: "line"))//扫描线
    var timer : Timer!
    var upOrdown = true
    var isStart = false
    var input: AVCaptureDeviceInput?//输入流
    //var output: AVCaptureMetadataOutput?//输出流,无法显示脸图片,现已不用
    var output = AVCaptureVideoDataOutput()//输出流
    let swiftOCRInstance = SwiftOCR()//OCR识别第三方库
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*//尝试检测一副图片
        let swiftOCRInstance = SwiftOCR()
        let testImage = UIImage(named: "Test2")
        swiftOCRInstance.recognize(testImage!) { recognizedString in
            print(recognizedString)
        }//尝试检测一副图片
        */
        
        //初始化相机
        //captureSession.sessionPreset = AVCaptureSession.Preset.low
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1280x720
        //device 硬件设备声明和初始化
        //captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if (device.hasMediaType(AVMediaType.video)) {
                if (device.position == AVCaptureDevice.Position.back) {// 设置为后置摄像头
                    captureDevice = device
                    if captureDevice != nil {
                        print("Capture Device found")
                        beginSession()
                    }
                }
            }
        }
        //扫描框,线,以及动画效果
        pickUIImager.frame = CGRect(x: self.view.bounds.width / 2 - 100, y: self.view.bounds.height / 2 - 100,width: 200,height: 200)
        line.frame = CGRect(x: self.view.bounds.width / 2 - 100, y: self.view.bounds.height / 2 - 100, width: 200, height: 2)
        self.view.addSubview(pickUIImager)
        self.view.addSubview(line)
        timer =  Timer.scheduledTimer(timeInterval: 0.01, target: self, selector:#selector(animationSate), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: 2, target: self, selector:#selector(isStartTrue), userInfo: nil, repeats: false)
    }//设置了有2秒的延迟，2秒之后开始检测
    
    @objc func isStartTrue(){
        self.isStart = true
    }
    
    @objc func animationSate(){//动态显示扫描线的方法
        if upOrdown {
            if (line.frame.origin.y >= pickUIImager.frame.origin.y + 200)
            {
                upOrdown = false
            }
            else
            {
                line.frame.origin.y += 2
            }
        } else {
            if (line.frame.origin.y <= pickUIImager.frame.origin.y)
            {
                upOrdown = true
            }
            else
            {
                line.frame.origin.y -= 2
            }
        }
        
    }

    func beginSession() {//开启摄像头
        //在设置output输出流，添加扫描识别类型时，一定要先添加input输入流，否则崩掉
        //input 输入流
        do {try input = AVCaptureDeviceInput(device: captureDevice!)
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
        if (captureSession.canAddInput(input!)) {
            captureSession.addInput(input!)
        }
        //output 输出流
        let err : NSError? = nil
        output.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : NSNumber(value: kCVPixelFormatType_32BGRA)]
        captureSession.addOutput(output)
        if err != nil {
            print("error: \(err?.localizedDescription)")
        }
        
        //preview 预览界面，可以设置为想要的扫描效果界面
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        previewLayer?.frame = self.view.bounds
        self.view.layer.addSublayer(previewLayer!)
        captureSession.startRunning()
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        DispatchQueue.global().async {//global是加入队列并行执行(且加入队列就立即执行),async是异步进程
            if(self.isStart){
                let resultImage = self.sampleBufferToImage(sampleBuffer: sampleBuffer)
                let context = CIContext(options:[kCIContextUseSoftwareRenderer:true])
                let detector = CIDetector(ofType:CIDetectorTypeText,  context:context, options:[CIDetectorAccuracy: CIDetectorAccuracyHigh])
                let ciImage = CIImage(image: resultImage)
                let results:NSArray = detector!.features(in: ciImage!,options: ["CIDetectorImageOrientation" : 6]) as NSArray
                for r in results {
                    let text:CITextFeature = r as! CITextFeature;
                    let textImage = UIImage(cgImage: context.createCGImage(ciImage!,from:text.bounds)!,scale: 1.0, orientation: .up)

                    self.swiftOCRInstance.recognize(textImage) { recognizedString in
                        print(recognizedString)
                        self.isStart = false
                    }
                }
            }
//        }
        
        /*
        // 识别中 则返回
        if self.viewModel.isOCRRecognizing {
            return
        }
        
        // 截取图片
        self.imgToRecognize = XGCameraScanWrapper.cropImageFromSampleBuffer(using: sampleBuffer, croppedSizeInScreen: (self.qRScanView?.getRetangeSize())!)
        
        // 调用 iOS 9 文字检测API. 若没有检测到文字 => 则返回 不跑数字识别算法
        if #available(iOS 9.0, *) {
            let ciDetector = CIDetector(ofType: CIDetectorTypeText, context: nil, options: nil)
            guard let ciImgToRecognize = self.convertUIImageToCIImage(uiImage: self.imgToRecognize!) else {
                return
            }
            
            let features = ciDetector?.features(in: ciImgToRecognize)
            if (features?.isEmpty)! {
                self.recognizedImgView?.isHidden = true
                return
            } else {
                self.recognizedImgView?.image = self.imgToRecognize
                self.recognizedImgView?.isHidden = false
            }
        }
        
        // 识别图像
        self.viewModel.isOCRRecognizing = true
        self.xgDigitalRecognizeService?.recognize(self.imgToRecognize!) { recognizedString in
            if recognizedString.utf16.count >= 11 {  // 简单通过识别结果的长度进行输出判断 实际可通过正则限制结果的输出
                DispatchQueue.main.async {
                    self.viewModel.phoneNumStr = recognizedString
                    self.resultLablePhoneNum?.text = "手机号: " + self.viewModel.phoneNumStr
                }
            }
            self.viewModel.isOCRRecognizing = false
        }*/
        
    }
    private func sampleBufferToImage(sampleBuffer: CMSampleBuffer!) -> UIImage {
        let imageBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let flags = CVPixelBufferLockFlags(rawValue: 0)
        CVPixelBufferLockBaseAddress(imageBuffer,flags)
        let baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitsPerCompornent = 8
        let bitmapInfo = CGBitmapInfo(rawValue: (CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue) as UInt32)
        let newContext = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: bitsPerCompornent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) as! CGContext
        let imageRef: CGImage = newContext.makeImage()!
        let returnImage = UIImage(cgImage: imageRef, scale: 1.0, orientation: UIImageOrientation.right)
        CVPixelBufferUnlockBaseAddress(imageBuffer,flags)//不加的话会一直出Finalizing CVPixelBuffer...while lock count is 1
        return returnImage
    }
    
    func imageResize (imageObj:UIImage, sizeChange:CGSize)-> UIImage{
        let hasAlpha = false
        let scale: CGFloat = 0.0
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        imageObj.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage!
    }//暂时没用到调整image
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.tabBarController?.tabBar.isHidden = true//如果project不带tarBar的话,这也不需要
    }
    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
        //self.tabBarController?.tabBar.isHidden = false//如果project不带tarBar的话,这也不需要
        if (captureSession.isRunning == true) {
            captureSession.stopRunning()
            self.isStart = false
        }
    }

}
