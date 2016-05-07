//
//  TextFieldTableViewCell.m
//  TweetRain
//
//  Created by b123400 on 8/5/2016.
//
//

#import "TextFieldTableViewCell.h"

@implementation TextFieldTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(textFieldCellDidPressedEnter:)]) {
        [self.delegate textFieldCellDidPressedEnter:self];
    }
    return YES;
}

- (IBAction)textFieldDidChange:(UITextField*)sender {
    if ([self.delegate respondsToSelector:@selector(textFieldCell:textDidChanged:)]) {
        [self.delegate textFieldCell:self textDidChanged:sender.text];
    }
}

@end
