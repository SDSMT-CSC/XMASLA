//
//  RHFirstTimeViewController.h
//  RemoteHome
//
//  Created by James Wiegand on 11/25/12.
//  Copyright (c) 2012 James Wiegand. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CMPopTipView.h"

@interface RHAddBaseStationViewController : UIViewController
<NSStreamDelegate, UITextFieldDelegate>
{
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
}

@property (strong, nonatomic) IBOutlet UITextField *serialNumberField;
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;

// Used for TCP/IP connection
@property (retain, atomic) NSInputStream *inputStream;
@property (retain, atomic) NSOutputStream *outputStream;

// Timer used for timeout conditions
@property (retain, nonatomic) NSTimer *timeout;
@property (retain, nonatomic) NSTimer *setupTimer;

// Shows the connection status, prevents users from pressing register again
@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;

@end
