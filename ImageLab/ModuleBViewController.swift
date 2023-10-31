//
//  ModuleBViewController.swift
//  ImageLab
//
//  Created by RongWei Ji on 10/29/23.
//  Copyright © 2023 Eric Larson. All rights reserved.
//

import UIKit
import MetalKit
import Accelerate

class ModuleBViewController: UIViewController {

    //Properties
    var videoManager:VisionAnalgesic!=nil
    var detector:CIDetector!=nil
    let bridge = OpenCVBridge()
    var fingerFlashFlag=false
    var isFingerMode=true // true means fingermode, false means facemode
    
    var DEFAULT_LABEL_TEXT="☝️ Cover your finger on back camera"
    var CACULATING_LABEL_TEXT="Caculating, keep covering"
    var FACEING_LABEL_TEXT="Look at front camera"
    
    @IBOutlet weak var bpmLabel: UILabel!
    
    @IBOutlet weak var cameraView: MTKView!
    
    @IBOutlet weak var colorChartView: ColorLineChartView!  // use a custom chart view to show the color value
    @IBOutlet weak var changeModeButton: UIButton!
    
    @IBOutlet weak var heartBeatView: UIView!
    
    override func viewDidAppear(_ animated: Bool) {
        self.videoManager.setCameraPosition(position: AVCaptureDevice.Position.back)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup the OpenCV, video manager, call the block func to detect the finger cover
        //default setting for the finger set
        self.bridge.loadHaarCascade(withFilename: "nose")
        
        self.videoManager=VisionAnalgesic(view: self.cameraView)
        self.videoManager.setCameraPosition(position: AVCaptureDevice.Position.back)
        self.videoManager.setProcessingBlock(newProcessBlock: processFinger)
        if !videoManager.isRunning{
            videoManager.start()
        }
        cameraView.isOpaque=true
        self.bridge.isFingerMode=true
    }
    
    
    // change the mode of detect for finger or face
    @IBAction func changeModeAction(_ sender: Any) {
        if self.isFingerMode{
            //change to the facemode
            bpmLabel.text=FACEING_LABEL_TEXT
            isFingerMode=false
            self.bridge.isFingerMode=false
            changeModeButton.setTitle("Start Finger Detection Mode", for: .normal)
            self.videoManager.setCameraPosition(position: AVCaptureDevice.Position.front)
            // not for finger function below comments
            // create dictionary for face detection
            // HINT: you need to manipulate these properties for better face detection efficiency
            let optsDetector = [CIDetectorAccuracy:CIDetectorAccuracyHigh,
                          CIDetectorNumberOfAngles:11,
                          CIDetectorTracking:false] as [String : Any]
            
            // setup a face detector in swift
            self.detector = CIDetector(ofType: CIDetectorTypeFace,
                                      context: self.videoManager.getCIContext(), // perform on the GPU is possible
                options: (optsDetector as [String : AnyObject]))
            self.videoManager.setProcessingBlock(newProcessBlock: processFaceSwift)
            cameraView.isOpaque=true
            
        }else{
            isFingerMode=true
            self.bridge.isFingerMode=true
            //change to the fingermode
            changeModeButton.setTitle("Start Face Detection Mode", for: .normal)
            self.videoManager.setCameraPosition(position: AVCaptureDevice.Position.back)
            self.videoManager.setProcessingBlock(newProcessBlock: processFinger)
            cameraView.isOpaque=false
        }
        
        if !videoManager.isRunning{
            videoManager.start()
        }
        
    }
    
    
    // block for processing finger cover camera
    func processFinger(inputImage:CIImage)->CIImage{
        var returnImage=inputImage
        self.bridge.setImage(returnImage, withBounds: returnImage.extent, andContext: self.videoManager.getCIContext())
        let processFingerResult=self.bridge.processFinger()
        returnImage=self.bridge.getImage()
        fingerCoverDectect(coveringBoolFlag: processFingerResult)
        //print("here is the count\(self.bridge.redArray.count) and here is the last value\(String(describing: self.bridge.redArray.lastObject))");
      
        return returnImage
    }
    
    
    
    //MARK: Process image output
    func processFaceSwift(inputImage:CIImage) -> CIImage{
        
        // detect faces
        let f = getFaces(img: inputImage)
        
        // if no faces, just return original image
        if f.count == 0 { return inputImage }
        
        var retImage = inputImage
        
        // Assuming you want to extract color values from a specific region (e.g., right side of the face)
        let roiRect = CGRect(x: 100, y: 50, width: 50, height: 50) // Adjust these values for your specific ROI
        
        let cgImage = retImage.cropped(to: roiRect)
        
        
        
        self.bridge.setImage(retImage,
                             withBounds: f[0].bounds, // the first face bounds
                             andContext: self.videoManager.getCIContext())
        
        self.bridge.processFinger()
        retImage = self.bridge.getImageComposite() // get back opencv processed part qinhof the image (overlayed on original)
        
    
       
        
        
        findPeakArray(self.bridge.redArray.lastObject as! Double) //call find function
        faceDetectUpdateChart(inputArray: peaks)
        getBPM(beatLengthArray: beatLengths)
        return retImage
    }
    
