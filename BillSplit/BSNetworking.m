//
//  BSNetworking.m
//  BillSplit
//
//  Created by Yujin Ariza on 2/7/14.
//  Copyright (c) 2014 Yujin Ariza. All rights reserved.
//

#import "BSNetworking.h"

@interface BSNetworking()



@end

@implementation BSNetworking

-(id) init
{
    if (self = [super init]) {
        self.myPeerID = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
        self.session = [[MCSession alloc] initWithPeer:self.myPeerID];
        self.advertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:@"billsplit" discoveryInfo:nil session:self.self.session];
        self.myWallet = [NSMutableArray arrayWithObjects:@(0), @(0), @(0), @(0), nil];
        self.dataStack = [NSMutableArray array];
        
        self.wallets = [NSMutableDictionary dictionary];
        self.host = nil;
    }
    return self;
}

-(BOOL) sendData:(id) object
{
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:object];
    NSLog(@"Data = %@", data);
    NSError* error = nil;
    if (![self.session sendData:data toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:&error]) {
        NSLog(@"[Error] %@", error);
        return NO;
    }
    return YES;
}

+(BSNetworking*) sharedNetworking
{
    static BSNetworking* mySingleton = nil;
    @synchronized(self) {
        if (mySingleton == nil) {
            mySingleton = [[BSNetworking alloc] init];
        }
    }
    return mySingleton;
}

#pragma mark -
#pragma mark MCSessionDelegate
// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    //    [self.navigationController.navigationBar setNeedsDisplay];
}

// Received data from remote peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    //  Decode data back to NSString
    //    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //  append message to text box:
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dataStack enqueue:[NSDictionary dictionaryWithObjectsAndKeys:data, @"data", peerID, @"peer", nil]];
    });
}

// Received a byte stream from remote peer
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{
    
}

// Start receiving a resource from remote peer
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
    
}

// Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error{
    
}

@end
