import UIKit
import Supabase

class onboardingQuestionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    // MARK: - Properties
    var questions: [QnAQuestion] = []
    var currentIndex = 0
    var selectedIndex: Int? = nil
    // Change to store multiple indices for the multi-choice question
    // Key: Question Index, Value: Set of selected option indices
    var selectedAnswers: [Int: Set<Int>] = [:]
    var isEditingMode: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        questions = DataStore.shared.currentQnA.questions
        selectedAnswers = DataStore.shared.userProfile?.savedPreferences ?? [:]
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0

        updateUI()
    }
    
    private struct AssessmentUpdatePayload: Encodable {
        let gender: String
        let assessment_answers: [String: [Int]]
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.layoutIfNeeded()
        tableHeightConstraints.constant = tableView.contentSize.height
    }
    
    func updateUI() {
        guard currentIndex < questions.count else { return }
        
        let q = questions[currentIndex]
        questionLabel.text = q.questionText
        
        // Progress UI
        let totalQuestions = Float(questions.count)
        let progressValue = Float(currentIndex + 1) / totalQuestions
        progressBar.setProgress(progressValue, animated: true)
        backButton.isHidden = (currentIndex == 0)
        tableView.allowsMultipleSelection = (currentIndex == questions.count - 1)
        tableView.reloadData()

        DispatchQueue.main.async {
            self.tableHeightConstraints.constant = self.tableView.contentSize.height
        }

        tableView.layer.cornerRadius = 20
        tableView.layer.masksToBounds = true
        tableView.backgroundColor = .white
        if isEditingMode && currentIndex == questions.count - 1 {
            nextButton.setTitle("Save", for: .normal)
        } else {
            nextButton.setTitle("Next", for: .normal)
        }
    }
    
    // MARK: - Actions
    @IBAction func backPressed(_ sender: Any) {
        if currentIndex > 0 {
            currentIndex -= 1
            updateUI()
        }
    }

    @IBAction func NextPressed(_ sender: Any) {
        let currentSelections = selectedAnswers[currentIndex] ?? []
            if currentSelections.isEmpty {
                let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
                animation.timingFunction = CAMediaTimingFunction(name: .linear)
                animation.duration = 0.6
                animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
                tableView.layer.add(animation, forKey: "shake")
                return
            }

            if currentIndex < questions.count - 1 {
                currentIndex += 1
                updateUI()
            } else {
                Task {
                    do {
                        try await self.persistUserGender()
                        DataStore.shared.userProfile?.savedPreferences = self.selectedAnswers
                        await DataStore.shared.refreshUserProfileFromSupabase()
                        DataStore.shared.reloadGenderDependentContent()
                        NotificationCenter.default.post(name: .preferencesDidChange, object: nil)

                        await MainActor.run {
                            if self.isEditingMode {
                                self.navigationController?.setNavigationBarHidden(false, animated: true)
                                if let nav = self.navigationController {
                                    nav.popViewController(animated: true)
                                } else {
                                    self.dismiss(animated: true)
                                }
                            } else {
                                UserDefaults.standard.set(true, forKey: "hasCompletedAssessment")
                                guard let parentNavController = self.presentingViewController as? UINavigationController
                                        ?? self.presentingViewController?.navigationController else {
                                    return
                                }

                                self.dismiss(animated: true) {
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "infoPageViewController") as! infoPageViewController
                                    parentNavController.pushViewController(vc, animated: true)
                                }
                            }
                        }
                    } catch {
                    }
                }
            }
    }
    
    private func persistUserGender() async throws {
        guard
            let genderQuestionIndex = questions.firstIndex(where: { $0.questionText.lowercased().contains("gender") }),
            let selectedOptionIndex = selectedAnswers[genderQuestionIndex]?.first,
            questions[genderQuestionIndex].options.indices.contains(selectedOptionIndex)
        else {
            throw NSError(
                domain: "onboardingQuestionViewController",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Gender selection is missing"]
            )
        }

        guard let userId = SupabaseManager.shared.currentUserId else {
            throw NSError(
                domain: "onboardingQuestionViewController",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "No authenticated user id"]
            )
        }

        let gender = questions[genderQuestionIndex].options[selectedOptionIndex].text
            .trimmingCharacters(in: .whitespacesAndNewlines)

        var answersDict: [String: [Int]] = [:]
        for (key, value) in selectedAnswers {
            answersDict[String(key)] = Array(value)
        }

        let payload = AssessmentUpdatePayload(
            gender: gender,
            assessment_answers: answersDict
        )

        try await SupabaseManager.shared.client
            .from("users")
            .update(payload)
            .eq("user_id", value: userId.uuidString)
            .execute()

        UserDefaults.standard.set(gender, forKey: "userGender")
    }

    // MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard currentIndex < questions.count else { return 0 }
        return questions[currentIndex].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath) as! OptionTableViewCell

        let currentOption = questions[currentIndex].options[indexPath.row]
        let isLastQuestion = (currentIndex == questions.count - 1)
        let isSelected = selectedAnswers[currentIndex]?.contains(indexPath.row) ?? false
        cell.configure(option: currentOption.text, isSelected: isSelected, isMultiSelect: isLastQuestion)
        
        cell.contentView.backgroundColor = .white
        cell.backgroundColor = .clear
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.05
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowRadius = 4

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let isLastQuestion = (currentIndex == questions.count - 1)

        if isLastQuestion {
            if selectedAnswers[currentIndex] == nil {
                selectedAnswers[currentIndex] = []
            }
            if selectedAnswers[currentIndex]!.contains(indexPath.row) {
                selectedAnswers[currentIndex]!.remove(indexPath.row)
            } else {
                selectedAnswers[currentIndex]!.insert(indexPath.row)
            }
        } else {
            selectedAnswers[currentIndex] = [indexPath.row]
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // Only relevant for the multi-choice last question
        selectedAnswers[currentIndex]?.remove(indexPath.row)
        tableView.reloadData()
    }
}
