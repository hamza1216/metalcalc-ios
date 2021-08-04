//
//  MCClientEditViewController.m
//  ScrapCalc
//
//  Created by Diana on 06.08.13.
//
//

#import "MCClientEditViewController_iPad.h"
#import "Client.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "MCPurchaseListViewController_iPad.h"
#import "MCPurchaseDetailsViewController_iPad.h"

@interface MCClientEditViewController_iPad ()
{
    UITextField *currentTextField_;
    BOOL keyboardIsShown;
    UIPopoverController *popover_;
}
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIButton *associateButton;
@property (nonatomic, strong) IBOutlet UILabel *associateLabel;

-(IBAction)cancelAction:(id)sender;
- (IBAction)saveClient:(id)sender;

@end

@implementation MCClientEditViewController_iPad

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.client = [[Client new] autorelease];
        [self setupForClient];
        // Custom initialization
    }
    return self;
}

#pragma mark - view life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    purchases_ = [NSMutableArray new];

}

-(void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setLeftToolBarButtonHidden:YES];
    [self setupForClient];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - actions

-(IBAction)cancelAction:(id)sender
{
    [[self delegate] didCancel];
    [[self navigationViewController] popViewControllerAnimated:YES];
}

- (IBAction)choosePhoto:(id)sender
{
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    imgPicker.delegate = self;
    //[self presentModalViewController:imgPicker animated:YES];
    
    CGFloat width = 320, height = 620;
    CGRect frame = CGRectMake(-50, 380, width, height);
    
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imgPicker];
    
    [popover presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    self.contentSizeForViewInPopover = frame.size;
    
    popover_ = popover;
    [imgPicker release];
}

- (IBAction)associatePurchase:(id)sender
{
    MCPurchaseListViewController_iPad *vc = [MCPurchaseListViewController_iPad new];
    vc.associateClient = self.client;
    [self.navigationViewController pushViewController:vc animated:YES];
    [vc release];
}

- (void)saveClient:(id)sender
{
    NSString *firstname = [self textFieldForTag:ClientButtonTagFirstname].text;
    NSString *lastname = [self textFieldForTag:ClientButtonTagLastname].text;
    
    if (firstname.length < 1 && lastname.length < 1) {
        [self showAlertWithTitle:@"Please, fill in firstname or lastname to continue" andMessage:@""];
        return;
    }
    
    self.client.firstname    = firstname;
    self.client.lastname     = lastname;
    self.client.phone        = [self textFieldForTag:ClientButtonTagPhone].text;
    self.client.email        = [self textFieldForTag:ClientButtonTagEmail].text;
    self.client.street       = [self textFieldForTag:ClientButtonTagStreet].text;
    self.client.city         = [self textFieldForTag:ClientButtonTagCity].text;
    self.client.state        = [self textFieldForTag:ClientButtonTagState].text;
    self.client.zip          = [self textFieldForTag:ClientButtonTagZip].text;
    self.client.icon = self.addPhotoView.hidden ? self.clientEditPhotoView.image : nil;
    
    if ([self.client.clientID intValue] > 0) {
        NSString *msg = @"";
        if ([[ModelManager shared] updateClient:self.client]) {
            msg = @"Changes successfully saved";
        }
        else {
            msg = @"An error occured. Please, try again later";
        }
        
        [self showAlertWithTitle:msg andMessage:nil];
    }
    else {
        [[ModelManager shared] addClient:self.client];
        
        if (self.associatePurchase) {
            self.associatePurchase.clientID = self.client.clientID;
            [[ModelManager shared] updatePurchaseWithNewClient:self.associatePurchase];
            if(self.navigationViewController.viewControllers.count > 2)
                [[self.navigationViewController viewControllers] removeObjectAtIndex:self.navigationViewController.viewControllers.count - 2];
        }
        if(self.selectClient)
        {
            [[ModelManager shared] setShouldSavePurchase:YES];
            Purchase *purchase = [[ModelManager shared] activePurchase];
            purchase.clientID = self.client.clientID;            
            [[ModelManager shared] approvePurchase];
            
            [[self.navigationViewController viewControllers] removeObjectAtIndex:self.navigationViewController.viewControllers.count - 2];
        }
    }
    if(self.isNewClient)
        [self. delegate newClientWasAdded:self.client];
    else
        [self.delegate clientDetailsDidUpdate:self.client];
    [self cancelAction:nil];
}

