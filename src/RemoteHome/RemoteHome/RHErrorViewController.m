//
//  RHErrorViewController.m
//  RemoteHome
//
//  Created by James Wiegand on 1/12/13.
//  Copyright (c) 2013 James Wiegand. All rights reserved.
//

#import "RHErrorViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface RHErrorViewController ()

@end

@implementation RHErrorViewController
@synthesize nameField, serialField, errorField, infoView, desc, device;

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
	// Do any additional setup after loading the view.
    
    // Round the edges of the two views
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:infoView.bounds byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *mask = [[CAShapeLayer alloc] init];
    [mask setFrame:infoView.bounds];
    [mask setPath:path.CGPath];
    [infoView.layer setMask:mask];
    
    [desc.layer setCornerRadius:10.0];
    [desc.layer setMasksToBounds:YES];
    
    [self updateFields];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Helper Functions

- (void)updateFields
{
    [nameField setText:device.deviceName];
    [serialField setText:device.deviceSerial];
    [errorField setText:[NSString stringWithFormat:@"%d", device.errorCode]];
    
    NSString *errorDescString;
    
    switch (device.errorCode) {
        case RHErrorNoError:
            errorDescString = @"The device is functioning properly.";
            break;
        case RHErrorOffline:
            errorDescString = @"The device is offline. Please ensure that the device is turned on and is connected to the base station.";
            break;
        default:
            errorDescString = @"Unknown error code. Please contact customer support.";
            break;
    }
    
    [desc setText:errorDescString];
}

@end