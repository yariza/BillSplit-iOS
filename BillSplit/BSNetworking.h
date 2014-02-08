//
//  BSNetworking.h
//  BillSplit
//
//  Created by Yujin Ariza on 2/7/14.
//  Copyright (c) 2014 Yujin Ariza. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "NSMutableArray+QueueAdditions.h"

@interface BSNetworking : NSObject<MCSessionDelegate>

@property (nonatomic, strong) MCAdvertiserAssistant* advertiser;
@property (nonatomic, strong) MCSession* session;
@property (nonatomic, strong) MCPeerID* myPeerID;
@property NSMutableArray* myWallet;

@property NSMutableArray* dataStack;

@property NSMutableDictionary* wallets;

@property MCPeerID* host;

+(BSNetworking*) sharedNetworking;
-(BOOL) sendData:(id) object;

@end
