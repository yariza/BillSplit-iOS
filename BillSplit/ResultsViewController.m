//
//  ResultsViewController.m
//  BillSplit
//
//  Created by Yujin Ariza on 2/8/14.
//  Copyright (c) 2014 Yujin Ariza. All rights reserved.
//

#import "ResultsViewController.h"
#import "BillSolver.h"
#import "BSNetworking.h"

@interface ResultsViewController ()

@end

@implementation ResultsViewController
{
    NSMutableArray* sendTransactions;
    NSMutableArray* receiveTransactions;
    BillSolver* solver;
    BSNetworking* networking;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    sendTransactions = [NSMutableArray array];
    receiveTransactions = [NSMutableArray array];
    solver = [BillSolver sharedBillSolver];
    networking = [BSNetworking sharedNetworking];
    
    for (Transaction* trans in solver.transactions) {
        if ([trans.orig isEqualToString:networking.myPeerID.displayName])
            [sendTransactions addObject:trans];
        else if ([trans.dest isEqualToString:networking.myPeerID.displayName])
            [receiveTransactions addObject:trans];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        case 0 : return @"Send";
        case 1 : return @"Receive";
        case 2 : return @"Summary";
        default : return [NSString stringWithFormat:@"Section no. %i",section + 1];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [ResultsViewController titleForHeaderForSection:(int)section];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: return [sendTransactions count];
        case 1: return [receiveTransactions count];
        case 2: return 2;
        default:
            return 0;
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0) {
        Transaction* trans = [sendTransactions objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@", trans];
    }
    else if (indexPath.section == 1) {
        Transaction* trans = [receiveTransactions objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@", trans];
    }
    else {
        if (indexPath.row == 0)
            cell.textLabel.text = [NSString stringWithFormat:@"Total Bill: $%@", [[solver totalBill] stringValue]];
        else
            cell.textLabel.text = [NSString stringWithFormat:@"Your Contribution: $%@", [[solver getPlayerContribution:networking.myPeerID.displayName] stringValue]];
    }
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