- (void)setupForClient
{
    if (self.client.clientID.integerValue > 0) {
        [self.saveButton setTitle:@"SAVE CLIENT" forState:UIControlStateNormal];
        self.associateButton.hidden = self.associateLabel.hidden = NO;
    }
    else {
        [self.saveButton setTitle:@"SAVE NEW CLIENT" forState:UIControlStateNormal];
        self.associateButton.hidden = self.associateLabel.hidden = YES;
    }
    
    [purchases_ removeAllObjects];
    [purchases_ addObjectsFromArray:[[ModelManager shared] purchasesForClient:self.client]];
    
    [[self titleLabel] setText:self.isNewClient?@"NEW CLIENT" : @"EDIT CLIENT"];
    [self textFieldForTag:ClientButtonTagFirstname].text = self.client.firstname;
    [self textFieldForTag:ClientButtonTagLastname].text = self.client.lastname;
    [self textFieldForTag:ClientButtonTagPhone].text = self.client.phone;
    [self textFieldForTag:ClientButtonTagEmail].text = self.client.email;
    [self textFieldForTag:ClientButtonTagStreet].text = self.client.street;
    [self textFieldForTag:ClientButtonTagCity].text = self.client.city;
    [self textFieldForTag:ClientButtonTagState].text = self.client.state;
    [self textFieldForTag:ClientButtonTagZip].text = self.client.zip;
    
    if (self.client.icon == nil) {
        self.clientEditPhotoView.image = [UIImage imageNamed:@"nophoto_big"];
        self.addPhotoView.hidden = NO;
    }
    else {
        self.clientEditPhotoView.image = self.client.icon;
        self.addPhotoView.hidden = YES;
    }
    [self resizeNewClientScroll];
    [self.tablePurchases reloadData];
}

- (void)resizeNewClientScroll
{
    self.tablePurchases.frame = CGRectMake(self.tablePurchases.frame.origin.x, self.tablePurchases.frame.origin.y, self.tablePurchases.frame.size.width, purchases_.count * NEWCLIENT_CELL_HEIGHT);
    self.finishView.frame = CGRectMake(self.finishView.frame.origin.x, self.tablePurchases.frame.origin.y + self.tablePurchases.frame.size.height + 10, self.finishView.frame.size.width, self.finishView.frame.size.height);
    self.scrollNewClient.contentSize = CGSizeMake(self.scrollNewClient.frame.size.width, MAX(367, self.finishView.frame.origin.y + self.finishView.frame.size.height + 10));
}

- (UITextField *)textFieldForTag:(NSInteger)tag
{
    return (UITextField *)[self.containerView viewWithTag:tag];
}


#pragma mark - UITableView methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return purchases_.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"NewClientPurchasesCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"input_arrow_norm"]] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    cell.textLabel.text = [purchases_[indexPath.row] number];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
     
     MCPurchaseDetailsViewController_iPad *vc = [MCPurchaseDetailsViewController_iPad new];
     vc.purchase = purchases_[indexPath.row];
     [self.navigationViewController pushViewController:vc animated:YES];
     [vc release];
}

#pragma mark - UITextField delegate methods

-(void) textFieldDidBeginEditing:(UITextField *)textFieldView {
    currentTextField_ = textFieldView;
    if(keyboardIsShown)
        [self.scrollNewClient scrollRectToVisible:textFieldView.frame animated:YES];
}

