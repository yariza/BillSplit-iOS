//
//  AddOrderViewController.m
//  BillSplit
//
//  Created by Yujin Ariza on 2/7/14.
//  Copyright (c) 2014 Yujin Ariza. All rights reserved.
//

#import "AddOrderViewController.h"
#import "OrdersViewController.h"
#import "BSNetworking.h"

@interface AddOrderViewController()

@end

@implementation AddOrderViewController
{
    BSNetworking* networking;
    NSMutableArray* payers;
    NSString* owner;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSLog(@"HI");
    networking = [BSNetworking sharedNetworking];
    payers = [NSMutableArray array];
    [payers addObject:@"Me"];
    for (MCPeerID* peer in networking.session.connectedPeers) {
        [payers addObject:peer.displayName];
    }
    [payers addObject:@"Shared"];
    owner = networking.myPeerID.displayName;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark PickerView DataSource

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return [payers count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return payers[row];
}

#pragma mark -
#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    if ([payers[row] isEqualToString:@"Me"])
        owner = networking.myPeerID.displayName;
    else
        owner = payers[row];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"addOrderSegue"]) {
        //YAY let's add an order
        OrdersViewController* dest = segue.destinationViewController;
        NSLog(@"Adding order");
        NSDecimalNumber* pr = [[NSDecimalNumber alloc] initWithDouble:[self.price.text doubleValue]];
        [dest addOrder:self.name.text price:pr owner:owner];
    }
}

@end
