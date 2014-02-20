//
//  CardImageViewController.m
//  CardDetectionApp
//
//  Created by Bharath G M on 11/10/13.
//  Copyright (c) 2014 Bharath G M. All rights reserved.
//
#include "opencv2/core/core.hpp"
#include "opencv2/features2d/features2d.hpp"
#include "opencv2/nonfree/features2d.hpp"
#include "opencv2/calib3d/calib3d.hpp"

#import "UIImageCVMatConverter.h"
#import "CardImageViewController.h"

@interface CardImageViewController ()

@end

@implementation CardImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem* item = [[UIBarButtonItem alloc ] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    self. navigationItem.leftBarButtonItem = item;
    UIImageView* cardImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 150, 295, 205)];
    cardImgView.image = self.cardImage;
    [self.view addSubview:cardImgView];
    cardType.text = self.cardName;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) goBack
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
