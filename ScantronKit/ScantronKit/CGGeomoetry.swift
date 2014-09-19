// from https://gist.github.com/detomon/864a6b7c51f8bed7a022

import Foundation

/**
* CGPoint
*
* var a = CGPointMake(13.5, -34.2)
* var b = CGPointMake(8.9, 22.4)
* ...
*/

/**
* ...
* a + b
*/
func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPointMake(left.x + right.x, left.y + right.y)
}

/**
* ...
* a += b
*/
func += (inout left: CGPoint, right: CGPoint) {
    left = left + right
}

/**
* ...
* a -= b
*/
func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPointMake(left.x - right.x, left.y - right.y)
}

/**
* ...
* a -= b
*/
func -= (inout left: CGPoint, right: CGPoint) {
    left = left - right
}

/**
* ...
* a * b
*/
func * (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPointMake(left.x * right.x, left.y * right.y)
}

/**
* ...
* a *= b
*/
func *= (inout left: CGPoint, right: CGPoint) {
    left = left * right
}

/**
* ...
* a / b
*/
func / (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPointMake(left.x / right.x, left.y / right.y)
}

/**
* ...
* a /= b
*/
func /= (inout left: CGPoint, right: CGPoint) {
    left = left / right
}

/**
* ...
* a * 10.4
*/
func * (left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPointMake(left.x * right, left.y * right)
}

/**
* ...
* a *= 10.4
*/
func *= (inout left: CGPoint, right: CGFloat) {
    left = left * right
}

/**
* ...
* a / 10.4
*/
func / (left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPointMake(left.x / right, left.y / right)
}

/**
* ...
* a /= 10.4
*/
func /= (inout left: CGPoint, right: CGFloat) {
    left = left / right
}

/**
* var c = CGSizeMake(20.4, 75.8)
* ...
*/

/**
* ...
* a + c
*/
func + (left: CGPoint, right: CGSize) -> CGPoint {
    return CGPointMake(left.x + right.width, left.y + right.height)
}

/**
* ...
* a += c
*/
func += (inout left: CGPoint, right: CGSize) {
    left = left + right
}

/**
* ...
* a - c
*/
func - (left: CGPoint, right: CGSize) -> CGPoint {
    return CGPointMake(left.x - right.width, left.y - right.height)
}

/**
* ...
* a -= c
*/
func -= (inout left: CGPoint, right: CGSize) {
    left = left - right
}

/**
* ...
* a * c
*/
func * (left: CGPoint, right: CGSize) -> CGPoint {
    return CGPointMake(left.x * right.width, left.y * right.height)
}

/**
* ...
* a *= c
*/
func *= (inout left: CGPoint, right: CGSize) {
    left = left * right
}

/**
* ...
* a / c
*/
func / (left: CGPoint, right: CGSize) -> CGPoint {
    return CGPointMake(left.x / right.width, left.y / right.height)
}

/**
* ...
* a /= c
*/
func /= (inout left: CGPoint, right: CGSize) {
    left = left / right
}

/**
* ...
* -a
*/
prefix func - (left: CGPoint) -> CGPoint {
    return CGPointMake(-left.x, -left.y)
}

extension CGPoint {
    /**
    * Get point by rounding to nearest integer value
    */
    func integerPoint() -> CGPoint {
        return CGPointMake(
            CGFloat(Int(self.x >= 0.0 ? self.x + 0.5 : self.x - 0.5)),
            CGFloat(Int(self.y >= 0.0 ? self.y + 0.5 : self.y - 0.5))
        )
    }
    
    func length() -> CGFloat {
        return sqrt(pow(self.x, 2) + pow(self.y, 2))
    }
    
    func angle() -> CGFloat {
        return CGFloat(atan2f(Float(self.y), Float(self.x)))
    }
}

/**
* Get minimum x and y values of multiple points
*/
func min(a: CGPoint, b: CGPoint, rest: CGPoint...) -> CGPoint {
    var p = CGPointMake(min(a.x, b.x), min(a.y, b.y))
    
    for point in rest {
        p.x = min(p.x, point.x)
        p.y = min(p.y, point.y)
    }
    
    return p
}

/**
* Get maximum x and y values of multiple points
*/
func max(a: CGPoint, b: CGPoint, rest: CGPoint...) -> CGPoint {
    var p = CGPointMake(max(a.x, b.x), max(a.y, b.y))
    
    for point in rest {
        p.x = max(p.x, point.x)
        p.y = max(p.y, point.y)
    }
    
    return p
}

/**
* CGSize
*/

/**
* var a = CGSizeMake(8.9, 14.5)
* var b = CGSizeMake(20.4, 75.8)
* ...
*/

/**
* ...
* a + b
*/
func + (left: CGSize, right: CGSize) -> CGSize {
    return CGSizeMake(left.width + right.width, left.height + right.width)
}

func * (size: CGSize, scale: CGFloat) -> CGSize {
    return CGSizeMake(size.width * scale, size.height * scale)
}

func / (size: CGSize, scale: CGFloat) -> CGSize {
    return CGSizeMake(size.width / scale, size.height / scale)
}

