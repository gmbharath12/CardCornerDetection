//
//  ViewController.m
//  CardDetectionApp
//
//  Created by Bharath G M on 11/10/13.
//  Copyright (c) 2014 Bharath G M. All rights reserved.
//
#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)

#define HEIGHT 480
#define  WIDTH 320
#define  THRESHOLD 60.0


#import "UIImageCVMatConverter.h"
#import "CardImageViewController.h"
#import "ViewController.h"
#import "RectangleView.h"

@interface ViewController ()
{
    RectangleView* rectangleFocusView;
    cv::Mat                   masterLogoImgDescriptors[10];
    cv::Mat                   visaLogoImgDescriptors[10];
    cv::Mat                   americanExpLogoImgDescriptors[10];

}
- (UIImage *)croppedImageInRect:(CGRect)bounds ofImage:(UIImage*) img;
- (void) edgeDetectionForImage:(UIImage*)img;
-(void) initializeLogoDescriptor;
- (NSString*)cardTypeFromImage:(UIImage*)image;
- (BOOL) isLogoType:(NSString* )logoType inImage:(cv::Mat) sourceImgDescriptors;

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSOperationQueue *lqueue = [[NSOperationQueue alloc] init];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(initializeLogoDescriptor) object:nil];
    [lqueue addOperation:operation];
   // [self initializeLogoDescriptor];
}

