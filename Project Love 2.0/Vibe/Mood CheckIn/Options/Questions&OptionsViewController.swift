import UIKit

// This protocol manages the communication back to the VibeViewController
protocol DailyExerciseFlowDelegate: AnyObject {
    func dailyExerciseDidFinish()
}

class Questions_OptionsViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var optionsCollectionView: UICollectionView!
    
    @IBOutlet weak var nextButton: UIButton!
    // MARK: - Properties
    weak var flowDelegate: DailyExerciseFlowDelegate?
    var currentStep = 0
    
    // NEW: Dictionary to store selection for each question step
    // Key = Step Index, Value = Selected Row Index
    var userSelections: [Int: Int] = [:]
    
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
        
        // REDUCE these insets slightly to stop clipping against the container
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(200) // Increase this slightly so the bottom isn't cut
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        // Add padding to the whole section so cards don't touch the screen edges
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        
        return UICollectionViewCompositionalLayout(section: section)
    }

    func updateUI() {
        guard currentStep < questionsList.count else { return }
        let currentQ = questionsList[currentStep]
        
        questionLabel.text = currentQ.title
        
        let totalQuestions = Float(questionsList.count)
        let progressValue = Float(currentStep ) / totalQuestions
        progressView.setProgress(progressValue, animated: true)
        
        optionsCollectionView.reloadData()
    }

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        if userSelections[currentStep] != nil {
                if currentStep < questionsList.count - 1 {
                    currentStep += 1
                    updateUI()
                } else {
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

                    _ = DataStore.shared.getSuggestedActivitiesForDailyCheckIn(selection: selection, limit: 3)
                    flowDelegate?.dailyExerciseDidFinish()
                    dismiss(animated: true)

                }
            }
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        if currentStep > 0 {
            currentStep -= 1
            updateUI()
        } else {
            dismiss(animated: true)
        }
    }
}

// MARK: - CollectionView DataSource & Delegate
extension Questions_OptionsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
        print("Step \(currentStep) selection: \(questionsList[currentStep].options[indexPath.item])")
    }
}
