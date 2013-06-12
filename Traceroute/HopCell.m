//
//  HopCell.m
//  Traceroute
//
//  Created by Christophe Janot on 06/06/13.
//  Copyright (c) 2013 Christophe Janot. All rights reserved.
//

#import "HopCell.h"

@implementation HopCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect {
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    if(!CGContextIsPathEmpty(currentContext)) {
        CGContextClip(currentContext);
    }
    
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat redComponents[8] = {    1.0, 0.0, 0.0, 1.0,     // Start color
                                    0.85, 0.0, 0.0, 1.0 };  // End color
    CGFloat greenComponents[8] = {  0.0, 1.0, 0.0, 1.0,     // Start color
                                    0.0, 0.85, 0.0, 1.0 };  // End color
    
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    if([_hostnameLabel.text isEqualToString:@"*"]) {
        glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, redComponents, locations, num_locations);
    } else {
        glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, greenComponents, locations, num_locations);
    }
    
    CGRect currentBounds = self.bounds;
    CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
    CGPoint midCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMaxY(currentBounds));
    CGContextDrawLinearGradient(currentContext, glossGradient, topCenter, midCenter, 0);
    
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace);
}

@end
