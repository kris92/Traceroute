//
//  ViewController.m
//  Traceroute
//
//  Created by Christophe Janot on 06/06/13.
//  Copyright (c) 2013 Christophe Janot. All rights reserved.
//

#import "ViewController.h"
#import "HopCell.h"
#import "BDHost.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [_activityIndicator setColor:[UIColor orangeColor]];
    [_activityIndicator setHidden:FALSE];
    [_activityIndicator setHidesWhenStopped:TRUE];
    
    // On récupère les valeurs par défaut
    prefs = [NSUserDefaults standardUserDefaults];
    NSInteger ttl = [prefs integerForKey:@"MaxTTL"];
    if(ttl == 0) {
        ttl = TRACEROUTE_MAX_TTL;
        [prefs setInteger:ttl forKey:@"MaxTTL"];
    }
    NSInteger timeout = [prefs integerForKey:@"Timeout"];
    if(timeout == 0) {
        timeout = TRACEROUTE_TIMEOUT;
        [prefs setInteger:timeout forKey:@"Timeout"];
    }
    NSInteger port = [prefs integerForKey:@"Port"];
    if(port == 0) {
        port = TRACEROUTE_PORT;
        [prefs setInteger:timeout forKey:@"Port"];
    }
    NSInteger maxAttempts = [prefs integerForKey:@"MaxAttempts"];
    NSLog(@"maxAttempts=%d",maxAttempts);
    if(maxAttempts == 0) {
        maxAttempts = TRACEROUTE_ATTEMPTS;
        [prefs setInteger:timeout forKey:@"MaxAttempts"];
    }
    NSLog(@"maxAttempts=%d",maxAttempts);
    [prefs synchronize];
    
    // On récupère le host utilisé lors de la dernière utilisation
    NSString *lastHost = [prefs stringForKey:@"LastHost"];
    if(lastHost) {
        [_hostTextField setText:lastHost];
    }
    
    traceRoute = [[TraceRoute alloc] initWithMaxTTL:ttl timeout:timeout maxAttempts:maxAttempts port:port];
    NSLog(@"ViewController 1");
    [traceRoute setDelegate:self];
    NSLog(@"ViewController 2");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * Callback sur le bouton d'exécution du traceroute
 */
- (IBAction)traceRoute:(id)sender
{
    NSLog(@"isRunning %d",[traceRoute isRunning]);
    if([traceRoute isRunning]) {
        [traceRoute stopTrace];
    } else {
        NSLog(@"traceRoute %@",traceRoute);
        [_activityIndicator startAnimating];
        NSLog(@"traceRoute to:%@",[_hostTextField text]);
        [prefs setObject:[_hostTextField text] forKey:@"LastHost"];
        
        dispatch_queue_t myQueue = dispatch_queue_create("TraceRoute Queue",NULL);
        
        [NSThread detachNewThreadSelector:@selector(doTraceRoute:) toTarget:traceRoute withObject:[_hostTextField text]];
        /*[[NSThread alloc] initWithTarget:traceRoute
                            selector:@selector(doTraceRoute:)
                              object:[_hostTextField text]];*/
        NSLog(@"traceRoute B");
    }
}

#pragma mark TraceRouteDelegate

- (void)newHop:(Hop *)hop
{
    NSLog(@"newHop");
    [_routeHopsTableView reloadData];
}

- (void)end
{
    [_activityIndicator stopAnimating];
}

#pragma mark -

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"numberOfSectionsInTableView");
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [traceRoute hopsCount]-1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HopCell";
    HopCell *cell = (HopCell *)[self.routeHopsTableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if(cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HopCell" owner:self options:nil];
        for (id currentObject in topLevelObjects) {
            if( [currentObject isKindOfClass:[UITableViewCell class]] ) {
                cell = (HopCell *) currentObject;
                [cell init];
				break;
			}
		}
    }
    
    int hopId = [indexPath indexAtPosition:1];
    NSLog(@"hopId=%d",[indexPath indexAtPosition:1]);
    Hop *hop = [Hop getHopAt:hopId];
    if(hop != nil) {
        NSLog(@"hostAddress=%@",[hop hostAddress]);
        cell.ttlLabel.text = [NSString stringWithFormat:@"%d",[hop ttl]];
        cell.hostAddressLabel.text = hop.hostAddress;
        cell.hostnameLabel.text = hop.hostName;
    }
    
    //Race *race = [Race getRace:rid];
    /*if(race != nil) {
     NSLog(@"raceName=%@ count=%d",race.raceName,[race participantsCount]);
     }*/
    //NSLog(@"IndexPath %@ %d",indexPath,[indexPath indexAtPosition:1]);
    
    /*cell.raceNameLabel.text = race.raceName;
    cell.runnersCountLabel.text = [NSString stringWithFormat:@"%d",[race participantsCount]];
    [cell.raceRatioView setPieRatio:[race raceRatio]];
    [cell setNeedsDisplay];
    [cell setNeedsLayout];*/
    
    return cell;
}

#pragma mark -

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark -

@end
