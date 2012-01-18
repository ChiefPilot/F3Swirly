//
//  ViewController.h
//  F3SwirlyDemo
//
//  Created by Brad Benson on 1/17/12.
//  Copyright (c) 2012 Flight III Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "F3Swirly.h"

@interface ViewController : UIViewController

@property (retain, nonatomic) IBOutlet F3Swirly *valueSwirly;
@property (retain, nonatomic) IBOutlet UISlider *valueSlider;
@property (retain, nonatomic) IBOutlet UILabel *valueLabel;

- (IBAction)didChangeValue:(id)sender;

@end
