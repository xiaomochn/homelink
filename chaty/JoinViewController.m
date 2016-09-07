//
//  JoinViewController.m
//  ChatDemo-UI3.0
//
//  Created by xiaomo on 16/1/28.
//  Copyright © 2016年 xiaomo. All rights reserved.
//

#import "JoinViewController.h"

#import "EMSearchBar.h"
#import "SRRefreshView.h"
#import "EMSearchDisplayController.h"
#import "PublicGroupDetailViewController.h"
#import "RealtimeSearchUtil.h"
#import "EMCursorResult.h"
#import "BaseTableViewCell.h"
#import "ChatViewController.h"

#import "ContactSelectionViewController.h"
#import "EMTextView.h"
#import "EMGroupOptions.h"
#import "ContactSelectionViewController.h"
#import "GroupSettingViewController.h"
#import "EMGroup.h"
#import "ContactView.h"
#import "GroupBansViewController.h"
#import "GroupSubjectChangingViewController.h"
#import "ChatGroupDetailViewController.h"
#import "PublicGroupListViewController.h"
@interface JoinViewController ()<UITextFieldDelegate>
@property (nonatomic, strong) NSString *cursor;
@property (weak, nonatomic) IBOutlet UITextField *groupName;
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (strong, nonatomic) EMGroup *chatGroup;


@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIButton *addButton;

@property (strong, nonatomic) UIView *footerView;
@property (strong, nonatomic) UIButton *clearButton;
@property (strong, nonatomic) UIButton *exitButton;
@property (strong, nonatomic) UIButton *dissolveButton;
@property (strong, nonatomic) UIButton *configureButton;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPress;
@end

@implementation JoinViewController
- (IBAction)onEdit:(id)sender {
    [self.groupName resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.groupName.delegate=self;
    UITapGestureRecognizer *gestureRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)   ];
    gestureRecognizer.cancelsTouchesInView=NO;
    [self.view addGestureRecognizer:gestureRecognizer];
}
-(void)viewTapped{
    [_groupName resignFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) createGroup{
      __weak JoinViewController *weakSelf = self;
     EMGroupOptions *setting = [[EMGroupOptions alloc] init];
    setting.maxUsersCount = 2000;
     setting.style = EMGroupStylePublicOpenJoin;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMdd"];
    NSString* dateStr =[dateFormat stringFromDate:self.datePicker.date];
    NSString *groupN=[NSString stringWithFormat:@"%@%@",dateStr, self.groupName.text];
    
//    [[EaseMob sharedInstance].chatManager asyncCreateGroupWithSubject:groupN description:@"没描述" invitees:nil initialWelcomeMessage:@"欢迎" styleSetting:setting completion:^(EMGroup *group, EMError *error) {
//        
//        if (group && !error) {
//            [weakSelf showHint:@"加入群组成功"];
//            [weakSelf.navigationController popViewControllerAnimated:YES];
//            [self jumpToGroup:group.groupId];
//        }
//        else{
//            [weakSelf showHint:@"加入群组失败"];
//        }
//    } onQueue:nil];
    
    
    {
    
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            EMError *error = nil;
            EMGroup *group = [[EMClient sharedClient].groupManager createGroupWithSubject:groupN description:@"没描述" invitees:nil message:@"欢迎" setting:setting error:&error];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf hideHud];
                if (group && !error) {
//                    [weakSelf showHint:NSLocalizedString(@"group.create.success", @"create group success")];
                    [self jumpToGroup:groupN ];
                }
                else{
                    [weakSelf hideHud];
                    [weakSelf showHint:NSLocalizedString(@"group.create.fail", @"Failed to create a group, please operate again")];
                }
            });
        });
    }
}

- (void)jumpToGroup:(NSString *)groupId
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMdd"];
    NSString* dateStr =[dateFormat stringFromDate:self.datePicker.date];
    NSString *groupN=[NSString stringWithFormat:@"%@%@",dateStr, self.groupName.text];
   
    ChatViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:groupId
                                                                                conversationType:EMConversationTypeGroupChat];
    chatController.title = groupN;
    [self.navigationController pushViewController:chatController animated:YES];
}
- (void)joinGroup:(NSString *)groupId
{
    [self showHudInView:self.view hint:NSLocalizedString(@"group.join.ongoing", @"join the group...")];
    __weak PublicGroupDetailViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = nil;
        [[EMClient sharedClient].groupManager joinPublicGroup:groupId error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
              [weakSelf hideHud];
            if(!error) {
              
                [self jumpToGroup:groupId];
            } else {
                [weakSelf showHint:NSLocalizedString(@"group.join.fail", @"again failed to join the group, please")];
            }
        });
    });
}
#define FetchPublicGroupsPageSize   500

- (void)reloadDataSource
{
    [self hideHud];
    [self showHudInView:self.view hint:NSLocalizedString(@"loadData", @"Load data...")];
    _cursor = nil;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = nil;
        EMCursorResult *result = [[EMClient sharedClient].groupManager getPublicGroupsFromServerWithCursor:weakSelf.cursor pageSize:FetchPublicGroupsPageSize error:&error];
        if (weakSelf)
        {
            JoinViewController *strongSelf = weakSelf;
            [strongSelf hideHud];
            if (!error)
            {
                
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"MMdd"];
                NSString* dateStr =[dateFormat stringFromDate:self.datePicker.date];
                NSString *groupN=[NSString stringWithFormat:@"%@%@",dateStr, self.groupName.text];
                
                for (EMGroup *g in result.list) {
                    
                    if ([g.subject isEqualToString:groupN]) {
                        [self joinGroup:g.groupId];
                        return ;
                    }
                }
                [self createGroup];
                
            }
            else
            {
            }
        }
//        if (weakSelf)
//        {
//            PublicGroupListViewController *strongSelf = weakSelf;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [strongSelf hideHud];
//                
//                if (!error)
//                {
//                    NSMutableArray *oldGroups = [self.dataSource mutableCopy];
//                    [self.dataSource removeAllObjects];
//                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                        [oldGroups removeAllObjects];
//                    });
//                    [strongSelf.dataSource addObjectsFromArray:result.list];
//                    [strongSelf.tableView reloadData];
//                    strongSelf.cursor = result.cursor;
//                    if ([result.cursor length])
//                    {
//                        self.footerView.state = eGettingMoreFooterViewStateIdle;
//                    }
//                    else
//                    {
//                        self.footerView.state = eGettingMoreFooterViewStateComplete;
//                    }
//                }
//                else
//                {
//                    self.footerView.state = eGettingMoreFooterViewStateFailed;
//                }
//            });
//        }
    });
}
- (IBAction)linkBle:(id)sender {
   UIViewController *vc= [[UIStoryboard storyboardWithName:@"bluetooth" bundle:nil] instantiateViewControllerWithIdentifier:@"ScansTableViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onJoin:(id)sender {
    if (![self isEmpty]){
    [self reloadDataSource];
    }
    
}
- (BOOL)isEmpty{
    BOOL ret = NO;
    NSString *username = self.groupName.text;
    if (username.length == 0 ) {
        ret = YES;
        [EMAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt")
                                message:@"请输入车次"
                        completionBlock:nil
                      cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                      otherButtonTitles:nil];
    }
    
    return ret;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}
@end
