//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Konstantin Penzin on 14.04.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
