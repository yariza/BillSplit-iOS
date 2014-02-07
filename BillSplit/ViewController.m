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


@interface ViewController ()

@end

@implementation ViewController {
    NSMutableArray* peers;
    BillSolver* solver;
    NSString* displayName;
    NSMutableArray* myWallet;
}

- (IBAction)inviteButtonTapped:(id)sender {
    NSLog(@"Invite!");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    peers = [NSMutableArray arrayWithObjects:@"Wenlan", @"Mick", nil];
    
    displayName = [UIDevice currentDevice].name;
    
    solver = [BillSolver sharedBillSolver];
    
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

@end