- (void)viewDidUnload
{
     [self setImageView:nil];
     [self setResizedImageView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    isTopLine = FALSE;
    isBottomLine = FALSE;
    isLeftLine = FALSE;
    isRightLine = FALSE;
    noOfCardFrame = 0;
    isLogoDetecting = FALSE;
    
    self.captureSession = [[AVCaptureSession alloc] init];
    context = [CIContext contextWithOptions:nil];
    /*If changing  preset other than AVCaptureSessionPreset640x480, make sure you have to change in size of blue rectangular overlay . Reason is the image will get scaled by changing preset. For iPhone 5 preset is AVCaptureSessionPreset1280x720 and rectangular change also made .*/
    if (IS_IPHONE5)
    {
        self.captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
    }
    else
    {
        self.captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    }
    AVCaptureDevice* inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    /*Flash mode on */
    [inputDevice lockForConfiguration:nil];
    if (inputDevice.flashMode == AVCaptureFlashModeOff)
    {
        [inputDevice setFlashMode:AVCaptureFlashModeOn];
    }
 [inputDevice unlockForConfiguration];
    
    NSError* error = nil;
    AVCaptureDeviceInput* captureInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
    if (!error)
    {
        AVCaptureVideoDataOutput* captureOutput = [[AVCaptureVideoDataOutput alloc] init];
        captureOutput.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        
        [captureOutput setAlwaysDiscardsLateVideoFrames:YES];
        videoDataQueue = dispatch_queue_create("VideoDataQueue",DISPATCH_QUEUE_SERIAL);
        [captureOutput setSampleBufferDelegate:self queue:videoDataQueue];
        
        [self.captureSession addInput:captureInput];
        [self.captureSession addOutput:captureOutput];
        [self.captureSession startRunning];
    }
    else
    {
        NSLog(@"Capture Input Error: %@", error.localizedDescription);
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate methods

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    __block  int noOfEdge = 0;
    
    CVPixelBufferRef buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage* ciImage = [CIImage imageWithCVPixelBuffer:buffer];
    CIImage* rotatedImg = [ciImage imageByApplyingTransform:CGAffineTransformMakeRotation(-M_PI/2)];
    dispatch_async(dispatch_get_main_queue(),  ^{
        if (isLogoDetecting)
        {
            return ;
        }
                   
                    CGImageRef cgRef = [context createCGImage:rotatedImg fromRect:rotatedImg.extent];
                      self.imageView.image  =  [UIImage imageWithCGImage:cgRef];
                       CGImageRelease(cgRef);
                       
                       CGSize imgSize = [self.imageView.image size];
 
          // CGFloat height = [[UIScreen mainScreen] bounds].size.height;
            CGRect rect;
                if (IS_IPHONE5)
                    {
                        /*(37,72) , (37+268, 72),(37, 72+205), (37+268, 72+205)  are the outside corner co-ordinates of blue line overlays with respect to screen*/
                        rect = CGRectMake(17*imgSize.width/320, 92*imgSize.height/[[UIScreen mainScreen] bounds].size.height, 288*imgSize.width/320,185*imgSize.height/[[UIScreen mainScreen] bounds].size.height);
                    }
                else
                {
                    /*(17,72) , (17+288, 72),(17, 72+205), (17+288, 72+205)  are the outside corner co-ordinates of blue line overlays with respect to screen*/
                    rect = CGRectMake(17*imgSize.width/320, 72*imgSize.height/[[UIScreen mainScreen] bounds].size.height, 288*imgSize.width/320, 205*imgSize.height/[[UIScreen mainScreen] bounds].size.height);
                }
                    CGSize  newSize =  CGSizeMake(288, 205); 
                      croppedImage = [self croppedImageInRect:rect ofImage:self.imageView.image];
        
                       UIImage*  resizedImage = [self resizedImage:newSize ]; 
                       
                       [self edgeDetectionForImage:resizedImage];
                       
                       if (!rectangleFocusView)
                       {
                           rectangleFocusView = [[RectangleView alloc] initWithFrame:CGRectMake(0,0,320,[[UIScreen mainScreen] bounds].size.height)];
                           [self.imageView addSubview:rectangleFocusView];
                       }
                       
                       rectangleFocusView.isTopEdge = isTopLine;
                       rectangleFocusView.isBottomEdge = isBottomLine;
                       rectangleFocusView.isLeftEdge = isLeftLine;
                       rectangleFocusView.isRightEdge = isRightLine;
                       
                       rectangleFocusView.backgroundColor = [UIColor clearColor];
                       [UIApplication sharedApplication].statusBarHidden = YES;
                       [rectangleFocusView drawAgain];  // redrawing the blue line (overlays) on basis of edge of card found 
                       
                       if(isTopLine)
                           noOfEdge ++;
                       if(isBottomLine)
                           noOfEdge++;
                       if(isLeftLine)
                           noOfEdge ++;
                       if(isRightLine)
                           noOfEdge++;
        
                       if (noOfEdge < 3)
                           cardInfoLabel.text = @"";
                           
                       if((noOfEdge > 3) && (noOfCardFrame > 1))
                       {
                           isLogoDetecting = TRUE;
                           NSDate* date1 = [NSDate date];
                           NSString* cardType =  [self cardTypeFromImage:croppedImage];
                           if ([cardType isEqualToString:@"Other Type Card"])
                           {
                               [self.captureSession stopRunning];
                               CardImageViewController* controller = [[CardImageViewController alloc] initWithNibName:@"CardImageViewController" bundle:nil];
                               controller.cardImage = croppedImage;
                               controller.cardName = cardType;
                               UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:controller];
                               [self presentViewController:navController animated:NO completion:nil];
                           }
                           else
                           {
                               cardInfoLabel.text = [NSString stringWithFormat:@"Sorry, You can not scan %@.", cardType];
                               isLogoDetecting = FALSE;
                           }
                           NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:date1];
                           NSLog(@"time interval is = %f", interval);
                         }
                   });
}

#pragma Boundary Checking

- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage
{
	CGContextRef    refContext = NULL;
	CGColorSpaceRef colorSpace;
	void *          bitmapData;
	int             bitmapByteCount;
	int             bitmapBytesPerRow;
	
	// Get image width, height. 
	size_t pixelsWide = CGImageGetWidth(inImage);
	size_t pixelsHigh = CGImageGetHeight(inImage);
	
	// Declare the number of bytes per row. Each pixel in the bitmap in this
	// example is represented by 4 bytes; 8 bits each of red, green, blue, and
	// alpha.
	bitmapBytesPerRow   = (pixelsWide * 4);
	bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	
	// Use the generic RGB color space.
	colorSpace = CGColorSpaceCreateDeviceRGB();
	if (colorSpace == NULL)
	{
		fprintf(stderr, "Error allocating color space\n");
		return NULL;
	}
	
	// Allocate memory for image data. This is the destination in memory
	// where any drawing to the bitmap context will be rendered.
	bitmapData = malloc( bitmapByteCount );
	if (bitmapData == NULL)
	{
		fprintf (stderr, "Memory not allocated!");
		CGColorSpaceRelease( colorSpace );
		return NULL;
	}
	
	// Create the bitmap context. We want pre-multiplied ARGB, 8-bits
	// per component. Regardless of what the source image format is
	// (CMYK, Grayscale, and so on) it will be converted over to the format
	// specified here by CGBitmapContextCreate.
	refContext = CGBitmapContextCreate (bitmapData,
									 pixelsWide,
									 pixelsHigh,
									 8,                          // bits per component
									 bitmapBytesPerRow,
									 colorSpace,
                                      kCGImageAlphaPremultipliedFirst);
	if (refContext == NULL)
	{
		free (bitmapData);
		fprintf (stderr, "Context not created!");
	}
	// Make sure and release colorspace before returning
	CGColorSpaceRelease( colorSpace );
	
	return refContext;
}

