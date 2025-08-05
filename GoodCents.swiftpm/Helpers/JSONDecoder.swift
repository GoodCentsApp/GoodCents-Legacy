//
//  JSONDecoder.swift
//  GoodCents
//
//  Created by GoodCents on 30/01/2025.
//

import Foundation

// JSON decoder
extension Bundle {
    func decode<T: Decodable>(_ type: T.Type, from file: String) -> T {
        // check the JSON file exists
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle. Ensure the file is added to the project and included in the target's Copy Bundle Resources.")
        }
        
        // load the file as a data object
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }

        let decoder = JSONDecoder()

        // decode the json otherwise fatalerror
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Failed to decode \(file) from bundle. Error: \(error.localizedDescription) Non Localized Error: \(error)")
        }
    }
}
