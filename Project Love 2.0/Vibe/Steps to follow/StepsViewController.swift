// // StepsViewController.swift
// Project Love 2.0 //
// Created by SDC-USER on 11/12/25. //


import UIKit

class ThreeDStackedCollectionViewLayout: UICollectionViewLayout {
    
    private var cache: [IndexPath: UICollectionViewLayoutAttributes] = [:]
    private var contentWidth: CGFloat = 0
    private var contentHeight: CGFloat = 0
    
    override func prepare() {
        super.prepare()
        cache.removeAll()
        
        guard let collectionView = collectionView, collectionView.numberOfSections > 0 else { return }
        
        let itemCount = collectionView.numberOfItems(inSection: 0)
        let width = collectionView.bounds.width
        let height = collectionView.bounds.height
        
        contentWidth = CGFloat(itemCount) * width
        contentHeight = height
        
        let progress = collectionView.contentOffset.x / max(1, width)
        
        // Card dimensions — slightly smaller to reveal stacked cards behind
        let cardWidth = width * 0.82
        let cardHeight = height * 0.72
        let originX = collectionView.contentOffset.x + (width - cardWidth) / 2
        
        // Shift down to give room at the top for stacked card vertical offsets
        let originY = (height - cardHeight) / 2 + 30
        
        for item in 0..<itemCount {
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            let diff = CGFloat(item) - progress
            
            // Set base frame centered horizontally and vertically
            attributes.frame = CGRect(x: originX, y: originY, width: cardWidth, height: cardHeight)
            
            if diff < 0 {
                // Swiped card sliding off to the left (3D fly-off effect)
                let progressLeft = -diff
                let translationX = diff * cardWidth * 1.35
                let translationY = diff * 45.0
                let scale = 1.0 + diff * 0.08
                let rotation = diff * 0.35
                let alpha: CGFloat = 1.0
                
                var transform = CATransform3DIdentity
                transform.m34 = -1.0 / 500.0 // True 3D perspective
                transform = CATransform3DTranslate(transform, translationX, translationY, 0)
                transform = CATransform3DScale(transform, scale, scale, 1.0)
                transform = CATransform3DRotate(transform, rotation, 0, 0, 1.0)
                
                attributes.transform3D = transform
                attributes.alpha = alpha
                attributes.zIndex = 1000 + item
                
            } else if diff >= 0 && diff < 5 {
                // ALL 4 CARDS visible in the stack:
                // Card 0 (Active Front): Straight (0°), centered, scale 1.0, alpha 1.0
                // Card 1 (Behind Left): Rotated left (-8°), shifted left & up, scale 0.93, alpha 1.0
                // Card 2 (Behind Right): Rotated right (+7°), shifted right & up, scale 0.88, alpha 1.0
                // Card 3 (Deepest): Subtle left (-4°), slight left & highest up, scale 0.84, alpha 0.95
                
                let scale: CGFloat
                let rotation: CGFloat
                let translationX: CGFloat
                let translationY: CGFloat
                let alpha: CGFloat
                
                if diff <= 1.0 {
                    // Front → Back card 1 (left tilt)
                    let p = diff
                    scale = 1.0 * (1.0 - p) + 0.93 * p
                    rotation = p * (-8.0 * .pi / 180.0)
                    translationX = p * -40.0
                    translationY = p * -28.0
                    alpha = 1.0
                } else if diff <= 2.0 {
                    // Back card 1 → Back card 2 (right tilt)
                    let p = diff - 1.0
                    scale = 0.93 * (1.0 - p) + 0.88 * p
                    rotation = (-8.0 * .pi / 180.0) * (1.0 - p) + (7.0 * .pi / 180.0) * p
                    translationX = -40.0 * (1.0 - p) + 35.0 * p
                    translationY = -28.0 * (1.0 - p) + (-50.0) * p
                    alpha = 1.0
                } else if diff <= 3.0 {
                    // Back card 2 → Back card 3 (deepest, subtle left)
                    let p = diff - 2.0
                    scale = 0.88 * (1.0 - p) + 0.84 * p
                    rotation = (7.0 * .pi / 180.0) * (1.0 - p) + (-4.0 * .pi / 180.0) * p
                    translationX = 35.0 * (1.0 - p) + (-12.0) * p
                    translationY = -50.0 * (1.0 - p) + (-70.0) * p
                    alpha = 1.0 * (1.0 - p) + 0.95 * p
                } else if diff <= 4.0 {
                    // Beyond the 4th card — fade out
                    let p = diff - 3.0
                    scale = 0.84 * (1.0 - p) + 0.80 * p
                    rotation = (-4.0 * .pi / 180.0) * (1.0 - p)
                    translationX = -12.0 * (1.0 - p)
                    translationY = -70.0 * (1.0 - p) + (-85.0) * p
                    alpha = 0.95 * (1.0 - p)
                } else {
                    scale = 0.80
                    rotation = 0
                    translationX = 0
                    translationY = -85.0
                    alpha = 0.0
                }
                
                var transform = CATransform3DIdentity
                transform.m34 = -1.0 / 500.0 // True 3D perspective
                // Apply 3D staggered coordinates with depth plane (-diff * 40.0 Z position)
                transform = CATransform3DTranslate(transform, translationX, translationY, -diff * 40.0)
                transform = CATransform3DScale(transform, scale, scale, 1.0)
                transform = CATransform3DRotate(transform, rotation, 0, 0, 1.0)
                
                attributes.transform3D = transform
                attributes.alpha = alpha
                attributes.zIndex = 1000 - Int(diff * 10.0)
                
            } else {
                attributes.alpha = 0.0
                attributes.zIndex = 0
            }
            
            cache[indexPath] = attributes
        }
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache.values.filter { $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    // Smooth elastic physics card deck carousel snapping
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return proposedContentOffset }
        
        let width = collectionView.bounds.width
        let currentOffset = collectionView.contentOffset.x
        let currentPage = currentOffset / width
        
        var targetPage = round(currentPage)
        
        if abs(velocity.x) > 0.28 {
            targetPage = velocity.x > 0 ? ceil(currentPage) : floor(currentPage)
        }
        
        let itemCount = collectionView.numberOfItems(inSection: 0)
        targetPage = max(0, min(CGFloat(itemCount - 1), targetPage))
        
        return CGPoint(x: targetPage * width, y: proposedContentOffset.y)
    }
}

