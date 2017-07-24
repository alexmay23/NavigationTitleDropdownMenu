//
//  Extensions.swift
//  NavigationTitleDropdownMenu
//
//  Created by Alex Moiseenko on 6/18/17.
//  Copyright © 2017 Alex Moiseenko. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC



let bundle = Bundle(url: Bundle(for: DropdownMenu.self).url(forResource: "UI", withExtension: "bundle"));

extension UIButton
{
    
    fileprivate struct Constants{
        
        static var edgeInsetsKey = "edgeInsetsKey"
    }
    
    public var hitEdgeInsets:UIEdgeInsets
    {
        get
        {
            return objc_getAssociatedObject(self, &Constants.edgeInsetsKey) as? UIEdgeInsets ?? UIEdgeInsets.zero
        }
        set
        {
            objc_setAssociatedObject(self,  &Constants.edgeInsetsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let insets = self.hitEdgeInsets;
        guard !UIEdgeInsetsEqualToEdgeInsets(insets, UIEdgeInsets.zero) else{ return super.point(inside: point, with: event)}
        let currentBounds = self.bounds;
        let updatedBounds = UIEdgeInsetsInsetRect(currentBounds, insets);
        return updatedBounds.contains(point);
    }
    
}
