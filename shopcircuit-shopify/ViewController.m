//
//  ViewController.m
//  shopcircuit-shopify
//
//  Created by Nolan Dey on 2016-01-19.
//  Copyright © 2016 Nolan Dey. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "Product.h"

static const int MaxWeightInGrams = 100*1000;

@interface ViewController ()

@property (nonatomic, strong) NSURL *filePath;
@property (nonatomic, strong) UILabel *answerLabel;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self downloadData];
    self.answerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                 (CGRectGetHeight(self.view.frame) - 30) / 2,
                                                                 CGRectGetWidth(self.view.frame),
                                                                 30)];
    self.answerLabel.font = [UIFont systemFontOfSize:24];
    self.answerLabel.text = @"Calculating answer...";
    self.answerLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.answerLabel];
}

- (void)downloadData
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL *URL = [NSURL URLWithString:@"http://shopicruit.myshopify.com/products.json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request
                                                                     progress:nil
                                                                  destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                                                                      NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                                                                                            inDomain:NSUserDomainMask
                                                                                                                                   appropriateForURL:nil
                                                                                                                                              create:NO
                                                                                                                                               error:nil];
                                                                      return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
                                                                  } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                                                                      NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:filePath]
                                                                                                                           options:NSJSONReadingMutableContainers
                                                                                                                             error:nil];
                                                                      [self computeAnswerWithJson:json];
                                                                  }];
    [downloadTask resume];
}

- (void)computeAnswerWithJson:(NSDictionary *)json
{
    NSArray *unfilteredProducts = json[@"products"];
    NSMutableArray *filteredProducts = [NSMutableArray array];
    //filter out anything that isn't a computer or a keyboard
    for (NSDictionary *product in unfilteredProducts) {
        NSString *title = product[@"title"];
        if ([title rangeOfString:@"keyboard"
                         options:NSCaseInsensitiveSearch].location != NSNotFound || [title rangeOfString:@"computer"
                                                                                                 options:NSCaseInsensitiveSearch].location != NSNotFound) {
            NSArray *variants = product[@"variants"];
            for (NSDictionary *variant in variants) {
                NSScanner *priceScanner = [NSScanner scannerWithString:variant[@"price"]];
                double price;
                [priceScanner scanDouble:&price];
                
                NSNumber *weight = variant[@"grams"];
                
                Product *product = [[Product alloc] initWithPriceInDollars:price
                                                             weightInGrams:[weight intValue]];
                [filteredProducts addObject:product];
            }
        }
    }
    //sort filtered products in ascending order by weight
    [filteredProducts sortUsingComparator:^NSComparisonResult(Product *product1, Product *product2) {
        if (product1.weightInGrams < product2.weightInGrams) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    int index = 0;
    int totalWeight = 0;
    double totalPrice = 0;
    while (totalWeight < MaxWeightInGrams && index < filteredProducts.count) {
        Product *product = filteredProducts[index];
        totalWeight += product.weightInGrams;
        totalPrice += product.priceInDollars;
        index++;
    }
    [self displayAnswer:totalPrice];
}

- (void)displayAnswer:(double)answer
{
    if (answer > 0) {
        self.answerLabel.text = [NSString stringWithFormat:@"$%.02f", answer];
    }
}
@end
