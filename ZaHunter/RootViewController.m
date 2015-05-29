//
//  ViewController.m
//  ZaHunter
//
//  Created by Brent Dady on 5/28/15.
//  Copyright (c) 2015 Brent Dady. All rights reserved.
//

#import "RootViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Pizzeria.h"

@interface RootViewController () <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>
@property CLLocationManager *locationManager;
@property NSMutableArray *pizzerias;
@property NSMutableArray *tempArray;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.pizzerias = [NSMutableArray new];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"error");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    for (CLLocation *location in locations) {
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000) {
            self.textView.text = @"Location found. Looking up pizza spots...";
            [self findPizzerias:location];
            [self.locationManager stopUpdatingLocation];
            break;
        }
    }
}

- (void)findPizzerias:(CLLocation *)location {
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = @"pizzeria";
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(1, 1));
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        NSArray *mapItems = response.mapItems;
        // NSMutableString *searchResults = [NSMutableString new];
        for (MKMapItem *mapItem in mapItems) {
            Pizzeria *pizzeria = [Pizzeria new];
            CLLocationDistance distance = ([mapItem.placemark.location distanceFromLocation:location]/1000);
            if (distance < 10) {
                // [searchResults appendFormat:@"%@ is %.1f KMs away\n", mapItem.name, distance];
                pizzeria.mapItem = mapItem;
                pizzeria.distance = distance;
                [self.pizzerias addObject:pizzeria];
            }
        }
        [self.tableView reloadData];
        // self.textView.text = searchResults;
    }];
}

- (IBAction)startLocationSearch:(id)sender {
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
}


#pragma mark TABLE VIEW METHODS

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.pizzerias.count < 4) {
        return self.pizzerias.count;
    } else {
        return 4;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Pizzeria *pizzeria = [self.pizzerias objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID" forIndexPath:indexPath];
    cell.textLabel.text = pizzeria.mapItem.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1F KM away", pizzeria.distance];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Delete" message:@"Are you sure?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *yesButton = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self.pizzerias removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
        UIAlertAction *noButton = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [tableView reloadData];
        }];
        [alertController addAction:yesButton];
        [alertController addAction:noButton];
        [self presentViewController:alertController animated:YES completion:nil];
        [self.tableView reloadData];
    }
}

@end