-(BOOL) textFieldShouldReturn:(UITextField *) textFieldView {
    [textFieldView resignFirstResponder];
    return NO;
}

-(void) textFieldDidEndEditing:(UITextField *) textFieldView {
    currentTextField_ = nil;
}

#pragma mark - UIImagePickerController delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *) info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToUse;
    
    // Handle a still image picked from a photo album
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        
        editedImage     = info[UIImagePickerControllerEditedImage];
        originalImage   = info[UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToUse = editedImage;
        }
        else {
            imageToUse = originalImage;
        }
        
        imageToUse = [self rotateImage:imageToUse byOrientationFlag:imageToUse.imageOrientation];
        
        self.clientEditPhotoView.image = imageToUse;
        self.addPhotoView.hidden = imageToUse != nil;
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    [popover_ dismissPopoverAnimated:YES];
    popover_ = nil;
}

#pragma mark - Setup for Interface Orientation

-(void)setupForLandscape
{
    [super setupForLandscape];
    [self resizeNewClientScroll];
}

-(void)setupForPortrait
{
    [super setupForPortrait];
    [self resizeNewClientScroll];
}

#pragma mark - private methods

- (UIImage *)rotateImage:(UIImage *)img byOrientationFlag:(UIImageOrientation)orient
{
    CGImageRef          imgRef = img.CGImage;
    CGFloat             width = CGImageGetWidth(imgRef);
    CGFloat             height = CGImageGetHeight(imgRef);
    CGAffineTransform   transform = CGAffineTransformIdentity;
    CGRect              bounds = CGRectMake(0, 0, width, height);
    CGSize              imageSize = bounds.size;
    CGFloat             boundHeight;
    
    switch(orient) {
            
        case UIImageOrientationUp:      // EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationDown:    // EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:    // EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRight:   // EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        default:
            // image is not auto-rotated by the photo picker, so whatever the user
            // sees is what they expect to get. No modification necessary
            transform = CGAffineTransformIdentity;
            break;
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if ((orient == UIImageOrientationDown) || (orient == UIImageOrientationRight) || (orient == UIImageOrientationUp)){
        // flip the coordinate space upside down
        CGContextScaleCTM(context, 1, -1);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}


//---when the keyboard appears---
-(void) keyboardDidShow:(NSNotification *) notification {
    if (keyboardIsShown) return;
    
    NSDictionary* info = [notification userInfo];
    //---obtain the size of the keyboard---
    NSValue *aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    CGFloat keyboardHeight;
    if (IS_LANDSCAPE([[UIApplication sharedApplication] statusBarOrientation])) {
        keyboardHeight = keyboardSize.width;
    }
    else {
        keyboardHeight = keyboardSize.height;
    }
    
    //---resize the scroll view (with keyboard)---
    CGRect viewFrame = [self.scrollNewClient frame];
    viewFrame.size.height -= keyboardHeight;
    self.scrollNewClient.frame = viewFrame;
    
    //---scroll to the current text field---
    CGRect textFieldRect = [currentTextField_ frame];
    [self.scrollNewClient scrollRectToVisible:textFieldRect animated:YES];
    
    keyboardIsShown = YES;
    [self resizeNewClientScroll];
}

-(void) keyboardDidHide:(NSNotification *) notification {
    NSDictionary* info = [notification userInfo];
    
    //---obtain the size of the keyboard---
    NSValue* aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    CGFloat keyboardHeight;
    if (IS_LANDSCAPE([[UIApplication sharedApplication] statusBarOrientation])) {
        keyboardHeight = keyboardSize.width;
    }
    else {
        keyboardHeight = keyboardSize.height;
    }
    //---resize the scroll view back to the original size (without keyboard)---
    CGRect viewFrame = [self.scrollNewClient frame];
    viewFrame.size.height += keyboardHeight;
    self.scrollNewClient.frame = viewFrame;
    
    keyboardIsShown = NO;
    [self resizeNewClientScroll];
}

@end
