import UIKit

class QnAViewController: UIViewController {

    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var questionTextView: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addQuestionTextView: UIView!
    @IBOutlet weak var addOptionTextView: UIView!
    @IBOutlet weak var doneTapped: UIButton!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    let store = DataStore.shared
    var currentQuestionIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupGestures()
        bindQuestionText()
    }

    private func setupUI() {
        doneTapped.configuration = .glass()
        doneTapped.setTitle("Done", for: .normal)

        [
            titleTextView,
            questionTextView,
            tableView,
            addOptionTextView,
            addQuestionTextView
        ].forEach {
            $0?.layer.cornerRadius = 10
            $0?.layer.masksToBounds = true
        }
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }

    private func setupGestures() {

        let addOptionTap = UITapGestureRecognizer(
            target: self,
            action: #selector(addOptionTapped)
        )
        addOptionTextView.addGestureRecognizer(addOptionTap)
        addOptionTextView.isUserInteractionEnabled = true

        let addQuestionTap = UITapGestureRecognizer(
            target: self,
            action: #selector(addQuestionTapped)
        )
        addQuestionTextView.addGestureRecognizer(addQuestionTap)
        addQuestionTextView.isUserInteractionEnabled = true
    }

    private func bindQuestionText() {
        questionTextView.addTarget(
            self,
            action: #selector(questionTextChanged(_:)),
            for: .editingChanged
        )
    }

    // Update this function in your QnAViewController
    @objc private func addOptionTapped() {
        let newOption = QnAOption(text: "", isSelected: false)
        store.currentQnA.questions[currentQuestionIndex].options.append(newOption)
        
        tableView.reloadData()
        
        // Update the height constraint so the table expands
        // Assuming a standard row height of 44 or 50
        tableViewHeightConstraint.constant = CGFloat(store.currentQnA.questions[currentQuestionIndex].options.count * 50)
        self.view.layoutIfNeeded()
    }

    @objc private func addQuestionTapped() {
        // 1. Save current state (optional, already handled by binding)
        
        // 2. Create new question
        let newQuestion = QnAQuestion(questionText: "", options: [])
        store.currentQnA.questions.append(newQuestion)
        
        // 3. Move to the new index
        currentQuestionIndex = store.currentQnA.questions.count - 1

        // 4. Reset UI for new question
        questionTextView.text = ""
        tableViewHeightConstraint.constant = 0 // Reset height for new question
        tableView.reloadData()
        
        print("Now editing Question: \(currentQuestionIndex + 1)")
    }
    @objc private func questionTextChanged(_ sender: UITextField) {
        store.currentQnA.questions[currentQuestionIndex]
            .questionText = sender.text ?? ""
    }

    @IBAction func doneButtonTapped(_ sender: UIButton) {
        store.currentQnA.title = titleTextView.text ?? ""
        print("FINAL QnA:", store.currentQnA)
    }
}

// MARK: - TableView

extension QnAViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        store.currentQnA.questions[currentQuestionIndex]
            .options.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "QnACell",
            for: indexPath
        ) as! QnATableViewCell

        let option = store.currentQnA.questions[currentQuestionIndex]
            .options[indexPath.row]

        cell.configure(option: option)

        cell.radioTapAction = { [weak self] in
            self?.selectOption(at: indexPath.row)
        }

        cell.optionTextField.tag = indexPath.row
        cell.optionTextField.addTarget(
            self,
            action: #selector(optionTextChanged(_:)),
            for: .editingChanged
        )

        return cell
    }

    private func selectOption(at index: Int) {
        for i in 0..<store.currentQnA.questions[currentQuestionIndex].options.count {
            store.currentQnA.questions[currentQuestionIndex]
                .options[i].isSelected = (i == index)
        }
        tableView.reloadData()
    }

    @objc private func optionTextChanged(_ sender: UITextField) {
        let index = sender.tag

        guard index <
            store.currentQnA.questions[currentQuestionIndex]
                .options.count else { return }

        store.currentQnA.questions[currentQuestionIndex]
            .options[index].text = sender.text ?? ""
    }
}

