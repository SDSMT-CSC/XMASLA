//
//  RHBaseStationTableViewController.h
//  RemoteHome
//
//  Created by James Wiegand on 1/3/13.
//  Copyright (c) 2013 James Wiegand. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CMPopTipView.h"

@interface RHBaseStationTableViewController : UITableViewController
<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate,
CMPopTipViewDelegate>
{
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
    NSMutableArray *dataSource;
}

@property (nonatomic) int selectedIndex;
@property (nonatomic, retain) CMPopTipView *popupNotice;

@end
