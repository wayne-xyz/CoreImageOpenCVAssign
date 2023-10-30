//
//  ModuleBViewController.swift
//  ImageLab
//
//  Created by RongWei Ji on 10/29/23.
//  Copyright © 2023 Eric Larson. All rights reserved.
//

import UIKit
import MetalKit

class ModuleBViewController: UIViewController {

    //Properties
    var videoManager:VisionAnalgesic!=nil
    var detector:CIDetector!=nil
    let bridge = OpenCVBridge()
    var fingerFlashFlag=false;
    
    @IBOutlet weak var cameraView: MTKView!
    
    @IBOutlet weak var colorChartView: ColorLineChartView!  // use a custom chart view to show the color value
    
    @IBOutlet weak var heartBeatView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup the OpenCV, video manager, call the block func to detect the finger cover
        self.bridge.loadHaarCascade(withFilename: "nose")
        
        self.videoManager=VisionAnalgesic(view: self.cameraView)
        self.videoManager.setCameraPosition(position: AVCaptureDevice.Position.back)
        self.videoManager.setProcessingBlock(newProcessBlock: processFinger)
        if !videoManager.isRunning{
            videoManager.start()
        }
    }
    
    
    
    func processFinger(inputImage:CIImage)->CIImage{
        var returnImage=inputImage
        self.bridge.setImage(returnImage, withBounds: returnImage.extent, andContext: self.videoManager.getCIContext())
        let processFingerResult=self.bridge.processFinger()
        returnImage=self.bridge.getImage()
        fingerCoverDectect(coveringBoolFlag: processFingerResult)
        print("here is the count\(self.bridge.redArray.count) and here is the last value\(String(describing: self.bridge.redArray.lastObject))");
      
        return returnImage
    }
    
    
    // use the red color for update the color chart for monitorting the red
    func updateColorChart(inputArray: [Double] ){
        if inputArray.count>0{
            if let lastValue=inputArray.last {
                self.colorChartView.addDataPoint(lastValue)
            }
        }
    }
    
    
    func fingerCoverDectect(coveringBoolFlag:Bool){
        // finger cover happen, turn on/off flash, avoid running everytime.
        if self.bridge.coverStatus==1{
            
            updateColorChart(inputArray: self.bridge.redArray as! [Double])// when finger is covering the chart show the data
            
            if(self.fingerFlashFlag==false){ // this is for the flash
               _ = self.videoManager.turnOnFlashwithLevel(1.0)
                self.fingerFlashFlag=true;
                print("finger cover,flash on.")
            }
          
        }else if self.bridge.coverStatus==2{
              print("something cover rather than finger")
        }else{
            if self.fingerFlashFlag{
                self.videoManager.turnOffFlash()
                self.fingerFlashFlag=false;
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
