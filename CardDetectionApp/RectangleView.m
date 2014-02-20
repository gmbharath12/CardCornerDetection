//
//  RectangleView.m
//  CardDetectionApp
//
//  Created by Bharath G M on 11/10/13.
//  Copyright (c) 2014 Bharath G M. All rights reserved.
//
#define IS_IPHONE5  (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)

#import "RectangleView.h"

@implementation RectangleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextBeginPath(context);

    /* Start : Upper Left Corner*/
    if (IS_IPHONE5)
    {
        CGContextMoveToPoint(context, 25, 140);//start point
        CGContextAddLineToPoint(context, 25, 100.0);
        CGContextAddLineToPoint(context, 50, 100.0);
    }
    else
    {
      CGContextMoveToPoint(context, 25, 120);//start point
      CGContextAddLineToPoint(context, 25, 80.0);
      CGContextAddLineToPoint(context, 50, 80.0);
    }
    CGContextSetLineWidth(context, 16.0); // this is set from now on until you explicitly change it
    CGContextStrokePath(context); // do actual stroking
    /* End   : Upper Left Corner*/

    /* Start : Upper Right Corner*/
    if (IS_IPHONE5)
    {
        CGContextMoveToPoint(context, 296, 140.0);
        CGContextAddLineToPoint(context, 296,100.0);
        CGContextAddLineToPoint(context, 271, 100.0);
    }
    else
    {
        CGContextMoveToPoint(context, 296, 120.0);
        CGContextAddLineToPoint(context, 296,80.0);
        CGContextAddLineToPoint(context, 271, 80.0);
    }
    CGContextSetLineWidth(context, 16.0); // this is set from now on until you explicitly change it
    CGContextStrokePath(context); // do actual stroking
    /* End   : Upper Right Corner*/

    /* Start : Bottom Left Corner*/
/*    if (IS_IPHONE5)
    {
        CGContextMoveToPoint(context, 45, 229);
        CGContextAddLineToPoint(context, 45, 269);
        CGContextAddLineToPoint(context, 70, 269);
    }
    else
    {
 */
    CGContextMoveToPoint(context, 25, 229);
    CGContextAddLineToPoint(context, 25, 269);
    CGContextAddLineToPoint(context, 50, 269);
 //   }
    CGContextSetLineWidth(context, 16.0); // this is set from now on until you explicitly change it
    CGContextStrokePath(context); // do actual stroking
    /* End : Bottom Left Corner*/

    /* Start : Bottom Right Corner*/
    CGContextMoveToPoint(context, 296, 229);
    CGContextAddLineToPoint(context, 296, 269);
    CGContextAddLineToPoint(context, 271, 269);
    CGContextSetLineWidth(context, 16.0); // this is set from now on until you explicitly change it
    CGContextStrokePath(context); // do actual stroking
    /* End : Bottom Right Corner*/
    
    if (self.isTopEdge)
    {
        /*Complete the top line */
        CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
        if (IS_IPHONE5)
        {
            CGContextMoveToPoint(context, 50, 100.0);//start point
            CGContextAddLineToPoint(context, 271, 100.0);
        }
        else
        {
            CGContextMoveToPoint(context, 50, 80.0);//start point
            CGContextAddLineToPoint(context, 271, 80.0);
        }
        CGContextSetLineWidth(context, 16.0); // this is set from now on until you explicitly change it
        CGContextStrokePath(context); // do actual stroking
    }
    else
    {
        /*Disconnect top line  */
        CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);
   /*     if (IS_IPHONE5)
        {
            CGContextMoveToPoint(context, 70, 80);//start point
        }
        else
        {
    */
            CGContextMoveToPoint(context, 50, 80);//start point
       // }
        CGContextAddLineToPoint(context, 271, 80.0);
        CGContextSetLineWidth(context, 16.0); // this is set from now on until you explicitly change it
        CGContextStrokePath(context); // do actual stroking
    }
    
    if (self.isBottomEdge)
    {
        /*Complete the bottom line */
        CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    /*    if (IS_IPHONE5)
        {
            CGContextMoveToPoint(context, 70, 269);//start point
        }
        else
        {*/
            CGContextMoveToPoint(context, 50, 269);//start point
    //    }
        CGContextAddLineToPoint(context, 271, 269);
        CGContextSetLineWidth(context, 16.0); // this is set from now on until you explicitly change it
        CGContextStrokePath(context); // do actual stroking
    }
    else
    {
        /*Disconnect bottom line  */
        CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);
    /*    if (IS_IPHONE5)
        {
            CGContextMoveToPoint(context, 70, 269);//start point
        }
        else
        {*/
            CGContextMoveToPoint(context, 50, 269);//start point
   //     }
        CGContextAddLineToPoint(context, 271, 269);
        CGContextSetLineWidth(context, 16.0); // this is set from now on until you explicitly change it
        CGContextStrokePath(context); // do actual stroking
    }
    
    if (self.isLeftEdge)
    {
        /*Complete the left line */
        CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
        if (IS_IPHONE5)
        {
            CGContextMoveToPoint(context, 25, 140);//start point
        }
        else
        {
          CGContextMoveToPoint(context, 25, 120);//start point
        }
        CGContextAddLineToPoint(context, 25, 229);
        CGContextSetLineWidth(context, 16.0); // this is set from now on until you explicitly change it
        CGContextStrokePath(context); // do actual stroking
    }
    else
    {
        /*Disconnect left line  */
        CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);
        if (IS_IPHONE5)
        {
            CGContextMoveToPoint(context, 25, 140);//start point
        }
        else
        {
          CGContextMoveToPoint(context, 25, 120);//start point
        }
        CGContextAddLineToPoint(context, 25, 229);
        CGContextSetLineWidth(context, 16.0); // this is set from now on until you explicitly change it
        CGContextStrokePath(context); // do actual stroking
    }
    
    if (self.isRightEdge)
    {
        /*Complete the right line */
        CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
        if (IS_IPHONE5)
        {
            CGContextMoveToPoint(context, 296, 140);//start point
        }
        else
        {
            CGContextMoveToPoint(context, 296, 120);//start point
        }
        CGContextAddLineToPoint(context, 296, 229);
        CGContextSetLineWidth(context, 16.0); // this is set from now on until you explicitly change it
        CGContextStrokePath(context); // do actual stroking
    }
    else
    {
        /*Disconnect right line  */
        CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);
        if (IS_IPHONE5)
        {
            CGContextMoveToPoint(context, 296, 140);//start point
        }
        else
        {
            CGContextMoveToPoint(context, 296, 120);//start point
        }
        CGContextAddLineToPoint(context, 296, 229);
        CGContextSetLineWidth(context, 16.0); // this is set from now on until you explicitly change it
        CGContextStrokePath(context); // do actual stroking
    }
}

- (void)drawAgain
{
    [self setNeedsDisplay];
}
@end
