//
//  TextFieldTableViewCell.h
//  TweetRain
//
//  Created by b123400 on 8/5/2016.
//
//

#import <UIKit/UIKit.h>

@protocol TextFieldTableViewCellDelegate <NSObject>

@optional
- (void)textFieldCell:(id)cell textDidChanged:(NSString*)text;
- (void)textFieldCellDidPressedEnter:(id)cell;

@end

@interface TextFieldTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (weak, nonatomic) id <TextFieldTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end
