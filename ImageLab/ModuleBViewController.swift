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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup the OpenCV, video manager
        self.bridge.loadHaarCascade(withFilename: "nose")
        
        self.videoManager=VisionAnalgesic(view: self.cameraView)
        self.videoManager.setCameraPosition(position: AVCaptureDevice.Position.back)
        // Do any additional setup after loading the view.
    }
    
    
    
    func processFinger(inputImage:CIImage)->CIImage{
        var returnImage=inputImage
        self.bridge.setImage(returnImage, withBounds: returnImage.extent, andContext: self.videoManager.getCIContext())
        let processFingerResult=self.bridge.processFinger()
        returnImage=self.bridge.getImage()
        fingerCoverDectect(coveringBoolFlag: processFingerResult)
        return returnImage
    }
    
    func fingerCoverDectect(coveringBoolFlag:Bool){
        if coveringBoolFlag==true{  // when something is covering disable the two button
          
        }else{
         
        }
        
        // finger cover happen, turn on/off flash, avoid running everytime.
        if self.bridge.coverStatus==1{
            if(self.fingerFlashFlag==false){
                self.videoManager.turnOnFlashwithLevel(1.0)
                self.fingerFlashFlag=true;
                print("flash on.")
            }
          
        }else if self.bridge.coverStatus==2{
           
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
