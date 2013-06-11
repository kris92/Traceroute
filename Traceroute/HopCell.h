//
//  HopCell.h
//  Traceroute
//
//  Created by Christophe Janot on 06/06/13.
//  Copyright (c) 2013 Christophe Janot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HopCell : UITableViewCell {
    
}
@property (weak, nonatomic) IBOutlet UILabel *ttlLabel;
@property (weak, nonatomic) IBOutlet UILabel *hostnameLabel;
@property (weak, nonatomic) IBOutlet UILabel *hostAddressLabel;

@end
