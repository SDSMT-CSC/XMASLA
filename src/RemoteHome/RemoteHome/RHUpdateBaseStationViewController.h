//
//  RHUpdateBaseStationViewController.h
//  RemoteHome
//
//  Created by James Wiegand on 1/8/13.
//  Copyright (c) 2013 James Wiegand. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RHBaseStationModel.h"
#import "CMPopTipView.h"

@interface RHUpdateBaseStationViewController : UIViewController
<UITextFieldDelegate>
{
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
    NSMutableArray *dataSource;
}

// Text fields
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UITextField *serialField;
@property (strong, nonatomic) IBOutlet UITextField *addressField;
@property (strong, nonatomic) RHBaseStationModel *selectedModel;


@end
