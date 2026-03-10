import UIKit

class infoPageViewController: UIViewController {

    @IBOutlet weak var slideImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!

    private var currentPage = 0
    
    struct OnboardingSlide {
        let title: String
        let description: String
        let imageName: String
    }
    
    private let slides: [OnboardingSlide] = [
        OnboardingSlide(
            title: "Current Energy",
            description: "Share your mood, so your partner knows exactly how to be there for you today.",
            imageName: "screen1"
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
        self.navigationItem.hidesBackButton = true
        
        setupUI()
        setupGestures()
        updateUI(animated: false)
    }
    
    // MARK: - Setup
    private func setupUI() {
        pageControl.numberOfPages = slides.count
        titleLabel.numberOfLines = 0
        descriptionLabel.numberOfLines = 0
    }
    
    private func setupGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }
    
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        if currentPage < slides.count - 1 {
               currentPage += 1
               updateUI(animated: true, transitionSubtype: .fromRight)
           } else {
               // Save onboarding completion
               UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")

               // Load Main storyboard
               let storyboard = UIStoryboard(name: "Main", bundle: nil)
               
               guard let mainVC = storyboard.instantiateInitialViewController() else {
                   return
               }

             
               if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let sceneDelegate = windowScene.delegate as? SceneDelegate,
                  let window = sceneDelegate.window {
                   
                   window.rootViewController = mainVC
                   window.makeKeyAndVisible()
               }
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
            
            slideImageView.layer.add(transition, forKey: nil)
            titleLabel.layer.add(transition, forKey: nil)
            descriptionLabel.layer.add(transition, forKey: nil)
        }
        
        titleLabel.text = slide.title
        descriptionLabel.text = slide.description
        slideImageView.image = UIImage(named: slide.imageName)
        
        let buttonTitle = (currentPage == slides.count - 1) ? "Lets Begin" : "Next"
        continueButton.setTitle(buttonTitle, for: .normal)
    }
}
