#ifndef QIOSNATIVETEXTFIELD_H
#define QIOSNATIVETEXTFIELD_H

#include <QQuickItem>

Q_FORWARD_DECLARE_OBJC_CLASS(UITextField);
Q_FORWARD_DECLARE_OBJC_CLASS(TextFieldDelegate);

//TODO: Add input accessory view setup from QML
class QiOSNativeTextField : public QQuickItem {
  Q_OBJECT
  Q_PROPERTY(QString placeholder READ placeholder WRITE setPlaceholder NOTIFY placeholderChanged)
  Q_PROPERTY(KeyboardType keyboardType READ keyboardType WRITE setKeyboardType NOTIFY keyboardTypeChanged)
  Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged)
  Q_PROPERTY(QFont font READ font WRITE setFont NOTIFY fontChanged)
  Q_PROPERTY(QString color READ color WRITE setColor NOTIFY colorChanged)
  Q_PROPERTY(TextAlignment horizontalAlignment READ horizontalAlignment WRITE setHorizontalAlignment NOTIFY horizontalAlignmentChanged)
  Q_PROPERTY(BorderStyle borderStyle READ borderStyle WRITE setBorderStyle NOTIFY borderStyleChanged)
  Q_PROPERTY(bool adjustFontSizeToFitWidth READ adjustFontSizeToFitWidth WRITE setAdjustFontSizeToFitWidth NOTIFY adjustFontSizeToFitWidthChanged)
  Q_PROPERTY(qreal minimumFontSize READ minimumFontSize WRITE setMinimumFontSize NOTIFY minimumFontSizeChanged)
  Q_PROPERTY(bool editing READ editing NOTIFY editingChanged)
  Q_PROPERTY(bool clearsOnBeginEditing READ clearsOnBeginEditing WRITE setClearsOnBeginEditing NOTIFY clearsOnBeginEditingChanged)
  Q_PROPERTY(bool clearsOnInsertion READ clearsOnInsertion WRITE setClearsOnInsertion NOTIFY clearsOnInsertionChanged)
  Q_PROPERTY(QString backgroundColor READ backgroundColor WRITE setBackgroundColor NOTIFY backgroundColorChanged)
  Q_PROPERTY(AutocorrectionType autocorretionType READ autocorretionType WRITE setAutocorretionType NOTIFY autocorretionTypeChanged)
  Q_PROPERTY(KeyboardAppearance keyboardAppearance READ keyboardAppearance WRITE setKeyboardAppearance NOTIFY keyboardAppearanceChanged)
  Q_PROPERTY(ReturnKeyType returnKeyType READ returnKeyType WRITE setReturnKeyType NOTIFY returnKeyTypeChanged)
  Q_PROPERTY(TextContentType contentType READ contentType WRITE setContentType NOTIFY contentTypeChanged)
  Q_PROPERTY(bool secureTextEntry READ secureTextEntry WRITE setSecureTextEntry NOTIFY secureTextEntryChanged)
  Q_PROPERTY(bool enableReturnKeyAutomatically READ enableReturnKeyAutomatically WRITE setEnableReturnKeyAutomatically NOTIFY enableReturnKeyAutomaticallyChanged)
  Q_PROPERTY(TextAutocapitalizationType autocapitalizationType READ autocapitalizationType WRITE setAutocapitalizationType NOTIFY autocapitalizationTypeChanged)
  Q_PROPERTY(SpellCheckingType spellCheckingType READ spellCheckingType WRITE setSpellCheckingType NOTIFY spellCheckingTypeChanged)
  Q_PROPERTY(TextSmartQuotesType smartQuotesType READ smartQuotesType WRITE setSmartQuotesType NOTIFY smartQuotesTypeChanged)
  Q_PROPERTY(qreal borderWidth READ borderWidth WRITE setBorderWidth NOTIFY borderWidthChanged)
  Q_PROPERTY(qreal radius READ radius WRITE setRadius NOTIFY radiusChanged)
  Q_PROPERTY(QString borderColor READ borderColor WRITE setBorderColor NOTIFY borderColorChanged)
  Q_PROPERTY(TextSmartDashesType smartDashesType READ smartDashesType WRITE setSmartDashesType NOTIFY smartDashesTypeChanged)
  Q_PROPERTY(TextSmartInsertDeleteType smartInsertDeleteType READ smartInsertDeleteType WRITE setSmartInsertDeleteType NOTIFY smartInsertDeleteTypeChanged)
