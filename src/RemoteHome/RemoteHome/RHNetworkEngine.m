#import "RHNetworkEngine.h"

#define TIMERTIME 1.0              // Timeout time

@implementation RHNetworkEngine

@synthesize address,
inputStream,
outputStream,
setupTimer,
mode,
timeout;

static RHNetworkEngine* sharedManager = nil;

#pragma mark - Public Static Methods


/**
 * @brief	Initializer for the singleton class.
 * @detail  This public method will initialize the singleton class.
 *          if the class was initialized before it will ignore the
 *          initialization.
 * @author	James A. Wiegand Jr.
 * @date	December 29, 2012
 */
+ (void)initialize
{
    // If shared manager exisits, dump it
    if (sharedManager)
    {
        return;
    }
    
    sharedManager = [[RHNetworkEngine alloc] init];
}


/**
 * @brief	Sends JSON data to the target.
 * @warning Make sure to call initialize and set the address before
 *          use of this function.
 * @detail  This is the main function of the RHNetworkEngine. This
 *          method will send the payload to the address. This method
 *          takes a target with two selectors. eSel if the transaciton
 *          is not successful. and rSel if the transactions is. If the
 *          transaction fails a NSString will be returned to the eSel.
 *          If the transaction is successful a NSDictonary will be sent
 *          to the rSel.
 * @author	James A. Wiegand Jr.
 * @date	December 29, 2012
 */
+ (void)sendJSON:(NSDictionary*)payload toAddressWithTarget:(id)targ withRetSelector:(SEL)rSel andErrSelector:(SEL)eSel withMode:(enum RHNetworkMode)mode
{
    // Set the return target and selectors
    [sharedManager setTarget:targ];
    [sharedManager setRetMethod:rSel];
    [sharedManager setErrMethod:eSel];
    [sharedManager setPayload:payload];
    
    // Check for a valid address, if not send the string back to the error selector
    if([[sharedManager address]isEqual:@""])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [targ performSelector:eSel withObject:@"no address"];
#pragma clang diagnostic pop
        return;
    }
    
    // Start the network traffic
    [sharedManager startNetworkTransaction];
}

/**
 * @brief	Static alias for cleanup
 * @detail  This method will close all streams. Used for
 *          when a view is closed and a stream might be
 *          open.
 * @see     cleanUp
 * @author	James A. Wiegand Jr.
 * @date	January 3, 2013
 */
+ (void)halt
{
    [sharedManager cleanUp];
}


/**
 * @brief	Access the sharedManager.
 * @warning Make sure to call initialize and set the address before
 *          use of this function.
 * @detail  Returns a pointer to the sharedManager singleton.
 * @author	James A. Wiegand Jr.
 * @date	December 29, 2012
 */
+ (RHNetworkEngine*)sharedManager
{
    return sharedManager;
}

#pragma mark - Private Mutators

/**
 * @brief	Class constructor.
 * @detail  This public method will initialize the singleton class.
 *          if the class was initialized before it will ignore the
 *          initialization.
 * @author	James A. Wiegand Jr.
 * @date	December 29, 2012
 */
- (id)init
{
    self = [super init];
    if (self) {
        address = @"";
    }

return self;
}


/**
 * @brief	Accessor for retMethod.
 * @detail  This method will return retMethod.
 * @author	James A. Wiegand Jr.
 * @date	December 29, 2012
 */
- (SEL)retMethod
{
    return retMethod;
}


/**
 * @brief	Accessor for errMethod.
 * @detail  This method will return errMethod.
 * @author	James A. Wiegand Jr.
 * @date	December 29, 2012
 */
- (SEL)errMethod
{
    return errMethod;
}


/**
 * @brief	Accessor for target.
 * @detail  This method will return target.
 * @author	James A. Wiegand Jr.
 * @date	December 29, 2012
 */
- (id)target
{
    return target;
}

/**
 * @brief	Mutator for errMethod.
 * @detail  This method will set errMethod to e.
 * @author	James A. Wiegand Jr.
 * @date	December 29, 2012
 */
- (void)setErrMethod:(SEL)e
{
    errMethod = e;
}


/**
 * @brief	Mutator for retMethod.
 * @detail  This method will set retMethod to r.
 * @author	James A. Wiegand Jr.
 * @date	December 29, 2012
 */
- (void)setRetMethod:(SEL)r
{
    retMethod = r;
}

/**
 * @brief	Mutator for target.
 * @detail  This method will set target to t
 * @author	James A. Wiegand Jr.
 * @date	December 29, 2012
 */
- (void)setTarget:(id)t
{
    target = t;
}

#pragma mark - Networking Methods

/**
 * @brief	This method is the starting point for any network transaction.
 * @detail  This method will initialize the streams for the singleton object.
 *          Once the streams are initialized the connections will be placed
 *          on a seperate thread.
 * @author	James A. Wiegand Jr.
 * @date	December 29, 2012
 */
- (void)startNetworkTransaction
{
    // Close any open connections
    [sharedManager cleanUp];
    
    // Connect to the DDNS to get the address (this should be refactored into a class)
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    // Create a connection
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)address, 8128, &readStream, &writeStream);
    
    inputStream = (__bridge NSInputStream*)readStream;
    outputStream = (__bridge NSOutputStream*)writeStream;
    
    [inputStream setDelegate:sharedManager];
    [outputStream setDelegate:sharedManager];
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    // Open the connection and set the timeout
    [inputStream open];
    [outputStream open];
    
    [self startTimeoutTimer];
}

