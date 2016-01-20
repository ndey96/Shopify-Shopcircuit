//
//  Product.m
//  shopcircuit-shopify
//
//  Created by Nolan Dey on 2016-01-19.
//  Copyright © 2016 Nolan Dey. All rights reserved.
//

#import "Product.h"

@implementation Product

- (instancetype)initWithPriceInDollars:(double)priceInDollars
                         weightInGrams:(int)weightInGrams
{
    if (self = [super init]) {
        self.priceInDollars = priceInDollars;
        self.weightInGrams = weightInGrams;
    }
    return self;
}

@end
