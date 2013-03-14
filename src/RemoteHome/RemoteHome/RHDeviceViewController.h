//
//  RHDeviceViewController.h
//  RemoteHome
//
//  Created by James Wiegand on 1/9/13.
//  Copyright (c) 2013 James Wiegand. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RHNetworkEngine.h"
#import "RHBaseStationModel.h"
#import "CMPopTipView.h"

@interface RHDeviceViewController : UITableViewController
<CMPopTipViewDelegate>

@property (nonatomic,retain) NSMutableArray *dataSource;
@property (nonatomic, retain) RHBaseStationModel *baseStation;
@property (nonatomic, retain) CMPopTipView *popupNotice;

@end