/**
 * @brief	Transmit the payload. 
 * @detail  After the connection is established this method will be called
 *          and will transmit the payload given.
 * @author	James A. Wiegand Jr.
 * @date	December 29, 2012
 */
- (void)sendTCPIPData
{
    // Construct the message
    NSError* e = nil;

    NSData* data = [NSJSONSerialization dataWithJSONObject:self.payload options:0 error:&e];
    
    // If an error occours return it
    if(e)
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [target performSelector:errMethod withObject:[e localizedDescription]];
#pragma clang pop
        
        // Clean up and close connections
        [self cleanUp];
        
        return;
    }
    [outputStream write:[data bytes] maxLength:[data length]];
    
}

/**
 * @brief	Stops the communications.
 * @detail  This method will close the streams and stop all timers.
 * @author	James A. Wiegand Jr.
 * @date	December 29, 2012
 */
- (void)cleanUp
{
    // Check for timers
    if(timeout.isValid)
    {
        [timeout invalidate];
    }
    
    [inputStream close];
    [outputStream close];
}

#pragma mark - Timeout


/**
 * @brief	Starts the timeout.
 * @detail  This method will start the timeout. It will use the time
 *          specified in the TIMERTIME macro at the top of the file.
 *          If the timer fires it will call the timeoutFire method.
 * @see     timeoutFire
 * @author	James A. Wiegand Jr.
 * @date	December 29, 2012
 */
- (void)startTimeoutTimer
{
    timeout = [NSTimer scheduledTimerWithTimeInterval:TIMERTIME
                                               target:self
                                             selector:@selector(timeoutFire)
                                             userInfo:nil
                                              repeats:NO];
}

/**
 * @brief	Stops the timeout.
 * @detail  This method will stop the timer.
 * @author	James A. Wiegand Jr.
 * @date	December 29, 2012
 */
- (void)stopTimer
{
    [timeout invalidate];
}


/**
 * @brief	Called when the timeout timer is fired.
 * @detail  This method will return an error to the errMethod and call
 *          the cleanup.
 * @author	James A. Wiegand Jr.
 * @date	December 29, 2012
 */
- (void)timeoutFire
{
    // Close sockets
    [self cleanUp];
    
    // Send an error back
    [target performSelector:errMethod withObject:@"timeout"];
}

#pragma mark - NSStreamDelegate

/**
 * @brief	Handles stream communication.
 * @detail  Once data is sent to the input stream this method is called.
 *          This method will handle all errors from connections issues.
 *          If no errors arise this method will synchronize the server
 *          and client without any action needed from the UI thread.
 *          If synchronization is successful, any response from the
 *          server will be passed back to the UI thread. This response
 *          will be in the form of a NSDictonary. If there is any error
 *          in the JSON parsing the targets error method will be sent
 *          a message.
 * @author	James A. Wiegand Jr.
 * @date	December 29, 2012
 */
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    // Socket Open
    if(eventCode == NSStreamEventOpenCompleted) {
        // Nothing to see here
    }
    
    // Server disconnected
    else if(eventCode == NSStreamEventEndEncountered) {
        
        // Close the sockets
        [self cleanUp];
        
        // Send server closed socket error
        [target performSelector:errMethod withObject:@"NSStreamEventEndEncountered"];
        
    }
    
    // Error
    else if (eventCode == NSStreamEventErrorOccurred) {
        
        // Close the sockets
        [self cleanUp];
        
        // Send a generic error code.
        [target performSelector:errMethod withObject:@"NSStreamEventErrorOccurred"];
    }
    
    // By: Ray Wenderlich
    // http://www.raywenderlich.com/3932/how-to-create-a-socket-based-iphone-app-and-server
    // If the system said somthing
    else if (eventCode == NSStreamEventHasBytesAvailable) {
        uint8_t buffer[1024];
        int len;
        
        while ([inputStream hasBytesAvailable]) {
            len = [inputStream read:buffer maxLength:sizeof(buffer)];
            if(len > 0) {
                
                
                //Convert the JSON into a dictonary
                NSError *e;
                NSData *inputData = [NSData dataWithBytes:buffer length:len];
                NSDictionary *response = [NSJSONSerialization JSONObjectWithData:inputData
                                                                         options:kNilOptions
                                                                           error:&e];
                
                // If an error occours return it
                if(e)
                {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [target performSelector:errMethod withObject:[e localizedDescription]];
#pragma clan pop
                    
                    // Clean up and close connections
                    [self cleanUp];
                    
                    return;
                } // End if
                
                // If the response is valid check to see if it is
                // a connection response
                NSArray* resArr = (NSArray*) [response objectForKey:@"DDNSConnected"];
                if (resArr != Nil && resArr[0]) {
                    // Invalidate second timer
                    [sharedManager stopTimer];
                    
                    // Connection established send the registration data
                    [sharedManager sendTCPIPData];
                }
                
                // Else return the response (managed mode)
                else
                {
                    if (mode == RHNetworkModeManaged) {
                        [self cleanUp];
                    }
                    
                    [target performSelector:retMethod withObject:response];
                }
                
                
            }
            
        }
    }
}

@end
