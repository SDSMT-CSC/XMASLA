//
//  RHBaseStationTableViewController.m
//  RemoteHome
//
//  Created by James Wiegand on 1/3/13.
//  Copyright (c) 2013 James Wiegand. All rights reserved.
//

#import "RHBaseStationTableViewController.h"
#import "RHAppDelegate.h"
#import "RHBaseStationModel.h"
#import "RHAddBaseStationViewController.h"
#import "RHNetworkEngine.h"
#import "RHDeviceModel.h"
#import "RHUpdateBaseStationViewController.h"
#import "RHDeviceViewController.h"


@interface RHBaseStationTableViewController ()

@end

@implementation RHBaseStationTableViewController

@synthesize selectedIndex, popupNotice;


#pragma mark - Lifecycle

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        // Fetch the context and model from the delegate
        RHAppDelegate *delegate = (RHAppDelegate*)[[UIApplication sharedApplication] delegate];
        context = [delegate managedObjectContext];
        model = [delegate managedObjectModel];
        
        [self reloadDataSource];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBaseStation)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    // Set the back button title
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self reloadDataSource];
    [[self tableView] reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [RHNetworkEngine halt];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Get model
    RHBaseStationModel *currModel = [dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = currModel.commonName;
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Only support for delete
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Get the object
        RHBaseStationModel *delModel = [dataSource objectAtIndex:indexPath.row];
        
        // Delete from database
        [context deleteObject:delModel];
        NSError *e;
        [context save:&e];
        
        // Delete the row from the data source
        [dataSource removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Pop up an action sheet
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Edit base station", @"Connect to base station", nil];
    
    // Set the selected index so we can retrieve the correct base station at a later time
    [self setSelectedIndex:indexPath.row];
    
    
    // Deselect
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Show the sheet
    [sheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Connect to base station"]) {
        [self connectToBaseStation];
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Edit base station"]) {
        
        // Fetch the correct model
        RHBaseStationModel *mod = [dataSource objectAtIndex:selectedIndex];
        
        // Create the view controller and push it on the stack
        RHUpdateBaseStationViewController *update = [[RHUpdateBaseStationViewController alloc] initWithNibName:@"RHUpdateBaseStationViewController" bundle:nil];
        
        [update setSelectedModel:mod];
        
        [update setTitle:@"Edit Base Station"];
        
        [self.navigationController pushViewController:update animated:YES];
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
        
        // Build the viewer
        RHDeviceViewController *deviceView = [[RHDeviceViewController alloc] initWithStyle:UITableViewStylePlain];
        [deviceView setDataSource: parsedDevices];
        [deviceView setBaseStation:[dataSource objectAtIndex:selectedIndex]];
        [deviceView setTitle:@"Devices"];
        
        [popupNotice dismissAnimated:YES];
        
        [self.navigationController pushViewController:deviceView animated:YES];
    }
    
    // No success
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The password was rejected. Please check that the password you suppled was correct" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        
        [alert show];
        
        [popupNotice dismissAnimated:YES];
    }
}

- (void)passwordTransactionDidRecieveError:(NSString*)error
{
    if ([error isEqualToString:@"timeout"] || [error isEqualToString:@"NSStreamEventErrorOccurred"]) {
        // Request DDNS update
        
        // Fetch the correct base station model
        RHBaseStationModel *station = [dataSource objectAtIndex:selectedIndex];
        
        // Create JSON data
        NSString *msg = [ NSString stringWithFormat:
                         @"{ \"HRHomeStationsRequest\" : [ { \"StationDID\" : \"%@\" } ] }", [station serialNumber]];
        NSError *e;
        NSDictionary *JSONMsg = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:[msg dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&e];
        
        if(e)
        {
            NSLog(@"Error : %@", e.description);
            return;
        }
        
        // Send the data
        SEL response = @selector(DDNSUpdateRequestDidRecieveResponse:);
        SEL eResponse = @selector(DDNSUpdateRequestDidRecieveError:);
        [[RHNetworkEngine sharedManager] setAddress:DDNSSERVERADDRESS];
        
        [RHNetworkEngine sendJSON:JSONMsg toAddressWithTarget:self withRetSelector:response andErrSelector:eResponse withMode:RHNetworkModeManaged];
    }
    else {
        // Give an error message
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error with the connection. Please try again later." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        
        [error show];
        
        [popupNotice dismissAnimated:YES];
    }
}

- (void)DDNSUpdateRequestDidRecieveResponse:(NSDictionary*)response
{
    // Check the address update
    
    // IP address of the base station
    NSArray *resArr = (NSArray*) [response objectForKey:@"HRHomeStationReply"];
    
    if (resArr != Nil)
    {
        // fetch the correct base station model
        RHBaseStationModel *station = [dataSource objectAtIndex:selectedIndex];
        
        // We only need to worry about the first element
        NSDictionary  *baseSationData = (NSDictionary*) resArr[0];
        
        // Find the address, we have the base station
        
        // Check for bad base station
        id baseStationAddress = [baseSationData objectForKey:@"StationIP"] ;
        if( baseStationAddress == [NSNull null])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please re-register your base station from the base station portal." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            
            [alert show];
        }
        
        // If address is good create a new base station object
        else
        {
            NSString *newAddress = (NSString*)baseStationAddress;
            
            // If the addresses are the same show an error
            if ([newAddress isEqualToString:[station ipAddress]]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please update your base station address from the base station portal and try again" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                
                [alert show];
                
                [popupNotice dismissAnimated:YES];
            }
            
            // If they are different update the address information and retry
            else {
                
                // Update the database with this information
                NSError *e = nil;
                
                NSFetchRequest *req = [[NSFetchRequest alloc] init];
                [req setReturnsObjectsAsFaults:NO];
                NSEntityDescription *desc = [[model entitiesByName] objectForKey:@"RHBaseStationModel"];
                [req setEntity:desc];
                NSPredicate *pred = [NSPredicate predicateWithFormat:@"serialNumber == %@", [station serialNumber]];
                [req setPredicate:pred];
                
                NSManagedObject *staticDataSource = [[context executeFetchRequest:req error:&e] lastObject];
                
                if (staticDataSource) {
                    // delete the object
                    [context deleteObject:staticDataSource];
                    
                    // create a mew object with the same properties
                    RHBaseStationModel *newBaseStation = [NSEntityDescription insertNewObjectForEntityForName:@"RHBaseStationModel" inManagedObjectContext:context];
                    
                    [newBaseStation setCommonName:[station commonName]];
                    [newBaseStation setIpAddress:baseStationAddress];
                    [newBaseStation setSerialNumber:[station serialNumber]];
                    [newBaseStation setPasswordWithoutHash:[station hashedPassword]];
                }
                
                [context save:&e];
                [self reloadDataSource];
                [self connectToBaseStation];
            }
        }
    }
    
}

