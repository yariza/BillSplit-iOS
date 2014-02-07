//
//  BillSolver.m
//  BillSplit
//
//  Created by Yujin Ariza on 2/6/14.
//  Copyright (c) 2014 Yujin Ariza. All rights reserved.
//

#import "BillSolver.h"

@implementation Transaction

-(NSString*) description
{
    return [NSString stringWithFormat:@"%@ %i x $%i => %@",
            self.orig, self.count, [self.bill intValue], self.dest];
}

@end

@implementation Player


@end

@implementation Order


@end

@implementation BillSolver

-(id) init
{
    if (self=[super init]) {
        
        billValues = [NSArray arrayWithObjects:
                        [NSDecimalNumber decimalNumberWithMantissa:100 exponent:-2 isNegative:NO],
                        [NSDecimalNumber decimalNumberWithMantissa:500 exponent:-2 isNegative:NO],
                        [NSDecimalNumber decimalNumberWithMantissa:1000 exponent:-2 isNegative:NO],
                        [NSDecimalNumber decimalNumberWithMantissa:2000 exponent:-2 isNegative:NO], nil];
        self.tax = [NSDecimalNumber decimalNumberWithMantissa:8875 exponent:-5 isNegative:NO];
        self.tip = [NSDecimalNumber decimalNumberWithMantissa:15 exponent:-2 isNegative:NO];
        
        players = [NSMutableArray arrayWithCapacity:8];
        [self addPlayer:@"Tab" wallet:
         [NSArray arrayWithObjects:@(0), @(0), @(0), @(0), nil]];
        //add empty "tab" player as 0th player element!
        orders = [NSMutableArray array];
    }
    return self;
}

+(BillSolver*) sharedBillSolver
{
    static BillSolver* mySingleton = nil;
    @synchronized(self) {
        if (mySingleton == nil) {
            mySingleton = [[BillSolver alloc] init];
        }
    }
    return mySingleton;
}

-(void) addPlayer:(NSString*) myName wallet:(NSArray*) myWallet
{
    Player* pl = [[Player alloc] init];
    pl.name = myName;
    pl.walletInitial = myWallet;
    [players addObject:pl];
    NSLog(@"Added player %@ with wallet %@", pl.name, pl.walletInitial);
}

-(void) addOrder:(NSString*) owner price:(NSDecimalNumber*) price
{
    Order* order = [[Order alloc] init];
    order.owner = owner;
    order.price = price;
    [orders addObject:order];
}

-(void) distribute
{
    [self calculateCharge];
    [self build];
    //do all the messy calculations and output to each player's
    //walletFinal
    [self sendToHeap];
    [self receiveFromHeap];
}

-(void) calculateCharge
{
    for(Player* player in players) {
        if ([player.name isEqualToString:@"Tab"])
            continue;
        NSDecimalNumber* subtotal = [NSDecimalNumber zero];
        for (Order* order in orders) {
            NSDecimalNumber* price;
            if ([player.name isEqualToString:order.owner])
                price = order.price;
            else if ([order.owner isEqualToString:@"Shared"])
            {
                NSDecimalNumber* numHumans = [[NSDecimalNumber alloc] initWithInt:(int)[players count]-1];
                //tab is not a human
                
                price = [order.price decimalNumberByDividingBy:numHumans]; //roundoff needed later
            }
            else
                price = [NSDecimalNumber zero];
            subtotal = [subtotal decimalNumberByAdding:price];
        }
        
        NSDecimalNumber* playerTax = [subtotal decimalNumberByMultiplyingBy:self.tax];
        NSDecimalNumber* playerTip = [subtotal decimalNumberByMultiplyingBy:self.tip];
        
        player.charge = [subtotal decimalNumberByAdding:playerTax];
        player.charge = [player.charge decimalNumberByAdding:playerTip];
        
        player.charge = [self roundDecimal:player.charge forCurrency:@"USD"];
        //Yay Rounding!
        
        NSLog(@"%@ - subtotal=%@, tax=%@, tip=%@, total=%@", player.name, subtotal, playerTax, playerTip, player.charge);
    }
}