- (void) edgeDetectionForImage:(UIImage*)img
{
    int counter1 = 0, counter2 = 0, counter3 = 0, counter4 = 0 ;
	CGImageRef inImage = img.CGImage;
	// Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
	CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
	if (cgctx == NULL)
    { return ; /* error */ }
	
    size_t w = CGImageGetWidth(inImage);
	size_t h = CGImageGetHeight(inImage);
	CGRect rect = {{0,0},{w,h}};
	
	// Draw the image to the bitmap context. Once we draw, the memory
	// allocated for the context for rendering will then contain the
	// raw image data in the specified color space.
	CGContextDrawImage(cgctx, rect, inImage);
	

 //  CGImageRef bwImage = CGBitmapContextCreateImage(cgctx);      // for checking the ccreated ARGB image
   //self.resizedImageView.image = [UIImage imageWithCGImage:bwImage];
     
    CGPoint point00 = {0,0};        /*Top left corner*/
    CGPoint point01 = {288,0};     /*Top right corner */
    CGPoint point10 = {0,205};      /*Bottom left corner*/
//    CGPoint point11 = {288, 205};  /*Bottom right corner*/
    
    int noOfPoints = 100;
    int lineWidth = 16;
    int widthDiff = (point01.x - point00.x)/noOfPoints;
    int heightDiff = (point10.y - point00.y)/noOfPoints;
    
   	// Now we can get a pointer to the image data associated with the bitmap context.
	unsigned char* data = (unsigned char*)CGBitmapContextGetData (cgctx);
    
	if (data != NULL) {
		//offset locates the pixel in the data from x,y.
		//4 for 4 bytes of data per pixel, w is width of one row of data.
        for (int i = 0; i < noOfPoints; i++)
        {
            //Top  boundary RGB difference calculation
            CGPoint point1 =  {point00.x + (i+1)*widthDiff , 1};
            int offset1 =  4*((w*round(point1.y))+round(point1.x));
       //   int alpha1 =  data[offset1];
            int red1      = data[offset1+1];
            int green1  = data[offset1+2];
            int blue1    = data[offset1+3];
            
            CGPoint point2 =  {point00.x + (i+1)*widthDiff , lineWidth - 1};
            int offset2 = 4*((w*round(point2.y))+round(point2.x));
      //   int alpha2 =  data[offset2];
            int red2       = data[offset2+1];
            int green2   = data[offset2+2];
            int blue2     = data[offset2+3];
            
            float diff12 = sqrt((red1 - red2)*(red1 - red2) + (green1 - green2)*(green1 - green2) + (blue1 - blue2)*(blue1 - blue2));
            //      NSLog(@"\n diff12[%d] difference is: %f",i,diff12);
            if (diff12 > THRESHOLD)
                counter1++;
            
            // Bottom  boundary RGB difference calculation
            CGPoint point3 =  {point10.x + (i+1)*widthDiff , point10.y - lineWidth + 1};
            int offset3 = 4*((w*round(point3.y))+round(point3.x));
 //        int alpha3     = data[offset3];
            int red3        = data[offset3+1];
            int green3    = data[offset3+2];
            int blue3       = data[offset3+3];
            
            CGPoint point4 =  {point10.x + (i+1)*widthDiff , point10.y - 1};
            int offset4 = 4*((w*round(point4.y))+round(point4.x));
    //      int alpha4      =  data[offset4];
            int red4          = data[offset4+1];
            int green4      = data[offset4+2];
            int blue4        = data[offset4+3];
            
            float diff34 = sqrt((red3 - red4)*(red3 - red4) + (green3 - green4)*(green3 - green4) + (blue3 - blue4)*(blue3 - blue4));
            //       NSLog(@"\n diff34[%d] difference is: %f",i,diff34);
            
            if (diff34 > THRESHOLD)
                counter2++;
            
            // Left  boundary RGB difference calculation
            CGPoint point5 =  {1, point00.y + (i+1)*heightDiff};
            int offset5 = 4*((w*round(point5.y))+round(point5.x));
    //     int alpha5    =  data[offset5];
            int red5       = data[offset5+1];
            int green5   = data[offset5+2];
            int blue5      = data[offset5+3];
            
            CGPoint point6 =  {lineWidth - 1,point00.y + (i+1)*heightDiff};
            int offset6 = 4*((w*round(point6.y))+round(point6.x));
        //  int alpha6      =  data[offset6];
            int red6          = data[offset6+1];
            int green6       = data[offset6+2];
            int blue6          = data[offset6+3];
            
            float diff56 = sqrt((red5 - red6)*(red5 - red6) + (green5 - green6)*(green5 - green6) + (blue5 - blue6)*(blue5 - blue6));
            //        NSLog(@"\n diff56[%d] difference is: %f",i,diff56);
            
            if (diff56 > THRESHOLD)
                counter3++;
            
            // Right boundary RGB difference calculation
            CGPoint point7 =  {point01.x - lineWidth + 1,point01.y + (i+1)*heightDiff};
            int offset7 = 4*((w*round(point7.y))+round(point7.x));
    //        int alpha7 =  data[offset7];
            int red7 = data[offset7+1];
            int green7 = data[offset7+2];
            int blue7 = data[offset7+3];
            
            CGPoint point8 =  {point01.x - 1,point01.y + (i+1)*heightDiff};
            int offset8 = 4*((w*round(point8.y))+round(point8.x));
         //   int alpha8 =  data[offset8];
            int red8 = data[offset8+1];
            int green8 = data[offset8+2];
            int blue8 = data[offset8+3];
            
            float diff78 = sqrt((red7 - red8)*(red7 - red8) + (green7 - green8)*(green7 - green8) + (blue7 - blue8)*(blue7 - blue8));
            //        NSLog(@"\n diff78[%d] difference is: %f",i,diff78);
            
            if (diff78 > THRESHOLD)
                counter4++;
        }
	}
    // NSLog(@"\n counter1: %d \n counter2:%d \n counter3:%d \n counter4:%d ",counter1,counter2,counter3,counter4);
    
  /* On basis of counters decide which boundary of card is overlapping with overlays.*/
    if (counter1 > 60)
        isTopLine = TRUE;
    else
        isTopLine =FALSE;
    
    if (counter2 > 60)
        isBottomLine = TRUE;
    else
        isBottomLine =FALSE;
    
    if (counter3 > 60)
        isLeftLine = TRUE;
    else
        isLeftLine =FALSE;
    
    if (counter4 > 60)
        isRightLine = TRUE;
    else
        isRightLine =FALSE;
    
    if (isTopLine && isBottomLine && isLeftLine && isRightLine)
    {
        noOfCardFrame++;
    }
    else
    {
        noOfCardFrame = 0;
    }
    
	CGContextRelease(cgctx);
	if (data)
    {
        free(data);
    }
}

