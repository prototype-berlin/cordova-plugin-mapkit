//
//  MapKit.m
//
//
//  Created by Victor Zimmer on 09/11/15.
//
//

#import "CDVWKWebViewEngine.h"
#import "MapKit.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MKComplexMapPin.h"

@interface MyMapView: MKMapView
@end

@implementation MyMapView
- (void) layoutSubviews
{
  [super layoutSubviews];
    
    for(UIView *view in self.subviews)
    {
        if([view isKindOfClass:NSClassFromString(@"MKCompassView")]) {
            NSLog(@"%@", view);
            
            float width = view.frame.size.width;
            float height = view.frame.size.height;
            view.frame = CGRectMake(self.bounds.size.width - width - 28, 180, width, height);
        }
    }
    return;
}

@end

@interface MapKit ()<MKMapViewDelegate>

@property (nonatomic, strong) MyMapView *mapView;
@end

@implementation MapKit

CLLocationManager* locationManager;
UIWebView* webView;

- (id)init
{

}

- (void)test:(CDVInvokedUrlCommand*)command
{

    NSString* callbackId = [command callbackId];
    NSString* name = [[command arguments] objectAtIndex:0];
    NSString* msg = [NSString stringWithFormat: @"MapKit, %@", name];

    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:msg];



    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)execJS: (NSString *)jsString {
    if ([self.webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)]) {
        [self.webView performSelector:@selector(stringByEvaluatingJavaScriptFromString:) withObject:jsString];
    } else if ([self.webView respondsToSelector:@selector(evaluateJavaScript:completionHandler:)]) {
        [self.webView performSelector:@selector(evaluateJavaScript:completionHandler:) withObject:jsString withObject:nil];
    }
}

- (void)checkLocationAuthStatus:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];

    CLAuthorizationStatus* authStatus = [CLLocationManager authorizationStatus];

    NSString* resultString;

    if (authStatus == kCLAuthorizationStatusAuthorized) {
        resultString = @"LOCATION_AUTH_AUTHORIZED";
    }
    else if (authStatus == kCLAuthorizationStatusAuthorizedAlways) {
        resultString = @"LOCATION_AUTH_AUTHORIZED_ALWAYS";
    }
    else if (authStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        resultString = @"LOCATION_AUTH_AUTHORIZED_WHEN_IN_USE";
    }
    else if (authStatus == kCLAuthorizationStatusNotDetermined) {
        resultString = @"LOCATION_AUTH_NOT_DETERMINED";
    }
    else if (authStatus == kCLAuthorizationStatusRestricted) {
        resultString = @"LOCATION_AUTH_RESTRICTED";
    }
    else if (authStatus == kCLAuthorizationStatusDenied) {
        resultString = @"LOCATION_AUTH_DENIED";
    }


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:resultString];



    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)requestLocationWhenInUsePermission:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];

    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];




    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:@"OK"];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}


- (void)requestLocationAlwaysPermission:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];

    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager requestAlwaysAuthorization];
    [locationManager startUpdatingLocation];




    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:@"OK"];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}


- (void)createMapView:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
    CGFloat height = [[[command arguments] objectAtIndex:1]floatValue];
    CGFloat width = [[[command arguments] objectAtIndex:2]floatValue];
    CGFloat xPos = [[[command arguments] objectAtIndex:3]floatValue];
    CGFloat yPos = [[[command arguments] objectAtIndex:4]floatValue];

    webView = (UIWebView*)self.webView;

    MyMapView* mapView = [[MyMapView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    mapView.tag = mapId;
    mapView.delegate = self;
    _mapView = mapView;

    [webView.superview insertSubview:mapView belowSubview:webView];
    [webView setBackgroundColor:[UIColor clearColor]];
    [webView setOpaque:NO];

    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}


- (void)showMapView:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
    MyMapView* mapView = self.mapView;
    AlphaPassUIWebView* webView = self.webView;
    [webView setAlphaPassEnabled:YES];

    mapView.hidden = NO;


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}


- (void)hideMapView:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];

    MyMapView* mapView = self.mapView;
    mapView.hidden = YES;

    AlphaPassUIWebView* webView = self.webView;
    [webView setAlphaPassEnabled:NO];

    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}

- (void)removeMapView:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
    MyMapView* mapView = self.mapView;
    [mapView removeFromSuperview];


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}

