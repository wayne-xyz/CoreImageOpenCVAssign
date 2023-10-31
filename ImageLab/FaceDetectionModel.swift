//
//  FaceDetectionModel.swift
//  ImageLab
//
//  Created by Owen on 10/31/23.
//  Copyright © 2023 Eric Larson. All rights reserved.
//

import UIKit

class FaceDetectionModel: NSObject {
    var detector:CIDetector! = nil
    var videoManager:VisionAnalgesic! = nil
    let bridge = OpenCVBridge()
    
    init(videoManager: VisionAnalgesic!) {
        super.init()
        self.videoManager = videoManager
        let optsDetector = [CIDetectorAccuracy:CIDetectorAccuracyHigh,
                      CIDetectorNumberOfAngles:9,
                            CIDetectorTracking:false] as [String : Any]
        
        // setup a face detector in swift
        self.detector = CIDetector(ofType: CIDetectorTypeFace,
                                   context: self.videoManager.getCIContext(), // perform on the GPU is possible
                                   options: (optsDetector as [String : AnyObject]))
        
        self.videoManager.setProcessingBlock(newProcessBlock: self.processImageSwift)
        
        if !videoManager.isRunning{
            videoManager.start()
        }
        
    }
    // process frames
    func processImageSwift(inputImage:CIImage) -> CIImage{
        // detect faces
        let f = getFaces(img: inputImage)
        
        // if no faces, just return original image
        if f.count == 0 { return inputImage }
        
        var retImage = inputImage
        
        self.bridge.setImage(retImage,
                             withBounds: inputImage.extent, // the first face bounds
                             andContext: self.videoManager.getCIContext())
        
        self.bridge.processFaces(f)
        retImage = self.bridge.getImageComposite() // get back opencv processed part of the image (overlayed on original)
        
        return retImage
    }
    
    // detect faces
    func getFaces(img:CIImage) -> [CIFaceFeature]{
        // this ungodly mess makes sure the image is the correct orientation
        let optsFace = [CIDetectorImageOrientation:self.videoManager.ciOrientation,
                                   CIDetectorSmile:true,
                                CIDetectorEyeBlink:true] as [String : Any]
        // get Face Features
        return self.detector.features(in: img, options: optsFace) as! [CIFaceFeature]
        
    }
}
