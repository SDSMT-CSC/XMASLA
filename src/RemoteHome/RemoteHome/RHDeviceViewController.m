//
//  RHDeviceViewController.m
//  RemoteHome
//
//  Created by James Wiegand on 1/9/13.
//  Copyright (c) 2013 James Wiegand. All rights reserved.
//

#import "RHDeviceViewController.h"
#import "RHDeviceModel.h"
#import "RHErrorViewController.h"

@interface RHDeviceViewController ()

@end

@implementation RHDeviceViewController

@synthesize popupNotice;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshDeviceList)];
    self.navigationItem.rightBarButtonItem = refreshButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self dataSource] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Get the corrisponding object
    RHDeviceModel *currentModel = (RHDeviceModel*)[[self dataSource] objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    [[cell textLabel] setText:[currentModel deviceName]];
    
    if ([currentModel errorCode] == RHErrorNoError) {
        [[cell detailTextLabel] setTextColor:[UIColor greenColor]];
        [[cell detailTextLabel] setText:@"Online"];
    } else {
        [[cell detailTextLabel] setTextColor:[UIColor redColor]];
        [[cell detailTextLabel] setText:@"Offline"];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    // Get the correct device
    RHDeviceModel *currentDevice = (RHDeviceModel*)[[self dataSource] objectAtIndex:indexPath.row];
    
    // If the device is online load the correct view
    if (currentDevice.errorCode == RHErrorNoError) {
        switch (currentDevice.deviceType) {
            case RHSprinklerType:
                [self loadSprinklerView:currentDevice];
                break;
            case RHGarageDoorType:
                [self loadGarageDoorView:currentDevice];
                break;
            case RHLightType:
                [self loadLightView:currentDevice];
                break;
            default:
                break;
        }
    }
    
    // If not load the correct error view
    else {
        RHErrorViewController *errorView = [[RHErrorViewController alloc] init];
        [errorView setDevice:currentDevice];
        
        [errorView setTitle:@"Device Information"];
        
        [self.navigationController pushViewController:errorView animated:YES];
    }
}

#pragma mark - Network transactions

- (void)passwordTransactionDidRecieveResponse:(NSDictionary*)response
{
    // Check for success
    BOOL success = [(NSNumber*)[response objectForKey:@"RHLoginSuccess"] boolValue];
    
    if (success) {
        
        // Get a list of devices
        NSUInteger count = [(NSNumber*)[response objectForKey:@"RHDeviceCount"] integerValue];
        
        NSMutableArray *parsedDevices =[[NSMutableArray alloc] init];
        
        if (count != 0) {
            // Copy the devices into a device array
            NSArray *devices = (NSArray*)[response objectForKey:@"RHDeviceList"];
            
            
            for (NSDictionary *currDict in devices) {
                RHDeviceModel *mod = [[RHDeviceModel alloc] init];
                [mod setDeviceName:(NSString*)[currDict objectForKey:@"DeviceName"]];
                [mod setDeviceSerial:(NSString*)[currDict objectForKey:@"DeviceSerial"]];
                [mod setDeviceType:[(NSNumber*)[currDict objectForKey:@"DeviceType"] integerValue]];
                [mod setErrorCode:[(NSNumber*)[currDict objectForKey:@"ErrorCode"] integerValue]];
                
                [parsedDevices addObject:mod];
            }
        }
        
        // Sort the devices by name
        [parsedDevices sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            RHDeviceModel *firstModel = (RHDeviceModel*)obj1;
            RHDeviceModel *secondModel = (RHDeviceModel*)obj2;
            
            return [firstModel.deviceName caseInsensitiveCompare:secondModel.deviceName];
        }];
        
        // Update the data souce
        self.dataSource = [NSMutableArray arrayWithArray:parsedDevices];
        [[self tableView] reloadData];
    }
    
    // No success
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The password was rejected. Please use the back button to view the base station and provide the correct password." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        
        [alert show];
    }
    
    [popupNotice dismissAnimated:YES];
}

- (void)passwordTransactionDidRecieveError:(NSString*)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was troubble connecting to the base station. Please ensure the base station is turned on." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    
    [popupNotice dismissAnimated:YES];
    
    [alert show];
}

#pragma mark - Refresh Button

- (void)refreshDeviceList
{
    // Notify the user of the loading status
    UIBarButtonItem *refreshItem = self.navigationItem.rightBarButtonItem;
    popupNotice = [[CMPopTipView alloc] initWithMessage:@"Refreshing. Tap the screen to stop connecting."];
    [popupNotice setDismissTapAnywhere:YES];
    [popupNotice setDelegate:self];
    [popupNotice presentPointingAtBarButtonItem:refreshItem animated:YES];
    
    // Transmit the password to the base station
    NSDictionary *JSONPasswordTransaction = @{@"HRLoginPassword" : [self.baseStation hashedPassword]};
    
    // Set the target
    [[RHNetworkEngine sharedManager] setAddress:[self.baseStation ipAddress]];
    
    // Send the request
    [RHNetworkEngine sendJSON:JSONPasswordTransaction toAddressWithTarget:self withRetSelector:@selector(passwordTransactionDidRecieveResponse:) andErrSelector:@selector(passwordTransactionDidRecieveError:) withMode:RHNetworkModeManaged];
}

#pragma mark - CMPopTipViewDelegate

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    //Terminate network connections
    [RHNetworkEngine halt];
}


# pragma mark - Device Views

- (void)loadSprinklerView:(RHDeviceModel*)currentDevice
{
    
}

- (void)loadGarageDoorView:(RHDeviceModel*)currentDevice
{
    
}

-(void)loadLightView:(RHDeviceModel*)currentDevice
{
    
}

@end