- (void)changeMapHeight:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
    CGFloat height = [[[command arguments] objectAtIndex:1]floatValue];
   MyMapView *mapView = self.mapView;

    [mapView setFrame:CGRectMake(mapView.frame.origin.x, mapView.frame.origin.y, mapView.frame.size.width, height)];


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];


}

- (void)changeMapWidth:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
    CGFloat width = [[[command arguments] objectAtIndex:1]floatValue];
   MyMapView *mapView = self.mapView;

    [mapView setFrame:CGRectMake(mapView.frame.origin.x, mapView.frame.origin.y, width, mapView.frame.size.height)];


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];


}

- (void)changeMapBounds:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
    CGFloat height = [[[command arguments] objectAtIndex:1]floatValue];
    CGFloat width = [[[command arguments] objectAtIndex:2]floatValue];
   MyMapView *mapView = self.mapView;

    [mapView setFrame:CGRectMake(mapView.frame.origin.x, mapView.frame.origin.y, width, height)];


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];


}

- (void)changeMapXPos:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
    CGFloat XPos = [[[command arguments] objectAtIndex:1]floatValue];
   MyMapView *mapView = self.mapView;

    [mapView setFrame:CGRectMake(XPos, mapView.frame.origin.y, mapView.frame.size.width, mapView.frame.size.height)];


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];


}

- (void)changeMapYPos:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
    CGFloat YPos = [[[command arguments] objectAtIndex:1]floatValue];
   MyMapView *mapView = self.mapView;

    [mapView setFrame:CGRectMake(mapView.frame.origin.x, YPos, mapView.frame.size.width, mapView.frame.size.height)];


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];


}

- (void)changeMapPosition:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
    CGFloat XPos = [[[command arguments] objectAtIndex:1]floatValue];
    CGFloat YPos = [[[command arguments] objectAtIndex:2]floatValue];
   MyMapView *mapView = self.mapView;

    [mapView setFrame:CGRectMake(XPos, YPos, mapView.frame.size.width, mapView.frame.size.height)];


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];


}



- (void)isShowingUserLocation:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
    MyMapView* mapView = self.mapView;

    NSString* stringRes;

    if (mapView.userLocationVisible) {
        stringRes = @"true";
    }
    else
    {
        stringRes = @"false";
    }

    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:stringRes];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}


- (void)showMapScale:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
   MyMapView *mapView = self.mapView;



    NSLog(@"%@", mapView);

    mapView.showsScale = YES;


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}

- (void)hideMapScale:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
   MyMapView *mapView = self.mapView;

    mapView.showsScale = NO;


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}

- (void)showMapUserLocation:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
   MyMapView *mapView = self.mapView;

    mapView.showsUserLocation = YES;


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}

- (void)hideMapUserLocation:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
   MyMapView *mapView = self.mapView;

    mapView.showsUserLocation = NO;


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}

- (void)showMapCompass:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
   MyMapView *mapView = self.mapView;

    mapView.showsCompass = YES;


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}

- (void)hideMapCompass:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
   MyMapView *mapView = self.mapView;

    mapView.showsCompass = NO;


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}

- (void)showMapPointsOfInterest:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
   MyMapView *mapView = self.mapView;

    mapView.showsPointsOfInterest = YES;


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}

- (void)hideMapPointsOfInterest:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
   MyMapView *mapView = self.mapView;

    mapView.showsPointsOfInterest = NO;


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}

- (void)showMapBuildings:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
   MyMapView *mapView = self.mapView;

    mapView.showsBuildings = YES;


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}

- (void)hideMapBuildings:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
   MyMapView *mapView = self.mapView;

    mapView.showsBuildings = NO;


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}

- (void)showMapTraffic:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
   MyMapView *mapView = self.mapView;

    mapView.showsTraffic = YES;


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}

- (void)hideMapTraffic:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
   MyMapView *mapView = self.mapView;

    mapView.showsTraffic = NO;


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}

- (void)setMapOpacity:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
    CGFloat newAlpha = [[[command arguments] objectAtIndex:1] floatValue];
   MyMapView *mapView = self.mapView;

    [mapView setAlpha: newAlpha];


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}

- (void)setMapCenter:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
    CGFloat centerLat = [[[command arguments] objectAtIndex:1] floatValue];
    CGFloat centerLon = [[[command arguments] objectAtIndex:2] floatValue];
    BOOL animated = [[[command arguments] objectAtIndex:3] boolValue];
   MyMapView *mapView = self.mapView;

    CLLocationCoordinate2D newCenter = CLLocationCoordinate2DMake(centerLat, centerLon);
    [mapView setCenterCoordinate:newCenter animated:animated];


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}