- (void)DDNSUpdateRequestDidRecieveError:(NSString*)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error communication with the registration server. Please check your connection and try again later" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    
    [alert show];
    
    // Dismiss the popup
    [popupNotice dismissAnimated:YES];
}

#pragma mark - CMPopTipViewDelegate

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    //Terminate network connections
    [RHNetworkEngine halt];
}

#pragma mark - Helper functions

- (void)reloadDataSource
{
    NSError *e = nil;
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setReturnsObjectsAsFaults:NO];
    NSEntityDescription *desc = [[model entitiesByName] objectForKey:@"RHBaseStationModel"];
    [req setEntity:desc];
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"commonName"
                                                               ascending:YES];
    [req setSortDescriptors:@[sortDesc]];
    NSArray *staticDataSource = [context executeFetchRequest:req error:&e];
    
    dataSource = [[NSMutableArray alloc] initWithArray:staticDataSource];
}

- (void)addBaseStation
{
    // Swap view controller
    RHAddBaseStationViewController *add = [[RHAddBaseStationViewController alloc] initWithNibName:@"RHAddBaseStationViewController" bundle:nil];
    
    // Set the title
    [add setTitle:@"Add Base Station"];
    
    // Push the controller
    [[self navigationController] pushViewController:add animated:YES];
}

- (void)connectToBaseStation
{
    // Notify the user of the loading status
    NSIndexPath *path = [NSIndexPath indexPathForItem:selectedIndex inSection:0];
    
    UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:path];
    popupNotice = [[CMPopTipView alloc] initWithMessage:@"Connecting. Tap the screen to stop connecting."];
    [popupNotice setDismissTapAnywhere:YES];
    [popupNotice setDelegate:self];
    [popupNotice presentPointingAtView:cell.contentView inView:self.view animated:YES];
    
    // Get the correct controller
    RHBaseStationModel *selectedStation = [dataSource objectAtIndex:selectedIndex];
    
    // Transmit the password to the base station
    NSDictionary *JSONPasswordTransaction = @{@"HRLoginPassword" : [selectedStation hashedPassword]};
    
    // Set the target
    [[RHNetworkEngine sharedManager] setAddress:[selectedStation ipAddress]];
    
    // Send the request
    [RHNetworkEngine sendJSON:JSONPasswordTransaction toAddressWithTarget:self withRetSelector:@selector(passwordTransactionDidRecieveResponse:) andErrSelector:@selector(passwordTransactionDidRecieveError:) withMode:RHNetworkModeManaged];
}

@end