-(NSDecimalNumber*) roundDecimal:(NSDecimalNumber*) number
                     forCurrency:(NSString*)currencyCode
{
    int32_t precision;
    double rounding;
    CFNumberFormatterGetDecimalInfoForCurrencyCode((__bridge CFStringRef)currencyCode, &precision, &rounding);
    NSDecimalNumberHandler *roundDown = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown
                                                                                               scale:precision
                                                                                    raiseOnExactness:NO
                                                                                     raiseOnOverflow:NO
                                                                                    raiseOnUnderflow:NO
                                                                                 raiseOnDivideByZero:NO];
    return [number decimalNumberByRoundingAccordingToBehavior:roundDown];
}

- (NSDictionary *)divideEvenlyWithRemainder:(NSDecimalNumber *)numerator
                                         by:(NSDecimalNumber *)denominator
                                forCurrency:(NSString *)currencyCode {
    int32_t precision;
    double rounding;
    CFNumberFormatterGetDecimalInfoForCurrencyCode((__bridge CFStringRef)currencyCode, &precision, &rounding);
    NSDecimalNumberHandler *roundDown = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown
                                                                                               scale:precision
                                                                                    raiseOnExactness:NO
                                                                                     raiseOnOverflow:NO
                                                                                    raiseOnUnderflow:NO
                                                                                 raiseOnDivideByZero:NO];
    
    NSDecimalNumber *roundDecimal = nil;
    NSDecimalNumber *result = nil;
    //If we have rounding, we need to convert to a count of the smallest physical currency
    if (rounding > 0) {
        //As far as I am aware, the smallest rounding is 0.005, added one more sig fig for safety
        roundDecimal = [NSDecimalNumber decimalNumberWithMantissa:rounding * 10000
                                                         exponent:-4
                                                       isNegative:NO];
        //Because we are now working with whole units, we set scale to 0
        roundDown = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown
                                                                           scale:0
                                                                raiseOnExactness:NO
                                                                 raiseOnOverflow:NO
                                                                raiseOnUnderflow:NO
                                                             raiseOnDivideByZero:NO];
        
        //this will give us a count of the smallest available physical currency for countries with
        //coins that are larger or smaller than a "penny"
        result = [numerator decimalNumberByDividingBy:roundDecimal withBehavior:roundDown];
        result = [result decimalNumberByDividingBy:denominator
                                      withBehavior:roundDown];
        //Convert back to currency value instead of count
        result = [result decimalNumberByMultiplyingBy:roundDecimal];
    } else {
        result = [numerator decimalNumberByDividingBy:denominator
                                         withBehavior:roundDown];
    }
    
    //Have to use original here in case the user decides to put in units smaller than all4owed for some reason
    NSDecimalNumber *remainder = [numerator decimalNumberBySubtracting:[result decimalNumberByMultiplyingBy:denominator]];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            result, @"amount",
            remainder, @"remainder",
            nil];
    
}

-(void) build
{


}

-(void) sendToHeap
{
    //construct heap array
    heap = [NSMutableArray arrayWithCapacity:[billValues count]];
    for (int billIndex=0; billIndex<[billValues count]; billIndex++) {
        int total = 0;
        for (Player* p in players) {
            total += [[p.walletInitial objectAtIndex:billIndex] intValue];
        }
        [heap addObject:@(total)];
    }
    NSLog(@"collected heap: %@", heap);
}

-(void) receiveFromHeap
{
    //construct walletFinal objects for all players
    //construct targets
    targets = [NSMutableArray arrayWithCapacity:[players count]];
    for (Player* p in players) {
        p.walletFinal = [NSMutableArray arrayWithCapacity:[billValues count]];
        for (NSDecimalNumber* d in billValues) {
            [p.walletFinal addObject:@(0)];
        }
        
        NSDecimalNumber* target = [[self walletTotal:p.walletInitial] decimalNumberBySubtracting:p.charge];
        [targets addObject:target];
    }
    
    
}


-(NSArray*) transactionsForPlayer:(NSString*) name
{
    //return an NSArray of Transactions for name
    return nil;
}

-(NSDecimalNumber*) walletTotal:(NSArray*) arr
{
    //Assumes Array is full of NSNumbers
    NSDecimalNumber* sum = [NSDecimalNumber zero];
    for (int i=0; i<billValues.count; i++) {
        NSDecimalNumber* bill = [billValues objectAtIndex:i];
        NSDecimalNumber* count = [[NSDecimalNumber alloc] initWithInteger:[[arr objectAtIndex:i] integerValue]];
        NSDecimalNumber* delta = [bill decimalNumberByMultiplyingBy:count];
        sum = [sum decimalNumberByAdding:delta];
    }
    return sum;
}



@end