public:
  enum KeyboardType {
    KeyboardTypeDefault,
    KeyboardTypeASCIICapable,
    KeyboardTypeNumbersAndPunctuation,
    KeyboardTypeURL,
    KeyboardTypeNumberPad,
    KeyboardTypePhonePad,
    KeyboardTypeNamePhonePad,
    KeyboardTypeEmailAddress,
    KeyboardTypeDecimalPad,
    KeyboardTypeTwitter,
    KeyboardTypeWebSearch,
    KeyboardTypeASCIICapableNumberPad
  };
  Q_ENUM(KeyboardType)

  enum TextAlignment {
    AlignLeft,
    AlignRight,
    AlignHCenter,
    AlignJustify,
    AlignNatural
  };
  Q_ENUM(TextAlignment)

  enum BorderStyle {
    BorderStyleNone,
    BorderStyleLine,
    BorderStyleBezel,
    BorderStyleRoundedRect
  };
  Q_ENUM(BorderStyle)

  enum AutocorrectionType {
    AutocorrectionTypeDefault,
    AutocorrectionTypeNo,
    AutocorrectionTypeYes
  };
  Q_ENUM(AutocorrectionType)

  enum KeyboardAppearance {
    KeyboardAppearanceDefault,
    KeyboardAppearanceDark,
    KeyboardAppearanceLight
  };
  Q_ENUM(KeyboardAppearance)

  enum ReturnKeyType {
    ReturnKeyDefault,
    ReturnKeyGo,
    ReturnKeyGoogle,
    ReturnKeyJoin,
    ReturnKeyNext,
    ReturnKeyRoute,
    ReturnKeySearch,
    ReturnKeySend,
    ReturnKeyYahoo,
    ReturnKeyDone,
    ReturnKeyEmergencyCall,
    ReturnKeyContinue
  };
  Q_ENUM(ReturnKeyType)

  enum TextContentType {
    ContentTypeUrl,
    ContentTypeAddressCity,
    ContentTypeAddressCityAndState,
    ContentTypeAddressState,
    ContentTypeCountryName,
    ContentTypeCreditCardNumber,
    ContentTypeEmailAddress,
    ContentTypeFamilyName,
    ContentTypeFullStreetAddress,
    ContentTypeGivenName,
    ContentTypeJobTitle,
    ContentTypeLocation,
    ContentTypeMiddleName,
    ContentTypeName,
    ContentTypeNamePrefix,
    ContentTypeNameSuffix,
    ContentTypeNickname,
    ContentTypeOrganizationName,
    ContentTypePostalCode,
    ContentTypeStreetAddressLine1,
    ContentTypeStreetAddressLine2,
    ContentTypeSublocality,
    ContentTypeTelephoneNumber,
    ContentTypeUsername,
    ContentTypePassword,
    ContentTypeNewPassword,
    ContentTypeOneTimeCode
  };
  Q_ENUM(TextContentType)

  enum TextAutocapitalizationType {
    AutocapitalizationNone,
    AutocapitalizationWords,
    AutocapitalizationSentences,
    AutocapitalizationAllCharacters
  };
  Q_ENUM(TextAutocapitalizationType)

  enum SpellCheckingType {
    SpellCheckingTypeDefault,
    SpellCheckingTypeNo,
    SpellCheckingTypeYes
  };
  Q_ENUM(SpellCheckingType)

  enum TextSmartQuotesType {
    SmartQuotesTypeDefault,
    SmartQuotesTypeNo,
    SmartQuotesTypeYes
  };
  Q_ENUM(TextSmartQuotesType)

  enum TextSmartDashesType {
    SmartDashesTypeDefault,
    SmartDashesTypeNo,
    SmartDashesTypeYes
  };
  Q_ENUM(TextSmartDashesType)

  enum TextSmartInsertDeleteType {
    SmartInsertDeleteTypeDefault,
    SmartInsertDeleteTypeNo,
    SmartInsertDeleteTypeYes
  };
  Q_ENUM(TextSmartInsertDeleteType)

  QiOSNativeTextField(QQuickItem* parent = nullptr);
  ~QiOSNativeTextField() override;

  void geometryChanged(const QRectF& newGeometry, const QRectF& oldGeometry) override;

  QString placeholder() const;
  KeyboardType keyboardType() const;
  QString text() const;
  QFont font() const;
  QString color() const;
  TextAlignment horizontalAlignment() const;
  BorderStyle borderStyle() const;
  bool adjustFontSizeToFitWidth() const;
  qreal minimumFontSize() const;
  bool editing() const;
  bool clearsOnBeginEditing() const;
  bool clearsOnInsertion() const;
  QString backgroundColor() const;
  AutocorrectionType autocorretionType() const;
  KeyboardAppearance keyboardAppearance() const;
  ReturnKeyType returnKeyType() const;
  TextContentType contentType() const;
  bool secureTextEntry() const;
  bool enableReturnKeyAutomatically() const;
  TextAutocapitalizationType autocapitalizationType() const;
  SpellCheckingType spellCheckingType() const;
  TextSmartQuotesType smartQuotesType() const;
  qreal borderWidth() const;
  qreal radius() const;
  QString borderColor() const;
  TextSmartDashesType smartDashesType() const;
  TextSmartInsertDeleteType smartInsertDeleteType() const;

  void setPlaceholder(const QString&);
  void setKeyboardType(const KeyboardType&);
  void setText(const QString&);
  void setFont(const QFont&);
  void setColor(const QString&);
  void setHorizontalAlignment(const TextAlignment&);
  void setBorderStyle(const BorderStyle&);
  void setAdjustFontSizeToFitWidth(const bool);
  void setMinimumFontSize(const qreal);
  void setClearsOnBeginEditing(const bool);
  void setClearsOnInsertion(const bool);
  void setBackgroundColor(const QString&);
  void setAutocorretionType(const AutocorrectionType&);
  void setKeyboardAppearance(const KeyboardAppearance&);
  void setReturnKeyType(const ReturnKeyType&);
  void setContentType(const TextContentType&);
  void setSecureTextEntry(const bool);
  void setEnableReturnKeyAutomatically(const bool);
  void setAutocapitalizationType(const TextAutocapitalizationType&);
  void setSpellCheckingType(const SpellCheckingType&);
  void setSmartQuotesType(const TextSmartQuotesType&);
  void setBorderWidth(const qreal);
  void setRadius(const qreal);
  void setBorderColor(const QString&);
  void setSmartDashesType(const TextSmartDashesType&);
  void setSmartInsertDeleteType(const TextSmartInsertDeleteType&);

