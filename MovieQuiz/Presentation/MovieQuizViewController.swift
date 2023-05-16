import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet private var buttons: [UIButton]!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    private var alertPresenter: AlertPresenterProtocol!
    
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter = AlertPresenter(delegate: self)
        
        showLoadingIndicator()
        
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
    
    // MARK: - View logic
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    func show(quiz result: QuizResultsViewModel) {

        let alertModel = AlertModel(title: result.title,
                                    message: result.text,
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
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        // Disable all buttons in the collection on click
        buttons.forEach { button in
            button.isEnabled = false
        }
    }
    
    func resetImageBorderHighlighting() {
        self.imageView.layer.borderWidth = 0
        self.imageView.layer.borderColor = nil
        // Enable buttons after new question is showed
        self.buttons.forEach { button in
            button.isEnabled = true
        }
    }
    
    // MARK: - Network activity
    
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
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else {
                return
            }
            
            self.presenter.restartGame()
        }
        
        alertPresenter?.showAlert(model: alert)
    }
}
