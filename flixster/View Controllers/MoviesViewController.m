//
//  MoviesViewController.m
//  flixster
//
//  Created by frankboamps on 6/26/19.
//  Copyright © 2019 frankboamps. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"


@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *searchActivityIndicator;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self fetchMovies];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
   
    [self.searchActivityIndicator startAnimating];
    
}
- (void) fetchMovies {
    
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            [self alerter];
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            NSLog(@"%@", dataDictionary);
            
            self.movies = dataDictionary [@"results"];
            
            for (NSDictionary *movie in self.movies){ // loooping through movies from reults of API retrieved
                NSLog(@"%@", movie[@"title"]);
            }
            
            [self.searchActivityIndicator stopAnimating];
            [self.refreshControl endRefreshing];
            [self.tableView reloadData];
        }
    }];
    [task resume];
}

-(void) alerter{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Get Movies"
                                                                   message:@"The Internet connection appears to be offline "
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             // handle cancel response here. Doing nothing will dismiss the view.
                                                         }];
    
    [alert addAction:cancelAction];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Try again"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         // handle response here.
                                                     }];
    
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:^{
        // optional code for what happens after the alert controller has finished presenting
    }];
    
    
  
    [self.refreshControl endRefreshing];
}


//-(void) reloadingResolutionphotosInOrder{
//
//    NSURL *urlSmall = [NSURL URLWithString:@"https://image.tmdb.org/t/p/w200/j0BtDE8M4Q2sJANrQjCosU8N7ji.jpg"];
//    NSURL *urlLarge = [NSURL URLWithString:@"https://image.tmdb.org/t/p/w500/j0BtDE8M4Q2sJANrQjCosU8N7ji.jpg"];
//
//    NSURLRequest *requestSmall = [NSURLRequest requestWithURL:urlSmall];
//    NSURLRequest *requestLarge = [NSURLRequest requestWithURL:urlLarge];
//
//    __weak DetailsViewController *weakSelf = self;
//
//    [self.imageView setImageWithURLRequest:requestSmall
//                          placeholderImage:nil
//                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *smallImage) {
//
//                                       // smallImageResponse will be nil if the smallImage is already available
//                                       // in cache (might want to do something smarter in that case).
//                                       weakSelf.imageView.alpha = 0.0;
//                                       weakSelf.imageView.image = smallImage;
//
//                                       [UIView animateWithDuration:0.3
//                                                        animations:^{
//
//                                                            weakSelf.imageView.alpha = 1.0;
//
//                                                        } completion:^(BOOL finished) {
//                                                            // The AFNetworking ImageView Category only allows one request to be sent at a time
//                                                            // per ImageView. This code must be in the completion block.
//                                                            [weakSelf.imageView setImageWithURLRequest:requestLarge
//                                                                                      placeholderImage:smallImage
//                                                                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage * largeImage) {
//                                                                                                   weakSelf.imageView.image = largeImage;
//                                                                                               }
//                                                                                               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//                                                                                                   // do something for the failure condition of the large image request
//                                                                                                   // possibly setting the ImageView's image to a default image
//                                                                                               }];
//                                                        }];
//                                   }
//                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//                                       // do something for the failure condition
//                                       // possibly try to get the large image
//                                   }];
//}








- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.movies.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    //[[UITableViewCell alloc] init];
    
    NSDictionary *movie = self.movies[indexPath.row];
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"overview"];
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    cell.posterView.image = nil;
    [cell.posterView setImageWithURL:posterURL];

    //cell.textLabel.text = movie[@"title"];
    
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    NSDictionary *movie = self.movies[indexPath.row];
    
    DetailsViewController *detailsViewController = [segue destinationViewController];
    detailsViewController.movie = movie;
    NSLog(@"Tapping on a movie!");
    
}



@end
