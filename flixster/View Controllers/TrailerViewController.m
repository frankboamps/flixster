//
//  TrailerViewController.m
//  flixster
//
//  Created by frankboamps on 6/28/19.
//  Copyright © 2019 frankboamps. All rights reserved.
//

#import "TrailerViewController.h"
#import  "UIImageView+AFNetworking.h"
#import <WebKit/WebKit.h>

@interface TrailerViewController ()
@property (weak, nonatomic) IBOutlet WKWebView *movieWebKitView;
//@property (nonatomic, strong) NSString *trailers;


@end

@implementation TrailerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self fetchTrailer];
}
    

- (void) fetchTrailer {
        
        NSString *baseURLString = @"https://api.themoviedb.org/3/movie/";
        NSString *movieIdString = [self.movie[@"id"] stringValue];
        NSString *movieURLString = [baseURLString stringByAppendingString:movieIdString];
        NSString *videosurl = @"/videos?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US";
        NSString *fullmovieURLString = [movieURLString stringByAppendingString:videosurl];
       // NSLog(@"movie %@", self.movie[@"id"]);
    
        NSURL *url = [NSURL URLWithString:fullmovieURLString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error != nil) {
                NSLog(@"%@", [error localizedDescription]);
            }
            else {
                NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSString *trailers = dataDictionary [@"results"][0][@"key"];
                
                NSString *urlBaseString = @"https://www.youtube.com/watch?v=";
             
                NSString *urlString = [urlBaseString stringByAppendingString:trailers];
                
                NSURL *url = [NSURL URLWithString:urlString];
                
                // Place the URL in a URL Request.
                NSURLRequest *request = [NSURLRequest requestWithURL:url
                                                         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                     timeoutInterval:10.0];
                // Load Request into WebView.
                [self.movieWebKitView loadRequest:request];

            }
        }];
        [task resume];
    }
- (IBAction)closeButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
