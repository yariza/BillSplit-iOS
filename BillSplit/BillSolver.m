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
            self.orig, [self.count intValue], [self.bill intValue], self.dest];
}

+(BOOL) supportsSecureCoding
{
    return YES;
}

-(id) initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (!self)
        return nil;
    
    self.orig = [decoder decodeObjectOfClass:[NSString class] forKey:@"orig"];
    self.dest = [decoder decodeObjectOfClass:[NSString class] forKey:@"dest"];
    self.bill = [decoder decodeObjectOfClass:[NSDecimalNumber class] forKey:@"bill"];
    self.count = [decoder decodeObjectOfClass:[NSNumber class] forKey:@"count"];
    
    return self;
}

-(void) encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.orig forKey:@"orig"];
    [encoder encodeObject:self.orig forKey:@"dest"];
    [encoder encodeObject:self.bill forKey:@"bill"];
    [encoder encodeObject:self.count forKey:@"count"];
}

@end

@implementation Player

-(NSString*) description
{
    return self.name;
}

@end

@implementation Order

-(NSString*) description
{
    return [NSString stringWithFormat:@"%@: %@ %@",
            self.name, self.owner, self.price ];
}

+(BOOL) supportsSecureCoding
{
    return YES;
}

-(id) initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (!self)
        return nil;
    
    self.name = [decoder decodeObjectOfClass:[NSString class] forKey:@"name"];
    self.owner = [decoder decodeObjectOfClass:[NSString class] forKey:@"owner"];
    self.price = [decoder decodeObjectOfClass:[NSDecimalNumber class] forKey:@"price"];
    return self;
}

-(void) encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.owner forKey:@"owner"];
    [encoder encodeObject:self.price forKey:@"price"];
}

@end

@implementation BillSolver

