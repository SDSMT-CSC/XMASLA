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
    /*int newValues[16] = { 0 };
    
    NSArray *myArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:newValues[0]], [NSNumber numberWithFloat:newValues[1]], [NSNumber numberWithFloat:newValues[2]], [NSNumber numberWithFloat:newValues[3]], [NSNumber numberWithFloat:newValues[4]], [NSNumber numberWithFloat:newValues[5]], [NSNumber numberWithFloat:newValues[6]], [NSNumber numberWithFloat:newValues[8]], [NSNumber numberWithFloat:newValues[9]], [NSNumber numberWithFloat:newValues[10]], [NSNumber numberWithFloat:newValues[11]], [NSNumber numberWithFloat:newValues[12]], [NSNumber numberWithFloat:newValues[13]], [NSNumber numberWithFloat:newValues[14]], [NSNumber numberWithFloat:newValues[15]], nil];
    
    //build an info object and convert to json
    NSDictionary *newDatasetInfo = [NSDictionary dictionaryWithObjectsAndKeys:myArray, @"vals", nil];
    
    NSURL *myURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://107.22.230.121:5000/channels"]];
    NSError *error;
    //convert object to data
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:newDatasetInfo options:kNilOptions error:&error];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:myURL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonData];
    
    // print json:
    NSLog(@"JSON summary: %@", [[NSString alloc] initWithData:jsonData
                                                     encoding:NSUTF8StringEncoding]);
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)SongPlayed:(id)sender
{
    UIButton *song = (UIButton *)sender;
    NSString *songName = song.currentTitle;
    self.songPlaying.text = songName;
    
    //build an info object and convert to json
    NSDictionary *newDatasetInfo = [NSDictionary dictionaryWithObjectsAndKeys:songName, @"play", nil];
    
    NSURL *myURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://107.22.230.121:5000/channels"]];
    NSError *error;
    //convert object to data
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:newDatasetInfo options:kNilOptions error:&error];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:myURL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonData];
    
    // print json:
    NSLog(@"JSON summary: %@", [[NSString alloc] initWithData:jsonData
                                                     encoding:NSUTF8StringEncoding]);
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    
    
}

- (IBAction)valueChanged:(id)sender
{
    //self.channel1.value;
    int newValues[] = { self.channel1.value, self.channel2.value, self.channel3.value, self.channel4.value, self.channel5.value, self.channel6.value, self.channel7.value, self.channel8.value, self.channel9.value, self.channel10.value, self.channel11.value, self.channel12.value, self.channel13.value, self.channel14.value, self.channel15.value, self.channel16.value };

    NSArray *myArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:newValues[0]], [NSNumber numberWithFloat:newValues[1]], [NSNumber numberWithFloat:newValues[2]], [NSNumber numberWithFloat:newValues[3]], [NSNumber numberWithFloat:newValues[4]], [NSNumber numberWithFloat:newValues[5]], [NSNumber numberWithFloat:newValues[6]], [NSNumber numberWithFloat:newValues[8]], [NSNumber numberWithFloat:newValues[9]], [NSNumber numberWithFloat:newValues[10]], [NSNumber numberWithFloat:newValues[11]], [NSNumber numberWithFloat:newValues[12]], [NSNumber numberWithFloat:newValues[13]], [NSNumber numberWithFloat:newValues[14]], [NSNumber numberWithFloat:newValues[15]], nil];
    
    //build an info object and convert to json
    NSDictionary *newDatasetInfo = [NSDictionary dictionaryWithObjectsAndKeys:myArray, @"vals", nil];
    
    NSURL *myURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://107.22.230.121:5000/channels"]];
    NSError *error;
    //convert object to data
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:newDatasetInfo options:kNilOptions error:&error];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:myURL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonData];
    
    // print json:
    NSLog(@"JSON summary: %@", [[NSString alloc] initWithData:jsonData
                                                     encoding:NSUTF8StringEncoding]);
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    
}
@end
