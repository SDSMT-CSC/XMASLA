//
//  StoryboardViewController.h
//  RemoteHome
//
//  Created by Jordan Doell on 3/19/13.
//  Copyright (c) 2013 James Wiegand. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "RHNetworkEngine.h"

@interface StoryboardViewController : UIViewController
@property (retain, nonatomic) IBOutlet UISlider *channel1;
@property (retain, nonatomic) IBOutlet UISlider *channel2;
@property (retain, nonatomic) IBOutlet UISlider *channel3;
@property (retain, nonatomic) IBOutlet UISlider *channel4;
@property (retain, nonatomic) IBOutlet UISlider *channel5;
@property (retain, nonatomic) IBOutlet UISlider *channel6;
@property (retain, nonatomic) IBOutlet UISlider *channel7;
@property (retain, nonatomic) IBOutlet UISlider *channel8;

@property (retain, nonatomic) IBOutlet UISlider *channel9;
@property (retain, nonatomic) IBOutlet UISlider *channel10;
@property (retain, nonatomic) IBOutlet UISlider *channel11;
@property (retain, nonatomic) IBOutlet UISlider *channel12;
@property (retain, nonatomic) IBOutlet UISlider *channel13;
@property (retain, nonatomic) IBOutlet UISlider *channel14;
@property (retain, nonatomic) IBOutlet UISlider *channel15;
@property (retain, nonatomic) IBOutlet UISlider *channel16;

@property (weak, nonatomic) IBOutlet UILabel *mylabel;
@property (weak, nonatomic) IBOutlet UILabel *songPlaying;

@property (retain, nonatomic ) NSURL *url;

- (IBAction)SongPlayed:(id)sender;

- (IBAction)valueChanged:(id)sender;

@end
