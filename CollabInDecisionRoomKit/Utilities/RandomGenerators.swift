//
//  DebuggingHelpers.swift
//
//  Created by Ella Isgar on 12/4/25.
//

/// Generates a string of n random characters.
///
/// CREDIT goes to iAhmed @ https://stackoverflow.com/a/26845710 - Retrieved 2025-12-04, License - CC BY-SA 4.0.
func randomString(length: Int) -> String {
    let letters =
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 "
    return String((0..<length).map { _ in letters.randomElement()! })
}

/// Generates a random Integer from 0 to n.
func randomNumber(from min: Int = 0, to max: Int) -> Int {
    return Int.random(in: min..<max)
}
