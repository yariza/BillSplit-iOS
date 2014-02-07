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

@property BillSolver* solver;

@end

@implementation ViewController {
    NSArray* peers;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    peers = [NSArray arrayWithObjects:@"Wenlan", @"Mick", nil];
    
    self.solver = [BillSolver sharedBillSolver];
    
    [self.solver addPlayer:@"Wenlan" wallet:
     [NSArray arrayWithObjects:@(4), @(5), @(1), @(3), nil]];
    [self.solver addPlayer:@"Mick" wallet:
     [NSArray arrayWithObjects:@(7), @(0), @(0), @(1), nil]];
    [self.solver addPlayer:@"Jeff" wallet:
     [NSArray arrayWithObjects:@(0), @(1), @(3), @(2), nil]];
    
    [self.solver addOrder:@"Wenlan" price:[[NSDecimalNumber alloc] initWithInt:5]];
    [self.solver addOrder:@"Mick" price:[[NSDecimalNumber alloc] initWithInt:7]];
    [self.solver addOrder:@"Jeff" price:[[NSDecimalNumber alloc] initWithInt:2]];
    [self.solver addOrder:@"Shared" price:[[NSDecimalNumber alloc] initWithInt:9]];
    
    [self.solver distribute];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return peers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* tableIdentifier = @"bill";
    
    BillValueTableCell* cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    
    if (cell == nil) {
        cell = [[BillValueTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
    }
    
//    cell.textLabel.text = [peers objectAtIndex:indexPath.row];
    cell.billValue.text = [peers objectAtIndex:indexPath.row];
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
