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

@end

@interface NHTextField : UITextField

@property (nonatomic, weak) id<NHTextFieldDelegate> nhDelegate;

@property (nonatomic, assign) NHTextFieldKeyboardType nhKeyboardType;

@property (nonatomic, copy) NSArray* pickerTextArray;
@property (nonatomic, assign) UIDatePickerMode datePickerMode;

@property (nonatomic, assign) CGRect caretRect;
@property (nonatomic, assign) CGSize caretSize;
@property (nonatomic, assign) CGPoint caretOffset;

@end