class StepsViewController: UIViewController {
    
    var steps: [StepsToFollow] = []
    var activitytitle: String = ""
    var flowSource: ActivityFlowSource?
    var activity: Activity?
    var selectedActivityIndex: Int?
    var bondName: String?
    var expandedIndex: Int? = nil
    
    weak var bondDelegate: BondActivityCompletionDelegate?

    @IBOutlet weak var activityTitle: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var stepsCollectionView: UICollectionView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableBackgroundCell: UIView!

    @IBOutlet var subtitle1: UILabel!
    @IBOutlet weak var combinedLabel: UILabel!
 
    private let indicatorStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var indicatorButtons: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let activity = activity else {
            return
        }

        activitytitle = activity.name
        activityTitle.text = activitytitle
        subtitle.text = "Set the scene with these steps"

        steps = DataStore.shared.getSteps(for: activity)

        // Setup collection view and custom layout
        stepsCollectionView.register(StepCardCollectionViewCell.self, forCellWithReuseIdentifier: "StepCardCell")
        let layout = ThreeDStackedCollectionViewLayout()
        stepsCollectionView.collectionViewLayout = layout
        stepsCollectionView.dataSource = self
        stepsCollectionView.delegate = self
        
        stepsCollectionView.isPagingEnabled = false
        stepsCollectionView.showsHorizontalScrollIndicator = false
        stepsCollectionView.backgroundColor = .clear
        // Allow enough visible cells to display all 4 stacked cards
        stepsCollectionView.clipsToBounds = false

        continueButton.configuration = .glass()

        if bondName != nil && selectedActivityIndex != nil && selectedActivityIndex! < 3 {
            continueButton.setTitle("Done", for: .normal)
        } else {
            continueButton.setTitle("Continue", for: .normal)
        }

        // Make background transparent for 3D stack cards
        tableBackgroundCell.backgroundColor = .clear
        tableBackgroundCell.layer.cornerRadius = 0
        tableBackgroundCell.clipsToBounds = false
        tableHeightConstraint.constant = 420
        
