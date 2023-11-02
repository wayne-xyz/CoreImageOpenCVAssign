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
        self.videoManager = VisionAnalgesic(view: self.cameraView)
        self.videoManager.setCameraPosition(position: AVCaptureDevice.Position.front)
        self.faceDetector = FaceDetectionModel(videoManager: self.videoManager)
        //self.view.backgroundColor = nil
    }
    
    //MARK: Convenience Methods for UI Flash and Camera Toggle
    @IBAction func flash(_ sender: AnyObject) {
        self.videoManager.toggleFlash()
    }
    
    @IBAction func switchCamera(_ sender: AnyObject) {
        self.videoManager.toggleCameraPosition()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.videoManager.shutdown()
    }
}
