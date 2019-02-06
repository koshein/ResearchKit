/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


@import XCTest;
@import ResearchKit.Private;


@interface ORKAnswerFormatTests : XCTestCase

@end

@protocol ORKComfirmAnswerFormat_Private <NSObject>

@property (nonatomic, copy, readonly) NSString *originalItemIdentifier;
@property (nonatomic, copy, readonly) NSString *errorMessage;

@end


@implementation ORKAnswerFormatTests

- (void)testValidEmailAnswerFormat {
    // Test email regular expression validation with correct input.
    XCTAssert([[ORKEmailAnswerFormat emailAnswerFormat] isAnswerValidWithString:@"someone@researchkit.org"]);
    XCTAssert([[ORKEmailAnswerFormat emailAnswerFormat] isAnswerValidWithString:@"some.one@researchkit.org"]);
    XCTAssert([[ORKEmailAnswerFormat emailAnswerFormat] isAnswerValidWithString:@"someone@researchkit.org.uk"]);
    XCTAssert([[ORKEmailAnswerFormat emailAnswerFormat] isAnswerValidWithString:@"some_one@researchkit.org"]);
    XCTAssert([[ORKEmailAnswerFormat emailAnswerFormat] isAnswerValidWithString:@"some-one@researchkit.org"]);
    XCTAssert([[ORKEmailAnswerFormat emailAnswerFormat] isAnswerValidWithString:@"someone1@researchkit.org"]);
    XCTAssert([[ORKEmailAnswerFormat emailAnswerFormat] isAnswerValidWithString:@"Someone1@ResearchKit.org"]);
}

- (void)testInvalidEmailAnswerFormat {
    // Test email regular expression validation with incorrect input.
    XCTAssertFalse([[ORKEmailAnswerFormat emailAnswerFormat] isAnswerValidWithString:@"emailtest"]);
    XCTAssertFalse([[ORKEmailAnswerFormat emailAnswerFormat] isAnswerValidWithString:@"emailtest@"]);
    XCTAssertFalse([[ORKEmailAnswerFormat emailAnswerFormat] isAnswerValidWithString:@"emailtest@researchkit"]);
    XCTAssertFalse([[ORKEmailAnswerFormat emailAnswerFormat] isAnswerValidWithString:@"emailtest@.org"]);
    XCTAssertFalse([[ORKEmailAnswerFormat emailAnswerFormat] isAnswerValidWithString:@"12345"]);
}

- (void)testInvalidRegularExpressionAnswerFormat {
    
    // Setup an answer format
    ORKTextAnswerFormat *answerFormat = [ORKAnswerFormat textAnswerFormat];
    answerFormat.multipleLines = NO;
    answerFormat.keyboardType = UIKeyboardTypeASCIICapable;
    NSRegularExpression *validationRegularExpression =
    [NSRegularExpression regularExpressionWithPattern:@"^[A-F,0-9]+$"
                                              options:(NSRegularExpressionOptions)0
                                                error:nil];
    answerFormat.validationRegularExpression = validationRegularExpression;
    answerFormat.invalidMessage = @"Only hexidecimal values in uppercase letters are accepted.";
    answerFormat.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    XCTAssertFalse([answerFormat isAnswerValidWithString:@"Q2"]);
    XCTAssertFalse([answerFormat isAnswerValidWithString:@"abcd"]);
    XCTAssertTrue([answerFormat isAnswerValidWithString:@"ABCD1234FFED0987654321"]);
}

