//
//  NViewController.m
//  NHTextField
//
//  Created by Naithar on 05/21/2015.
//  Copyright (c) 2014 Naithar. All rights reserved.
//

#import "NViewController.h"
#import <NHTextField.h>

@interface NViewController ()<NHTextFieldDelegate>
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
    self.textField.pickerSelectedRow = 3;
    self.textField.pickerTitlesArray = @[@"1", @"2", @"3", @"4", @"5"];

    self.textField.nhDelegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)nhTextField:(NHTextField *)textField didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"selection %@ -- %@", @(row), @(component));
}

- (NSInteger)numberOfComponentsInNHTextField:(NHTextField *)textField {
    return 2;
}
- (NSInteger)nhTextField:(NHTextField *)textField numberOfRowsInComponent:(NSInteger)component {
    return 10;
}

- (UIView *)nhTextField:(NHTextField *)textField viewForRow:(NSInteger)row andComponent:(NSInteger)component {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor redColor];
    return view;
}

- (NSString *)nhTextField:(NHTextField *)textField titleForSelectedRow:(NSInteger)row andComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%@ -- %@", @(row), @(component)];
}

@end
