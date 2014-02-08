//
//  OrdersViewController.m
//  BillSplit
//
//  Created by Yujin Ariza on 2/6/14.
//  Copyright (c) 2014 Yujin Ariza. All rights reserved.
//

#import "OrdersViewController.h"
#import "BillValueTableCell.h"
#import "OrderTableCell.h"
#import "TaxTipTableCell.h"
#import "BSNetworking.h"
#import "BillSolver.h"
#import "AddOrderViewController.h"
#import "CollapsableTableView.h"
#import "ResultsViewController.h"


@interface OrdersViewController ()<MCSessionDelegate>

@end

@implementation OrdersViewController
{
    BSNetworking* networking;
    BillSolver* solver;
    NSMutableArray* orders;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    solver = [BillSolver sharedBillSolver];
    networking = [BSNetworking sharedNetworking];
    [networking.advertiser stop];
    networking.session.delegate = self;
    orders = [NSMutableArray array];
    
    while ([networking.dataStack count] != 0) {
        NSDictionary* dict = [networking.dataStack dequeue];
        NSData* data = [dict objectForKey:@"data"];
        MCPeerID* peer = [dict objectForKey:@"peer"];
        [self session:networking.session didReceiveData:data fromPeer:peer];
    }
    
    [self.table setIsCollapsed:YES forHeaderWithTitle:@"My Wallet:"];

}

#pragma mark - 
#pragma mark UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

+ (NSString*) titleForHeaderForSection:(int) section
{
    switch (section)
    {
        case 0 : return @"My Wallet:";
        case 1 : return @"Orders:";
        case 2 : return @"Settings:";
        default : return [NSString stringWithFormat:@"Section no. %i",section + 1];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [OrdersViewController titleForHeaderForSection:(int)section];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: return [solver.billValues count];
        case 1: return [orders count];
        case 2: return 3;
        default:
            return 0;
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
        return YES;
    else
        return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* billIdentifier = @"bill";
    static NSString* orderIdentifier = @"order";
    static NSString* taxTipIdentifier = @"taxtip";
    static NSString* doneIdentifier = @"done";
    
    if (indexPath.section == 0) {
        BillValueTableCell* cell = [tableView dequeueReusableCellWithIdentifier:billIdentifier];
        
        if (cell == nil) {
            cell = [[BillValueTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:billIdentifier];
        }
        //    cell.textLabel.text = [peers objectAtIndex:indexPath.row];
        cell.billValue.text = [NSString stringWithFormat:@"$%i", (int)indexPath.row];
        NSNumber* num = [[BSNetworking sharedNetworking].myWallet objectAtIndex:indexPath.row];
        cell.numField.text = [num stringValue];
        cell.stepper.value = [num doubleValue];
        return cell;
    }
    else if (indexPath.section == 1) {
        OrderTableCell* cell = [tableView dequeueReusableCellWithIdentifier:orderIdentifier];
        if (cell == nil) {
            cell = [[OrderTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:orderIdentifier];
        }
        Order* order = [orders objectAtIndex:indexPath.row];
        cell.name.text = order.name;
        cell.owner.text = order.owner;
        cell.price.text = [NSString stringWithFormat:@"$%@", order.price];
        return cell;
    } //or else, section == 2
    else if (indexPath.row == 2) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:doneIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:doneIdentifier];
        }
        return cell;
    }
    else {
        TaxTipTableCell* cell = [tableView dequeueReusableCellWithIdentifier:taxTipIdentifier];
        if (cell == nil) {
            cell = [[TaxTipTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:taxTipIdentifier];
        }
        if (indexPath.row == 0)  {
            //tax
            NSDecimalNumber* taxRaw = solver.tax;
            NSDecimalNumber* taxDisplay = [taxRaw decimalNumberByMultiplyingByPowerOf10:2];
            cell.label.text = @"Tax:";
            cell.numField.text = [taxDisplay stringValue];
        }
        else {
            //tip
            NSDecimalNumber* tipRaw = solver.tip;
            NSDecimalNumber* tipDisplay = [tipRaw decimalNumberByMultiplyingByPowerOf10:2];
            cell.label.text = @"Tip:";
            cell.numField.text = [tipDisplay stringValue];
        }
        return cell;
    }
    
    
    BillValueTableCell* cell = [tableView dequeueReusableCellWithIdentifier:billIdentifier];
    
    if (cell == nil) {
        cell = [[BillValueTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:billIdentifier];
    }
    //    cell.textLabel.text = [peers objectAtIndex:indexPath.row];
    cell.billValue.text = [NSString stringWithFormat:@"$%i", (int)indexPath.row];
    return cell;
}

-(void) addOrder:(NSString*)name price:(NSDecimalNumber*)price owner:(NSString*)ownerID
{
    NSLog(@"Adding order %@ $%@ by %@", name, [price stringValue], ownerID);
    
    Order* order = [[Order alloc] init];
    order.name = name;
    order.price = price;
    order.owner = ownerID;
    
    [orders addObject:order];
    [self.table reloadData];
    
//    [networking sendData:order];
    
    NSString* str = [NSString stringWithFormat:@"Order;%@;%@;%@", order.name, [order.price stringValue], order.owner];
    
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    if (![networking.session sendData:data
                        toPeers:networking.session.connectedPeers
                       withMode:MCSessionSendDataReliable
                          error:&error]) {
        NSLog(@"[Error] %@", error);
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) unwindToOrders:(UIStoryboardSegue*)unwindSegue
{
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"goToResultsSegue"]) {
//        ResultsViewController* dest = [segue destinationViewController];
        //todo: say i'm host if there isn't a host yet
        [solver addPlayer:networking.myPeerID.displayName wallet:networking.myWallet];
        for (MCPeerID* peer in networking.session.connectedPeers) {
            [solver addPlayer:peer.displayName wallet:[networking.wallets objectForKey:peer.displayName]];
        }
        
        for (Order* order in orders) {
            [solver addOrder:order.owner price:order.price];
        }
        [solver distribute];
    }
}

#pragma mark -
#pragma mark MCSessionDelegate
// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{

}

// Received data from remote peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    //  Decode data back to NSString
    //    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
//    NSLog(@"Data = %@", data);
//    NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
//    unarchiver.requiresSecureCoding = YES;
//    id object = [unarchiver decodeObject];
//    [unarchiver finishDecoding];
//    NSLog(@"%@", (Order*)object);
    
    NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSArray* args = [str componentsSeparatedByString:@";"];
    if ([args[0] isEqualToString:@"Order"]) {
        Order* order = [[Order alloc] init];
        order.name = args[1];
        order.price = [NSDecimalNumber decimalNumberWithString:args[2]];
        order.owner = args[3];
        
        [orders addObject:order];
        [self.table reloadData];
    }
    else if ([args[0] isEqualToString:@"Wallet"]) {
        NSArray* wallet = [NSArray arrayWithObjects:
                           @([args[1] intValue]),
                           @([args[2] intValue]),
                           @([args[3] intValue]),
                           @([args[4] intValue]), nil];
        [networking.wallets setObject:wallet forKey:peerID.displayName];
        NSLog(@"%@'s wallet: %@", peerID.displayName, [networking.wallets objectForKey:peerID.displayName]);
    }
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