- (void)testConfirmAnswerFormat {
    
    // Setup an answer format
    ORKTextAnswerFormat *answerFormat = [ORKAnswerFormat textAnswerFormat];
    answerFormat.multipleLines = NO;
    answerFormat.secureTextEntry = YES;
    answerFormat.keyboardType = UIKeyboardTypeASCIICapable;
    if (@available(iOS 12.0, *)) {
        answerFormat.textContentType = UITextContentTypeNewPassword;
    } else {
        answerFormat.textContentType = UITextContentTypePassword;
    }
    answerFormat.maximumLength = 12;
    NSRegularExpression *validationRegularExpression =
    [NSRegularExpression regularExpressionWithPattern:@"^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$!%*?&])[A-Za-z\\d$@$!%*?&]{10,}"
                                              options:(NSRegularExpressionOptions)0
                                                error:nil];
    answerFormat.validationRegularExpression = validationRegularExpression;
    answerFormat.invalidMessage = @"Invalid password";
    answerFormat.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    
    // Note: setting these up incorrectly for a password to test that the values are *not* copied.
    // DO NOT setup a real password field with these options.
    answerFormat.autocorrectionType = UITextAutocorrectionTypeDefault;
    answerFormat.spellCheckingType = UITextSpellCheckingTypeDefault;
    
    
    ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"foo" text:@"enter value" answerFormat:answerFormat optional:NO];
    
    // -- method under test
    ORKFormItem *confirmItem = [item confirmationAnswerFormItemWithIdentifier:@"bar"
                                                                         text:@"enter again"
                                                                 errorMessage:@"doesn't match"];
    
    XCTAssertEqualObjects(confirmItem.identifier, @"bar");
    XCTAssertEqualObjects(confirmItem.text, @"enter again");
    XCTAssertFalse(confirmItem.optional);
    
    // Inspect the answer format
    ORKAnswerFormat *confirmFormat = confirmItem.answerFormat;
    
    // ORKAnswerFormat that is returned should be a subclass of ORKTextAnswerFormat.
    // The actual subclass that is returned is private to the API and should not be accessed directly.
    XCTAssertNotNil(confirmFormat);
    XCTAssertTrue([confirmFormat isKindOfClass:[ORKTextAnswerFormat class]]);
    if (![confirmFormat isKindOfClass:[ORKTextAnswerFormat class]]) { return; }
    
    ORKTextAnswerFormat *confirmAnswer = (ORKTextAnswerFormat*)confirmFormat;
    
    // These properties should match the original format
    XCTAssertFalse(confirmAnswer.multipleLines);
    XCTAssertTrue(confirmAnswer.secureTextEntry);
    XCTAssertEqual(confirmAnswer.keyboardType, UIKeyboardTypeASCIICapable);
    if (@available(iOS 12.0, *)) {
        XCTAssertEqual(confirmAnswer.textContentType, UITextContentTypeNewPassword);
    } else {
        XCTAssertEqual(confirmAnswer.textContentType, UITextContentTypePassword);
    }
    XCTAssertEqual(confirmAnswer.maximumLength, 12);
    
    // This property should match the input answer format so that cases that
    // require all-upper or all-lower (for whatever reason) can be met.
    XCTAssertEqual(confirmAnswer.autocapitalizationType, UITextAutocapitalizationTypeAllCharacters);
    
    // These properties should always be set to not autocorrect
    XCTAssertEqual(confirmAnswer.autocorrectionType, UITextAutocorrectionTypeNo);
    XCTAssertEqual(confirmAnswer.spellCheckingType, UITextSpellCheckingTypeNo);
    
    // These properties should be nil
    XCTAssertNil(confirmAnswer.validationRegularExpression);
    XCTAssertNil(confirmAnswer.invalidMessage);
    
    // Check that the confirmation answer format responds to the internal methods
    XCTAssertTrue([confirmFormat respondsToSelector:@selector(originalItemIdentifier)]);
    XCTAssertTrue([confirmFormat respondsToSelector:@selector(errorMessage)]);
    if (![confirmFormat respondsToSelector:@selector(originalItemIdentifier)] ||
        ![confirmFormat respondsToSelector:@selector(errorMessage)]) {
        return;
    }
    
    NSString *originalItemIdentifier = [(id)confirmFormat originalItemIdentifier];
    XCTAssertEqualObjects(originalItemIdentifier, @"foo");
    
    NSString *errorMessage = [(id)confirmFormat errorMessage];
    XCTAssertEqualObjects(errorMessage, @"doesn't match");
    
}

- (void)testConfirmAnswerFormat_Optional_YES {
    
    // Setup an answer format
    ORKTextAnswerFormat *answerFormat = [ORKAnswerFormat textAnswerFormat];
    answerFormat.multipleLines = NO;
    
    ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"foo" text:@"enter value" answerFormat:answerFormat optional:YES];
    
    // -- method under test
    ORKFormItem *confirmItem = [item confirmationAnswerFormItemWithIdentifier:@"bar"
                                                                         text:@"enter again"
                                                                 errorMessage:@"doesn't match"];
    
    // Check that the confirm item optional value matches the input item
    XCTAssertTrue(confirmItem.optional);
    
}

