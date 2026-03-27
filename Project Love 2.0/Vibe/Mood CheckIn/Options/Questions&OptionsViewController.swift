import UIKit
import AVFoundation
import SwiftUI
import WebKit

// This protocol manages the communication back to the VibeViewController
protocol DailyExerciseFlowDelegate: AnyObject {
    func dailyExerciseDidFinish(with selection: DailyCheckInSelection)
}

class Questions_OptionsViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var optionsCollectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!

    // Result page outlets (4th step)
    @IBOutlet weak var resultContainerView: UIView!
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var resultVideoContainerView: UIView!
    @IBOutlet weak var resultTitleLabel: UILabel!
    @IBOutlet weak var resultDescriptionLabel: UILabel!

    // AVPlayer for result-page video
    private var resultQueuePlayer: AVQueuePlayer?
    private var resultPlayerLooper: AVPlayerLooper?
    private var resultPlayerLayer: AVPlayerLayer?

    // SwiftUI hosting controller for GIF-based animations
    private var gifHostingController: UIViewController?

    // MARK: - Properties
    weak var flowDelegate: DailyExerciseFlowDelegate?
    var currentStep = 0

    // Dictionary to store selection for each question step
    // Key = Step Index, Value = Selected Row Index
    var userSelections: [Int: Int] = [:]

    /// Set after the 3rd question to carry through to the result page
    private var resolvedSelection: DailyCheckInSelection?
    private var resolvedVibeTitle: VibeTitle?

    /// Total steps: 3 questions + 1 result page = 4
    private let totalSteps = 4

    var questionsList: [Question] {
        return DataStore.shared.dailyCheckInQuestions
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        optionsCollectionView.collectionViewLayout = generateLayout()
        setupCollectionView()
        updateUI()
        nextButton.configuration = .glass()
        nextButton.setTitle("Next", for: .normal)
    }

    private func setupCollectionView() {
        optionsCollectionView.delegate = self
        optionsCollectionView.dataSource = self

        // Ensure single selection is enabled
        optionsCollectionView.allowsSelection = true
        optionsCollectionView.allowsMultipleSelection = false

        let nib = UINib(nibName: "optionsCollectionViewCell", bundle: nil)
        optionsCollectionView.register(nib, forCellWithReuseIdentifier: "optionCell")
    }

    func generateLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(200)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)

        return UICollectionViewCompositionalLayout(section: section)
    }

    func updateUI() {
        let isResultPage = currentStep >= questionsList.count

        if isResultPage {
            // --- 4th step: Result page ---
            showResultPage()
        } else {
            // --- Steps 1-3: Question pages ---
            showQuestionPage()
        }

        // Progress bar: always reflects current step out of total
        let progressValue = Float(currentStep) / Float(totalSteps)
        progressView.setProgress(progressValue, animated: true)
    }

    // MARK: - Show Question Page

    private func showQuestionPage() {
        optionsCollectionView.isHidden = false
        resultContainerView.isHidden = true

        // Restore left-alignment for question text
        questionLabel.textAlignment = .left
        questionLabel.font = UIFont.preferredFont(forTextStyle: .title1)

        let currentQ = questionsList[currentStep]
        questionLabel.text = currentQ.title

        nextButton.setTitle("Next", for: .normal)
        nextButton.isEnabled = true
        optionsCollectionView.reloadData()
    }

    // MARK: - Show Result Page

    private func showResultPage() {
        optionsCollectionView.isHidden = true
        resultContainerView.isHidden = false

        // Center the "Relationship Vibe" title
        questionLabel.textAlignment = .center
        questionLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        questionLabel.text = "Relationship Vibe"

        // Hide the static image — video container takes over
        resultImageView.isHidden = true
        resultVideoContainerView.isHidden = false

        if let vibeTitle = resolvedVibeTitle {
            resultTitleLabel.text = vibeTitle.displayTitle

            // Justified alignment for the rich page description
            resultDescriptionLabel.text = vibeTitle.pageDescription
            resultDescriptionLabel.textAlignment = .justified

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                // Route: GIF for categories with a transparent GIF asset,
                //        video for everything else.
                self.playResultVideo(named: self.videoName(for: vibeTitle))
            }
        }

        // Progress bar at 100%
        progressView.setProgress(1.0, animated: true)

        nextButton.setTitle("Continue", for: .normal)
        nextButton.isEnabled = true
    }

    // MARK: - GIF / Video Playback

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Keep the AVPlayerLayer frame in sync on resize
        if let container = resultVideoContainerView {
            resultPlayerLayer?.frame = container.bounds
        }
    }

    /// Returns the GIF filename for a vibe category that has a transparent GIF asset.
    /// Return nil for categories that should use the video player instead.
    private func gifName(for vibeTitle: VibeTitle) -> String? {
        switch vibeTitle.name {
        case "The Always-Attached":  return "always_attached_doodles"
        // Add more GIF mappings here as you add assets, e.g.:
        // case "The In-Sync Duo":   return "in_sync_duo_doodles"
        default:                     return nil  // fall back to video
        }
    }

    /// Tears down both the GIF hosting controller and the AVPlayer.
    private func stopMedia() {
        // Remove GIF hosting controller
        gifHostingController?.willMove(toParent: nil)
        gifHostingController?.view.removeFromSuperview()
        gifHostingController?.removeFromParent()
        gifHostingController = nil

        // Remove AVPlayer
        resultPlayerLayer?.removeFromSuperlayer()
        resultQueuePlayer?.pause()
        resultQueuePlayer = nil
        resultPlayerLooper = nil
        resultPlayerLayer = nil
    }

    /// Maps each vibe category name to its bundled video filename (no extension).
    private func videoName(for vibeTitle: VibeTitle) -> String {
        switch vibeTitle.name {
        case "The Always-Attached":   return "Doodles_Animated_Video_Generation"
        case "The In-Sync Duo":       return "Doodles_Animated_Video_Generation"
        case "The Deep-Dive Duo":     return "Doodles_Animated_Video_Generation"
        case "The Independent Hearts":return "Doodles_Animated_Video_Generation"
        case "The Reassurers":        return "Doodles_Animated_Video_Generation"
        case "The Routine-Steady":    return "Doodles_Animated_Video_Generation"
        case "The Life-Logistics Team":return "Doodles_Animated_Video_Generation"
        case "The Wave-Riders":       return "Doodles_Animated_Video_Generation"
        case "The Power-Builders":    return "Doodles_Animated_Video_Generation"
        case "The Mending Souls":     return "Doodles_Animated_Video_Generation"
        case "The Fresh-Start Pair":  return "Doodles_Animated_Video_Generation"
        case "The High-Emotion Duo":  return "Doodles_Animated_Video_Generation"
        default:                      return "Doodles_Animated_Video_Generation"
        }
    }

    /// Loads and plays a looping video inside resultVideoContainerView.
    /// Uses AVQueuePlayer + AVPlayerLooper — the correct Swift 6 / concurrency-safe
    /// approach (avoids capturing non-Sendable AVPlayer in a @Sendable closure).
    private func playResultVideo(named videoName: String) {
        stopMedia()   // also removes any active GIF hosting controller

        // Locate the video file in the main bundle (.mp4 preferred, .mov fallback)
        guard let url = Bundle.main.url(forResource: videoName, withExtension: "mp4")
                     ?? Bundle.main.url(forResource: videoName, withExtension: "mov") else {
            return
        }

        let templateItem = AVPlayerItem(url: url)
        let queuePlayer  = AVQueuePlayer(items: [templateItem])
        // AVPlayerLooper keeps the queue player looping automatically
        let looper = AVPlayerLooper(player: queuePlayer, templateItem: templateItem)

        let playerLayer = AVPlayerLayer(player: queuePlayer)
        playerLayer.videoGravity = .resizeAspect
        playerLayer.frame = resultVideoContainerView.bounds
        // nil background = fully transparent behind the video content (no black fill)
        playerLayer.backgroundColor = nil

        // Make the container itself fully transparent
        resultVideoContainerView.isOpaque = false
        resultVideoContainerView.backgroundColor = .clear
        resultVideoContainerView.clipsToBounds = false
        resultVideoContainerView.layer.addSublayer(playerLayer)

        // Retain strongly so they aren't deallocated
        resultQueuePlayer  = queuePlayer
        resultPlayerLooper = looper
        resultPlayerLayer  = playerLayer

        queuePlayer.play()
    }

    // MARK: - Button Actions

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        let isResultPage = currentStep >= questionsList.count

        if isResultPage {
            // On the result page — "Continue" tapped → dismiss and notify delegate
            if let selection = resolvedSelection {
                flowDelegate?.dailyExerciseDidFinish(with: selection)
            }
            dismiss(animated: true)
            return
        }

        // On a question page — require selection before advancing
        guard userSelections[currentStep] != nil else { return }

        if currentStep < questionsList.count - 1 {
            // Advance to next question
            currentStep += 1
            updateUI()
        } else {
            // Last question answered — resolve vibe title and go to result page
            let selectedMood = DataStore.shared.getHerMood()?.title ?? "Calm"

            let vibeAnswer = questionsList[0].options[userSelections[0] ?? 0]
            let needAnswer = questionsList[1].options[userSelections[1] ?? 0]
            let closenessAnswer = questionsList[2].options[userSelections[2] ?? 0]

            let selection = DailyCheckInSelection(
                mood: selectedMood,
                closeness: closenessAnswer,
                vibe: vibeAnswer,
                need: needAnswer
            )

            _ = DataStore.shared.getSuggestedActivitiesForDailyCheckIn(selection: selection)

            // Resolve vibe title
            let vibeTitle = DataStore.shared.resolveVibeTitle(
                vibe: vibeAnswer,
                need: needAnswer,
                closeness: closenessAnswer
            )

            self.resolvedSelection = selection
            self.resolvedVibeTitle = vibeTitle

            // Advance to the result page (step 3 → step 4)
            currentStep = questionsList.count
            updateUI()
        }
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        if currentStep > 0 {
            // If on result page, go back to last question
            if currentStep >= questionsList.count {
                currentStep = questionsList.count - 1
            } else {
                currentStep -= 1
            }
            updateUI()
        } else {
            dismiss(animated: true)
        }
    }
}

// MARK: - CollectionView DataSource & Delegate
extension Questions_OptionsViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard currentStep < questionsList.count else { return 0 }
        return questionsList[currentStep].options.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "optionCell", for: indexPath) as! optionsCollectionViewCell

        let optionTitle = questionsList[currentStep].options[indexPath.item]
        cell.configure(with: optionTitle)

        // UI RECALL: Check if this specific item was previously selected
        if let selectedRow = userSelections[currentStep], selectedRow == indexPath.item {
            cell.isSelected = true
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        } else {
            cell.isSelected = false
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // STORE SELECTION: Save the choice for this step
        userSelections[currentStep] = indexPath.item
    }
}