- (void)enableMapRotate:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
   MyMapView *mapView = self.mapView;

    [mapView setRotateEnabled:YES];


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}
- (void)disableMapRotate:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
   MyMapView *mapView = self.mapView;

    [mapView setRotateEnabled:NO];


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}

- (void)enableMapScroll:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
   MyMapView *mapView = self.mapView;

    [mapView setScrollEnabled:YES];


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}
- (void)disableMapScroll:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
   MyMapView *mapView = self.mapView;

    [mapView setScrollEnabled:NO];


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}

- (void)enableMapUserInteraction:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
   MyMapView *mapView = self.mapView;

    [mapView setUserInteractionEnabled:YES];


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}
- (void)disableMapUserInteraction:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
   MyMapView *mapView = self.mapView;

    [mapView setUserInteractionEnabled:NO];


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}

- (void)clearMapOverlays:(CDVInvokedUrlCommand*)command
{
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
    MyMapView *mapView = self.mapView;

    [mapView removeOverlays:[mapView overlays]];

    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}

- (void)setMapRegion:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
    CGFloat centerLat = [[[command arguments] objectAtIndex:1] floatValue];
    CGFloat centerLon = [[[command arguments] objectAtIndex:2] floatValue];
    CGFloat spanLat = [[[command arguments] objectAtIndex:3] floatValue];
    CGFloat spanLon = [[[command arguments] objectAtIndex:4] floatValue];
    BOOL animated = [[[command arguments] objectAtIndex:5] boolValue];
   MyMapView *mapView = self.mapView;

    CLLocationCoordinate2D newCenter = CLLocationCoordinate2DMake(centerLat, centerLon);
    MKCoordinateSpan newSpan = MKCoordinateSpanMake(spanLat, spanLon);

    MKCoordinateRegion newRegion = MKCoordinateRegionMake(newCenter, newSpan);
    [mapView setRegion:newRegion animated:animated];


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}

- (void)setMapRoute:(CDVInvokedUrlCommand*)command
{
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
    NSDictionary *json = [command.arguments objectAtIndex:1];
    MyMapView* mapView = self.mapView;

    NSArray *points = [json objectForKey:@"points"];
    int i = 0;
    NSDictionary *latLng;
    CLLocationCoordinate2D coordinates[points.count];
    for (i = 0; i < points.count; i++) {
        latLng = [points objectAtIndex:i];
        coordinates[i] = CLLocationCoordinate2DMake([[latLng objectForKey:@"lat"] floatValue], [[latLng objectForKey:@"lng"] floatValue]);
    }

    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordinates count:points.count];
    [mapView addOverlay:polyline level:(MKOverlayLevelAboveLabels)];

    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}

