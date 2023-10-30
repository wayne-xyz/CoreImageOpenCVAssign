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
    private let MAX_POINTS_VALUE=255 // the hight
    private let LINE_WIDTH=2.0  // for the line width
        
    var peaksPoints:[Double]=[]
    
    func addDataPoint(_ dataPoint: Double) {
        dataPoints.append(dataPoint/255)
        if dataPoints.count > MAX_POINTS_SHOW{
            dataPoints.removeFirst()
        }
        setNeedsDisplay()
    }

    func addPeakPoint(dataP:Double){
        peaksPoints.append(dataP/255)
        if peaksPoints.count>MAX_POINTS_SHOW{
            peaksPoints.removeFirst()
        }
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
       drawLineChart(points:dataPoints,color:UIColor.red)
       drawLineChart(points: peaksPoints, color: UIColor.blue)
    }
    
    
    
    
    func drawLineChart( points:[Double], color:UIColor) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.setLineWidth(LINE_WIDTH)
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
