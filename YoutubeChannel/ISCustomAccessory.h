//
//  ISCustomAccessory.h
//  CustomAccessory
//
//  Created by Istvan Szabo on 2013.01.05..
//  Copyright (c) 2013 Istvan Szabo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ISCustomAccessory : UIControl
{
	UIColor *_accessoryColor;
	UIColor *_highlightedColor;
}

@property (nonatomic, strong) UIColor *accessoryColor;
@property (nonatomic, strong) UIColor *highlightedColor;

+ (ISCustomAccessory *)accessoryWithColor:(UIColor *)color;

@end