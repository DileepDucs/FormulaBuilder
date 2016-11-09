//
//  Formula.m
//  AppSavy
//
//  Created by Taj Ahmed on 16/01/16.
//  Copyright © 2016 MOBINEERS. All rights reserved.
//

#import "Formula.h"
#import "ControlGridText.h"
#import "ExpresstionEvaluator.h"

@implementation Formula{
    NSMutableDictionary* functions;
}

- (id)initWithDetailDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        [self setControlId:dictionary[@"CONTROL_ID"]];
        [self setFormulaId:[dictionary[@"FORMULA_ID"] integerValue]];
        [self setFormId:[dictionary[@"FORM_ID"] integerValue]];
        [self setFormula:dictionary[@"FORMULA"]];
        [self setFailAction:dictionary[@"FAIL_ACTION"]];
        [self setFailureMessage:dictionary[@"FAILURE_MESSAGE"]];
        self.formula = [self.formula stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
        self.formula = [self.formula stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
        [self setType:dictionary[@"FORMULA_TYPE"]];
        functions = [[NSMutableDictionary alloc] init];
        [functions setObject:@"Multiplication" forKey:@"*"];
        [functions setObject:@"Division" forKey:@"/"];
        [functions setObject:@"Subtraction" forKey:@"-"];
        [functions setObject:@"Addition" forKey:@"+"];
        [functions setObject:@"Summation" forKey:@"S+"];
        [functions setObject:@"GreaterThanOrEqualsTo" forKey:@">="];
        [functions setObject:@"LessThanOrEqualsTo" forKey:@"<="];
    }
    return self;
}

- (id)evaluate{
    NSArray* formulas = [[self formula] componentsSeparatedByString:@" "];
    NSMutableDictionary* controlValues = [[NSMutableDictionary alloc] init];
    for (NSString* formulaToken in formulas) {
        if (![functions valueForKey:formulaToken]) {
            NSArray* controlIds = [formulaToken componentsSeparatedByString:@"."];
            NSString* controlId = [controlIds firstObject];
            if ([formulaToken hasPrefix:@"["]) {
                NSString* controlValue = [formulaToken stringByReplacingOccurrencesOfString:@"[" withString:@""];
                controlValue = [controlValue stringByReplacingOccurrencesOfString:@"]" withString:@""];
                [controlValues setValue:controlValue forKey:formulaToken];
            }else if ([formulaToken containsString:@"."]) {
                NSString* childControlId = [controlIds lastObject];
                ControlGridText* gridControl = (ControlGridText*)[IUVEventManager getViewControlForControlId:[controlId integerValue]];
                BOOL nextOperatorIsAggregation;
                @try {
                    nextOperatorIsAggregation = [[formulas objectAtIndex:[formulas indexOfObject:formulaToken]+1] isEqualToString:@"S+"];
                } @catch (NSException *exception) { }
                if (!nextOperatorIsAggregation) {
                    NSDictionary* currentGridInfo = [gridControl readCurrentGrid];
                    for (id gridInfo in currentGridInfo) {
                        if ([[gridInfo valueForKey:@"controlId"] isEqual:[controlIds objectAtIndex:1]]) {
                            id gridValue = [gridInfo valueForKey:@"value"];
                            if ([gridValue isEqualToString:@""]) gridValue = @(0);
                            [controlValues setObject:gridValue forKey:formulaToken];
                        }
                    }
                } else {
                    [controlValues setObject:[gridControl readValueForChildConrol:[childControlId integerValue]] forKey:formulaToken];
                }
            } else {
                Control* control = [IUVEventManager getViewControlForControlId:[controlId integerValue]];
                [controlValues setValue:[[control readValue] valueForKey:@"value"] forKey:formulaToken];
            }
        }
    }
    NSMutableArray* formulaWithValues = [formulas mutableCopy];
    for (NSString* formula in formulas) {
        if ([controlValues valueForKey:formula]) {
            if ([[controlValues valueForKey:formula] isKindOfClass:[NSArray class]]) {
                [formulaWithValues replaceObjectAtIndex:[formulaWithValues indexOfObject:formula]
                                             withObject:[(NSArray*)[controlValues valueForKey:formula] componentsJoinedByString:@":"]];
            } else {
                [formulaWithValues replaceObjectAtIndex:[formulaWithValues indexOfObject:formula] withObject:[controlValues valueForKey:formula]];
            }
        }
    }
    id result = [ExpresstionEvaluator evaluate:[formulaWithValues componentsJoinedByString:@" "] type:[self type]];
    return result;
}

@end
