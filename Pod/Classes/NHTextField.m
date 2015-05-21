//
//  NHTextField.m
//  Pods
//
//  Created by Sergey Minakov on 21.05.15.
//
//

#import "NHTextField.h"

const CGFloat kNHTextFieldDefaultCaretSize = -1;
const CGFloat kNHTextFieldKeyboardHeight = 216;

@interface NHTextField ()<UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UIView *pickerInputViewContainer;

@property (nonatomic, strong) id startEditingNotification;
@end

@implementation NHTextField

- (instancetype)init {
    self = [super init];

    if (self) {
        [self commonInit];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    if (self) {
        [self commonInit];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        [self commonInit];
    }

    return self;
}

- (void)commonInit {
    _nhKeyboardType = NHTextFieldKeyboardTypeDefault;

    _caretRect = CGRectNull;
    _caretSize = CGSizeMake(kNHTextFieldDefaultCaretSize, kNHTextFieldDefaultCaretSize);
    _caretOffset = CGPointZero;

    __weak __typeof(self) weakSelf = self;
    self.startEditingNotification = [[NSNotificationCenter defaultCenter]
                                     addObserverForName:UITextFieldTextDidBeginEditingNotification
                                     object:self
                                     queue:nil
                                     usingBlock:^(NSNotification *note) {
                                         __strong __typeof(weakSelf) strongSelf = weakSelf;

                                         NSLog(@"did start");
    }];
}

- (CGRect)caretRectForPosition:(UITextPosition *)position {
    if (CGRectIsNull(self.caretRect)) {
        CGRect resultCaretRect = [super caretRectForPosition:position];

        if (self.caretSize.width != kNHTextFieldDefaultCaretSize) {
            resultCaretRect.size.width = self.caretSize.width;
        }

        if (self.caretSize.height != kNHTextFieldDefaultCaretSize) {
            resultCaretRect.size.height = self.caretSize.height;
        }

        resultCaretRect.origin.x += self.caretOffset.x;
        resultCaretRect.origin.y += self.caretOffset.y;
        
        return resultCaretRect;
    }
    
    return self.caretRect;
}

- (void)setNhKeyboardType:(NHTextFieldKeyboardType)nhKeyboardType {
    [self willChangeValueForKey:@"nhKeyboardType"];
    _nhKeyboardType = nhKeyboardType;
    [self didChangeValueForKey:@"nhKeyboardType"];

    [self resetKeyboard];
}

- (void)resetKeyboard {
    switch (self.nhKeyboardType) {
        case NHTextFieldKeyboardTypeDefault:
            [self rebuildInputView];
            self.inputView = nil;
            break;
        case NHTextFieldKeyboardTypePicker:
            [self rebuildInputView];
            self.inputView = self.pickerInputViewContainer;
            break;
        case NHTextFieldKeyboardTypeDatePicker:
            [self rebuildInputView];
            self.inputView = self.pickerInputViewContainer;
            break;
        default:
            break;
    }
}

- (void)rebuildInputView {
    [self.pickerInputViewContainer.subviews enumerateObjectsUsingBlock:^(UIView *obj,
                                                                         NSUInteger idx,
                                                                         BOOL *stop) {
        [obj removeFromSuperview];
    }];

    if (self.nhKeyboardType == NHTextFieldKeyboardTypeDefault) {
        return;
    }

    UIView *newInputSubview;

    switch (self.nhKeyboardType) {
        case NHTextFieldKeyboardTypePicker: {
            newInputSubview = [[UIPickerView alloc]
                               initWithFrame:(CGRect) {
                                   .size.height = kNHTextFieldKeyboardHeight
                               }];
//            ((UIPickerView*)newInputSubview).delegate = self;
//            ((UIPickerView*)newInputSubview).dataSource = self;
        } break;
        case NHTextFieldKeyboardTypeDatePicker:
            newInputSubview = [[UIDatePicker alloc]
                               initWithFrame:(CGRect) {
                                   .size.height = kNHTextFieldKeyboardHeight
                               }];
            ((UIDatePicker*)newInputSubview).datePickerMode = self.datePickerMode;
            break;
        default:
            return;
    }

    self.pickerInputViewContainer = newInputSubview;

}

- (void)setDatePickerMode:(UIDatePickerMode)datePickerMode {
    [self willChangeValueForKey:@"datePickerMode"];
    _datePickerMode = datePickerMode;
    [self didChangeValueForKey:@"datePickerMode"];

    if ([self.pickerInputViewContainer isKindOfClass:[UIDatePicker class]]) {
        ((UIDatePicker*)self.pickerInputViewContainer).datePickerMode = datePickerMode;
    }
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self.startEditingNotification];
    self.inputView = nil;
    self.delegate = nil;
    self.nhDelegate = nil;
}

@end
