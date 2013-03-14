//
//  RHBaseStationModel.m
//  RemoteHome
//
//  Created by James Wiegand on 11/29/12.
//  Copyright (c) 2012 James Wiegand. All rights reserved.
//

#import "RHBaseStationModel.h"


@implementation RHBaseStationModel

@synthesize commonName;
@synthesize hashedPassword;
@synthesize ipAddress;
@synthesize serialNumber;

// ONLY USE IF PASSWORD IS HASHED
- (void)setPasswordWithoutHash:(NSString*)password;
{
    hashedPassword = password;
}

// Override setter for hashed password to support SHA 512
- (void)setHashedPassword:(NSString*)p
{
    NSData *data = [p dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char hash[CC_SHA512_DIGEST_LENGTH];
    if ( CC_SHA512([data bytes], [data length], hash) ) {
        NSMutableString *passStr = [[NSMutableString alloc] init];
        
        // Copy the characters into the passStr
        for (int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++) {
            [passStr appendString:[NSString stringWithFormat:@"%x", hash[i]]];
        }
        
        hashedPassword = passStr;
    }
}

@end
