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
    NSLog(@"HopsManager");
    if(!HopsManager) {
        NSLog(@"init hopsManager");
        HopsManager = [[self allocWithZone:NULL] init];
        hops = [[NSMutableArray alloc] init];
    }
    NSLog(@"HopsManager passed");
    
    return HopsManager;
}

+ (Hop *)getHopAt:(int)pos
{
    NSLog(@"getHopAt:%d",pos);
    if(pos >= [hops count]) {
        return [hops objectAtIndex:0];
    }
    return [hops objectAtIndex:pos];
}

/**
 * Ajoute un nouveau hop retourné par le traceroute.
 */
+ (void)addHop:(Hop *)hop
{
    NSLog(@"addHop");
    [hops addObject:hop];
}

/**
 * Retourne le nombre de hops couramment trouvés
 */
+ (int)hopsCount
{
    NSLog(@"hopsCount:%d",[hops count]);
    return [hops count];
}

/**
 * Réinitialise la liste des hops
 */
+ (void)clear
{
    [hops removeAllObjects];
}

@end
