//
//  FetchLocationController.m
//  LocationTracker
//
//  Created by Naveen Katari on 17/11/15.
//  Copyright (c) 2015 Sourcebits. All rights reserved.
//

#import "FetchLocationController.h"
#define METERS_PER_MILE 1609.344

@interface FetchLocationController ()<UISearchBarDelegate, UISearchDisplayDelegate>
{
    NSMutableArray *matchingSearchResults;
    CLPlacemark *locationPlacemark;
    CLGeocoder *geoCoder;
    MKLocalSearch *localSearch;
    MKLocalSearchResponse *searchResponse;
    NSInteger selectedIndex;
    MKMapItem *item;
}

@end

@implementation FetchLocationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_mapResultsTable registerNib:[UINib nibWithNibName:@"LocationDetailsViewCell" bundle:nil] forCellReuseIdentifier:@"LocationDetailsCell"];
    self.searchBar.delegate = self;
    geoCoder = [[CLGeocoder alloc]init];
    if (_locationManager == nil)
    {
        _locationManager = [[CLLocationManager alloc]init];
        
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
        [[self locationManager] setDelegate:self];
        
    }
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [self.locationManager requestWhenInUseAuthorization];
        
    }
    [_locationManager startUpdatingLocation];
    [[self mapView] setShowsUserLocation:YES];
    
    
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    if( authorizationStatus == kCLAuthorizationStatusAuthorizedAlways )
        
    {
        [_locationManager startUpdatingLocation];
        [[self mapView] setShowsUserLocation:YES];
        
    }
    _mapResultsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) viewWillAppear:(BOOL)animated
{
    
}
#pragma mark - CLLocationManager Delegate methods

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    CLLocation *location = [locations lastObject];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if(error == nil && [placemarks count] > 0)
         {
             
             locationPlacemark = [placemarks lastObject];
         }
         else
         {
             NSLog(@"%@", error.debugDescription);
         }
     }];
    CLLocationCoordinate2D zoomLocation;
    zoomLocation=location.coordinate;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    [self.mapView setRegion:viewRegion animated:YES];
    [manager stopUpdatingLocation];
    
}
#pragma CLLocationManager didFailWithError delegate method

-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Unable to find the location");
    NSLog(@"error %@",error.description);
}

#pragma Searchbar delegate methods
-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [localSearch cancel];
    MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc]init];
    searchRequest.naturalLanguageQuery = self.searchBar.text;
    searchRequest.region = self.mapView.region;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    localSearch = [[MKLocalSearch alloc] initWithRequest:searchRequest];
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error)
     {
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         if (response.mapItems.count == 0 )
         {
             NSLog(@"No Matches Found");
         }
         else
             for (item in response.mapItems)
             {
                 NSLog(@"name == %@", item.name);
                 NSLog(@"Phone == %@", item.phoneNumber);
                 NSLog(@"Address == %@", item.placemark);
                 
             }
         searchResponse = response;
         locationPlacemark = item.placemark;
         [_mapResultsTable reloadData];
     }];
}
#pragma Tableview delegate methods
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [searchResponse.mapItems count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"LocationDetailsCell";
    LocationDetailsViewCell *cell = [self.mapResultsTable dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        cell = [[LocationDetailsViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:Identifier];
    }
    
        item = searchResponse.mapItems[indexPath.row];
    
    cell.locationNameLabel.text = item.name;
    return cell;
}
@end
