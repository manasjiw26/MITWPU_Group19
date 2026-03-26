import UIKit

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
    @IBOutlet weak var resultTitleLabel: UILabel!
    @IBOutlet weak var resultDescriptionLabel: UILabel!

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

        questionLabel.text = "Relationship Vibe"

        resultImageView.image = UIImage(named: "DailyCheckIn")

        if let vibeTitle = resolvedVibeTitle {
            resultTitleLabel.text = vibeTitle.displayTitle
            resultDescriptionLabel.text = vibeTitle.description
        }

        // Progress bar at 100%
        progressView.setProgress(1.0, animated: true)

        nextButton.setTitle("Continue", for: .normal)
        nextButton.isEnabled = true
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
