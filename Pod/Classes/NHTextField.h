//
//  NHTextField.h
//  Pods
//
//  Created by Sergey Minakov on 21.05.15.
//
//

#import <UIKit/UIKit.h>

extern const CGFloat kNHTextFieldDefaultCaretSize;
extern const CGFloat kNHTextFieldKeyboardHeight;

typedef NS_ENUM(NSUInteger, NHTextFieldKeyboardType) {
    NHTextFieldKeyboardTypeDefault,
    NHTextFieldKeyboardTypePicker,
    NHTextFieldKeyboardTypeDatePicker,
};

@class NHTextField;

@protocol NHTextFieldDelegate <NSObject>


@optional
- (void)nhTextField:(NHTextField*)textField
       didSelectRow:(NSInteger)row
        inComponent:(NSInteger)component;

- (NSInteger)numberOfComponentsInNHTextField:(NHTextField *)textField;
- (NSInteger)nhTextField:(NHTextField *)textField numberOfRowsInComponent:(NSInteger)component;
- (UIView*)nhTextField:(NHTextField *)textField viewForRow:(NSInteger)row andComponent:(NSInteger)component;
- (NSString*)nhTextField:(NHTextField *)textField titleForSelectedRow:(NSInteger)row andComponent:(NSInteger)component;


- (void)nhTextField:(NHTextField*)textField didChangeDateTo:(NSDate*)date;
@end

@interface NHTextField : UITextField

@property (nonatomic, weak) id<NHTextFieldDelegate> nhDelegate;

@property (nonatomic, assign) NHTextFieldKeyboardType nhKeyboardType;

@property (nonatomic, readonly, strong) UIView *pickerInputViewContainer;

@property (nonatomic, copy) NSArray* pickerTitlesArray;
@property (nonatomic, assign) NSInteger pickerSelectedComponent;
@property (nonatomic, assign) NSInteger pickerSelectedRow;
@property (nonatomic, strong) UIFont *pickerLabelTextFont;
@property (nonatomic, strong) UIColor *pickerLabelTextColor;

@property (nonatomic, assign) UIDatePickerMode datePickerMode;
@property (nonatomic, assign) NSDateFormatterStyle datePickerDateStyle;
@property (nonatomic, assign) NSDateFormatterStyle datePickerTimeStyle;
@property (nonatomic, strong) NSTimeZone *datePickerTimeZone;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSDate *maxDate;
@property (nonatomic, strong) NSDate *minDate;

@property (nonatomic, assign) CGRect caretRect;
@property (nonatomic, assign) CGSize caretSize;
@property (nonatomic, assign) CGPoint caretOffset;

@end
