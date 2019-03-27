/*
 Copyright (c) 2019, Apple Inc. All rights reserved.
 
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


#import "ORKStepContainerView.h"
#import "ORKTitleLabel.h"


@implementation ORKStepContainerView {
    
    UIView *_scrollableContainerView;
    UIView *_staticContainerView;
    
    ORKTitleLabel *_titleLabel;
    UIImageView *_topContentImageView;
    
//    variable constraints:
    NSLayoutConstraint *_scrollableContainerTopConstraint;
    NSArray<NSLayoutConstraint *> *_topContentImageViewConstraints;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupScrollableContainerView];
        [self setupConstraints];
    }
    return self;
}

- (void)setStepTopContentImage:(UIImage *)stepTopContentImage {
    
    _stepTopContentImage = stepTopContentImage;
    
    //    1.) nil Image; updateConstraints
    if (!stepTopContentImage && _topContentImageView) {
        [_topContentImageView removeFromSuperview];
        _topContentImageView = nil;
        [self deactivateTopContentImageViewConstraints];
        [self updateScrollableContainerTopConstraint];
        [self setNeedsUpdateConstraints];
    }
    
    //    2.) First Image; updateConstraints
    if (stepTopContentImage && !_topContentImageView) {
        [self setupTopContentImageView];
        _topContentImageView.image = stepTopContentImage;
        [self updateScrollableContainerTopConstraint];
        [self setNeedsUpdateConstraints];
    }
    
    //    3.) >= second Image;
    if (stepTopContentImage && _topContentImageView) {
        _topContentImageView.image = stepTopContentImage;
    }
}

- (void)setupScrollableContainerView {
    if (!_scrollableContainerView) {
        _scrollableContainerView = [[UIScrollView alloc] init];
    }
    [_scrollableContainerView setBackgroundColor:UIColor.greenColor];
    [self addSubview:_scrollableContainerView];
}

- (void)setupTopContentImageView {
    if (!_topContentImageView) {
        _topContentImageView = [UIImageView new];
    }
    [self addSubview:_topContentImageView];
    [self setTopContentImageViewConstraints];
}

- (NSArray<NSLayoutConstraint *> *)scrollableContainerStaticConstraints {
    return @[
             [NSLayoutConstraint constraintWithItem:_scrollableContainerView
                                          attribute:NSLayoutAttributeLeft
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:self
                                          attribute:NSLayoutAttributeLeft
                                         multiplier:1.0
                                           constant:0.0],
             [NSLayoutConstraint constraintWithItem:_scrollableContainerView
                                          attribute:NSLayoutAttributeRight
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:self
                                          attribute:NSLayoutAttributeRight
                                         multiplier:1.0
                                           constant:0.0],
             [NSLayoutConstraint constraintWithItem:_scrollableContainerView
                                          attribute:NSLayoutAttributeCenterX
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:self
                                          attribute:NSLayoutAttributeCenterX
                                         multiplier:1.0
                                           constant:0.0],
             [NSLayoutConstraint constraintWithItem:_scrollableContainerView
                                          attribute:NSLayoutAttributeHeight
                                          relatedBy:NSLayoutRelationGreaterThanOrEqual
                                             toItem:self
                                          attribute:NSLayoutAttributeHeight
                                         multiplier:1.0
                                           constant:0.0]
             ];
}

- (void)setScrollableContainerTopConstraint {
    _scrollableContainerTopConstraint = [NSLayoutConstraint constraintWithItem:_scrollableContainerView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_topContentImageView ? : self
                                                                     attribute:_topContentImageView ? NSLayoutAttributeBottom : NSLayoutAttributeTop
                                                                    multiplier:1.0
                                                                      constant:0.0];
}

- (void)updateScrollableContainerTopConstraint {
    if (_scrollableContainerTopConstraint) {
        [NSLayoutConstraint deactivateConstraints:@[_scrollableContainerTopConstraint]];
    }
    [self setScrollableContainerTopConstraint];
}

- (void)setTopContentImageViewConstraints {
    _topContentImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _topContentImageViewConstraints = @[
                                        [NSLayoutConstraint constraintWithItem:_topContentImageView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0
                                                                      constant:0.0],
                                        [NSLayoutConstraint constraintWithItem:_topContentImageView
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1.0
                                                                      constant:0.0],
                                        [NSLayoutConstraint constraintWithItem:_topContentImageView
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1.0
                                                                      constant:0.0],
                                        [NSLayoutConstraint constraintWithItem:_topContentImageView
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1.0
                                                                      constant:200.0]
                                        ];
}

- (void)deactivateTopContentImageViewConstraints {
    if (_topContentImageViewConstraints) {
        [NSLayoutConstraint deactivateConstraints:_topContentImageViewConstraints];
    }
    _topContentImageViewConstraints = nil;
}

- (void)setupConstraints {
    _scrollableContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self setScrollableContainerTopConstraint];
    NSMutableArray<NSLayoutConstraint *> *scrollableContainerConstraints = [[NSMutableArray alloc] initWithArray:[self scrollableContainerStaticConstraints]];
    [scrollableContainerConstraints addObject:_scrollableContainerTopConstraint];
    [NSLayoutConstraint activateConstraints:scrollableContainerConstraints];
}

- (void)updateContainerConstraints {
    NSMutableArray<NSLayoutConstraint *> *updatedConstraints = [[NSMutableArray alloc] init];
    if (_topContentImageViewConstraints) {
        [updatedConstraints addObjectsFromArray:_topContentImageViewConstraints];
    }
    [updatedConstraints addObject:_scrollableContainerTopConstraint];
    [NSLayoutConstraint activateConstraints:updatedConstraints];
}

- (void)updateConstraints {
    [self updateContainerConstraints];
    [super updateConstraints];
}

@end
