/*=====================================================================
 Program: Christmas Lights Animation
 File: StoryboardViewController.m
 Author: Jordan Doell
 Date: 4/25/13
 Description: App for Christmas Lights Animation Project
 Sends commands to server: play, pause, and changes each
 channel's brightness
 ======================================================================*/


#import "StoryboardViewController.h"

@interface StoryboardViewController ()

@end

@implementation StoryboardViewController

/*=====================================================================
 Function: initWithNibName
 Author: none
 Description:initializations
 Parameters: (NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
 ======================================================================*/
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/*=====================================================================
 Function: viewDidLoad
 Author: none
 Description:runs when view loads
 Parameters: none
 ======================================================================*/
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

}

/*=====================================================================
 Function: didReceiveMemoryWarning
 Author: none
 Description: memory stuff
 Parameters: none
 ======================================================================*/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*=====================================================================
 Function: SongPlayed
 Author: Jordan Doell
 Description: event handler for songs
 Parameters: (id)sender
 ======================================================================*/
- (IBAction)SongPlayed:(id)sender
{
    UIButton *song = (UIButton *)sender; // song button
    NSString *songName = song.currentTitle; // song name
    self.songPlaying.text = songName; // updates now playing text
    
    //build an object and convert to json
    NSDictionary *newDatasetInfo = [NSDictionary dictionaryWithObjectsAndKeys:songName, @"play", nil];
    
    NSURL *myURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://107.22.230.121:5000/player"]];
    NSError *error;
    
    //convert object to data
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:newDatasetInfo options:kNilOptions error:&error];
    
    //build request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    // make request
    [request setURL:myURL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonData];
    
    // print json:
    NSLog(@"JSON summary: %@", [[NSString alloc] initWithData:jsonData
                                                     encoding:NSUTF8StringEncoding]);
    // make connection
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    
    
}

/*=====================================================================
 Function: valueChanged
 Author: Jordan Doell
 Description: event handler for channel value changes
 Parameters: (id)sender
 ======================================================================*/
- (IBAction)valueChanged:(id)sender
{
    // set array values to send off to server
    int newValues[] = { self.channel1.value, self.channel2.value, self.channel3.value, self.channel4.value, self.channel5.value, self.channel6.value, self.channel7.value, self.channel8.value, self.channel9.value, self.channel10.value, self.channel11.value, self.channel12.value, self.channel13.value, self.channel14.value, self.channel15.value, self.channel16.value };

    // make array into nsarray to make easier
    NSArray *myArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:newValues[0]], [NSNumber numberWithFloat:newValues[1]], [NSNumber numberWithFloat:newValues[2]], [NSNumber numberWithFloat:newValues[3]], [NSNumber numberWithFloat:newValues[4]], [NSNumber numberWithFloat:newValues[5]], [NSNumber numberWithFloat:newValues[6]], [NSNumber numberWithFloat:newValues[8]], [NSNumber numberWithFloat:newValues[9]], [NSNumber numberWithFloat:newValues[10]], [NSNumber numberWithFloat:newValues[11]], [NSNumber numberWithFloat:newValues[12]], [NSNumber numberWithFloat:newValues[13]], [NSNumber numberWithFloat:newValues[14]], [NSNumber numberWithFloat:newValues[15]], nil];
    
    //build an object and convert to json
    NSDictionary *newDatasetInfo = [NSDictionary dictionaryWithObjectsAndKeys:myArray, @"vals", nil];
    
    NSURL *myURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://107.22.230.121:5000/channels"]];
    NSError *error;
    //convert object to data
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:newDatasetInfo options:kNilOptions error:&error];

    // make request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:myURL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonData];
    
    // print json:
    NSLog(@"JSON summary: %@", [[NSString alloc] initWithData:jsonData
                                                     encoding:NSUTF8StringEncoding]);
    
    // start connection
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    
}

/*=====================================================================
 Function: SongPaused
 Author: Jordan Doell
 Description: event handler for pausing a song
 Parameters:(id)sender
 ======================================================================*/
- (IBAction)SongPaused:(id)sender
{
    NSString *songName = self.songPlaying.text; // gets current song thats playing
    
    //build an  object and convert to json
    NSDictionary *newDatasetInfo = [NSDictionary dictionaryWithObjectsAndKeys:songName, @"pause", nil];
    
    NSURL *myURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://107.22.230.121:5000/player"]];
    NSError *error;
    //convert object to data
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:newDatasetInfo options:kNilOptions error:&error];
    
    // make request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:myURL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonData];
    
    // print json:
    NSLog(@"JSON summary: %@", [[NSString alloc] initWithData:jsonData
                                                     encoding:NSUTF8StringEncoding]);
    
    // start connection
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
}
@end
