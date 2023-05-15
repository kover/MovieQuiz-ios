import UIKit

final class MovieQuizViewController: UIViewController {
    
//    private var questionFactory: QuestionFactoryProtocol?
    
    private var alertPresenter: AlertPresenterProtocol?
    
    private var statisticService: StatisticService?
    
    private var presenter: MovieQuizPresenter!
    
    
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
        
//        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        showLoadingIndicator()
//        questionFactory?.loadData()
        
        imageView.layer.borderColor = UIColor.ypWhite.cgColor
        
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    // MARK: - Business logic
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        // Disable all buttons in the collection on click
        buttons.forEach { button in
            button.isEnabled = false
        }
        
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {
                return
            }
            self.presenter.showNextQuestionOrResults()
            self.imageView.layer.borderWidth = 0
            self.imageView.layer.borderColor = nil
            // Enable buttons after new question is showed
            self.buttons.forEach { button in
                button.isEnabled = true
            }
        }
    }

    func show(quiz result: QuizResultsViewModel) {
        
        var message = result.text
        
        if let statisticService = statisticService {
            statisticService.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
            
            message += "\nКоличество сыграных квизов: \(statisticService.gamesCount)\nРекорд: \(String(describing: statisticService.bestGame))\nСредняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        }

        let alertModel = AlertModel(title: result.title,
                                    message: message,
                                    buttonText: result.buttonText) {
            // Not sure if this needs to be wrapped with DispatchQueue.main
            DispatchQueue.main.async { [weak self] in
                self?.imageView.layer.borderWidth = 0
                self?.imageView.layer.borderColor = nil
                self?.presenter.restartGame()
            }
        }
        
        alertPresenter?.showAlert(model: alertModel)
    }
    
    // MARK: - Network interaction
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alert = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать ещъ раз") { [weak self] in
            guard let self = self else {
                return
            }
            
            self.presenter.restartGame()
        }
        
        alertPresenter?.showAlert(model: alert)
    }
}
