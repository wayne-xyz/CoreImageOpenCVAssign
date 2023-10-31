//
//  ViewController.swift
//  ImageLab
//
//  Created by Eric Larson
//  Copyright © Eric Larson. All rights reserved.
//

import UIKit
import AVFoundation
import MetalKit

class MouduleAViewController: UIViewController   {

    //MARK: Class Properties
    var videoManager:VisionAnalgesic! = nil
    var faceDetector: FaceDetectionModel! = nil
    
    //MARK: Outlets in view
    @IBOutlet weak var cameraView: MTKView!
    
    //MARK: ViewController Hierarchy
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = nil
        self.videoManager = VisionAnalgesic(view: self.cameraView)
        self.videoManager.setCameraPosition(position: AVCaptureDevice.Position.front)
        self.faceDetector = FaceDetectionModel(videoManager: self.videoManager)
    }
    
    //MARK: Convenience Methods for UI Flash and Camera Toggle
    @IBAction func flash(_ sender: AnyObject) {
        if(self.videoManager.toggleFlash()){
            self.videoManager.turnOnFlashwithLevel(1.0)
        }
        else{
           self.videoManager.turnOffFlash()
        }
    }
    
    @IBAction func switchCamera(_ sender: AnyObject) {
        self.videoManager.toggleCameraPosition()
    }
}