- (void)setMapDirectionRoute:(CDVInvokedUrlCommand*)command
{
   CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
   NSDictionary *json = [command.arguments objectAtIndex:1];
   MyMapView* mapView = self.mapView;

   NSArray *points = [json objectForKey:@"points"];
   int i = 0;
   NSDictionary *latLng;
   MKMapItem *coordinates[points.count];
   for (i = 0; i < points.count; i++) {
      latLng = [points objectAtIndex:i];
      MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake([[latLng objectForKey:@"lat"] floatValue], [[latLng objectForKey:@"lng"] floatValue]) addressDictionary:nil];
      coordinates[i] = [[MKMapItem alloc] initWithPlacemark:placemark];
   }

   // TODO Create thingy for directions
   for (i = 1; i < points.count; i++) {
      MKDirectionsRequest *directionsRequest = [MKDirectionsRequest new];
      [directionsRequest setTransportType:MKDirectionsTransportTypeWalking];
      [directionsRequest setSource:coordinates[i-1]];
      [directionsRequest setDestination:coordinates[i]];
      [directionsRequest setRequestsAlternateRoutes:NO];
      MKDirections *direction = [[MKDirections alloc] initWithRequest:directionsRequest];

      // For each object in the locations array, we request that route from its origin and its destination
      [direction calculateDirectionsWithCompletionHandler: ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
            NSLog(@"There was an error getting your directions");
            return;
         }
         MKRoute *route = [response.routes firstObject];
         [mapView addOverlay:route.polyline level:(MKOverlayLevelAboveLabels)];
      }];
   }

   CDVPluginResult* result = [CDVPluginResult
      resultWithStatus:CDVCommandStatus_OK
       messageAsString:[NSString stringWithFormat:@"%f", mapId]];

   [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)setMapZone:(CDVInvokedUrlCommand*)command
{
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
    NSDictionary *json = [command.arguments objectAtIndex:1];
    MyMapView* mapView = self.mapView;

    NSString *hexColor = [json objectForKey:@"color"];

    NSArray *points = [json objectForKey:@"points"];
    int i = 0;
    NSDictionary *latLng;
    CLLocationCoordinate2D coordinates[points.count];
    for (i = 0; i < points.count; i++) {
        latLng = [points objectAtIndex:i];
        coordinates[i] = CLLocationCoordinate2DMake([[latLng objectForKey:@"lat"] floatValue], [[latLng objectForKey:@"lng"] floatValue]);
    }

    MKPolygon *polygon = [MKPolygon polygonWithCoordinates:coordinates count:points.count];
    polygon.title = hexColor;
    [mapView addOverlay:polygon level:(MKOverlayLevelAboveRoads)];

    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (MKOverlayRenderer *)mapView:(MyMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay{

    NSLog(@"%@", overlay.title);

    if ([overlay isKindOfClass: [MKPolyline class]]) {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        renderer.strokeColor = [UIColor orangeColor];
        renderer.lineWidth = 3.f;

        return renderer;
    }

    if ([overlay isKindOfClass: [MKPolygon class]]) {

        // TODO We need to check wether the title string is valid hex
        unsigned rgbValue = 0;
        NSScanner *scanner = [NSScanner scannerWithString:overlay.title];
        [scanner setScanLocation:1];
        [scanner scanHexInt:&rgbValue];
        UIColor *color = UIColorFromRGB(rgbValue);
        UIColor *colorWithAlpha = [color colorWithAlphaComponent:0.4];

        MKPolygonRenderer *renderer = [[MKPolygonRenderer alloc] initWithOverlay:overlay];
        renderer.strokeColor = color;
        renderer.fillColor = colorWithAlpha;
        renderer.lineWidth = 1.f;

        return renderer;
    }

    return nil;
}


- (void)getMapCenter:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];

   MyMapView *mapView = self.mapView;

    CLLocationCoordinate2D center = mapView.centerCoordinate;
    CGPoint centerPoint = CGPointMake(center.longitude, center.latitude);

    NSString *jsEval = [NSString stringWithFormat:@"MKInterface.__objc__.getCenterCallback(%f, %@)", mapId, [[NSStringFromCGPoint(centerPoint) stringByReplacingOccurrencesOfString:@"{" withString:@"["]stringByReplacingOccurrencesOfString:@"}" withString:@"]" ]];


    [webView stringByEvaluatingJavaScriptFromString: jsEval];

    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}


- (void)addSimpleMapPin:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
    CGFloat lat = [[[command arguments] objectAtIndex:1]floatValue];
    CGFloat lon = [[[command arguments] objectAtIndex:2]floatValue];
    NSString* title = [[command arguments] objectAtIndex:3];
    NSString* description = [[command arguments] objectAtIndex:4];
   MyMapView *mapView = self.mapView;

    MKPointAnnotation* pin = [[MKPointAnnotation alloc]init];
    pin.coordinate = CLLocationCoordinate2DMake(lat, lon);
    pin.title = title;
    pin.subtitle = description;


    [mapView addAnnotation:pin];

    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}

- (void)addSimpleMapPins:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
   MyMapView *mapView = self.mapView;

    NSArray* pins = [[command arguments] objectAtIndex:1];
    NSMutableArray* Pins = [[NSMutableArray alloc] init];

    for (int i = 0; i < pins.count; i++)
    {
        NSArray* pinInfo = [pins objectAtIndex:i];

        CGFloat lat = [[pinInfo objectAtIndex:0]floatValue];
        CGFloat lon = [[pinInfo objectAtIndex:1]floatValue];
        NSString* title = [pinInfo objectAtIndex:2];
        NSString* description = [pinInfo objectAtIndex:3];

        MKPointAnnotation* pin = [[MKPointAnnotation alloc]init];
        pin.coordinate = CLLocationCoordinate2DMake(lat, lon);
        pin.title = title;
        pin.subtitle = description;

        [Pins addObject:pin];
    }

    [mapView addAnnotations:Pins];

    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}

