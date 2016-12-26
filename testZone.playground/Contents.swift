//: Playground - noun: a place where people can play

import UIKit

let data: String = ""

let jsonResult = data

if jsonResult is NSDictionary {
    print ("is Dictionnary")
} else if jsonResult is NSMutableArray {
    print ("is Mutable array")
} else {
    print ("is nothing known in this land...")
}