import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    private let questionsAmount = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var alertPresenter: AlertPresenterProtocol?
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private var statisticService: StatisticService?
    
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    
    @IBOutlet private var buttons: [UIButton]!
    
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        statisticService = StatisticServiceImpementation()
        
        alertPresenter = AlertPresenter(delegate: self)
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        showLoadingIndicator()
        questionFactory?.loadData()
        
        imageView.layer.borderColor = UIColor.ypWhite.cgColor
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    
    // MARK: - Business logic
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        // Disable all buttons in the collection on click
        buttons.forEach { button in
            button.isEnabled = false
        }
        
        if (isCorrect) {
            correctAnswers += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {
                return
            }
            self.showNextQuestionOrResults()
            // Enable buttons after new question is showed
            self.buttons.forEach { button in
                button.isEnabled = true
            }
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            show(quiz: QuizResultsViewModel(title: "Этот раунд окончен!",
                                            text: "Ваш результат: \(correctAnswers)/\(questionsAmount)",
                                            buttonText: "Сыграть ещё раз"))
        } else {
            currentQuestionIndex += 1
            imageView.layer.borderWidth = 0
            imageView.layer.borderColor = nil
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        
        var message = result.text
        
        if let statisticService = statisticService {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            message += "\nКоличество сыграных квизов: \(statisticService.gamesCount)\nРекорд: \(String(describing: statisticService.bestGame))\nСредняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        }

        let alertModel = AlertModel(title: result.title,
                                    message: message,
                                    buttonText: result.buttonText) {
            // Not sure if this needs to be wrapped with DispatchQueue.main
            DispatchQueue.main.async { [weak self] in
                self?.imageView.layer.borderWidth = 0
                self?.imageView.layer.borderColor = nil
                self?.currentQuestionIndex = 0
                self?.correctAnswers = 0
                self?.questionFactory?.requestNextQuestion()
            }
        }
        
        alertPresenter?.showAlert(model: alertModel)
    }
    
    // MARK: - Network interaction
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alert = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать ещъ раз") { [weak self] in
            guard let self = self else {
                return
            }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.showAlert(model: alert)
    }
}