    //use uiview update chart and detect the face in same time will not perfom well for GPS ,the UIFPS will be 30
    // deprecate this function
    func faceDetectUpdateChart(inputArray:[Double]){
        if inputArray.count>0 {
            if  let lastValue=inputArray.last {
                self.colorChartView.addDataPoint(lastValue)
            }
        }
        
    }
    
    
    //MARK: Setup Face Detection
    
    func getFaces(img:CIImage) -> [CIFaceFeature]{
        // this ungodly mess makes sure the image is the correct orientation
        let optsFace = [CIDetectorImageOrientation:self.videoManager.ciOrientation]
        // get Face Features
        return self.detector.features(in: img, options: optsFace) as! [CIFaceFeature]
    }
    
    
    // use the red color for update the color chart for mozhonitorting the red
    func updateColorChart(inputArray: [Double] , type:Int){ //type 0 for main color , 1 for the peak
        if inputArray.count>0 {
            if type==0, let lastValue=inputArray.last {
                self.colorChartView.addDataPoint(lastValue)
            }else if type==1, let lastVaule=inputArray.last{
                self.colorChartView.addPeakPoint(dataP: lastVaule)
            }
        }
    }
    
    
    // check the finger cover satus for show chart
    // and generate the hearbeat rate
    func fingerCoverDectect(coveringBoolFlag:Bool){
        // finger cover happen, turn on/off flash, avoid running everytime.
        if self.bridge.coverStatus==1{
            bpmLabel.text=CACULATING_LABEL_TEXT
            updateColorChart(inputArray: self.bridge.redArray as! [Double],type:0)// when finger is covering the chart show the data update the main color
            findPeakArray(self.bridge.redArray.lastObject as! Double) //call find function
            updateColorChart(inputArray: peaks, type:1)
            getBPM(beatLengthArray: beatLengths)
            
            if(self.fingerFlashFlag==false){ // this is for the flash
               _ = self.videoManager.turnOnFlashwithLevel(1.0)
                self.fingerFlashFlag=true;
                print("finger cover,flash on.")
            }
          
        }else if self.bridge.coverStatus==2{
              print("something cover rather than finger")
        }else{
            bpmLabel.text=DEFAULT_LABEL_TEXT
            if self.fingerFlashFlag{
                self.videoManager.turnOffFlash()
                self.fingerFlashFlag=false;
            }
        }
    }

    
    // find out the peak of the color data, and save the each distance of beat length
    private var windowSize = 60
    private var currentWindow: [Double] = []
    var peaks: [Double] = []
    private var currentIndex = 0
    private var lastPeakindex = -1
    private var beatLengths:[Int]=[] // array for each peak distance
    
    // this function is to find the peaks and save them in peaks array
    func findPeakArray(_ newData:Double){
        currentWindow.append(newData)
        
        if currentWindow.count>windowSize{
            currentWindow.removeFirst()
        }
        currentIndex+=1
        
        if currentIndex>=windowSize{
            if let peak = currentWindow.max() ,  peak == currentWindow[windowSize/2] {
                if currentIndex - lastPeakindex > 20{
                    beatLengths.append(currentIndex-lastPeakindex) // save the beat length for caculate the BPM
                    
                    peaks.append(peak) // this is the peak and in the middel of the period
                    lastPeakindex=currentIndex
                }else{
                    peaks.append(0)
                }
            }else{
                peaks.append(0)
            }
        }else{
            peaks.append(0)
        }
    }
    
    // every two frame spend 19ms from nslog
    // theory value 60fps camera 16ms.
    // this func is to get the BPM from the peak distance array
    func getBPM(beatLengthArray:[Int]){
        if beatLengthArray.count>20{ //when the array is stable
            // get the last new ten everage distance and get the BPM
            var movingAverage: Double = 0.0
            let subArray=Array(beatLengthArray[beatLengthArray.count-5...beatLengthArray.count-1])
            let doubleDataPoints = subArray.map { Double( $0 ) }
            vDSP_meanvD(doubleDataPoints, 1, &movingAverage, vDSP_Length(5))
            print("5 peaks: \(doubleDataPoints)")
            let bpmStr=String(format: "%.2f", 60000/(movingAverage*19))
            bpmLabel.text="❤️BPM:\(bpmStr)"
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
