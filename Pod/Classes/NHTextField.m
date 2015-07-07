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

@property (nonatomic, strong) NSDateFormatter *pickerDateFormatter;
@end

@implementation NHTextField
//
//- (instancetype)init {
//    self = [super init];
//
//    if (self) {
//        [self commonInit];
//    }
//
//    return self;
//}

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
    
    _pickerDateFormatter = [[NSDateFormatter alloc] init];
    _pickerDateFormatter.timeZone = self.datePickerTimeZone ?: [NSTimeZone timeZoneForSecondsFromGMT:0];
    _pickerDateFormatter.dateStyle = self.datePickerDateStyle;
    _pickerDateFormatter.timeStyle = self.datePickerTimeStyle;
    
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

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return self.canPerform
    && [super canPerformAction:action withSender:sender];
}


- (void)rebuildInputView {
    
    if ([self.pickerInputViewContainer isKindOfClass:[UIDatePicker class]]) {
        //        [((UIDatePicker*)self.pickerInputViewContainer) removeObserver:self
        //                                                            forKeyPath:@"date"];
        [((UIDatePicker*)self.pickerInputViewContainer) removeTarget:self
                                                              action:@selector(dateChanged:)
                                                    forControlEvents:UIControlEventValueChanged];
    }
    [self.pickerInputViewContainer.subviews enumerateObjectsUsingBlock:^(UIView *obj,
                                                                         NSUInteger idx,
                                                                         BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    self.pickerInputViewContainer = nil;
    
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
            ((UIDatePicker*)newInputSubview).date = self.selectedDate ?: [NSDate date];
            ((UIDatePicker*)newInputSubview).minimumDate = self.minDate;
            ((UIDatePicker*)newInputSubview).maximumDate = self.maxDate;
            [((UIDatePicker*)newInputSubview) addTarget:self
                                                 action:@selector(dateChanged:)
                                       forControlEvents:UIControlEventValueChanged];
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
    
    if ([self.pickerInputViewContainer isKindOfClass:[UIPickerView class]]) {
        [self resetTextUsingPickerTitles];
    }
}
- (void)setPickerSelectedRow:(NSInteger)pickerSelectedRow {
    if (_pickerSelectedRow == pickerSelectedRow) {
        return;
    }
    
    [self willChangeValueForKey:@"pickerSelectedRow"];
    _pickerSelectedRow = pickerSelectedRow;
    [self didChangeValueForKey:@"pickerSelectedRow"];
    
    if ([self.pickerInputViewContainer isKindOfClass:[UIPickerView class]]) {
        [self resetTextUsingPickerTitles];
    }
}

- (void)setSelectedDate:(NSDate *)selectedDate {
    if ([_selectedDate isEqualToDate:selectedDate]) {
        return;
    }
    
    [self willChangeValueForKey:@"selectedDate"];
    _selectedDate = selectedDate;
    [self didChangeValueForKey:@"selectedDate"];
    
    if ([self.pickerInputViewContainer isKindOfClass:[UIDatePicker class]]) {
        [self resetTextUsingSelectedDate];
    }
}

- (void)setDatePickerDateStyle:(NSDateFormatterStyle)datePickerDateStyle {
    [self willChangeValueForKey:@"datePickerDateStyle"];
    _datePickerDateStyle = datePickerDateStyle;
    [self didChangeValueForKey:@"datePickerDateStyle"];
    
    self.pickerDateFormatter.dateStyle = datePickerDateStyle;
    
    if ([self.pickerInputViewContainer isKindOfClass:[UIDatePicker class]]) {
        [self resetTextUsingSelectedDate];
    }
}

- (void)setDatePickerTimeStyle:(NSDateFormatterStyle)datePickerTimeStyle {
    [self willChangeValueForKey:@"datePickerTimeStyle"];
    _datePickerTimeStyle = datePickerTimeStyle;
    [self didChangeValueForKey:@"datePickerTimeStyle"];
    
    self.pickerDateFormatter.timeStyle = datePickerTimeStyle;
    
    if ([self.pickerInputViewContainer isKindOfClass:[UIDatePicker class]]) {
        [self resetTextUsingSelectedDate];
    }
}

- (void)setMinDate:(NSDate *)minDate {
    [self willChangeValueForKey:@"minDate"];
    _minDate = minDate;
    [self didChangeValueForKey:@"minDate"];
    
    if ([self.pickerInputViewContainer isKindOfClass:[UIDatePicker class]]) {
        ((UIDatePicker*)self.pickerInputViewContainer).minimumDate = minDate;
    }
}

- (void)setMaxDate:(NSDate *)maxDate {
    [self willChangeValueForKey:@"maxDate"];
    _maxDate = maxDate;
    [self didChangeValueForKey:@"maxDate"];
    
    if ([self.pickerInputViewContainer isKindOfClass:[UIDatePicker class]]) {
        ((UIDatePicker*)self.pickerInputViewContainer).maximumDate = maxDate;
    }
}

- (void)setDatePickerTimeZone:(NSTimeZone *)datePickerTimeZone {
    [self willChangeValueForKey:@"datePickerTimeZone"];
    _datePickerTimeZone = datePickerTimeZone;
    [self didChangeValueForKey:@"datePickerTimeZone"];
    
    self.pickerDateFormatter.timeZone = datePickerTimeZone ?: [NSTimeZone timeZoneForSecondsFromGMT:0];
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
    [self resetText];
}

- (void)resetText {
    [self resetTextAnimated:NO];
}
- (void)resetTextAnimated:(BOOL)animated {
    if ([self.pickerInputViewContainer isKindOfClass:[UIPickerView class]]) {
        [((UIPickerView*)self.pickerInputViewContainer) selectRow:self.pickerSelectedRow
                                                      inComponent:self.pickerSelectedComponent
                                                         animated:animated];
    }
    else if ([self.pickerInputViewContainer isKindOfClass:[UIDatePicker class]]) {
        if (!self.selectedDate) {
            self.selectedDate = [NSDate new];
        }
        [((UIDatePicker*)self.pickerInputViewContainer) setDate:self.selectedDate animated:animated];
    }
}

- (void)resetTextUsingSelectedDate {
    NSString *dateText = [self.pickerDateFormatter stringFromDate:self.selectedDate];
    
    self.text = dateText;
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
    
    if (self.pickerSelectedRow != row
        || self.pickerSelectedComponent != component) {
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
    
}

//MARK: Date picker

- (void)dateChanged:(id)sender {
    if ([self.pickerInputViewContainer isKindOfClass:[UIDatePicker class]]) {
        NSDate *value = ((UIDatePicker*)self.pickerInputViewContainer).date;
        
        self.selectedDate = value;
        
        __weak __typeof(self) weakSelf = self;
        if ([weakSelf.nhDelegate respondsToSelector:@selector(nhTextField:didChangeDateTo:)]) {
            [weakSelf.nhDelegate nhTextField:weakSelf didChangeDateTo:value];
        }
    }
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.startEditingNotification];
    self.inputView = nil;
    self.delegate = nil;
    self.nhDelegate = nil;
}

@end