- (void)testConfirmAnswerFormat_MultipleLines_YES {
    
    // Setup an answer format
    ORKTextAnswerFormat *answerFormat = [ORKAnswerFormat textAnswerFormat];
    answerFormat.multipleLines = YES;
    
    ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"foo" text:@"enter value" answerFormat:answerFormat optional:YES];
    
    // -- method under test
    XCTAssertThrows([item confirmationAnswerFormItemWithIdentifier:@"bar"
                                                              text:@"enter again"
                                                      errorMessage:@"doesn't match"]);
    
}

- (void)testContinuousScaleAnswerFormat{
    
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat continuousScaleAnswerFormatWithMaximumValue:10
                                                                                 minimumValue:100
                                                                                 defaultValue:10
                                                                        maximumFractionDigits:10
                                                                                     vertical:YES
                                                                      maximumValueDescription:NULL
                                                                      minimumValueDescription:NULL], NSException, NSInvalidArgumentException, @"Shoud throw NSInvalidArgumentException since max < min");
    
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat continuousScaleAnswerFormatWithMaximumValue:10001
                                                                                 minimumValue:100
                                                                                 defaultValue:10
                                                                        maximumFractionDigits:10
                                                                                     vertical:YES
                                                                      maximumValueDescription:NULL
                                                                      minimumValueDescription:NULL], NSException, NSInvalidArgumentException, @"Shoud throw NSInvalidArgumentException since max > effectiveUpperBound");
    
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat continuousScaleAnswerFormatWithMaximumValue:100
                                                                                 minimumValue:-10001
                                                                                 defaultValue:10
                                                                        maximumFractionDigits:10
                                                                                     vertical:YES
                                                                      maximumValueDescription:NULL
                                                                      minimumValueDescription:NULL], NSException, NSInvalidArgumentException, @"Shoud throw NSInvalidArgumentException since min < effectiveLowerBound");
    
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat continuousScaleAnswerFormatWithMaximumValue:10
                                                                                 minimumValue:100
                                                                                 defaultValue:10
                                                                        maximumFractionDigits:10
                                                                                     vertical:YES
                                                                      maximumValueDescription:NULL
                                                                      minimumValueDescription:NULL], NSException, NSInvalidArgumentException, @"Shoud throw NSInvalidArgumentException since max < min");
    
    
    ORKContinuousScaleAnswerFormat *answerFormat = [ORKAnswerFormat continuousScaleAnswerFormatWithMaximumValue:1
                                                                                                   minimumValue:0
                                                                                                   defaultValue:10
                                                                                          maximumFractionDigits:10
                                                                                                       vertical:YES
                                                                                        maximumValueDescription:NULL
                                                                                        minimumValueDescription:NULL];
    
    XCTAssertEqual([answerFormat maximum], 1);
    XCTAssertEqual([answerFormat minimum], 0);
    XCTAssertEqual([answerFormat defaultValue], 10);
    XCTAssertEqual([answerFormat maximumFractionDigits], 4, @"Should return 4 since the maximumFractionDigits needs to 0 <= maximumFractionDigits <= 4");
    XCTAssertEqual([answerFormat isVertical], YES);
    XCTAssertEqual([answerFormat maximumValueDescription], NULL);
    XCTAssertEqual([answerFormat minimumValueDescription], NULL);
    
     ORKContinuousScaleAnswerFormat *answerFormatTwo = [ORKAnswerFormat continuousScaleAnswerFormatWithMaximumValue:1
                                                                                                       minimumValue:0
                                                                                                       defaultValue:10
                                                                                              maximumFractionDigits:-1
                                                                                                           vertical:YES
                                                                                            maximumValueDescription:NULL
                                                                                            minimumValueDescription:NULL];
    
    XCTAssertEqual([answerFormatTwo maximumFractionDigits], 0, @"Should return 0 since the maximumFractionDigits needs to 0 <= maximumFractionDigits <= 4");
    
}

