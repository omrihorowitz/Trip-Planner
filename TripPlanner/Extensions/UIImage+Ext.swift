//
//  UIImage+Additions.swift
//  TripPlanner
//
//  Created by Omri Horowitz on 3/14/21.
//

import UIKit

extension UIImage {
  static var buttonBackground: UIImage {
    let imageSideLength: CGFloat = 8
    let halfSideLength = imageSideLength / 2
    let imageFrame = CGRect(
      x: 0,
      y: 0,
      width: imageSideLength,
      height: imageSideLength
    )

    let image = UIGraphicsImageRenderer(size: imageFrame.size).image { ctx in
      ctx.cgContext.addPath(
        UIBezierPath(
          roundedRect: imageFrame,
          cornerRadius: halfSideLength
        ).cgPath
      )
        ctx.cgContext.setFillColor(CGColor.init(red: 0, green: 100, blue: 0, alpha: 1))
      ctx.cgContext.fillPath()
    }

    return image.resizableImage(
      withCapInsets: UIEdgeInsets(
        top: halfSideLength,
        left: halfSideLength,
        bottom: halfSideLength,
        right: halfSideLength
      )
    )
  }
}
