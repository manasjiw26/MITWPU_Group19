import UIKit

class infoPageViewController: UIViewController {

    // MARK: - Outlets
    // Connect these to your Storyboard elements
    @IBOutlet weak var slideImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    
    // MARK: - Properties
    private var currentPage = 0
    private let pageControl = UIPageControl()
    
    struct OnboardingSlide {
        let title: String
        let description: String
        let imageName: String
    }
    private let slides: [OnboardingSlide] = [
        OnboardingSlide(
            title: "Current Energy",
            description: "Share your mood, so your partner knows exactly how to be there for you today.",
            imageName: "DeletetheGlitch"
        ),
        OnboardingSlide(
            title: "Our Little Rituals",
            description: "Uplift the vibe with shared activities, designed to make the distance feel like nothing at all.",
            imageName: "DeletetheGlitch"
        ),
        OnboardingSlide(
            title: "The Archive",
            description: "Save those daily wins and sweet moments, creating a digital space that is purely ours.",
            imageName: "Screen3"
        )
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // As per your requirement: Hide the back button
        self.navigationItem.hidesBackButton = true
        
        setupUI()
        setupPageControl()
        setupGestures()
        updateUI(animated: false)
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Styling the button
        continueButton.layer.cornerRadius = 25
        continueButton.backgroundColor = .systemPink
        continueButton.setTitleColor(.white, for: .normal)
        
        // Ensuring text wraps correctly
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
    }
    
    private func setupPageControl() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)
        
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .systemGray4
        pageControl.currentPageIndicatorTintColor = .systemPink
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -20)
        ])
    }
    
    private func setupGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }
    
    // MARK: - Actions
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        if currentPage < slides.count - 1 {
            currentPage += 1
            updateUI(animated: true, transitionSubtype: .fromRight)
        } else {
            // Logic for when onboarding is finished
            print("Onboarding Finished!")
            // e.g., navigate to your pairing/home screen
        }
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left && currentPage < slides.count - 1 {
            currentPage += 1
            updateUI(animated: true, transitionSubtype: .fromRight)
        } else if gesture.direction == .right && currentPage > 0 {
            currentPage -= 1
            updateUI(animated: true, transitionSubtype: .fromLeft)
        }
    }
    
    // MARK: - UI Update Logic
    private func updateUI(animated: Bool, transitionSubtype: CATransitionSubtype? = nil) {
        let slide = slides[currentPage]
        pageControl.currentPage = currentPage
        
        if animated {
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = .push
            transition.subtype = transitionSubtype ?? .fromRight
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            // Animating the content for a "page turn" feel
            slideImageView.layer.add(transition, forKey: nil)
            titleLabel.layer.add(transition, forKey: nil)
            descriptionLabel.layer.add(transition, forKey: nil)
        }
        
        titleLabel.text = slide.title
        descriptionLabel.text = slide.description
        slideImageView.image = UIImage(named: slide.imageName)
        
        let buttonTitle = (currentPage == slides.count - 1) ? "Get Started" : "Next"
        continueButton.setTitle(buttonTitle, for: .normal)
    }
}
