//
//  MCNewClientViewController.m
//  ScrapCalc
//
//  Created by word on 13.03.13.
//
//

#import "MCNewClientViewController.h"
#import "MCPurchasesViewController.h"
#import "MCDetailedPurchaseViewController.h"
#import "ModelManager.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "GTMUIImage+Resize.h"

#define NEWCLIENT_CELL_HEIGHT 44

@implementation MCNewClientViewController

@synthesize scroll;
@synthesize table;
@synthesize finishView;
@synthesize photoView;
@synthesize addPhotoLabel;
@synthesize saveButton;
@synthesize addPhotoView;
@synthesize client;
@synthesize associatePurchase;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.client = [[Client new] autorelease];
        [self setupForClient];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initBackButton];
    for (NSInteger i = 1; i < ClientButtonTagCount; ++i) {
        UITextField *textField = [self textFieldForTag:i];
        if (textField != nil) {
            textField.delegate = self;
            textField.returnKeyType = UIReturnKeyDone;
            //textField.returnKeyType = i == ClientButtonTagCount-1 ? UIReturnKeyDone : UIReturnKeyNext;
            
            textField.layer.borderColor = [UIColor darkGrayColor].CGColor;
            textField.layer.borderWidth = 1;
            textField.layer.cornerRadius = 2;
            
            if (i == ClientButtonTagFirstname || i == ClientButtonTagLastname || i == ClientButtonTagStreet || i == ClientButtonTagCity || i == ClientButtonTagState) {
                textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
            }
        }
    }
    
    table.layer.cornerRadius = 2;    
    purchases_ = [NSMutableArray new];
    [self resizeScroll];
    
    [self setupForClient];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [purchases_ removeAllObjects];
    [purchases_ addObjectsFromArray:[[ModelManager shared] purchasesForClient:client]];
    
    [self reload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setScreenName:NEW_CLIENT_SCREEN_NAME];
}

- (void)setupForClient
{
    self.navigationItem.title = self.client.name.length < 1 ? @"NEW CLIENT" : self.client.name;
    if (self.client.clientID.integerValue > 0) {
        [saveButton setTitle:@"SAVE CLIENT" forState:UIControlStateNormal];
        self.associateButton.hidden = self.associateLabel.hidden = NO;
    }
    else {
        [saveButton setTitle:@"SAVE NEW CLIENT" forState:UIControlStateNormal];
        self.associateButton.hidden = self.associateLabel.hidden = YES;
    }
    
    [purchases_ removeAllObjects];
    [purchases_ addObjectsFromArray:[[ModelManager shared] purchasesForClient:client]];
    
    [self textFieldForTag:ClientButtonTagFirstname].text = client.firstname;
    [self textFieldForTag:ClientButtonTagLastname].text = client.lastname;
    [self textFieldForTag:ClientButtonTagPhone].text = client.phone;
    [self textFieldForTag:ClientButtonTagEmail].text = client.email;
    [self textFieldForTag:ClientButtonTagStreet].text = client.street;
    [self textFieldForTag:ClientButtonTagCity].text = client.city;
    [self textFieldForTag:ClientButtonTagState].text = client.state;
    [self textFieldForTag:ClientButtonTagZip].text = client.zip;
    
    if (client.icon == nil) {
        photoView.image = [UIImage imageNamed:@"client_no_photo.png"];
        addPhotoView.hidden = NO;
    }
    else {
        photoView.image = client.icon;
        addPhotoView.hidden = YES;
    }
}

- (UITextField *)textFieldForTag:(NSInteger)tag
{
    return (UITextField *)[self.scroll viewWithTag:tag];
}

- (void)resizeScroll
{
    table.frame = CGRectMake(table.frame.origin.x, table.frame.origin.y, table.frame.size.width, purchases_.count * NEWCLIENT_CELL_HEIGHT);
    finishView.frame = CGRectMake(finishView.frame.origin.x, table.frame.origin.y + table.frame.size.height + 10, finishView.frame.size.width, finishView.frame.size.height);
    scroll.contentSize = CGSizeMake(scroll.frame.size.width, MAX(367, finishView.frame.origin.y + finishView.frame.size.height + 10));
}

- (void)reload
{
    [table reloadData];
    //[self resizeScroll];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //if (textField.tag == ClientButtonTagCount-1)
        [textField resignFirstResponder];
    //else
    //    [[self textFieldForTag:textField.tag+1] becomeFirstResponder];
    return YES;
}

#pragma mark - UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [self resizeScroll];
    return purchases_.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"NewClientPurchasesCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    cell.textLabel.text = [purchases_[indexPath.row] number];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];   
    
    MCDetailedPurchaseViewController *vc = [MCDetailedPurchaseViewController new];
    vc.purchase = purchases_[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

#pragma mark - Actions

- (IBAction)saveClient:(id)sender
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
    self.client.icon = addPhotoView.hidden ? photoView.image : nil;
    
    if ([self.client.clientID intValue] > 0) {
        NSString *msg = @"";
        if ([[ModelManager shared] updateClient:client]) {
            msg = @"Changes successfully saved";
        }
        else {
            msg = @"An error occured. Please, try again later";
        }
        [self showAlertWithTitle:msg andMessage:nil];
    }
    else {
        [[ModelManager shared] addClient:client];
        if (self.associatePurchase) {
            self.associatePurchase.clientID = client.clientID;
            [[ModelManager shared] updatePurchaseWithNewClient:self.associatePurchase];
            
        }
        if(self.selectClient)
        {
            [[ModelManager shared] setShouldSavePurchase:YES];
            Purchase *purchase = [[ModelManager shared] activePurchase];
            purchase.clientID = self.client.clientID;
            [[self navigationController] popToRootViewControllerAnimated:YES];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }    
}

- (IBAction)choosePhoto:(id)sender
{
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    imgPicker.delegate = self;
    [self presentViewController:imgPicker animated:YES completion:nil];
    [imgPicker release];
}

- (IBAction)associatePurchase:(id)sender
{
    MCPurchasesViewController *vc = [MCPurchasesViewController new];
    vc.associateClient = self.client;
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

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
        imageToUse = [imageToUse gtm_imageByResizingToSize:CGSizeMake(320, 320) preserveAspectRatio:NO trimToFit:NO];
        
        photoView.image = imageToUse;
        addPhotoView.hidden = imageToUse != nil;
    }       
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

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

#pragma mark - Memory

- (void)dealloc
{
    [purchases_ release];
    [client release];
    [super dealloc];
}

@end
