//
//  RHAppDelegate.h
//  RemoteHome
//
//  Created by James Wiegand on 11/25/12.
//  Copyright (c) 2012 James Wiegand. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RHAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)loadNavRootViewController;

@end
