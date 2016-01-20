//
//  Product.h
//  shopcircuit-shopify
//
//  Created by Nolan Dey on 2016-01-19.
//  Copyright © 2016 Nolan Dey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface Product : NSObject

@property (nonatomic, assign) double priceInDollars;
@property (nonatomic, assign) int weightInGrams;

- (instancetype)initWithPriceInDollars:(double)priceInDollars
                         weightInGrams:(int)weightInGrams;

@end
