//
//  Hop.m
//  Traceroute
//
//  Created by Christophe Janot on 06/06/13.
//  Copyright (c) 2013 Christophe Janot. All rights reserved.
//

#import "Hop.h"

@implementation Hop

static Hop *HopsManager;
static NSMutableArray *hops;

@synthesize hostAddress = _hostAddress;
@synthesize hostName = _hostName;
@synthesize ttl = _ttl;

- (Hop *)initWithHostAddress:(NSString *)hostAddress hostName:(NSString *)hostName ttl:(int)ttl
{
    _hostAddress = hostAddress;
    _hostName = hostName;
    _ttl = ttl;
    
    return self;
}

+ (Hop *)HopsManager
{
    if(!HopsManager) {
        NSLog(@"init hopsManager");
        HopsManager = [[self allocWithZone:NULL] init];
        hops = [[NSMutableArray alloc] init];
    }
    
    return HopsManager;
}

/**
 * Ajoute un nouveau hop retourné par le traceroute.
 */
+ (void)addHop:(Hop *)hop
{
    [hops addObject:hop];
}

/**
 * Retourne le nombre de hops couramment trouvés
 */
+ (int)hopsCount
{
    return [hops count];
}

@end
