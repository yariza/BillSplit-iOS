//
//  BillValueTableCell.m
//  BillSplit
//
//  Created by Yujin Ariza on 2/6/14.
//  Copyright (c) 2014 Yujin Ariza. All rights reserved.
//

#import "BillValueTableCell.h"

@implementation BillValueTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)numFieldChanged:(id)sender {
    if ([self.numField.text isEqualToString:@""])
        self.numField.text = @"0";
    self.stepper.value = [self.numField.text doubleValue];
}

- (IBAction)valueChanged:(id)sender {
    self.numField.text =
    [NSString stringWithFormat:@"%i", (int)self.stepper.value];
}



@end