        setupIndicators()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.hidesBottomBarWhenPushed = true
    }
    
    private func setupIndicators() {
        guard let container = tableBackgroundCell.superview else { return }
        
        container.addSubview(indicatorStackView)
        
        NSLayoutConstraint.activate([
            indicatorStackView.topAnchor.constraint(equalTo: tableBackgroundCell.bottomAnchor, constant: 16),
            indicatorStackView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            indicatorStackView.heightAnchor.constraint(equalToConstant: 60),
            indicatorStackView.widthAnchor.constraint(equalToConstant: 320)
        ])
        
        indicatorButtons.forEach { $0.removeFromSuperview() }
        indicatorButtons.removeAll()
        
        let count = steps.count
        for i in 0..<count {
            let button = UIButton(type: .custom)
            button.setTitle("\(i + 1)", for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            button.backgroundColor = .white
            button.layer.cornerRadius = 16
            button.layer.borderWidth = 1.0
            button.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
            
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.05
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.layer.shadowRadius = 4
            button.layer.masksToBounds = false
            
            button.tag = i
            button.addTarget(self, action: #selector(indicatorTapped(_:)), for: .touchUpInside)
            
            indicatorStackView.addArrangedSubview(button)
            indicatorButtons.append(button)
        }
        
        updateIndicators(activeIndex: 0)
    }
    
    @objc private func indicatorTapped(_ sender: UIButton) {
        let index = sender.tag
        scrollToIndex(index)
    }
    
    private func scrollToIndex(_ index: Int) {
        guard index >= 0 && index < steps.count else { return }
        let offset = CGFloat(index) * stepsCollectionView.bounds.width
        stepsCollectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
        updateIndicators(activeIndex: index)
    }
    
    private func updateIndicators(activeIndex: Int) {
        for (index, button) in indicatorButtons.enumerated() {
            let isActive = (index == activeIndex)
            UIView.performWithoutAnimation {
                if isActive {
                    button.backgroundColor = UIColor(red: 179/255, green: 183/255, blue: 238/255, alpha: 1.0)
                    button.layer.borderColor = UIColor.clear.cgColor
                    button.transform = .identity
                } else {
                    button.backgroundColor = .white
                    button.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
                    button.transform = .identity
                }
                button.layoutIfNeeded()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableHeightConstraint.constant = 420
    }
    
    @IBAction func continueButton(_ sender: Any) {
        if let bondName = bondName, let index = selectedActivityIndex, index < 3 {
            if let activity = activity {
                DataStore.shared.markActivityCompleted(activity: activity)
                DataStore.shared.unlockNextBondActivity(bondName: bondName, completedIndex: index)
                bondDelegate?.didCompleteBondActivity()
            }
            if let navController = self.navigationController {
                navController.popViewController(animated: true)
            } else {
                dismiss(animated: true)
            }
            return
        }

        let feedbackTitle = bondName ?? activitytitle

        let storyboard = UIStoryboard(name: "feedBack", bundle: nil)
        let feedbackVC = storyboard.instantiateViewController(
            withIdentifier: "FeedBackViewController"
        ) as! FeedBackViewController

        let feedbackItem = FeedBackGiven(
            title: feedbackTitle,   
            subTitle: "Tell us how this activity made you feel",
            imageName: "camera",
            userMessage: nil,
            selectedMood: nil
        )

        feedbackVC.feedbackItem = feedbackItem
        feedbackVC.activity = activity
        feedbackVC.flowSource = flowSource
        
        feedbackVC.bondName = bondName
        feedbackVC.selectedActivityIndex = selectedActivityIndex
        feedbackVC.bondDelegate = bondDelegate

        if let navController = self.navigationController {
            navController.pushViewController(feedbackVC, animated: true)
        } else {
            feedbackVC.modalPresentationStyle = .fullScreen
            present(feedbackVC, animated: true)
        }
    }
}

extension StepsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return steps.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StepCardCell", for: indexPath) as! StepCardCollectionViewCell
        
        let step = steps[indexPath.item]
        let model = StepCardModel(
            stepNumber: step.number,
            title: step.title,
            description: step.descriptionLabel,
            leftImageName: "Step_half",
            rightImageName: "Step_half_1",
            waveVariant: indexPath.item % 2
        )
        
        cell.configure(with: model)
        return cell
    }
}

extension StepsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.width
        guard width > 0 else { return }
        
        let progress = scrollView.contentOffset.x / width
        let page = Int(round(progress))
        let clampedPage = max(0, min(steps.count - 1, page))
        updateIndicators(activeIndex: clampedPage)
        
        // Map scroll delta directly to cell's swipe progress, which deforms the vector wave dynamically!
        for cell in stepsCollectionView.visibleCells {
            if let cardCell = cell as? StepCardCollectionViewCell,
               let indexPath = stepsCollectionView.indexPath(for: cardCell) {
                let itemIndex = CGFloat(indexPath.item)
                let diff = itemIndex - progress
                
                let distance = abs(diff)
                let cellSwipeProgress = max(0.0, min(1.0, 1.0 - distance))
                
                cardCell.swipeProgress = cellSwipeProgress
                cardCell.swipeOffset = max(-1.0, min(1.0, diff))
            }
        }
    }
}
