//
//  StoryboardViewController.m
//  RemoteHome
//
//  Created by Jordan Doell on 3/19/13.
//  Copyright (c) 2013 James Wiegand. All rights reserved.
//

#import "StoryboardViewController.h"

@interface StoryboardViewController ()

@end

@implementation StoryboardViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)songPlayed:(id)sender
{
    UIButton *song = (UIButton *)sender;
    NSString *songName = song.currentTitle;
    
    // call sendJSon with the songname and however it should be formatted
}

- (IBAction)valueChanged:(id)sender
{
    //self.channel1.value;
    int newValues[] = {self.channel1.value, self.channel2.value, self.channel3.value, self.channel4.value, self.channel5.value, self.channel6.value, self.channel7.value, self.channel8.value, self.channel9.value, self.channel10.value, self.channel11.value, self.channel12.value, self.channel13.value, self.channel14.value, self.channel15.value, self.channel16.value };
    
    // call sendJSon with array and however it should be formatted
    
    
    
}
@end
