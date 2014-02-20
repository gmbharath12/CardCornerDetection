//
//  RectangleView.h
//  CardDetectionApp
//
//  Created by Bharath G M on 11/10/13.
//  Copyright (c) 2014 Bharath G M. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RectangleView : UIView
{
    
}

@property (nonatomic) bool isTopEdge;
@property (nonatomic) bool isBottomEdge;
@property (nonatomic) bool isLeftEdge;
@property (nonatomic) bool isRightEdge;

- (void)drawAgain;
@end