signals:
  void commited(QString text);

  void placeholderChanged();
  void keyboardTypeChanged();
  void textChanged();
  void fontChanged();
  void colorChanged();
  void horizontalAlignmentChanged();
  void borderStyleChanged();
  void adjustFontSizeToFitWidthChanged();
  void minimumFontSizeChanged();
  void clearsOnBeginEditingChanged();
  void clearsOnInsertionChanged();
  void backgroundColorChanged();
  void autocorretionTypeChanged();
  void keyboardAppearanceChanged();
  void returnKeyTypeChanged();
  void contentTypeChanged();
  void secureTextEntryChanged();
  void enableReturnKeyAutomaticallyChanged();
  void autocapitalizationTypeChanged();
  void spellCheckingTypeChanged();
  void smartQuotesTypeChanged();
  void editingChanged();
  void borderWidthChanged();
  void radiusChanged();
  void borderColorChanged();
  void smartDashesTypeChanged();
  void smartInsertDeleteTypeChanged();

private slots:
  void onWindowChanged(QQuickWindow* window);
  void onVisibleChanged();
  void onEnabledChanged();
  void onOpacityChanged();
  void onFocusChanged(bool);
  void onScaleChanged();

private:  
  UITextField* _textfield;
  TextFieldDelegate* _delegate;
  QFont _font;
};

#endif // QIOSNATIVETEXTFIELD_H
