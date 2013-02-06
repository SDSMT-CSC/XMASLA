/**
 * @brief	A class that wraps the base stations.
 * @detail	This class holds the information for a base station.
 * @author	James A. Wiegand Jr.
 * @date	November 29, 2013
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CommonCrypto/CommonCrypto.h>

@interface RHBaseStationModel : NSManagedObject

@property (nonatomic, retain) NSString * commonName;
@property (nonatomic, retain) NSString * hashedPassword;
@property (nonatomic, retain) NSString * ipAddress;
@property (nonatomic, retain) NSString * serialNumber;


- (void)setPasswordWithoutHash:(NSString*)password;

@end
