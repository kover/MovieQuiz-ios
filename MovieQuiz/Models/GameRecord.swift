//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Konstantin Penzin on 16.04.2023.
//

import Foundation

struct GameRecord: Codable, Comparable, CustomStringConvertible {
    let correct: Int
    let total: Int
    let date: Date
    
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        return lhs.correct < rhs.correct
    }
    
    var description: String {
        return "\(correct)/\(total) (\(date.dateTimeString))"
    }
}
