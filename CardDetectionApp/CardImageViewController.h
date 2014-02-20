//
//  CardImageViewController.h
//  CardDetectionApp
//
//  Created by Bharath G M on 11/10/13.
//  Copyright (c) 2014 Bharath G M. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardImageViewController : UIViewController
{
    IBOutlet UILabel*          cardType;
}
@property(nonatomic, retain) UIImage*         cardImage;
@property(nonatomic, retain) NSString*        cardName;

@end