-(id) init
{
    if (self=[super init]) {
        
        self.billValues = [NSArray arrayWithObjects:
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
    //do all the messy calculations and output to each player's
    //walletFinal
    [self sendToHeap];
    [self receiveFromHeap];
    [self makeTransactions];
}

-(void) calculateCharge
{
    for(Player* player in players) {
        NSDecimalNumber* subtotal = [NSDecimalNumber zero];
        for (Order* order in orders) {
            NSDecimalNumber* price;
            if ([player.name isEqualToString:@"Tab"])
                continue;
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

-(void) sendToHeap
{
    //construct heap array
    heap = [NSMutableArray arrayWithCapacity:[self.billValues count]];
    for (int billIndex=0; billIndex<[self.billValues count]; billIndex++) {
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
    for (Player* p in players) {
        p.walletFinal = [NSMutableArray arrayWithCapacity:[self.billValues count]];
        for (NSDecimalNumber* d in self.billValues) {
            [p.walletFinal addObject:@(0)];
        }
        
        NSDecimalNumber* total = [self walletTotal:p.walletInitial];
        p.target = [total decimalNumberBySubtracting:p.charge];
        NSLog(@"%@ - wallet Total=%@, target=%@", p.name, total, p.target);
    }
    
    Player* receiver = [self playerWithMostDebt];
    NSDecimalNumber* debt = [self debtForPlayer:receiver];
    int billIndex = [self largestBillToSatisfyDebt:debt];
    
    while (billIndex != -1) {
        NSLog(@"Most Debt: %@ at %@; satisfied with %@", receiver, debt, [self.billValues objectAtIndex:billIndex]);
        
        NSMutableArray* wallet = receiver.walletFinal;
        [wallet replaceObjectAtIndex:billIndex withObject:@([[wallet objectAtIndex:billIndex] intValue]+1)];
        //receiver receives a bill
        
        [heap replaceObjectAtIndex:billIndex withObject:@([[heap objectAtIndex:billIndex] intValue]-1)];
        //heap sends a bill
        
        receiver = [self playerWithMostDebt];
        debt = [self debtForPlayer:receiver];
        billIndex = [self largestBillToSatisfyDebt:debt];
    }
    NSLog(@"Leftover debt: %@", debt);
    
    //moving leftovers to Tab
    Player* tab = (Player*)[players objectAtIndex:0];
    tab.walletFinal = [NSMutableArray arrayWithArray:heap];
    
    NSLog(@"Transaction finished!");
    for (Player* player in players) {
        NSLog(@"%@: %@", player.name, player.walletFinal);
    }
}

-(Player*) playerWithMostDebt
{
    Player* max = [players objectAtIndex:1];
    
    for (Player* player in players) {
        if ([player.name isEqualToString:@"Tab"])
            continue;
        if ([[self debtForPlayer:max] compare:[self debtForPlayer:player]] == NSOrderedAscending)
            max = player;
    }
    return max;
}

-(int) largestBillToSatisfyDebt:(NSDecimalNumber*)debt
{
    int index;
    
    for (index=(int)[self.billValues count]-1; index>=0; index--) {
        NSDecimalNumber* billValue = [self.billValues objectAtIndex:index];
        int count = [[heap objectAtIndex:index] intValue];
        NSComparisonResult comp = [billValue compare:debt];
        if (count && (comp == NSOrderedAscending || comp == NSOrderedSame)) {
            return index;
        }
    }
    return -1; //not found
}

-(NSDecimalNumber*) debtForPlayer:(Player*) player
{
    NSDecimalNumber* debt = [player.target decimalNumberBySubtracting:[self walletTotal:player.walletFinal]];
    return debt;
}

-(void) makeTransactions
{
    self.transactions = [NSMutableArray array];
    
    for (int billIndex=0; billIndex<[self.billValues count]; billIndex++) {
        NSDecimalNumber* bill = [self.billValues objectAtIndex:billIndex];
        
        //construct debt array for each bill
        int debts[[players count]];
        for (int pIndex=0; pIndex<[players count]; pIndex++) {
            Player* player = [players objectAtIndex:pIndex];
            int delta = [[player.walletFinal objectAtIndex:billIndex] intValue] - [[player.walletInitial objectAtIndex:billIndex] intValue];
            debts[pIndex] = delta;
        }
        
        int maxIndex = [self maxIndexIn:debts];
        while (debts[maxIndex] != 0) {
            int minIndex = [self minIndexIn:debts];
            int count = MIN(-debts[minIndex], debts[maxIndex]);
            Player* sender = [players objectAtIndex:minIndex];
            Player* receiver = [players objectAtIndex:maxIndex];
            
            Transaction* trans = [[Transaction alloc] init];
            trans.orig = sender.name;
            trans.dest = receiver.name;
            trans.bill = bill;
            trans.count = @(count);
            
            [self.transactions addObject:trans];
            NSLog(@"Trans: %@", trans);
            
            debts[minIndex] += count;
            debts[maxIndex] -= count;
        }
    }
    
}

-(int) maxIndexIn:(int[]) array
{
    int max = 0;
    for (int i=0; i<[players count]; i++) {
        if (array[max] < array[i]) {
            max = i;
        }
    }
    return max;
}

-(int) minIndexIn:(int[]) array
{
    int min = 0;
    for (int i=0; i<[players count]; i++) {
        if (array[min] > array[i]) {
            min = i;
        }
    }
    return min;
}

-(Player*) findPlayerByName:(NSString*)name
{
    for (Player* player in players) {
        if ([player.name isEqualToString:name])
            return player;
    }
    return [players objectAtIndex:0];
}

-(NSDecimalNumber*) walletTotal:(NSArray*) arr
{
    //Assumes Array is full of NSNumbers
    NSDecimalNumber* sum = [NSDecimalNumber zero];
    for (int i=0; i<self.billValues.count; i++) {
        NSDecimalNumber* bill = [self.billValues objectAtIndex:i];
        NSDecimalNumber* count = [[NSDecimalNumber alloc] initWithInteger:[[arr objectAtIndex:i] integerValue]];
        NSDecimalNumber* delta = [bill decimalNumberByMultiplyingBy:count];
        sum = [sum decimalNumberByAdding:delta];
    }
    return sum;
}



@end
