//
//  NViewController.m
//  NHTextField
//
//  Created by Naithar on 05/21/2015.
//  Copyright (c) 2014 Naithar. All rights reserved.
//

#import "NViewController.h"
#import <NHTextField.h>

@interface NViewController ()
@property (strong, nonatomic) IBOutlet NHTextField *textField;

@end

@implementation NViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NHTextField alloc] init];
	// Do any additional setup after loading the view, typically from a nib.
    self.textField.caretSize = CGSizeMake(5, kNHTextFieldDefaultCaretSize);
    self.textField.nhKeyboardType = NHTextFieldKeyboardTypePicker;
    self.textField.datePickerMode = UIDatePickerModeDate;
    self.textField.pickerTitlesArray = @[@"1", @"2", @"3", @"4", @"5"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
