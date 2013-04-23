/*=====================================================================
 Program: Christmas Lights Animation
 File: StoryboardViewController.h
 Author: Jordan Doell
 Date: 4/25/13
 Description: App for Christmas Lights Animation Project
 Sends commands to server: play, pause, and changes each
 channel's brightness
 ======================================================================*/


#import <UIKit/UIKit.h>
//#import "RHNetworkEngine.h"

@interface StoryboardViewController : UIViewController

// sliders for each channel
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

// labels for songs playing
@property (weak, nonatomic) IBOutlet UILabel *mylabel;
@property (weak, nonatomic) IBOutlet UILabel *songPlaying;

- (IBAction)SongPlayed:(id)sender;

- (IBAction)valueChanged:(id)sender;

- (IBAction)SongPaused:(id)sender;

@end
