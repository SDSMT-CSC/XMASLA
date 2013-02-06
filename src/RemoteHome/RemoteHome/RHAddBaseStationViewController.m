	//
//  RHFirstTimeViewController.m
//  RemoteHome
//
//  Created by James Wiegand on 11/25/12.
//  Copyright (c) 2012 James Wiegand. All rights reserved.
//

#import "RHAddBaseStationViewController.h"
#import "RHBaseStationModel.h"
#import "RHAppDelegate.h"
#import "RHNetworkEngine.h"


@interface RHAddBaseStationViewController ()

@end

@implementation RHAddBaseStationViewController

@synthesize inputStream,outputStream, timeout, setupTimer;


#pragma mark - Lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Fetch the context and model from the delegate
        RHAppDelegate *delegate = (RHAppDelegate*)[[UIApplication sharedApplication] delegate];
        context = [delegate managedObjectContext];
        model = [delegate managedObjectModel];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //set delegate
    [[self serialNumberField] setDelegate:self];
    [[self nameField] setDelegate:self];
    [[self passwordField] setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [RHNetworkEngine halt];
}

#pragma mark - Buttons	

// Create a connection and retrieve the data for that base station object
- (IBAction)userDidPressRegisterButton:(id)sender {
    
    // Check to see if any of the fields are blank
    // If so print an error and return to the UIView
    NSString *serial = [[self serialNumberField] text];
    NSString *name = [[self nameField] text];
    NSString *pass = [[self passwordField] text];
    
    if ([serial isEqualToString:@""]) {
        CMPopTipView *error = [[CMPopTipView alloc] initWithMessage:@"Please enter the serial number in the serial number field."];
        [error setDismissTapAnywhere:YES];
        [error setBackgroundColor:[UIColor redColor]];
        [error presentPointingAtView:[self serialNumberField] inView:self.view animated:YES];
        
        return;
    }
    else if ([name isEqualToString:@""]) {
        CMPopTipView *error = [[CMPopTipView alloc] initWithMessage:@"Please enter a name in the name field."];
        [error setDismissTapAnywhere:YES];
        [error setBackgroundColor:[UIColor redColor]];
        [error presentPointingAtView:[self nameField] inView:self.view animated:YES];
        return;
    }
    else if ([pass isEqualToString:@""]) {
        // Print an error
        CMPopTipView *error = [[CMPopTipView alloc] initWithMessage:@"Please enter the password in the password field."];
        [error setDismissTapAnywhere:YES];
        [error setBackgroundColor:[UIColor redColor]];
        [error presentPointingAtView:[self nameField] inView:self.view animated:YES];
        return;
    }
    
    // Show the status
    [[self loadingView] setHidden:NO];
    [[self statusLabel] setText:@"Connecting..."];
    
    // Create JSON data
    NSString *msg = [ NSString stringWithFormat:
                     @"{ \"HRHomeStationsRequest\" : [ { \"StationDID\" : \"%@\" } ] }",
                     [[self serialNumberField] text] ];
    NSError *e;
    NSDictionary *JSONMsg = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:[msg dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&e];
    
    if(e)
    {
        NSLog(@"Error : %@", e.description);
        return;
    }
    
    // Send the data
    SEL response = @selector(nonErrorResponse:);
    SEL eResponse = @selector(errorResponse:);
    [[RHNetworkEngine sharedManager] setAddress:DDNSSERVERADDRESS];
    
    [RHNetworkEngine sendJSON:JSONMsg toAddressWithTarget:self withRetSelector:response andErrSelector:eResponse withMode:RHNetworkModeManaged];
    
    // Check first responder status
    [[self serialNumberField] resignFirstResponder];
    [[self nameField] resignFirstResponder];
    [[self passwordField] resignFirstResponder];
}

#pragma mark - Data response

- (void)nonErrorResponse:(NSDictionary*)res
{
    // IP address of the base station
    NSArray *resArr = (NSArray*) [res objectForKey:@"HRHomeStationReply"];
    if (resArr != Nil)
    {
        // We only need to worry about the first element
        NSDictionary  *baseSationData = (NSDictionary*) resArr[0];
        
        // Find the address, we have the base station
        
        // Check for bad base station
        id baseStationAddress = [baseSationData objectForKey:@"StationIP"] ;
        if( baseStationAddress == [NSNull null])
        {
            [self noSuchBaseStationInDDNS];
        }
        
        // If address is good create a new base station object
        else
        {
            [self createNewBaseStation:(NSString*)baseStationAddress];
        }
        
    }
    
    // Hide the loading indicator
    [[self loadingView] setHidden:YES];
}

- (void)errorResponse:(NSString*)errString
{
    NSLog(@"Error : %@", errString);
    
    // Hide the loading indicator
    [[self loadingView] setHidden:YES];
    
    // String match to find the correct error.
    UIAlertView *err;
    
    // Handle timeout
    if ([errString isEqualToString:@"timeout"]) {
        err = [[UIAlertView alloc] initWithTitle:@"Error"
                                                      message:@"Could not contact the registration server. Please check your network connection and try again later."
                                                     delegate:Nil
                                            cancelButtonTitle:@"Okay"
                                            otherButtonTitles: nil];
        
    }
    
    // Generic errors
    else {
        err = [[UIAlertView alloc] initWithTitle:@"Error"
                                                      message:@"There was an error with the registration. Please try again later."
                                                     delegate:nil
                                            cancelButtonTitle:@"Okay"
                                            otherButtonTitles: nil];
    }
    
    [err show];
}

#pragma mark - Database Communications

// Create new base station object with ip address
- (void)createNewBaseStation:(NSString *) addr
{
    RHBaseStationModel *newBaseStation = [NSEntityDescription insertNewObjectForEntityForName:@"RHBaseStationModel" inManagedObjectContext:context];
    
    // Get the data from fields
    NSString *serial = [[self serialNumberField] text];
    NSString *name = [[self nameField] text];
    NSString *pass = [[self passwordField] text];
    
    // Set the correct data
    [newBaseStation setSerialNumber:serial];
    [newBaseStation setCommonName:name];
    [newBaseStation setHashedPassword:pass];
    [newBaseStation setIpAddress:addr];
    
    // Place the base station into the SQLLite DB
    NSError *e;
    [context save:&e];
    
    UIAlertView *suc = [[UIAlertView alloc]
                        initWithTitle:@"Success"
                        message:@"The station was successfully registered"
                        delegate:Nil
                        cancelButtonTitle:@"Continue"
                        otherButtonTitles: nil];
    
    [suc show];
    
    // Set the user defaults so that it loads the normal view
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    NSString* firstTimeString = [uDef objectForKey:@"firstTime"];
    
    if(firstTimeString == nil);
    {
        
        [uDef setObject:@"complete" forKey:@"firstTime"];
        
        // Load the root controller
        RHAppDelegate *delegate = (RHAppDelegate*)[[UIApplication sharedApplication] delegate];
        [delegate loadNavRootViewController];
    }
}

// If a the station is not registered
- (void)noSuchBaseStationInDDNS
{
    // Show an error message
    UIAlertView *err = [[UIAlertView alloc]
                        initWithTitle:@"Error"
                        message:@"The station ID was not found. Please check to make sure your station ID was entered correctly and that your station was properly set up."
                        delegate:Nil
                        cancelButtonTitle:@"Okay"
                        otherButtonTitles: nil];
    [err show];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