- (void)removeMapPin:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
    NSString* pinTitle = [[command arguments] objectAtIndex:1];
   MyMapView *mapView = self.mapView;

    NSArray* pins = [mapView annotations];

    for (int i = 0; i < pins.count; i++)
    {
        MKPointAnnotation* pin = [pins objectAtIndex:i];
        if (pin.title == pinTitle)
        {
            [mapView removeAnnotation:pin];
        }
    }


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}

- (void)removeAllMapPins:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
   MyMapView *mapView = self.mapView;

    [mapView removeAnnotations:mapView.annotations];


    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}

- (void)addComplexMapPin:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    CGFloat mapId = [[[command arguments] objectAtIndex:0] floatValue];
    CGFloat lat = [[[command arguments] objectAtIndex:1]floatValue];
    CGFloat lon = [[[command arguments] objectAtIndex:2]floatValue];
    NSString* title = [[command arguments] objectAtIndex:3];
    NSString* description = [[command arguments] objectAtIndex:4];
    CGFloat pinColor = [[[command arguments] objectAtIndex:5] floatValue];
    NSString* pinImage = [[command arguments] objectAtIndex:6];
    CGFloat pinImageOffsetX = [[[command arguments] objectAtIndex:7] floatValue];
    CGFloat pinImageOffsetY = [[[command arguments] objectAtIndex:8] floatValue];
    CGFloat draggable = [[[command arguments] objectAtIndex:9] floatValue];
    CGFloat canShowCallout = [[[command arguments] objectAtIndex:10] floatValue];
    CGFloat showInfoButton = [[[command arguments] objectAtIndex:11] floatValue];
    MyMapView *mapView = self.mapView;

    MKComplexMapPin* pinAnnotation = [[MKComplexMapPin alloc] init];
    pinAnnotation.coordinate = CLLocationCoordinate2DMake(lat, lon);
    pinAnnotation.title = title;
    pinAnnotation.subtitle = description;
    pinAnnotation.mapId = mapId;

    if (pinColor == 1)
    {
        pinAnnotation.pinColor = MKPinAnnotationColorRed;
    }
    else if (pinColor == 2)
    {
        pinAnnotation.pinColor = MKPinAnnotationColorGreen;
    }
    else if (pinColor == 3)
    {
        pinAnnotation.pinColor = MKPinAnnotationColorPurple;
    }
    else
    {
        pinAnnotation.pinColor = MKPinAnnotationColorRed;
    }

    if ([pinImage length] != 0) {
        pinAnnotation.customImage = YES;
        pinAnnotation.pinImage = pinImage;
        pinAnnotation.pinImageOffsetX = pinImageOffsetX;
        pinAnnotation.pinImageOffsetY = pinImageOffsetY;
    }

    if ([pinImage length] != 0) {
        pinAnnotation.customImage = YES;
        pinAnnotation.pinImage = pinImage;
        pinAnnotation.pinImageOffsetX = pinImageOffsetX;
        pinAnnotation.pinImageOffsetY = pinImageOffsetY;
    }

    if (draggable > 0)
    {
        pinAnnotation.draggable = YES;
    }
    else
    {
        pinAnnotation.draggable = NO;
    }

    if (canShowCallout > 0)
    {
        pinAnnotation.canShowCallout = YES;
    }
    else
    {
        pinAnnotation.canShowCallout = NO;
    }

    if (showInfoButton > 0)
    {
        pinAnnotation.showInfoButton = YES;
    }
    else
    {
        pinAnnotation.showInfoButton = NO;
    }

//    pinAnnotation.canShowCallout = canShowCallout;

    [mapView addAnnotation:pinAnnotation];

    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:[NSString stringWithFormat:@"%f", mapId]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}

-(void)mapView:(MyMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    id <MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[MKComplexMapPin class]])
    {
      MKComplexMapPin *pin = (MKComplexMapPin *)annotation;
      NSLog(@"Clicked Complex Pin Infobutton");
      // NSLog(pin.mapId);
      NSLog(pin.title);
      NSMutableString* jsParam = [[NSMutableString alloc] init];
      [jsParam appendString:@"\""];
      [jsParam appendString:[NSString stringWithFormat:@"%f", pin.mapId]];
      [jsParam appendString:@"\""];
      [jsParam appendString:@","];
      [jsParam appendString:@"\""];
      [jsParam appendString:pin.title];
      [jsParam appendString:@"\""];
      NSLog(jsParam);

      NSString* jsString = [NSString stringWithFormat:@"MKInterface.__objc__.pinInfoClickCallback(%@);", jsParam];
      [(UIWebView*)self.webView stringByEvaluatingJavaScriptFromString:jsString];
    }

}