/**
* ...
* a += b
*/
func += (inout left: CGSize, right: CGSize) {
    left = left + right
}

/**
* ...
* a - b
*/
func - (left: CGSize, right: CGSize) -> CGSize {
    return CGSizeMake(left.width - right.width, left.height - right.height)
}

/**
* ...
* a -= b
*/
func -= (inout left: CGSize, right: CGSize) {
    left = left - right
}

/**
* ...
* a * b
*/
func * (left: CGSize, right: CGSize) -> CGSize {
    return CGSizeMake(left.width * right.width, left.height * right.height)
}

/**
* ...
* a *= b
*/
func *= (inout left: CGSize, right: CGSize) {
    left = left * right
}

/**
* ...
* a / b
*/
func / (left: CGSize, right: CGSize) -> CGSize {
    return CGSizeMake(left.width / right.width, left.height / right.height)
}

/**
* ...
* a /= b
*/
func /= (inout left: CGSize, right: CGSize) {
    left = left / right
}

/**
* var c = CGPointMake(-3.5, -17.6)
* ...
*/

/**
* ...
* a + c
*/
func + (left: CGSize, right: CGPoint) -> CGSize {
    return CGSizeMake(left.width + right.x, left.height + right.y)
}

/**
* ...
* a += c
*/
func += (inout left: CGSize, right: CGPoint) {
    left = left + right
}

/**
* ...
* a - c
*/
func - (left: CGSize, right: CGPoint) -> CGSize {
    return CGSizeMake(left.width - right.x, left.height - right.y)
}

/**
* ...
* a -= c
*/
func -= (inout left: CGSize, right: CGPoint) {
    left = left - right
}

/**
* ...
* a * c
*/
func * (left: CGSize, right: CGPoint) -> CGSize {
    return CGSizeMake(left.width * right.x, left.height * right.y)
}

/**
* ...
* a *= c
*/
func *= (inout left: CGSize, right: CGPoint) {
    left = left * right
}

/**
* ...
* a / c
*/
func / (left: CGSize, right: CGPoint) -> CGSize {
    return CGSizeMake(left.width / right.x, left.height / right.y)
}

/**
* ...
* a /= c
*/
func /= (inout left: CGSize, right: CGPoint) {
    left = left / right
}

/**
* ...
* a * 4.6
*/

/**
* ...
* a *= 4.6
*/
func *= (inout left: CGSize, right: CGFloat) {
    left = left * right
}

/**
* CGRect
*
* var a = CGRectMake(30.4, 58.6, 20.3, 78.3)
* var b = CGPointMake(-16.7, 40.5)
* ...
*/

/**
* ...
* a + b
*/
func + (left: CGRect, right: CGPoint) -> CGRect {
    return CGRectMake(left.origin.x + right.x, left.origin.y + right.y, left.size.width, left.size.height)
}

/**
* ...
* a += b
*/
func += (inout left: CGRect, right: CGPoint) {
    left = left + right
}

/**
* ...
* a - b
*/
func - (left: CGRect, right: CGPoint) -> CGRect {
    return CGRectMake(left.origin.x - right.x, left.origin.y - right.y, left.size.width, left.size.height)
}

/**
* ...
* a -= b
*/
func -= (inout left: CGRect, right: CGPoint) {
    left = left - right
}

/**
* ...
* a * 2.5
*/
func * (left: CGRect, right: CGFloat) -> CGRect {
    return CGRectMake(left.origin.x * right, left.origin.y * right, left.size.width * right, left.size.height * right)
}

/**
* ...
* a *= 2.5
*/
func *= (inout left: CGRect, right: CGFloat) {
    left = left * right
}

/**
* ...
* a / 4.0
*/
func / (left: CGRect, right: CGFloat) -> CGRect {
    return CGRectMake(left.origin.x / right, left.origin.y / right, left.size.width / right, left.size.height / right)
}

/**
* ...
* a /= 4.0
*/
func /= (inout left: CGRect, right: CGFloat) {
    left = left / right
}

extension CGRect {
    /**
    * Extend CGRect by CGPoint
    */
    mutating func union(withPoint: CGPoint) {
        if withPoint.x < self.origin.x { self.size.width += self.origin.x - withPoint.x; self.origin.x = withPoint.x }
        if withPoint.y < self.origin.y { self.size.height += self.origin.y - withPoint.y; self.origin.y = withPoint.y }
        if withPoint.x > self.origin.x + self.size.width { self.size.width = withPoint.x - self.origin.x }
        if withPoint.y > self.origin.y + self.size.height { self.size.height = withPoint.y - self.origin.y; }
    }
    
    /**
    * Get end point of CGRect
    */
    func maxPoint() -> CGPoint {
        return CGPointMake(self.origin.x + self.size.width, self.origin.y + self.size.height)
    }
}

func abs(a: CGFloat) -> CGFloat {
    return CGFloat(fabsf(Float(a)))
}

struct CGGeometry {
    static func angleDiff(a: CGFloat, b: CGFloat) -> CGFloat {
        let pi = CGFloat(M_PI)
        let d = abs(a - b) % (pi * 2)
        return d > pi ? pi * 2 - d : d
    }
}