#pragma ResizingImage

- (UIImage *)croppedImageInRect:(CGRect)bounds ofImage:(UIImage*) img
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([img CGImage], bounds);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return image;
}

// Returns a copy of the image that has been scaled to the new size
- (UIImage *)resizedImage:(CGSize)newSize
{
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGImageRef imageRef = croppedImage.CGImage;
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));
    
    // Rotate and/or flip the image if required by its orientation
    CGContextConcatCTM(bitmap, CGAffineTransformIdentity);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, kCGInterpolationHigh);
    
    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    return newImage;
}

#pragma Logo Detection

-(void) initializeLogoDescriptor
{
    /*Descriptor of logos get creadted and saved in array .*/
    // Detect the keypoints using SURF Detector
    int minHessian = 400;
    cv::SurfFeatureDetector detector( minHessian );
    cv::vector<cv::KeyPoint> logoImgKeypoints;
    
    //Calculate descriptors (feature vectors)
    cv::SurfDescriptorExtractor extractor;
   
    for (int i = 0; i < 7; i++)
    {
        NSString* imgName  = [NSString stringWithFormat:@"%@_logo%d.jpg",@"master",i+1];
        UIImage* logoImg = [UIImage imageNamed:imgName];
        cv::Mat logoImgMat = [UIImageCVMatConverter cvMatGrayFromUIImage:logoImg];
        if( !logoImgMat.data )
        {
            NSLog(@"Prob in image loading");
            break;
        }
        detector.detect( logoImgMat, logoImgKeypoints );
        extractor.compute( logoImgMat, logoImgKeypoints, masterLogoImgDescriptors[i] );
  }
    for (int i = 0; i < 7; i++)
    {
        NSString* imgName  = [NSString stringWithFormat:@"%@_logo%d.jpg",@"visa",i+1];
        UIImage* logoImg = [UIImage imageNamed:imgName];
        cv::Mat logoImgMat = [UIImageCVMatConverter cvMatGrayFromUIImage:logoImg];
        if( !logoImgMat.data )
        {
            NSLog(@"Prob in image loading");
            break;
        }
        detector.detect( logoImgMat, logoImgKeypoints );
        extractor.compute( logoImgMat, logoImgKeypoints, visaLogoImgDescriptors[i] );
    }
    for (int i = 0; i < 7; i++)
    {
        NSString* imgName  = [NSString stringWithFormat:@"%@_logo%d.jpg",@"americanexp",i+1];
        UIImage* logoImg = [UIImage imageNamed:imgName];
        cv::Mat logoImgMat = [UIImageCVMatConverter cvMatGrayFromUIImage:logoImg];
        if( !logoImgMat.data )
        {
            NSLog(@"Prob in image loading");
            break;
        }
        detector.detect( logoImgMat, logoImgKeypoints );
        extractor.compute( logoImgMat, logoImgKeypoints, americanExpLogoImgDescriptors[i] );
    }
}


