#include "qiosnativetextfield.h"
#include <QQuickWindow>
#include <QDebug>

#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIColor(HexString)
+ (UIColor*) colorWithHexString:(NSString*) hexString;
+ (CGFloat) colorComponentFrom:(NSString*) string start:(NSUInteger) start length:(NSUInteger) length;
+ (NSString*) toHexString:(CGColor*) cgColor;
@end

@implementation UIColor(HexString)
+ (NSString*) toHexString:(CGColor*) cgColor {
  const CGFloat* components = CGColorGetComponents(cgColor);

  CGFloat r = components[0];
  CGFloat g = components[1];
  CGFloat b = components[2];

  return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
      lround(r * 255),
      lround(g * 255),
      lround(b * 255)];
}

+ (UIColor*) colorWithHexString:(NSString*) hexString {
  NSString*colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
  CGFloat alpha, red, blue, green;
  switch ([colorString length]) {
    case 3: // #RGB
      alpha = 1.0;
      red   = [self colorComponentFrom:colorString start:0 length:1];
      green = [self colorComponentFrom:colorString start:1 length:1];
      blue  = [self colorComponentFrom:colorString start:2 length:1];
      break;
    case 4: // #ARGB
      alpha = [self colorComponentFrom:colorString start:0 length:1];
      red   = [self colorComponentFrom:colorString start:1 length:1];
      green = [self colorComponentFrom:colorString start:2 length:1];
      blue  = [self colorComponentFrom:colorString start:3 length:1];
      break;
    case 6: // #RRGGBB
      alpha = 1.0;
      red   = [self colorComponentFrom:colorString start:0 length:2];
      green = [self colorComponentFrom:colorString start:2 length:2];
      blue  = [self colorComponentFrom:colorString start:4 length:2];
      break;
    case 8: // #AARRGGBB
      alpha = [self colorComponentFrom:colorString start:0 length:2];
      red   = [self colorComponentFrom:colorString start:2 length:2];
      green = [self colorComponentFrom:colorString start:4 length:2];
      blue  = [self colorComponentFrom:colorString start:6 length:2];
      break;
    default:
      [NSException raise:@"Invalid color value" format:@"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString];
      break;
    }
  return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (CGFloat) colorComponentFrom:(NSString*) string start:(NSUInteger) start length:(NSUInteger) length {
  NSString* substring = [string substringWithRange:NSMakeRange(start, length)];
  NSString* fullHex = length == 2 ? substring :[NSString stringWithFormat:@"%@%@", substring, substring];
  unsigned hexComponent;
  [[NSScanner scannerWithString:fullHex] scanHexInt:&hexComponent];
  return hexComponent / 255.0;
}
@end

@interface TextFieldDelegate : NSObject<UITextFieldDelegate>
@property (assign, nonatomic) QiOSNativeTextField* qmlTextField;
@property (assign, nonatomic) UITextField* textfield;
- (id) initWithQmlTextField:(QiOSNativeTextField*)qmlTextField;
- (void)textFieldDidChange:(UITextField*)textField;
- (void)keyboardWillShow:(NSNotification*)notification;
- (void)keyboardWillHide:(NSNotification*)notification;
- (void)doneBtnFromKeyboardClicked:(id)sender;
@end

@implementation TextFieldDelegate
@synthesize qmlTextField;
@synthesize textfield;
- (id) initWithQmlTextField:(QiOSNativeTextField*)qmlTextField {
  self = [super init];
  if (self) {
      self.qmlTextField = qmlTextField;
    }
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

  return self;
}

- (id) initWithQmlTextField:(QiOSNativeTextField*)qmlTextField andUITextField:(UITextField*)textField {
  self = [super init];
  if (self) {
      self.qmlTextField = qmlTextField;
      self.textfield = textField;
    }
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
  return self;
}

- (void)textFieldDidBeginEditing:(UITextField*)textField {
  Q_UNUSED(textField)
  emit self.qmlTextField->editingChanged();
}

- (void)textFieldDidEndEditing:(UITextField*)textField {
  Q_UNUSED(textField)
  emit self.qmlTextField->editingChanged();
}

- (void)textFieldDidChange:(UITextField*)textField {
  Q_UNUSED(textField);
  emit self.qmlTextField->textChanged();
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
  emit self.qmlTextField->commited(QString::fromNSString(textField.text));
  [textField resignFirstResponder];
  return YES;
}

- (void)doneBtnFromKeyboardClicked:(id)sender{
  Q_UNUSED(sender)
  [self.textfield endEditing:YES];
}

- (void)keyboardWillShow:(NSNotification*)notification {
  NSValue* keyboardInfo = [[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey];
  CGSize keyboardSize = [keyboardInfo CGRectValue].size;
  NSNumber* durationValue = [[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey];
  NSTimeInterval duration = [durationValue doubleValue];
  if (self.textfield.frame.origin.y + self.textfield.frame.size.height > [UIScreen mainScreen].bounds.size.height - keyboardSize.height) {
      [UIView animateWithDuration:duration animations:^{
        UIView* parentView = reinterpret_cast<UIView*>(self.qmlTextField->window()->winId());
        CGRect f = parentView.frame;
        f.origin.y = -keyboardSize.height;
        parentView.frame = f;
      }];
  }
}

- (void)keyboardWillHide:(NSNotification*)notification {
  NSNumber* durationValue = [[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey];
  NSTimeInterval duration = [durationValue doubleValue];
  [UIView animateWithDuration:duration animations:^{
      UIView* parentView = reinterpret_cast<UIView*>(self.qmlTextField->window()->winId());
      CGRect f = parentView.frame;
      f.origin.y = 0.0;
      parentView.frame = f;
  }];
}
@end

static inline CGRect toCGRect(const QRectF& rect) {
  return CGRectMake(rect.x(), rect.y(), rect.width(), rect.height());
}

QiOSNativeTextField::QiOSNativeTextField(QQuickItem*parent /*= nullptr*/) :QQuickItem(parent) {
  _textfield = [[UITextField alloc] init];
  _delegate = [[TextFieldDelegate alloc] initWithQmlTextField:this andUITextField:_textfield];
  _textfield.delegate = _delegate;
  [_textfield addTarget:_delegate action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

  UIToolbar* accessoryView = [[UIToolbar alloc] init];
  [accessoryView sizeToFit];
  UIBarButtonItem* flexBarButton = [[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
      target:nil action:nil];
  UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
      target:_delegate action:@selector(doneBtnFromKeyboardClicked:)];
  accessoryView.items = @[flexBarButton, doneBarButton];
  [accessoryView setTranslucent:YES];
  _textfield.inputAccessoryView = accessoryView;

  connect(this, &QiOSNativeTextField::windowChanged, this, &QiOSNativeTextField::onWindowChanged);
  connect(this, &QiOSNativeTextField::visibleChanged, this, &QiOSNativeTextField::onVisibleChanged);
  connect(this, &QiOSNativeTextField::enabledChanged, this, &QiOSNativeTextField::onEnabledChanged);
  connect(this, &QiOSNativeTextField::opacityChanged, this, &QiOSNativeTextField::onOpacityChanged);
  connect(this, &QiOSNativeTextField::focusChanged, this, &QiOSNativeTextField::onFocusChanged);
  connect(this, &QiOSNativeTextField::scaleChanged, this, &QiOSNativeTextField::onScaleChanged);
}

QiOSNativeTextField::~QiOSNativeTextField() {
  [_textfield release];
  [_delegate release];
}

void QiOSNativeTextField::onWindowChanged(QQuickWindow*window) {
  if (window != nullptr) {
      UIView* parentView = reinterpret_cast<UIView*>(window->winId());
      [parentView addSubview:_textfield];
    } else {
      [_textfield removeFromSuperview];
    }
}

void QiOSNativeTextField::geometryChanged(const QRectF& newGeometry, const QRectF& oldGeometry) {
  QQuickItem::geometryChanged(newGeometry, oldGeometry);
  CGRect rc = toCGRect(newGeometry.toRect());
  [_textfield setFrame:rc];
}

QString QiOSNativeTextField::placeholder() const {
  return QString::fromNSString(_textfield.placeholder);
}

QiOSNativeTextField::KeyboardType QiOSNativeTextField::keyboardType() const {
  switch (_textfield.keyboardType) {
    case UIKeyboardTypeDefault: return KeyboardTypeDefault;
    case UIKeyboardTypeASCIICapable: return KeyboardTypeASCIICapable;
    case UIKeyboardTypeNumbersAndPunctuation: return KeyboardTypeNumbersAndPunctuation;
    case UIKeyboardTypeURL: return KeyboardTypeURL;
    case UIKeyboardTypeNumberPad: return KeyboardTypeNumberPad;
    case UIKeyboardTypeNamePhonePad: return KeyboardTypeNamePhonePad;
    case UIKeyboardTypePhonePad: return KeyboardTypePhonePad;
    case UIKeyboardTypeEmailAddress: return KeyboardTypeEmailAddress;
    case UIKeyboardTypeDecimalPad: return KeyboardTypeDecimalPad;
    case UIKeyboardTypeTwitter: return KeyboardTypeTwitter;
    case UIKeyboardTypeWebSearch: return KeyboardTypeWebSearch;
    case UIKeyboardTypeASCIICapableNumberPad: return KeyboardTypeASCIICapableNumberPad;
    }
}

QString QiOSNativeTextField::text() const {
  return QString::fromNSString(_textfield.text);
}

QFont QiOSNativeTextField::font() const {
  return _font;
}

QString QiOSNativeTextField::color() const {
  return QString::fromNSString([UIColor toHexString:_textfield.textColor.CGColor]);
}

QiOSNativeTextField::TextAlignment QiOSNativeTextField::horizontalAlignment() const {
  switch (_textfield.textAlignment) {
    case NSTextAlignmentLeft: return AlignLeft;
    case NSTextAlignmentRight: return AlignRight;
    case NSTextAlignmentCenter: return AlignHCenter;
    case NSTextAlignmentJustified: return AlignJustify;
    case NSTextAlignmentNatural: return AlignNatural;
  }
}

QiOSNativeTextField::BorderStyle QiOSNativeTextField::borderStyle() const {
  switch (_textfield.borderStyle) {
    case UITextBorderStyleNone: return BorderStyleNone;
    case UITextBorderStyleBezel: return BorderStyleBezel;
    case UITextBorderStyleLine: return BorderStyleLine;
    case UITextBorderStyleRoundedRect: return BorderStyleRoundedRect;
    }
}

bool QiOSNativeTextField::adjustFontSizeToFitWidth() const {
  return _textfield.adjustsFontSizeToFitWidth;
}

qreal QiOSNativeTextField::minimumFontSize() const {
  return _textfield.minimumFontSize;
}

bool QiOSNativeTextField::editing() const {
  return _textfield.editing;
}

bool QiOSNativeTextField::clearsOnBeginEditing() const {
  return _textfield.clearsOnBeginEditing;
}

bool QiOSNativeTextField::clearsOnInsertion() const {
  return _textfield.clearsOnInsertion;
}

QString QiOSNativeTextField::backgroundColor() const {
  return QString::fromNSString([UIColor toHexString:_textfield.backgroundColor.CGColor]);
}

QiOSNativeTextField::AutocorrectionType QiOSNativeTextField::autocorretionType() const {
  switch (_textfield.autocorrectionType) {
    case UITextAutocorrectionTypeDefault: return AutocorrectionTypeDefault;
    case UITextAutocorrectionTypeNo: return AutocorrectionTypeNo;
    case UITextAutocorrectionTypeYes: return AutocorrectionTypeYes;
    }
}

QiOSNativeTextField::KeyboardAppearance QiOSNativeTextField::keyboardAppearance() const {
  switch (_textfield.keyboardAppearance) {
    case UIKeyboardAppearanceDefault: return KeyboardAppearanceDefault;
    case UIKeyboardAppearanceLight: return KeyboardAppearanceLight;
    case UIKeyboardAppearanceDark: return KeyboardAppearanceDark;
    }
}

QiOSNativeTextField::ReturnKeyType QiOSNativeTextField::returnKeyType() const {
  switch (_textfield.returnKeyType) {
    case UIReturnKeyDefault: return ReturnKeyDefault;
    case UIReturnKeyDone: return ReturnKeyDone;
    case UIReturnKeyContinue: return ReturnKeyContinue;
    case UIReturnKeyGo: return ReturnKeyGo;
    case UIReturnKeyEmergencyCall: return ReturnKeyEmergencyCall;
    case UIReturnKeyGoogle: return ReturnKeyGoogle;
    case UIReturnKeyJoin: return ReturnKeyJoin;
    case UIReturnKeyNext: return ReturnKeyNext;
    case UIReturnKeyRoute: return ReturnKeyRoute;
    case UIReturnKeySearch: return ReturnKeySearch;
    case UIReturnKeySend: return ReturnKeySend;
    case UIReturnKeyYahoo: return ReturnKeyYahoo;
    }
}

QiOSNativeTextField::TextContentType QiOSNativeTextField::contentType() const {
  if (_textfield.textContentType == UITextContentTypeURL) {
      return ContentTypeUrl;
    } else if (_textfield.textContentType == UITextContentTypeAddressCity) {
      return ContentTypeAddressCity;
    } else if (_textfield.textContentType == UITextContentTypeAddressCityAndState) {
      return ContentTypeAddressCityAndState;
    } else if (_textfield.textContentType == UITextContentTypeAddressState) {
      return ContentTypeAddressState;
    } else if (_textfield.textContentType == UITextContentTypeCountryName) {
      return ContentTypeCountryName;
    } else if (_textfield.textContentType == UITextContentTypeCreditCardNumber) {
      return ContentTypeCreditCardNumber;
    } else if (_textfield.textContentType == UITextContentTypeEmailAddress) {
      return ContentTypeEmailAddress;
    } else if (_textfield.textContentType == UITextContentTypeFamilyName) {
      return ContentTypeFamilyName;
    } else if (_textfield.textContentType == UITextContentTypeFullStreetAddress) {
      return ContentTypeFullStreetAddress;
    } else if (_textfield.textContentType == UITextContentTypeGivenName) {
      return ContentTypeGivenName;
    } else if (_textfield.textContentType == UITextContentTypeJobTitle) {
      return ContentTypeJobTitle;
    } else if (_textfield.textContentType == UITextContentTypeLocation) {
      return ContentTypeLocation;
    } else if (_textfield.textContentType == UITextContentTypeMiddleName) {
      return ContentTypeMiddleName;
    } else if (_textfield.textContentType == UITextContentTypeName) {
      return ContentTypeName;
    } else if (_textfield.textContentType == UITextContentTypeNamePrefix) {
      return ContentTypeNamePrefix;
    } else if (_textfield.textContentType == UITextContentTypeNameSuffix) {
      return ContentTypeNameSuffix;
    } else if (_textfield.textContentType == UITextContentTypeNickname) {
      return ContentTypeNickname;
    } else if (_textfield.textContentType == UITextContentTypeOrganizationName) {
      return ContentTypeOrganizationName;
    } else if (_textfield.textContentType == UITextContentTypePostalCode) {
      return ContentTypePostalCode;
    } else if (_textfield.textContentType == UITextContentTypeStreetAddressLine1) {
      return ContentTypeStreetAddressLine1;
    } else if (_textfield.textContentType == UITextContentTypeStreetAddressLine2) {
      return ContentTypeStreetAddressLine2;
    } else if (_textfield.textContentType == UITextContentTypeSublocality) {
      return ContentTypeSublocality;
    } else if (_textfield.textContentType == UITextContentTypeTelephoneNumber) {
      return ContentTypeTelephoneNumber;
    } else if (@available(iOS 11, *)) {
      if (_textfield.textContentType == UITextContentTypeUsername) {
          return ContentTypeUsername;
        } else if (_textfield.textContentType == UITextContentTypePassword) {
          return ContentTypePassword;
        }
    } else if (@available(iOS 12, *)) {
      if (_textfield.textContentType == UITextContentTypeNewPassword) {
          return ContentTypeNewPassword;
        } else if (_textfield.textContentType == UITextContentTypeOneTimeCode) {
          return ContentTypeOneTimeCode;
        }
    }
  return ContentTypeName;
}

bool QiOSNativeTextField::secureTextEntry() const {
  return _textfield.secureTextEntry;
}

bool QiOSNativeTextField::enableReturnKeyAutomatically() const {
  return _textfield.enablesReturnKeyAutomatically;
}

QiOSNativeTextField::TextAutocapitalizationType QiOSNativeTextField::autocapitalizationType() const {
  switch (_textfield.autocapitalizationType) {
    case UITextAutocapitalizationTypeNone: return AutocapitalizationNone;
    case UITextAutocapitalizationTypeWords: return AutocapitalizationWords;
    case UITextAutocapitalizationTypeSentences: return AutocapitalizationSentences;
    case UITextAutocapitalizationTypeAllCharacters: return AutocapitalizationAllCharacters;
    }
}

QiOSNativeTextField::SpellCheckingType QiOSNativeTextField::spellCheckingType() const {
  switch (_textfield.spellCheckingType) {
    case UITextSpellCheckingTypeDefault: return SpellCheckingTypeDefault;
    case UITextSpellCheckingTypeNo: return SpellCheckingTypeNo;
    case UITextSpellCheckingTypeYes: return SpellCheckingTypeYes;
    }
}

QiOSNativeTextField::TextSmartQuotesType QiOSNativeTextField::smartQuotesType() const {
  if (@available(iOS 11, *)) {
      switch (_textfield.smartQuotesType) {
        case UITextSmartQuotesTypeDefault: return SmartQuotesTypeDefault;
        case UITextSmartQuotesTypeNo: return SmartQuotesTypeNo;
        case UITextSmartQuotesTypeYes: return SmartQuotesTypeYes;
        }
    } else return SmartQuotesTypeNo;
}

qreal QiOSNativeTextField::borderWidth() const {
  return _textfield.layer.borderWidth;
}

qreal QiOSNativeTextField::radius() const {
  return _textfield.layer.cornerRadius;
}

QString QiOSNativeTextField::borderColor() const {
  return QString::fromNSString([UIColor toHexString:_textfield.layer.borderColor]);
}

QiOSNativeTextField::TextSmartDashesType QiOSNativeTextField::smartDashesType() const {
  if (@available(iOS 11, *)) {
      switch (_textfield.smartDashesType) {
        case UITextSmartDashesTypeDefault: return SmartDashesTypeDefault;
        case UITextSmartDashesTypeNo: return SmartDashesTypeNo;
        case UITextSmartDashesTypeYes: return SmartDashesTypeYes;
        }
    } else return SmartDashesTypeNo;
}

QiOSNativeTextField::TextSmartInsertDeleteType QiOSNativeTextField::smartInsertDeleteType() const {
  if (@available(iOS 11, *)) {
      switch (_textfield.smartInsertDeleteType) {
        case UITextSmartInsertDeleteTypeDefault: return SmartInsertDeleteTypeDefault;
        case UITextSmartInsertDeleteTypeNo: return SmartInsertDeleteTypeNo;
        case UITextSmartInsertDeleteTypeYes: return SmartInsertDeleteTypeYes;
        }
    } else return SmartInsertDeleteTypeNo;
}

void QiOSNativeTextField::setPlaceholder(const QString& placeholder) {
  _textfield.placeholder = placeholder.toNSString();
  emit placeholderChanged();
}

void QiOSNativeTextField::setKeyboardType(const KeyboardType& keyboardType) {
  switch (keyboardType) {
    case KeyboardTypeDefault:
      [_textfield setKeyboardType:UIKeyboardTypeDefault];
      break;
    case KeyboardTypeDecimalPad:
      [_textfield setKeyboardType:UIKeyboardTypeDecimalPad];
      break;
    case KeyboardTypeNumberPad:
      [_textfield setKeyboardType:UIKeyboardTypeNumberPad];
      break;
    case KeyboardTypeNumbersAndPunctuation:
      [_textfield setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
      break;
    case KeyboardTypePhonePad:
      [_textfield setKeyboardType:UIKeyboardTypePhonePad];
      break;
    case KeyboardTypeNamePhonePad:
      [_textfield setKeyboardType:UIKeyboardTypeNamePhonePad];
      break;
    case KeyboardTypeEmailAddress:
      [_textfield setKeyboardType:UIKeyboardTypeEmailAddress];
      break;
    case KeyboardTypeURL:
      [_textfield setKeyboardType:UIKeyboardTypeURL];
      break;
    case KeyboardTypeTwitter:
      [_textfield setKeyboardType:UIKeyboardTypeTwitter];
      break;
    case KeyboardTypeASCIICapable:
      [_textfield setKeyboardType:UIKeyboardTypeASCIICapable];
      break;
    case KeyboardTypeASCIICapableNumberPad:
      [_textfield setKeyboardType:UIKeyboardTypeASCIICapableNumberPad];
      break;
    case KeyboardTypeWebSearch:
      [_textfield setKeyboardType:UIKeyboardTypeWebSearch];
      break;
    }
  emit keyboardTypeChanged();
}

void QiOSNativeTextField::setText(const QString& text) {
  [_textfield setText:text.toNSString()];
  emit textChanged();
}

void QiOSNativeTextField::setFont(const QFont& font) {
  _font = font;
  UIFont* uiFont = [UIFont fontWithName:_font.family().toNSString() size:_font.pointSizeF()];
  [_textfield setFont:uiFont];
  emit fontChanged();
}

void QiOSNativeTextField::setColor(const QString& color) {
  [_textfield setTextColor:[UIColor colorWithHexString:color.toNSString()]];
  emit colorChanged();
}

void QiOSNativeTextField::setHorizontalAlignment(const TextAlignment& alignment) {
  switch (alignment) {
    case AlignRight:
      [_textfield setTextAlignment:NSTextAlignmentRight];
      break;
    case AlignLeft:
      [_textfield setTextAlignment:NSTextAlignmentLeft];
      break;
    case AlignHCenter:
      [_textfield setTextAlignment:NSTextAlignmentCenter];
      break;
    case AlignJustify:
      [_textfield setTextAlignment:NSTextAlignmentJustified];
      break;
    case AlignNatural:
      [_textfield setTextAlignment:NSTextAlignmentNatural];
      break;
    }
  emit horizontalAlignmentChanged();
}

void QiOSNativeTextField::setBorderStyle(const BorderStyle& borderStyle) {
  switch (borderStyle) {
    case BorderStyleNone:
      [_textfield setBorderStyle:UITextBorderStyleNone];
      break;
    case BorderStyleBezel:
      [_textfield setBorderStyle:UITextBorderStyleBezel];
      break;
    case BorderStyleLine:
      [_textfield setBorderStyle:UITextBorderStyleLine];
      break;
    case BorderStyleRoundedRect:
      [_textfield setBorderStyle:UITextBorderStyleRoundedRect];
      break;
    }
  emit borderStyleChanged();
}

void QiOSNativeTextField::setAdjustFontSizeToFitWidth(const bool adjustFontSizeToFitWidth) {
  [_textfield setAdjustsFontSizeToFitWidth:adjustFontSizeToFitWidth];
  emit adjustFontSizeToFitWidthChanged();
}

void QiOSNativeTextField::setMinimumFontSize(const qreal minimumFontSize) {
  [_textfield setMinimumFontSize:minimumFontSize];
  emit minimumFontSizeChanged();
}

void QiOSNativeTextField::setClearsOnBeginEditing(const bool clearsOnBeginEditing) {
  [_textfield setClearsOnBeginEditing:clearsOnBeginEditing];
  emit clearsOnBeginEditingChanged();
}

void QiOSNativeTextField::setClearsOnInsertion(const bool clearsOnInsertion) {
  [_textfield setClearsOnInsertion:clearsOnInsertion];
  emit clearsOnInsertionChanged();
}

void QiOSNativeTextField::setBackgroundColor(const QString& color) {
  [_textfield setBackgroundColor:[UIColor colorWithHexString:color.toNSString()]];
  emit backgroundColorChanged();
}

void QiOSNativeTextField::setAutocorretionType(const AutocorrectionType& autocorretionType) {
  switch (autocorretionType) {
    case AutocorrectionTypeDefault:
      [_textfield setAutocorrectionType:UITextAutocorrectionTypeDefault];
      break;
    case AutocorrectionTypeYes:
      [_textfield setAutocorrectionType:UITextAutocorrectionTypeYes];
      break;
    case AutocorrectionTypeNo:
      [_textfield setAutocorrectionType:UITextAutocorrectionTypeNo];
      break;
    }
  emit autocorretionTypeChanged();
}

void QiOSNativeTextField::setKeyboardAppearance(const KeyboardAppearance& keyboardAppearance) {
  switch (keyboardAppearance) {
    case KeyboardAppearanceDefault:
      if ([_textfield.inputAccessoryView isKindOfClass:[UIToolbar class]]) {
          [(UIToolbar*)_textfield.inputAccessoryView setBarTintColor:nil];
        }
      [_textfield setKeyboardAppearance:UIKeyboardAppearanceDefault];
      break;
    case KeyboardAppearanceLight:
      if ([_textfield.inputAccessoryView isKindOfClass:[UIToolbar class]]) {
          [(UIToolbar*)_textfield.inputAccessoryView setBarTintColor:nil];
        }
      [_textfield setKeyboardAppearance:UIKeyboardAppearanceLight];
      break;
    case KeyboardAppearanceDark:
      if ([_textfield.inputAccessoryView isKindOfClass:[UIToolbar class]]) {
          [(UIToolbar*)_textfield.inputAccessoryView setBarTintColor:[UIColor darkGrayColor]];
        }
      [_textfield setKeyboardAppearance:UIKeyboardAppearanceDark];
      break;
    }
  emit keyboardAppearanceChanged();
}

void QiOSNativeTextField::setReturnKeyType(const ReturnKeyType& returnKeyType) {
  switch (returnKeyType) {
    case ReturnKeyDefault:
      [_textfield setReturnKeyType:UIReturnKeyDefault];
      break;
    case ReturnKeyGo:
      [_textfield setReturnKeyType:UIReturnKeyGo];
      break;
    case ReturnKeyDone:
      [_textfield setReturnKeyType:UIReturnKeyDone];
      break;
    case ReturnKeyGoogle:
      [_textfield setReturnKeyType:UIReturnKeyGoogle];
      break;
    case ReturnKeyYahoo:
      [_textfield setReturnKeyType:UIReturnKeyYahoo];
      break;
    case ReturnKeySearch:
      [_textfield setReturnKeyType:UIReturnKeySearch];
      break;
    case ReturnKeyContinue:
      [_textfield setReturnKeyType:UIReturnKeyContinue];
      break;
    case ReturnKeyEmergencyCall:
      [_textfield setReturnKeyType:UIReturnKeyEmergencyCall];
      break;
    case ReturnKeyJoin:
      [_textfield setReturnKeyType:UIReturnKeyJoin];
      break;
    case ReturnKeyNext:
      [_textfield setReturnKeyType:UIReturnKeyNext];
      break;
    case ReturnKeyRoute:
      [_textfield setReturnKeyType:UIReturnKeyRoute];
      break;
    case ReturnKeySend:
      [_textfield setReturnKeyType:UIReturnKeySend];
      break;
    }
  emit returnKeyTypeChanged();
}

void QiOSNativeTextField::setContentType(const TextContentType& contentType) {
  switch (contentType) {
    case ContentTypeUrl:
      [_textfield setTextContentType:UITextContentTypeURL];
      break;
    case ContentTypeAddressCity:
      [_textfield setTextContentType:UITextContentTypeAddressCity];
      break;
    case ContentTypeAddressCityAndState:
      [_textfield setTextContentType:UITextContentTypeAddressCityAndState];
      break;
    case ContentTypeAddressState:
      [_textfield setTextContentType:UITextContentTypeAddressState];
      break;
    case ContentTypeCountryName:
      [_textfield setTextContentType:UITextContentTypeCountryName];
      break;
    case ContentTypeCreditCardNumber:
      [_textfield setTextContentType:UITextContentTypeCreditCardNumber];
      break;
    case ContentTypeEmailAddress:
      [_textfield setTextContentType:UITextContentTypeEmailAddress];
      break;
    case ContentTypeFamilyName:
      [_textfield setTextContentType:UITextContentTypeFamilyName];
      break;
    case ContentTypeFullStreetAddress:
      [_textfield setTextContentType:UITextContentTypeFullStreetAddress];
      break;
    case ContentTypeGivenName:
      [_textfield setTextContentType:UITextContentTypeGivenName];
      break;
    case ContentTypeJobTitle:
      [_textfield setTextContentType:UITextContentTypeJobTitle];
      break;
    case ContentTypeLocation:
      [_textfield setTextContentType:UITextContentTypeLocation];
      break;
    case ContentTypeMiddleName:
      [_textfield setTextContentType:UITextContentTypeMiddleName];
      break;
    case ContentTypeName:
      [_textfield setTextContentType:UITextContentTypeName];
      break;
    case ContentTypeNamePrefix:
      [_textfield setTextContentType:UITextContentTypeNamePrefix];
      break;
    case ContentTypeNameSuffix:
      [_textfield setTextContentType:UITextContentTypeNameSuffix];
      break;
    case ContentTypeNickname:
      [_textfield setTextContentType:UITextContentTypeNickname];
      break;
    case ContentTypeOrganizationName:
      [_textfield setTextContentType:UITextContentTypeOrganizationName];
      break;
    case ContentTypePostalCode:
      [_textfield setTextContentType:UITextContentTypePostalCode];
      break;
    case ContentTypeStreetAddressLine1:
      [_textfield setTextContentType:UITextContentTypeStreetAddressLine1];
      break;
    case ContentTypeStreetAddressLine2:
      [_textfield setTextContentType:UITextContentTypeStreetAddressLine2];
      break;
    case ContentTypeSublocality:
      [_textfield setTextContentType:UITextContentTypeSublocality];
      break;
    case ContentTypeTelephoneNumber:
      [_textfield setTextContentType:UITextContentTypeTelephoneNumber];
      break;
    case ContentTypeUsername:
      if (@available(iOS 11, *)) {
          [_textfield setTextContentType:UITextContentTypeUsername];
        }
      break;
    case ContentTypePassword:
      if (@available(iOS 11, *)) {
          [_textfield setTextContentType:UITextContentTypePassword];
        }
      break;
    case ContentTypeNewPassword:
      if (@available(iOS 12, *)) {
          [_textfield setTextContentType:UITextContentTypeNewPassword];
        }
      break;
    case ContentTypeOneTimeCode:
      if (@available(iOS 12, *)) {
          [_textfield setTextContentType:UITextContentTypeOneTimeCode];
        }
      break;
    }
  emit contentTypeChanged();
}

void QiOSNativeTextField::setSecureTextEntry(const bool secureTextEntry) {
  [_textfield setSecureTextEntry:secureTextEntry];
  emit secureTextEntryChanged();
}

void QiOSNativeTextField::setEnableReturnKeyAutomatically(const bool enableReturnKeyAutomatically) {
  [_textfield setEnablesReturnKeyAutomatically:enableReturnKeyAutomatically];
  emit enableReturnKeyAutomaticallyChanged();
}

void QiOSNativeTextField::setAutocapitalizationType(const TextAutocapitalizationType& autocapitalizationType) {
  switch (autocapitalizationType) {
    case AutocapitalizationNone:
      [_textfield setAutocapitalizationType:UITextAutocapitalizationTypeNone];
      break;
    case AutocapitalizationWords:
      [_textfield setAutocapitalizationType:UITextAutocapitalizationTypeWords];
      break;
    case AutocapitalizationSentences:
      [_textfield setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
      break;
    case AutocapitalizationAllCharacters:
      [_textfield setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
      break;
    }
  emit autocapitalizationTypeChanged();
}

void QiOSNativeTextField::setSpellCheckingType(const SpellCheckingType& spellCheckingType) {
  switch (spellCheckingType) {
    case SpellCheckingTypeDefault:
      [_textfield setSpellCheckingType:UITextSpellCheckingTypeDefault];
      break;
    case SpellCheckingTypeNo:
      [_textfield setSpellCheckingType:UITextSpellCheckingTypeNo];
      break;
    case SpellCheckingTypeYes:
      [_textfield setSpellCheckingType:UITextSpellCheckingTypeYes];
      break;
    }
  emit spellCheckingTypeChanged();
}

void QiOSNativeTextField::setSmartQuotesType(const TextSmartQuotesType& smartQuotesType) {
  if (@available(iOS 11, *)) {
      switch (smartQuotesType) {
        case SmartQuotesTypeDefault:
          [_textfield setSmartQuotesType:UITextSmartQuotesTypeDefault];
          break;
        case SmartQuotesTypeNo:
          [_textfield setSmartQuotesType:UITextSmartQuotesTypeNo];
          break;
        case SmartQuotesTypeYes:
          [_textfield setSmartQuotesType:UITextSmartQuotesTypeYes];
          break;
        }
      emit smartQuotesTypeChanged();
    }
}

void QiOSNativeTextField::setBorderWidth(const qreal borderWidth) {
  [_textfield.layer setBorderWidth:borderWidth];
  emit borderWidthChanged();
}

void QiOSNativeTextField::setRadius(const qreal radius) {
  [_textfield.layer setCornerRadius:radius];
  emit radiusChanged();
}

void QiOSNativeTextField::setBorderColor(const QString& borderColor) {
  [_textfield.layer setBorderColor:[[UIColor colorWithHexString:borderColor.toNSString()] CGColor]];
  emit borderColorChanged();
}

void QiOSNativeTextField::setSmartDashesType(const QiOSNativeTextField::TextSmartDashesType& smartDashesType) {
  if (@available(iOS 11, *)) {
      switch (smartDashesType) {
        case SmartDashesTypeDefault:
          [_textfield setSmartDashesType:UITextSmartDashesTypeDefault];
          break;
        case SmartDashesTypeNo:
          [_textfield setSmartDashesType:UITextSmartDashesTypeNo];
          break;
        case SmartDashesTypeYes:
          [_textfield setSmartDashesType:UITextSmartDashesTypeYes];
          break;
        }
      emit smartDashesTypeChanged();
    }
}

void QiOSNativeTextField::setSmartInsertDeleteType(const QiOSNativeTextField::TextSmartInsertDeleteType& smartInsertDeleteType) {
  if (@available(iOS 11, *)) {
      switch (smartInsertDeleteType) {
        case SmartInsertDeleteTypeDefault:
          [_textfield setSmartInsertDeleteType:UITextSmartInsertDeleteTypeDefault];
          break;
        case SmartInsertDeleteTypeNo:
          [_textfield setSmartInsertDeleteType:UITextSmartInsertDeleteTypeNo];
          break;
        case SmartInsertDeleteTypeYes:
          [_textfield setSmartInsertDeleteType:UITextSmartInsertDeleteTypeYes];
          break;
        }
      emit smartInsertDeleteTypeChanged();
    }
}

void QiOSNativeTextField::onVisibleChanged() {
  [_textfield setHidden:isVisible()];
}

void QiOSNativeTextField::onEnabledChanged() {
  [_textfield setEnabled:isEnabled()];
}

void QiOSNativeTextField::onOpacityChanged() {
  [_textfield setAlpha:opacity()];
}

void QiOSNativeTextField::onFocusChanged(bool focus) {
  if (focus) {
      [_textfield becomeFirstResponder];
    } else {
      [_textfield resignFirstResponder];
    }
}

void QiOSNativeTextField::onScaleChanged() {
  [_textfield setContentScaleFactor:scale()];
}
