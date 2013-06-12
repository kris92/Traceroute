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
    
    [_hostTextField becomeFirstResponder];
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        hopCellNibName = @"HopCellIPad";
    } else {
        hopCellNibName = @"HopCellIPhone";
    }
    
    [_activityIndicator setColor:[UIColor blueColor]];
    [_activityIndicator setHidden:FALSE];
    [_activityIndicator setHidesWhenStopped:TRUE];
    
    // On spécifie les valeurs par défaut
    NSInteger ttl = TRACEROUTE_MAX_TTL;
    NSInteger timeout = TRACEROUTE_TIMEOUT;
    NSInteger port = TRACEROUTE_PORT;
    NSInteger maxAttempts = TRACEROUTE_ATTEMPTS;
    
    // On récupère le host utilisé lors de la dernière utilisation.
    prefs = [NSUserDefaults standardUserDefaults];
    NSString *lastHost = [prefs stringForKey:@"LastHost"];
    if(lastHost) {
        [_hostTextField setText:lastHost];
    }
    
    traceRoute = [[TraceRoute alloc] initWithMaxTTL:ttl timeout:timeout maxAttempts:maxAttempts port:port];
    NSLog(@"ViewController 1");
    [traceRoute setDelegate:self];
    NSLog(@"ViewController %@",hopCellNibName);
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
    [_hostTextField resignFirstResponder];
    if([traceRoute isRunning]) {
        [traceRoute stopTrace];
    } else {
        [_activityIndicator startAnimating];
        // On stocke le host recherché pour faciliter les recherches ultérieures.
        [prefs setObject:[_hostTextField text] forKey:@"LastHost"];
        [prefs synchronize];
        
        //dispatch_queue_t myQueue = dispatch_queue_create("TraceRoute Queue",NULL);
        
        [NSThread detachNewThreadSelector:@selector(doTraceRoute:) toTarget:traceRoute withObject:[_hostTextField text]];
        
        // On modifie le libellé du bouton.
        [_execButton setTitle:@"Stop" forState:UIControlStateNormal];
        
        NSLog(@"traceRoute B");
    }
}

#pragma mark TraceRouteDelegate

- (void)newHop:(Hop *)hop
{
    [_routeHopsTableView reloadData];
}

- (void)end
{
    // On rétablie le libellé du bouton.
    [_execButton setTitle:@"Start" forState:UIControlStateNormal];
    [_activityIndicator stopAnimating];
    //[_routeHopsTableView reloadData];
}

- (void)error:(NSString *)errorDesc
{
    NSLog(@"ERROR %@",errorDesc);
    // Par défaut on se contente de réinitialiser l'état de l'UI.
    [self end];
}

#pragma mark -

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Count=%d",[TraceRoute hopsCount]);
    return [TraceRoute hopsCount];
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
    
    HopCell *cell = (HopCell *)[_routeHopsTableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if(cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:hopCellNibName owner:self options:nil];
        for (id currentObject in topLevelObjects) {
            if( [currentObject isKindOfClass:[UITableViewCell class]] ) {
                NSLog(@"1 cellForRowAtIndexPath %d",[indexPath indexAtPosition:1]);
                cell = (HopCell *) currentObject;
				break;
			}
		}
    }
    
    int hopId = [indexPath indexAtPosition:1];
    NSLog(@"2 cellForRowAtIndexPath %d",hopId);
    Hop *hop = [Hop getHopAt:hopId];
    if(hop != nil) {
        cell.ttlLabel.text = [NSString stringWithFormat:@"%d",[hop ttl]];
        cell.hostAddressLabel.text = hop.hostAddress;
        cell.hostnameLabel.text = hop.hostName;
        [cell setNeedsDisplay];
    }
    
    return cell;
}

#pragma mark -

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
