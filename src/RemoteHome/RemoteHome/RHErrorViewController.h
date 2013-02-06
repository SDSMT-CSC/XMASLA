//
//  RHErrorViewController.h
//  RemoteHome
//
//  Created by James Wiegand on 1/12/13.
//  Copyright (c) 2013 James Wiegand. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RHDeviceModel.h"

@interface RHErrorViewController : UIViewController

@property (nonatomic, retain) RHDeviceModel *device;

// Fields
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *serialField;
@property (strong, nonatomic) IBOutlet UITextField *errorField;

// Views
@property (strong, nonatomic) IBOutlet UIView *infoView;
@property (strong, nonatomic) IBOutlet UITextView *desc;


@end