-(void)mapView:(MyMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    id <MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[MKComplexMapPin class]] && newState == MKAnnotationViewDragStateEnding)
    {
        MKComplexMapPin *pin = (MKComplexMapPin *)annotation;
        NSLog(@"Moved Complex Pin Infobutton");
        NSLog(@"%f", pin.mapId);
        NSLog(pin.title);
        NSMutableString* jsParam = [[NSMutableString alloc] init];
        [jsParam appendString:@"\""];
        [jsParam appendString:[NSString stringWithFormat:@"%f", pin.mapId]];
        [jsParam appendString:@"\""];
        [jsParam appendString:@","];
        [jsParam appendString:@"\""];
        [jsParam appendString:pin.title];
        [jsParam appendString:@"\""];
        [jsParam appendString:@","];
        [jsParam appendString:[NSString stringWithFormat:@"%f", pin.coordinate.latitude]];
        [jsParam appendString:@","];
        [jsParam appendString:[NSString stringWithFormat:@"%f", pin.coordinate.longitude]];
        NSLog(jsParam);

        NSString* jsString = [NSString stringWithFormat:@"MKInterface.__objc__.pinDragCallback(%@);", jsParam];
        [self execJS:jsString];
    }

}

- (void)mapView:(MyMapView *)mapView didSelectAnnotationView:(nonnull MKAnnotationView *)view
{
    id <MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[MKComplexMapPin class]])
    {
        MKComplexMapPin *pin = (MKComplexMapPin *)annotation;
        NSLog(@"Clicked Complex Pin");
        NSLog(@"%f", pin.mapId);
        NSLog(pin.title);
        NSMutableString* jsParam = [[NSMutableString alloc] init];
        [jsParam appendString:@"\""];
        [jsParam appendString:[NSString stringWithFormat:@"%f", pin.mapId]];
        [jsParam appendString:@"\""];
        [jsParam appendString:@","];
        [jsParam appendString:@"\""];
        [jsParam appendString:pin.title];
        [jsParam appendString:@"\""];
        NSLog(jsParam);

        [mapView deselectAnnotation:view.annotation animated:NO];

        NSString* jsString = [NSString stringWithFormat:@"MKInterface.__objc__.pinClickCallback(%@);", jsParam];
        [self execJS:jsString];
    }
}

- (MKAnnotationView *)mapView:(MyMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;

    static NSString *reuseSimplePinId = @"SimplePin";
    static NSString *reuseComplexPinId = @"ComplexPin";
    static NSString *reuseCustomImageComplexPinId = @"CustomImageComplexPin";
    MKAnnotationView *pav = nil;
    if ([annotation isKindOfClass:[MKComplexMapPin class]])
    {
        MKComplexMapPin *pin = (MKComplexMapPin *)annotation;
        if (pin.customImage)
        {
            pav = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseCustomImageComplexPinId];
            if (pav == nil)
            {
                pav = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseCustomImageComplexPinId];
            }
            else
            {
                pav.annotation = annotation;
            }

            NSURL *url = [NSURL URLWithString:pin.pinImage];
            NSData *imageData = [NSData dataWithContentsOfURL:url];
            pav.image = [UIImage imageWithData:imageData scale:2];
            pav.centerOffset = CGPointMake(pin.pinImageOffsetX, pin.pinImageOffsetY);
        }
        else
        {
            pav = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseComplexPinId];
            if (pav == nil)
            {
                pav = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseComplexPinId];
            }
            else
            {
                pav.annotation = annotation;
            }


            ((MKPinAnnotationView *)pav).pinColor = pin.pinColor;
        }

        pav.draggable = pin.draggable;
        pav.canShowCallout = pin.canShowCallout;

        if (pin.showInfoButton)
        {
            UIButton* info = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            pav.rightCalloutAccessoryView = info;
        }

    }
    else if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        pav = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseSimplePinId];
        if (pav == nil)
        {
            pav = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseSimplePinId];
        }
        else
        {
            pav.annotation = annotation;
        }
        pav.canShowCallout = YES;
    }

    return pav;
}







@end


