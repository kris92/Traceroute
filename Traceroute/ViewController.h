//
//  ViewController.h
//  Traceroute
//
//  Created by Christophe Janot on 06/06/13.
//  Copyright (c) 2013 Christophe Janot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TraceRoute.h"

@interface ViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,TraceRouteDelegate,UITextFieldDelegate> {
    TraceRoute *traceRoute;
    NSUserDefaults *prefs;
    NSString *hopCellNibName;
}
@property (weak, nonatomic) IBOutlet UIButton *execButton;
@property (weak, nonatomic) IBOutlet UITextField *hostTextField;
@property (weak, nonatomic) IBOutlet UITableView *routeHopsTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)traceRoute:(id)sender;

@end
