//
//  SimpleTestViewController.swift
//  NumRecoDemo
//
//  Created by lano on 2020/9/15.
//  Copyright © 2020 SCS. All rights reserved.
//
import SwiftOCR
import UIKit
class SimpleTestViewController: UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //尝试检测一副图片
        let swiftOCRInstance = SwiftOCR()
        let testImage = UIImage(named: "Test2")
        swiftOCRInstance.recognize(testImage!) { recognizedString in
            print(recognizedString)
        }//尝试检测一副图片
    }
}
