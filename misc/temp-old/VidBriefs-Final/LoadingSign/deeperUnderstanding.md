# Logic behind the Loading Sign

- [ ] The spinner will be a circular shape with a gray stroke color (UIColor.gray.cgColor).

- [ ] The stroke width of the circle will be 5.0 points (lineWidth = 5.0).

- [ ] The circle will not be fully complete; it will have a gap. This is because the strokeEnd property of the circleLayer is set to 0.5, which means only half of the circle will be drawn.

- [ ] The size of the circle will be determined by the radius constant, which is currently set to 50.0. This means the diameter of the circle will be 100 points.

- [ ] The spinner will be centered within the view bounds, as the centrePoint is calculated based on the view's midX and midY values.

The spinner will continuously rotate clockwise. This is achieved by applying a CABasicAnimation to the circleLayer with a rotation from 0 to 2π radians (CGFloat.pi * 2) and an infinite repeat count.