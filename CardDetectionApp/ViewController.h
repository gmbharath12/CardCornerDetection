//
//  ViewController.h
//  CardDetectionApp
//
//  Created by Bharath G M on 11/10/13.
//  Copyright (c) 2014 Bharath G M. All rights reserved.
//
#include "opencv2/core/core.hpp"
#include "opencv2/features2d/features2d.hpp"
#include "opencv2/nonfree/features2d.hpp"
#include "opencv2/calib3d/calib3d.hpp"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    IBOutlet UILabel*    cardInfoLabel;
    UIImage*                  croppedImage;
    CIContext*               context;
    dispatch_queue_t    videoDataQueue;
    bool                          isTopLine;
    bool                          isBottomLine;
    bool                          isLeftLine;
    bool                          isRightLine;
    int                            noOfCardFrame;
    bool                         isLogoDetecting;
}

@property ( nonatomic, strong) IBOutlet UIImageView* imageView;
@property (nonatomic, strong) IBOutlet UIImageView* resizedImageView;
@property (nonatomic, strong) AVCaptureSession* captureSession;

@end
