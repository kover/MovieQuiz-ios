//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Konstantin Penzin on 14.04.2023.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}
