/**
 * @brief	A singleton class that handles the TCP/IP data transfer.
 * @warning This is a singleton. Do not create objects from this class.
 *          use the shared manager public method.
 * @detail	This class is a singleton class. The class is responsible for all
 *			TCP/IP traffic. The class is initialized in the app delegate.
 *			Once the class is initialized other classes may set the address to send
 *			the data to. This data must be JSON data in NSDictonary form. If the
 *			connection fails the class will pass back the error as an NSString.
 * @author	James A. Wiegand Jr.
 * @date	December 29, 2012
 */

#import <Foundation/Foundation.h>
#define DDNSSERVERADDRESS @"10.0.1.10"

enum RHNetworkMode {
    RHNetworkModeManaged = 0,
    RHNetworkModeUnmanaged = 1
    };

@interface RHNetworkEngine : NSObject
<NSStreamDelegate>
{
    @private
        id target;
        SEL retMethod;
        SEL errMethod;
}

// Used to track who we are talking to
@property (nonatomic, retain)NSString* address;

// Used to track data to send
@property (nonatomic, retain)NSDictionary* payload;

// Used for TCP/IP connection
@property (retain, atomic) NSInputStream *inputStream;
@property (retain, atomic) NSOutputStream *outputStream;

// Timer used for timeout conditions
@property (retain, nonatomic) NSTimer *timeout;
@property (retain, nonatomic) NSTimer *setupTimer;

// Used to determine the network mode
@property (nonatomic) enum RHNetworkMode mode;

// Initialze the shared manager
+ (void)initialize;

// Send the data to an address with a target and return selector
+ (void)sendJSON:(NSDictionary*)payload toAddressWithTarget:(id)targ withRetSelector:(SEL)rSel andErrSelector:(SEL)eSel withMode:(enum RHNetworkMode)mode;

// Used to access the singleton object
+ (RHNetworkEngine*)sharedManager;

// Used to stop connections
+ (void)halt;

@end
