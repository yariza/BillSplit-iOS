//
//  BillSolver.h
//  BillSplit
//
//  Created by Yujin Ariza on 2/6/14.
//  Copyright (c) 2014 Yujin Ariza. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Transaction : NSObject<NSSecureCoding>

@property NSString* orig;
@property NSString* dest;
@property NSDecimalNumber* bill;
@property NSNumber* count;

@end

@interface Player : NSObject

@property NSString* name;
@property NSMutableArray* walletFinal;
@property NSArray* walletInitial;
@property NSDecimalNumber* charge;
@property NSDecimalNumber* target;

@end

@interface Order : NSObject

@property NSString* owner;
@property NSDecimalNumber* price;

@end

@interface BillSolver : NSObject
{
    NSArray* billValues;
    
    NSMutableArray* orders;
    
    NSMutableArray* players;
    NSMutableArray* heap;
}

@property NSDecimalNumber* tax;
@property NSDecimalNumber* tip;
@property NSMutableArray* transactions;

+(BillSolver*) sharedBillSolver;

-(void) addPlayer:(NSString*) myName wallet:(NSArray*) myWallet;
-(void) addOrder:(NSString*) owner price:(NSDecimalNumber*) price;

-(NSDecimalNumber*) walletTotal:(NSArray*) arr;
-(void) distribute;

@end