- (void)testScaleAnswerFormat{
    
    ORKScaleAnswerFormat *answerFormat = [ORKAnswerFormat scaleAnswerFormatWithMaximumValue:100
                                                                               minimumValue:0
                                                                               defaultValue:10
                                                                                       step:10
                                                                                   vertical:YES
                                                                    maximumValueDescription:@"MAX"
                                                                    minimumValueDescription:@"MIN"];
    
    XCTAssertEqual([answerFormat maximum], 100);
    XCTAssertEqual([answerFormat minimum], 0);
    XCTAssertEqual([answerFormat defaultValue], 10);
    XCTAssertEqual([answerFormat step], 10);
    XCTAssertEqual([answerFormat isVertical], YES);
    XCTAssertEqual([answerFormat maximumValueDescription], @"MAX");
    XCTAssertEqual([answerFormat minimumValueDescription], @"MIN");
    
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat scaleAnswerFormatWithMaximumValue:25
                                                                       minimumValue:50
                                                                       defaultValue:10
                                                                               step:10
                                                                           vertical:YES
                                                            maximumValueDescription:NULL
                                                            minimumValueDescription:NULL],
                                 NSException, NSInvalidArgumentException,
                                 @"Should throw NSInvalidArgumentException since max < min");
    
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat scaleAnswerFormatWithMaximumValue:100
                                                                       minimumValue:10
                                                                       defaultValue:200
                                                                               step:0
                                                                           vertical:YES
                                                            maximumValueDescription:NULL
                                                            minimumValueDescription:NULL],
                                 NSException, NSInvalidArgumentException,
                                 @"Should throw NSInvalidArgumentException since step < 1");
    
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat scaleAnswerFormatWithMaximumValue:100
                                                                       minimumValue:0
                                                                       defaultValue:10
                                                                               step:3
                                                                           vertical:YES
                                                            maximumValueDescription:NULL
                                                            minimumValueDescription:NULL],
                                 NSException, NSInvalidArgumentException,
                                 @"Should throw NSInvalidArgumentException since step is not divisible by the difference of max and min");
    
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat scaleAnswerFormatWithMaximumValue:25
                                                                       minimumValue:-20000
                                                                       defaultValue:10
                                                                               step:10
                                                                           vertical:YES
                                                            maximumValueDescription:NULL
                                                            minimumValueDescription:NULL],
                                 NSException, NSInvalidArgumentException,
                                 @"Should throw NSInvalidArgumentException since min < -10000");
    
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat scaleAnswerFormatWithMaximumValue:20000
                                                                       minimumValue:0
                                                                       defaultValue:10
                                                                               step:10
                                                                           vertical:YES
                                                            maximumValueDescription:NULL
                                                            minimumValueDescription:NULL],
                                 NSException, NSInvalidArgumentException,
                                 @"Should throw NSInvalidArgumentException since max > 10000");
    
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat scaleAnswerFormatWithMaximumValue:100
                                                                       minimumValue:0
                                                                       defaultValue:10
                                                                               step:1
                                                                           vertical:YES
                                                            maximumValueDescription:NULL
                                                            minimumValueDescription:NULL],
                                 NSException, NSInvalidArgumentException,
                                 @"Should throw NSInvalidArgumentException since step count > 13");
    
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat scaleAnswerFormatWithMaximumValue:100
                                                                       minimumValue:100
                                                                       defaultValue:10
                                                                               step:1
                                                                           vertical:YES
                                                            maximumValueDescription:NULL
                                                            minimumValueDescription:NULL],
                                 NSException, NSInvalidArgumentException,
                                 @"Should throw NSInvalidArgumentException since step count < 1");
    
}

- (void) testTextScaleAnswerFormat{

    ORKTextChoice *choiceOne = [ORKTextChoice choiceWithText:@"Choice One" value:[NSNumber numberWithInteger:1]];
    ORKTextChoice *choiceTwo = [ORKTextChoice choiceWithText:@"Choice Two" value:[NSNumber numberWithInteger:2]];
    NSArray *choices = [NSArray arrayWithObjects:choiceOne, choiceTwo, nil];
    ORKTextScaleAnswerFormat *answerFormat = [ORKAnswerFormat textScaleAnswerFormatWithTextChoices:choices defaultIndex:0 vertical:YES];
    
    XCTAssertEqual([[[answerFormat textChoices] objectAtIndex:0] value],[NSNumber numberWithInteger:1]);
    XCTAssertEqual([[[answerFormat textChoices] objectAtIndex:1] value],[NSNumber numberWithInteger:2]);
    XCTAssertEqual([[[answerFormat textChoices] objectAtIndex:0] text], @"Choice One");
    XCTAssertEqual([[[answerFormat textChoices] objectAtIndex:1] text], @"Choice Two");
    XCTAssertEqual([answerFormat defaultIndex], 0);
    XCTAssertEqual([answerFormat isVertical], YES);
    
}

@end
