//
//  RHFirstTimeInstructionViewController.m
//  RemoteHome
//
//  Created by James Wiegand on 11/25/12.
//  Copyright (c) 2012 James Wiegand. All rights reserved.
//

#import "RHFirstTimeInstructionViewController.h"
#import "RHAppDelegate.h"
#import "RHAddBaseStationViewController.h"

@interface RHFirstTimeInstructionViewController ()

@end

@implementation RHFirstTimeInstructionViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark BUTTONS
- (IBAction)userDidClickContinueButton:(id)sender {
    // Swap the view controllers
    RHAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    RHAddBaseStationViewController *reg = [[RHAddBaseStationViewController alloc]
                                              initWithNibName:@"RHAddBaseStationViewController"
                                              bundle:Nil];
    
    [delegate.window setRootViewController:reg];
    
}


@end
