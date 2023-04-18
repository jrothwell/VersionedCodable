//
//  ExamplePoem.swift
//  
//
//  Created by Jonathan Rothwell on 18/04/2023.
//

import Foundation

/// **Glasgow**, by William Topaz McGonagall
let examplePoem =
    [
        "Beautiful city of Glasgow, with your streets so neat and clean,",
        "Your stateley mansions, and beautiful Green!",
        "Likewise your beautiful bridges across the River Clyde,",
        "And on your bonnie banks I would like to reside."
    ]

let poemForEncoding = Poem(
    author: .init(name: "William Topaz McGonagall",
                  born: DateComponents(calendar: .current,
                                       timeZone: TimeZone(identifier: "UTC"),
                                       year: 1825,
                                       month: 3).date!,
                  died: DateComponents(calendar: .current,
                                       timeZone: TimeZone(identifier: "UTC"),
                                       year: 1902,
                                       month: 9,
                                       day: 29).date!),
    lines: examplePoem)
