//
//  Formula.h
//  AppSavy
//
//  Created by Taj Ahmed on 16/01/16.
//  Copyright © 2016 MOBINEERS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Formula : NSObject

@property(strong, nonatomic) NSString* controlId;
@property(nonatomic) NSInteger formulaId;
@property(nonatomic) NSInteger formId;
@property(strong, nonatomic) NSString* formula;
@property(strong, nonatomic) NSString* type,*failAction,*failureMessage;

- (id)initWithDetailDictionary:(NSDictionary*)dictionary;
- (id)evaluate;

@end
