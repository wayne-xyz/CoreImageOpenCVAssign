//
//  ColorLineChartView.swift
//  ImageLab
//
//  Created by RongWei Ji on 10/29/23.
//  Copyright © 2023 Eric Larson. All rights reserved.
//

import UIKit

class ColorLineChartView: UIView {

    // set main properties
    var dataPoints: [Double] = []
    private let MAX_POINTS_SHOW=1000 // count in one wide wide
    private let MAX_POINTS_VALUE=255 // the hight for chart1
    private let MAX_POINTS_VALUE2=235 // the hight for chat2  zoomed the PPG chart
    private let MIN_POINTS_VALUE2 = 210  // second chart that is about 100 for chart 2 because chart 2 is 100-150 range
    private let LINE_WIDTH=2.0  // for the line width
        
    var peaksPoints:[Double]=[]
    
    func addDataPoint(_ dataPoint: Double , istype1:Bool) { // type 1:  ture for chart 1 , type 2 :false
        if istype1{
            dataPoints.append(dataPoint/Double(MAX_POINTS_VALUE))
        }else{
            let normalizedDataPoint = (dataPoint - Double(MIN_POINTS_VALUE2)) / (Double(MAX_POINTS_VALUE2) - Double(MIN_POINTS_VALUE2))
            dataPoints.append(normalizedDataPoint)
        }
       
        if dataPoints.count > MAX_POINTS_SHOW{
            dataPoints.removeFirst()
        }
        setNeedsDisplay()
    }

    func addPeakPoint(dataP:Double , istype1: Bool){
        if istype1{
            peaksPoints.append(dataP/Double(MAX_POINTS_VALUE))
        }else{
            let normalizedDataPoint = (dataP - Double(MIN_POINTS_VALUE2)) / (Double(MAX_POINTS_VALUE2) - Double(MIN_POINTS_VALUE2))
            dataPoints.append(normalizedDataPoint)
        }
        
        if peaksPoints.count>MAX_POINTS_SHOW{
            peaksPoints.removeFirst()
        }
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawLineChart(points:dataPoints,color:UIColor.red,lineWidth: LINE_WIDTH)
        drawLineChart(points: peaksPoints, color: UIColor.blue,lineWidth: LINE_WIDTH/2)
    }
    
    
    
    
    func drawLineChart( points:[Double], color:UIColor, lineWidth:CGFloat) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.setLineWidth(lineWidth)
        context.setStrokeColor(color.cgColor)

        let stepX = frame.size.width / CGFloat(MAX_POINTS_SHOW - 1) //
        var x: CGFloat = 0

        for (index, dataPoint) in points.enumerated() {
            let y = frame.size.height * (1 - CGFloat(dataPoint))
            if index == 0 {
                context.move(to: CGPoint(x: x, y: y))
            } else {
                context.addLine(to: CGPoint(x: x, y: y))
            }
            x += stepX
        }

        context.strokePath()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
