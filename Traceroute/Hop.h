//
//  Hop.h
//  Traceroute
//
//  Created by Christophe Janot on 06/06/13.
//  Copyright (c) 2013 Christophe Janot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Hop : NSObject {
}

@property NSString *hostAddress;
@property NSString *hostName;
@property int ttl;

- (Hop *)initWithHostAddress:(NSString *)hostAddress hostName:(NSString *)hostName ttl:(int)ttl;
+ (Hop *)HopsManager;
+ (void)addHop:(Hop *)hop;
+ (int)hopsCount;

@end
