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
                                         [strongSelf didStartEditing];
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
            ((UIPickerView*)newInputSubview).delegate = self;
            ((UIPickerView*)newInputSubview).dataSource = self;
            self.pickerSelectedComponent = 0;
            self.pickerSelectedRow = 0;
            [self resetTextUsingPickerTitles];
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

- (void)setPickerTitlesArray:(NSArray *)pickerTextArray {
    [self willChangeValueForKey:@"pickerTitlesArray"];
    _pickerTitlesArray = pickerTextArray;
    [self didChangeValueForKey:@"pickerTitlesArray"];

    if ([self.pickerInputViewContainer isKindOfClass:[UIPickerView class]]) {
        [((UIPickerView*)self.pickerInputViewContainer) reloadAllComponents];
        [self resetTextUsingPickerTitles];
    }
}

- (void)setPickerSelectedComponent:(NSInteger)pickerSelectedComponent {
    if (_pickerSelectedComponent == pickerSelectedComponent) {
        return;
    }

    [self willChangeValueForKey:@"pickerSelectedComponent"];
    _pickerSelectedComponent = pickerSelectedComponent;
    [self didChangeValueForKey:@"pickerSelectedComponent"];

    [self resetTextUsingPickerTitles];
}
- (void)setPickerSelectedRow:(NSInteger)pickerSelectedRow {
    if (_pickerSelectedRow == pickerSelectedRow) {
        return;
    }

    [self willChangeValueForKey:@"pickerSelectedRow"];
    _pickerSelectedRow = pickerSelectedRow;
    [self didChangeValueForKey:@"pickerSelectedRow"];

    [self resetTextUsingPickerTitles];
}

- (void)setNhDelegate:(id<NHTextFieldDelegate>)nhDelegate {
    [self willChangeValueForKey:@"nhDelegate"];
    _nhDelegate = nhDelegate;
    [self didChangeValueForKey:@"nhDelegate"];

    if ([self.pickerInputViewContainer isKindOfClass:[UIPickerView class]]) {
        [((UIPickerView*)self.pickerInputViewContainer) reloadAllComponents];
        [self resetTextUsingPickerTitles];
    }
}

//MARK: text field view helpers
- (void)didStartEditing {
    if ([self.pickerInputViewContainer isKindOfClass:[UIPickerView class]]) {
        [((UIPickerView*)self.pickerInputViewContainer) selectRow:self.pickerSelectedRow
                                                            inComponent:self.pickerSelectedComponent
                                                               animated:NO];
    }
}

- (void)resetTextUsingPickerTitles {
    if (![self hasCustomPicker]) {
        self.text = [self getTextFromPickerTitlesAtIndex:self.pickerSelectedRow];
        return;
    }

    NSString *returnValue = nil;
    __weak __typeof(self) weakSelf = self;
    if ([weakSelf.nhDelegate respondsToSelector:@selector(nhTextField:titleForSelectedRow:andComponent:)]) {
        returnValue = [weakSelf.nhDelegate nhTextField:weakSelf titleForSelectedRow:weakSelf.pickerSelectedRow andComponent:weakSelf.pickerSelectedComponent];
    }

    self.text = returnValue;
}

- (NSString*)getTextFromPickerTitlesAtIndex:(NSInteger)index {
    if (index >= self.pickerTitlesArray.count) {
        return nil;
    }

    id value = self.pickerTitlesArray[index];
    NSString *title;

    if ([value isKindOfClass:[NSString class]]) {
        title = value;
    }
    else if ([value isKindOfClass:[NSNumber class]]) {
        title = [((NSNumber*)value) stringValue];
    }
    else {
        title = @"";
    }

    return title;
}
//MARK: Picker view delegate and data source

- (BOOL)hasCustomPicker {
    return [self.nhDelegate respondsToSelector:@selector(numberOfComponentsInNHTextField:)]
    || [self.nhDelegate respondsToSelector:@selector(nhTextField:numberOfRowsInComponent:)]
    || [self.nhDelegate respondsToSelector:@selector(nhTextField:viewForRow:andComponent:)]
    || [self.nhDelegate respondsToSelector:@selector(nhTextField:titleForSelectedRow:andComponent:)];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {

    if (![self hasCustomPicker]) {
        return 1;
    }

    NSInteger returnValue = 1;
    __weak __typeof(self) weakSelf = self;
    if ([weakSelf.nhDelegate respondsToSelector:@selector(numberOfComponentsInNHTextField:)]) {
        returnValue = [weakSelf.nhDelegate numberOfComponentsInNHTextField:weakSelf];
    }

    return returnValue;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {

    if (![self hasCustomPicker]) {
        return self.pickerTitlesArray.count;
    }

    NSInteger returnValue = 0;
    __weak __typeof(self) weakSelf = self;
    if ([weakSelf.nhDelegate respondsToSelector:@selector(nhTextField:numberOfRowsInComponent:)]) {
        returnValue = [weakSelf.nhDelegate nhTextField:weakSelf numberOfRowsInComponent:component];
    }

    return returnValue;
}

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view {
    if (![self hasCustomPicker]) {
        UILabel *resultView = [[UILabel alloc] init];
        resultView.textAlignment = NSTextAlignmentCenter;
        resultView.font = self.pickerLabelTextFont ?: [UIFont systemFontOfSize:17];
        resultView.textColor = self.pickerLabelTextColor ?: [UIColor blackColor];
        resultView.text = [self getTextFromPickerTitlesAtIndex:row];

        return resultView;
    }

    UIView *returnValue = nil;
    __weak __typeof(self) weakSelf = self;
    if ([weakSelf.nhDelegate respondsToSelector:@selector(nhTextField:viewForRow:andComponent:)]) {
        returnValue = [weakSelf.nhDelegate nhTextField:weakSelf viewForRow:row andComponent:component];
    }

    return returnValue;
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    self.pickerSelectedComponent = component;
    self.pickerSelectedRow = row;

    __weak __typeof(self) weakSelf = self;
    if ([weakSelf.nhDelegate respondsToSelector:@selector(nhTextField:didSelectRow:inComponent:)]) {
        [weakSelf.nhDelegate nhTextField:weakSelf
                            didSelectRow:weakSelf.pickerSelectedRow
                             inComponent:weakSelf.pickerSelectedComponent];
    }

    [self resetTextUsingPickerTitles];

}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self.startEditingNotification];
    self.inputView = nil;
    self.delegate = nil;
    self.nhDelegate = nil;
}

@end
