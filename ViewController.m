//
//  ViewController.m
//  LocationTracker
//
//  Created by Naveen Katari on 03/11/15.
//  Copyright (c) 2015 Sourcebits. All rights reserved.
//

#import "ViewController.h"
#define METERS_PER_MILE 1609.344

@interface ViewController () <UISearchBarDelegate, UISearchDisplayDelegate>
{
    NSMutableArray *matchingSearchResults;
    CLPlacemark *locationPlacemark;
    CLGeocoder *geoCoder;
    MKLocalSearch *localSearch;
    MKLocalSearchResponse *searchResponse;

}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
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
             self.stateLabel.text = locationPlacemark.administrativeArea;
             self.countryLabel.text = locationPlacemark.country;
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
             for (MKMapItem *item in response.mapItems)
                  {
                      NSLog(@"name == %@", item.name);
                      NSLog(@"Phone == %@", item.phoneNumber);
                      NSLog(@"Address == %@", item.placemark);
                      
                   }
         searchResponse = response;
     }];
    [_mapResultsTable reloadData];
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [searchResponse.mapItems count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"SearchResultsCell";
    UITableViewCell *cell = [self.mapResultsTable dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:Identifier];
    }
    
    MKMapItem *item = searchResponse.mapItems[indexPath.row];
    
    cell.textLabel.text = item.name;
    
    return cell;
}
//-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [self.searchDisplayController setActive:NO animated:YES];
//    MKMapItem *item = searchResponse.mapItems[indexPath.row];
//    [self.mapView addAnnotation:item.placemark];
//    [self.mapView selectAnnotation:item.placemark animated:YES];
//    [self.mapView setCenterCoordinate:item.placemark.location.coordinate animated:YES];
//    [self.mapView setUserTrackingMode:MKUserTrackingModeNone];
//}
@end