//
//  ViewController.m
//  F3SwirlyDemo
//
//  Created by Brad Benson on 1/17/12.
//  Copyright (c) 2012 Flight III Systems. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize valueSwirly;
@synthesize valueSlider;
@synthesize valueLabel;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  // Pass it up first
  [super viewDidLoad];
  
  // Initialize the swirly
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    // Phone-specific sizes
    valueSwirly.font            = [UIFont fontWithName:@"Futura-Medium" size:30.0];
    valueSwirly.thickness       = 30.0f;
    valueSwirly.shadowOffset    = CGSizeMake(1,1);
  } 
  else {
    // Tablet-specific sizes
    valueSwirly.font            = [UIFont fontWithName:@"Futura-Medium" size:44.0];
    valueSwirly.thickness       = 50.0f;
    valueSwirly.shadowOffset    = CGSizeMake(2,2);
  }
  valueSwirly.backgroundColor = [UIColor clearColor];
  valueSwirly.textColor       = [UIColor whiteColor];
  valueSwirly.shadowColor     = [UIColor blackColor];
  [valueSwirly addThreshold:-INFINITY
                  withColor:[UIColor redColor] 
                        rpm:-30
                      label:@"Danger"
                   segments:8];
  [valueSwirly addThreshold:-0.45
                  withColor:[UIColor yellowColor] 
                        rpm:-15
                      label:@"Warning"
                   segments:4];                           
  [valueSwirly addThreshold:-0.30
                  withColor:[UIColor blueColor] 
                        rpm:-15
                      label:@"Normal"
                   segments:2];
  [valueSwirly addThreshold:-0.10
                  withColor:[UIColor grayColor]
                        rpm:0
                      label:@"Stopped"];
  [valueSwirly addThreshold:0.10 
                  withColor:[UIColor greenColor] 
                        rpm:15
                      label:@"Normal"
                   segments:2];
  [valueSwirly addThreshold:0.30
                  withColor:[UIColor yellowColor] 
                        rpm:15
                      label:@"Warning"
                   segments:4];
  [valueSwirly addThreshold:0.45
                  withColor:[UIColor redColor] 
                        rpm:30
                      label:@"Danger"
                   segments:8];
  
  // Initialize the value lable by pretending the slider changed
  [self didChangeValue:valueSlider];
  
}


- (void)viewDidUnload
{
  [self setValueSwirly:nil];
  [self setValueSlider:nil];
  [self setValueLabel:nil];
  [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // All orientations are supported.
  return YES;
}


- (void)dealloc 
{
  [valueSwirly release];
  [valueSlider release];
  [valueLabel release];
  [super dealloc];
}


- (IBAction)didChangeValue:(id)sender 
{
  // Update the swirly and label
  valueSwirly.value = valueSlider.value;
  valueLabel.text = [NSString stringWithFormat:@"%0.02f", valueSlider.value];
}


@end
