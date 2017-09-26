//
//  SYPolygonButton.swift
//  App-Swift
//
//  Created by 谷胜亚 on 2017/9/7.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//  正多边形按钮

import Foundation
import UIKit


/// 按钮的风格
class SYPolygonStyle {
    /// 是否可以圆角
    var roundedCornersEnable: Bool = false
    /// 圆角程度 - 值越大,角越平滑
    var filletDegree: Double = 5.0
    
    /// 边界宽度(边线的宽度)
    var borderWidth: CGFloat = 0.0
    /// 边界颜色
    var borderColor: UIColor = UIColor.gray
    
    /// 多边形最大半径 -- 如果不设置该值, 默认是按钮中可显示的最大多边形的半径
    var Max_Radius: CGFloat = 0.0
    
    /// 整个路径以按钮的中心点为中心按顺时针方向偏移的弧度(需要传入一个带π的弧度) -- 默认六边形顶点为水平方向, 如果设置该值为π/2则顶点为竖直方向
    var offset: Double = 0
    /// 多边形的边数 - 默认是正六边形
    var sides: Int = 6
}


/// 多边形按钮
class SYPolygonButton: UIButton {
    
    private var style: SYPolygonStyle
    
    init(frame: CGRect = CGRect.zero, style: SYPolygonStyle = SYPolygonStyle()) {
        
        self.style = style
        
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        hexagon()
    }
    private func hexagon() {
        var Max_R: CGFloat
        if style.Max_Radius == 0 {
            let W = bounds.width
            let H = bounds.height
            assert(W > 0 && H > 0, "此时宽或者高没有值")
            Max_R = H > W ? W / 2 : H / 2
        }else {
            Max_R = style.Max_Radius
        }
        assert(Max_R > style.borderWidth, "多边形最大半径不能小于边界宽度")
        for (index, layer) in self.layer.sublayers!.enumerated() {
            if index != 0 {
                layer.removeFromSuperlayer()
            }
        }
        let topLayer = CAShapeLayer()
        topLayer.path = drawPath(radius: Max_R)
        topLayer.strokeColor = style.borderColor.cgColor
        topLayer.fillColor = UIColor.clear.cgColor
        topLayer.lineWidth = style.borderWidth
        let bottomLayer = CAShapeLayer()
        bottomLayer.path = drawPath(radius: Max_R)
        self.layer.mask = bottomLayer
        self.layer.insertSublayer(topLayer, above: bottomLayer)
    }

    private func drawPath(radius: CGFloat) ->CGPath {
        let W = bounds.width
        let H = bounds.height
        assert(W > 0 && H > 0, "此时宽或者高没有值")
        let isWBigger: Bool = W * sqrt(3.0) > H
        var r = isWBigger ? H / 2 : sqrt(3.0) / 3 * W
        assert(radius <= r, "传入的半径超过可以显示的最大半径")
        if radius < r {
            r = radius
        }
        let path = UIBezierPath()
        if style.roundedCornersEnable {
            let points = regularPolygonCoordinatesWithRoundedCorner(sides: style.sides, radius: r, offset: style.offset)
            var temPoint: CGPoint!
            for (index, point) in points.enumerated() {
                
                if index == 0 {
                    path.move(to: point)
                }else {
                    let remainder = index % 3
                    
                    switch remainder {
                    case 0:
                        path.addLine(to: point)
                    case 1:
                        temPoint = point
                    case 2:
                        path.addQuadCurve(to: point, controlPoint: temPoint)
                    default:
                        break
                    }
                }
            }
            path.close()
        }else {
            let points = regularPolygonCoordinates(sides: style.sides, radius: r, offset: style.offset)
            
            for (index, point) in points.enumerated() {
                if index == 0 {
                    path.move(to: point)
                }else {
                    path.addLine(to: point)
                }
            }
            path.close()
        }
        return path.cgPath
    }

    private func vertexCoordinates(radius: CGFloat, angle: Double, offset: Double = 0) ->CGPoint {
        let centerPoint = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let X = centerPoint.x + radius * (angle + offset).cosValue
        let Y = centerPoint.y + radius * (angle + offset).sinValue
        return CGPoint(x: X, y: Y)
    }
    private func regularPolygonCoordinates(sides: Int, radius: CGFloat, offset: Double = 0) ->[CGPoint] {
        
        assert(sides >= 3, "多边形最少为3边")
        assert(radius > 0, "多边形半径必须大于0")
        var coordinates = [CGPoint]()
        for i in 0..<sides {
            let corner = Double(360) / Double(sides)
            let radian = corner / Double(180) * Double.pi
            let radianOfPoint = Double(i) * radian
            let point = vertexCoordinates(radius: radius, angle: radianOfPoint, offset: offset)
            coordinates.append(point)
        }
        return coordinates
    }

    private func regularPolygonCoordinatesWithRoundedCorner(sides: Int, radius: CGFloat, offset: Double = 0) ->[CGPoint] {
        assert(sides >= 3, "多边形最少为3边")
        assert(radius > 0, "多边形半径必须大于0")
        let CAB = Double(360) / Double(6) / Double(180) * Double.pi
        let EC = Double(radius * (CAB / 2).sinValue)
        let AE = Double(radius * (CAB / 2).cosValue)
        let ED = EC - style.filletDegree
        let EAD = atan(ED / AE)
        let DAC = CAB / 2 - EAD
        let newRadius = sqrt(pow(AE, 2) + pow(ED, 2))
        var coordinates = [CGPoint]()
        for i in 0..<sides {
            let direction = Double(i) * Double(360) / Double(sides) / Double(180) * Double.pi
            let point = vertexCoordinates(radius: radius, angle: direction, offset: offset)
            let leftAngle = direction - DAC
            let leftPoint = vertexCoordinates(radius: CGFloat(newRadius), angle: leftAngle, offset: offset)
            let rightAngle = direction + DAC
            let rightPoint = vertexCoordinates(radius: CGFloat(newRadius), angle: rightAngle, offset: offset)
            coordinates.append(leftPoint)
            coordinates.append(point)
            coordinates.append(rightPoint)
        }
        return coordinates
    }
}


extension Double {
    var sinValue: CGFloat {
        let double = sin(self)
        return CGFloat(double)
    }

    var cosValue: CGFloat {
        let double = cos(self)
        return CGFloat(double)
    }
}
