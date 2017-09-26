# SYPolygonButton
`谷胜亚初次编辑于2017年9月25日`

>前言

![image.png](http://upload-images.jianshu.io/upload_images/2460711-255c5f9ddbc69cdf.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

要实现如图片中左侧的正六边形按钮，其中要有边框以及角的弧度。由于以前做过`CALayer`相关的功能，自然想起利用`CALayer`绘制`path`来实现该功能。
>根据最大半径计算各顶点坐标


![2460711-1410c2a76ad83148.png](http://upload-images.jianshu.io/upload_images/2460711-4262cc67c9807007.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


先确定按钮的`size`得出最大`r`值，然后按照这个模式得出每个点相对于按钮的坐标，使用`UIBezierPath`绘制`path`得到最后的图样。按照这样的逻辑确实可以做出如UI展示的效果(先忽略圆角和边框)，但是因此会引发一个问题:这种代码是一种死代码。本着代码的可扩展性原则，在此封装了一个`多边形按钮`


>弧度计算顶点坐标

* 首先进行一下逻辑分析，按照固定点坐标的做法会导致代码死板，因此换个思路进行设计: 使用`角度`的形式来设置对应点坐标。
* 以按钮的中心点`centerPoint`作为原点，按钮所在坐标系的`x`轴上点`(r, 0)`点作为绘制的起始点，依据顺时针方向依次计算每个点的坐标
* 根据规律可知对应弧度所表示的点的坐标的`x`值等于`centerPoint.x + 
 r * cos(弧度)`，而`y`值等于`centerPoint.y + r * sin(弧度)` 该坐标既是多边形对应顶点的坐标

获取单个点的坐标
```
    private func vertexCoordinates(radius: CGFloat, angle: Double, offset: Double = 0) ->CGPoint {
        let centerPoint = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let X = centerPoint.x + radius * (angle + offset).cosValue
        let Y = centerPoint.y + radius * (angle + offset).sinValue
        return CGPoint(x: X, y: Y)
    }
```

根据多边形的边数、最大半径以及偏移弧度获得多边形的每个顶点的坐标
```
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
```

再进一步根据获得的各个顶点的坐标数组可以用`UIBezierPath`绘制图案
```
            let points = regularPolygonCoordinates(sides: style.sides, radius: r, offset: style.offset)

            for (index, point) in points.enumerated() {
                if index == 0 {
                    path.move(to: point)
                }else {
                    path.addLine(to: point)
                }
            }
            path.close()
```

到现在只是得到了完整的`path`还需要设置到`layer`上才能变相的按该路径裁剪按钮

```
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
```

然后在`layoutSubviews()`方法中调用该绘制方法即可获得对应图形的按钮
```
override func layoutSubviews() {
        super.layoutSubviews()
        
        hexagon()
    }
```

>圆角的设置

我这里的圆角采用的不是平时按钮的`cornerRadius`，而是采用的`贝塞尔曲线`的形式设置圆角，即根据两个定点以及一个控制点来绘制一条有弧度的曲线，原因是多边形如果设置`cornerRadius`会导致曲率很大最后裁剪出的弧度十分难看(不认同的话欢迎指正)

![A226DCFDDF69510054DD2C8A47A2CA48.jpg](http://upload-images.jianshu.io/upload_images/2460711-1bf99895482ffee1.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

如果把`正多边形`以`中心点`、`顶点`与`邻近顶点`组成的`等边三角形`视为一个子模块，选取`贝塞尔曲线`的固定两点其一为`D`点(另一点以`AC`边对称)与控制点`C`，则只需要计算出`D`点对应的坐标即可(`C`点坐标已知，`r`最大半径已知，`CD`长度自定义，多边形边数自定义)

* 首先需要计算出`∠DAC`角的弧度
* 然后计算出`AD`边的大小
* 根据普通正多边形各顶点坐标的规律计算出`AD`为`R`的多边形相对于原多边形偏移`∠DAC`角度的各顶点坐标
```
private func regularPolygonCoordinatesWithRoundedCorner(sides: Int, radius: CGFloat, offset: Double = 0) ->[CGPoint] {
        assert(sides >= 3, "多边形最少为3边")
        assert(radius > 0, "多边形半径必须大于0")
        let CAB = Double(360) / Double(sides) / Double(180) * Double.pi
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
```
通过上面的代码逻辑可以计算出有圆角的多边形的各关键点坐标，然后就只需要把这些关键点根据规律连接到一起。
```
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
```

>封装控制属性
```

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
```

当然，有了控制属性的类没有使用场景怎么行，只需要一个新的构造方法即可
```
init(frame: CGRect = CGRect.zero, style: SYPolygonStyle = SYPolygonStyle()) {
        self.style = style
        super.init(frame: frame)
    }
```
使用方法类似于下例:
```
        let style = SYPolygonStyle()
        style.filletDegree = 10
        style.borderWidth = 10
        style.borderColor = .orange
        style.roundedCornersEnable = true
        style.offset = Double.pi / 4
        style.sides = 5

        let liubianxing = SYPolygonButton(frame: CGRect.zero, style: style)
        liubianxing.setImage(UIImage.init(named: "zhbd_qq_icon"), for: .normal)
        liubianxing.setImage(UIImage.init(named: "zhbd_weibo_icon"), for: .selected)
        liubianxing.addTarget(self, action: #selector(btnClickAction(sender:)), for: .touchUpInside)
        view.addSubview(liubianxing)
        liubianxing.snp.makeConstraints { (make) in
            make.top.left.equalTo(100)
            make.width.height.equalTo(100)
        }
```

Demo <https://github.com/githubOfGuShengYa/SYPolygonButton>