- (NSString*)cardTypeFromImage:(UIImage*)image
{
      CGSize imgSize = [image size];
   /*  Cropping size frame is (5.5*imgSize.width/8, 3*imgSize.height/5, 2.5*imgSize.width/8, 2*imgSize.height/5) .  It is assumed as per observation that  card logo lies in right bottom corner of card.*/
    CGRect rect = CGRectMake(5.5*imgSize.width/8, 3*imgSize.height/5, 2.5*imgSize.width/8, 2*imgSize.height/5);
    UIImage* sourceImg = [self croppedImageInRect:rect ofImage:image];
    cv::Mat sourceImgMat = [UIImageCVMatConverter cvMatGrayFromUIImage:sourceImg];
    
    if (!sourceImgMat.data )
    {
        NSLog(@"Problem in image loading");
        return NO;
    }
    // Detect the keypoints using SURF Detector
    int minHessian = 400;
    cv::SurfFeatureDetector detector( minHessian );
    cv::vector<cv::KeyPoint> logoImgKeypoints;
    cv::vector<cv::KeyPoint> sourceImgKeypoints;
    detector.detect( sourceImgMat, sourceImgKeypoints );
    
    //Calculate descriptors (feature vectors)
    cv::SurfDescriptorExtractor extractor;
    cv::Mat  logoImgDescriptors, sourceImgDescriptors;
    extractor.compute( sourceImgMat, sourceImgKeypoints, sourceImgDescriptors );
    if ([self isLogoType:@"master" inImage:sourceImgDescriptors])
    {
        return @"Master Card";
    }
    else if ([self isLogoType:@"visa" inImage:sourceImgDescriptors])
    {
        return @"Visa Card";
    }
    else if ([self isLogoType:@"americanexp" inImage:sourceImgDescriptors])
    {
        return @"American Express Card";
    }
    else
    {
        return @"Other Type Card";
    }
}

- (BOOL) isLogoType:(NSString* )logoType inImage:(cv::Mat) sourceImgDescriptors
{
    cv::Mat  logoImgDescriptors;
    int matchCount = 0;

    for (int i = 0; (i < 7) && (matchCount < 4); i++)
    {
        if ([logoType isEqualToString:@"master"])
            logoImgDescriptors = masterLogoImgDescriptors[i];
        else if([logoType isEqualToString:@"visa"])
            logoImgDescriptors = visaLogoImgDescriptors[i];
        else
            logoImgDescriptors = americanExpLogoImgDescriptors[i];
               
        // Matching descriptor vectors using FLANN matcher
        cv::FlannBasedMatcher matcher;
        std::vector< cv::DMatch > matches;
        matcher.match( logoImgDescriptors, sourceImgDescriptors, matches );
        
        double maxDistance = 0, minimumDistance = .70;
    //    int minDistCount = 0;
        //Calculation of max and min distances between keypoints
        for( int j = 0; (j < logoImgDescriptors.rows) && (minimumDistance >= .38) ; j++ )
        {
            double dist = matches[j].distance;
            if( dist < minimumDistance ) minimumDistance = dist;
            if( dist > maxDistance ) maxDistance = dist;
            
   /*         if (dist < .38)
            {
                minDistCount++;
            }
    */
        }
   //      NSLog([NSString stringWithFormat:@"MinDistanceCount = %d\n MinDistance = %f",minDistCount,minimumDistance]);
        if (minimumDistance < .38)
        {
            matchCount++;
        }
        /*   //Calculate"good" matches (i.e. whose distance is less than minDistance )
         // Can be used in future
         
         std::vector< cv::DMatch > good_matches;
         double sumDistance = 0;
         for( int i = 0; i < logoImgDescriptors.rows; i++ )
         {
         sumDistance = sumDistance + matches[i].distance;
         if( matches[i].distance < .40 )
         { good_matches.push_back( matches[i]); }
         }
         sumDistance = sumDistance/logoImgDescriptors.rows;
         int count = good_matches.size();
         NSLog([NSString stringWithFormat:@"\ngood matches of image %d  = %d\n average distance = %f",i+1, count, sumDistance]);
         */
       }
 
    if ([logoType isEqualToString:@"master"] && (matchCount >= 4))
    {
        return YES;
    }
    else if ([logoType isEqualToString:@"visa"] && (matchCount >= 3) )
    {
        return YES;
    }
    else if ([logoType isEqualToString:@"americanexp"] && (matchCount >= 3) )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end
