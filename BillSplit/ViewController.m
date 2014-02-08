//
//  ViewController.m
//  BillSplit
//
//  Created by Yujin Ariza on 2/2/14.
//  Copyright (c) 2014 Yujin Ariza. All rights reserved.
//

#import "ViewController.h"
#import "BillValueTableCell.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "BillSolver.h"
#import "BSNetworking.h"
#import "CollapsableTableView.h"

@interface ViewController ()<MCSessionDelegate, MCBrowserViewControllerDelegate>

@property (nonatomic, strong) MCBrowserViewController *browserVC;

@end

@implementation ViewController {
    NSMutableArray* peers;
    BillSolver* solver;
    BSNetworking* networking;
    NSString* displayName;
    NSMutableArray* myWallet;
}

- (IBAction)inviteButtonTapped:(id)sender {
    [self showBrowserVC];
}
- (IBAction)tap:(id)sender {
    [self.view endEditing:YES];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"goToOrderSegue"]) {
        for(int i=0; i<[networking.myWallet count]; i++) {
            NSIndexPath* path = [NSIndexPath indexPathForRow:i inSection:0];
            int num = [[[(BillValueTableCell*)[self.table cellForRowAtIndexPath:path] numField] text] intValue];
            [networking.myWallet replaceObjectAtIndex:i withObject:@(num)];
        }
        
        NSString* str = [NSString stringWithFormat:@"Wallet;%@;%@;%@;%@",
                         networking.myWallet[0],
                         networking.myWallet[1],
                         networking.myWallet[2],
                         networking.myWallet[3]];
        
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        if (![networking.session sendData:data
                                  toPeers:networking.session.connectedPeers
                                 withMode:MCSessionSendDataReliable
                                    error:&error]) {
            NSLog(@"[Error] %@", error);
        }

    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    peers = [NSMutableArray array];
    
    displayName = [UIDevice currentDevice].name;
    
    solver = [BillSolver sharedBillSolver];
    networking = [BSNetworking sharedNetworking];
    networking.session.delegate = self;
    [networking.advertiser start];
    
    NSLog(@"Num Peers = %lu", (unsigned long)[networking.session.connectedPeers count]);
    
//    [solver addPlayer:@"Wenlan" wallet:
//     [NSArray arrayWithObjects:@(4), @(5), @(1), @(3), nil]];
//    [solver addPlayer:@"Mick" wallet:
//     [NSArray arrayWithObjects:@(7), @(0), @(0), @(1), nil]];
//    [solver addPlayer:@"Jeff" wallet:
//     [NSArray arrayWithObjects:@(0), @(1), @(3), @(2), nil]];
//    
//    [solver addOrder:@"Wenlan" price:[[NSDecimalNumber alloc] initWithInt:5]];
//    [solver addOrder:@"Mick" price:[[NSDecimalNumber alloc] initWithInt:7]];
//    [solver addOrder:@"Jeff" price:[[NSDecimalNumber alloc] initWithInt:2]];
//    [solver addOrder:@"Shared" price:[[NSDecimalNumber alloc] initWithInt:9]];
    
//    [solver distribute];
    
    myWallet = [NSMutableArray arrayWithObjects:@(0), @(0), @(0), @(0), nil];
    
    self.browserVC = [[MCBrowserViewController alloc] initWithServiceType:@"billsplit" session:networking.session];
    self.browserVC.delegate = self;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


+ (NSString*) titleForHeaderForSection:(int) section
{
    switch (section)
    {
        case 0 : return @"My Wallet:";
        case 1 : return @"Peers:";
        default : return [NSString stringWithFormat:@"Section no. %i",section + 1];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [ViewController titleForHeaderForSection:(int)section];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: return [solver.billValues count];
        case 1: return [peers count]+1;
    }
    return peers.count;
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString* billIdentifier = @"bill";
    static NSString* peerIdentifier = @"peer";
    static NSString* inviteIdentifier = @"invite";
    
    if (indexPath.section == 0) {
        BillValueTableCell* cell = [tableView dequeueReusableCellWithIdentifier:billIdentifier];
        
        if (cell == nil) {
            cell = [[BillValueTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:billIdentifier];
        }
        
        cell.billValue.text = [NSString stringWithFormat:@"$%@", [solver.billValues objectAtIndex:indexPath.row]];
        
        return cell;
    }
    else if (indexPath.row == [peers count]) {
        
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:inviteIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:inviteIdentifier];
        }
        return cell;
    }
    else {
        
        
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:peerIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:peerIdentifier];
        }
        
        cell.textLabel.text = [peers objectAtIndex:indexPath.row];
        
        return cell;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark CollapsableTableViewDelegate

- (void) collapsableTableView:(CollapsableTableView*) tableView willCollapseSection:(NSInteger) section title:(NSString*) sectionTitle headerView:(UIView*) headerView
{
}

- (void) collapsableTableView:(CollapsableTableView*) tableView didCollapseSection:(NSInteger) section title:(NSString*) sectionTitle headerView:(UIView*) headerView
{
}

- (void) collapsableTableView:(CollapsableTableView*) tableView willExpandSection:(NSInteger) section title:(NSString*) sectionTitle headerView:(UIView*) headerView
{
}

- (void) collapsableTableView:(CollapsableTableView*) tableView didExpandSection:(NSInteger) section title:(NSString*) sectionTitle headerView:(UIView*) headerView
{
}

- (void) showBrowserVC{
    [self presentViewController:self.browserVC animated:YES completion:nil];
}

- (void) dismissBrowserVC{
    [self.browserVC dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark MCBrowserViewControllerDelegate

// Notifies the delegate, when the user taps the done button
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
    [self dismissBrowserVC];
}

// Notifies delegate that the user taps the cancel button.
- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    [self dismissBrowserVC];
}

#pragma mark -
#pragma mark MCSessionDelegate
// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    NSLog(@"Num Peers = %lu", (unsigned long)[session.connectedPeers count]);
    if ([session.connectedPeers count] > 0)
        self.navigationItem.rightBarButtonItem.enabled = YES;
    else
        self.navigationItem.rightBarButtonItem.enabled = NO;
    [peers removeAllObjects];
    for (MCPeerID* peer in session.connectedPeers) {
        [peers addObject:peer.displayName];
    }
    [self.table reloadData];
//    [self.navigationController.navigationBar setNeedsDisplay];
}

// Received data from remote peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    //  Decode data back to NSString
//    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //  append message to text box:
    dispatch_async(dispatch_get_main_queue(), ^{
        [networking.dataStack enqueue:[NSDictionary dictionaryWithObjectsAndKeys:data, @"data", peerID, @"peer", nil]];
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
