import UIKit

class QnAViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Data Source
    var questions: [[String]] = [[""]]   // Each question has options

    // MARK: - Outlets
    @IBOutlet weak var backTapped: UIButton!
    @IBOutlet weak var doneTapped: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        backTapped.configuration = .glass()
        doneTapped.configuration = .glass()
        doneTapped.setTitle("Done", for: .normal)

        backTapped.setImage(
            UIImage(systemName: "chevron.left",
                    withConfiguration: UIImage.SymbolConfiguration(weight: .medium)),
            for: .normal
        )

        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
                                   action: #selector(addNewQuestion))
        )
    }

    // MARK: - Add New Question
    @objc func addNewQuestion() {
        questions.append([""])
        tableView.insertSections(IndexSet(integer: questions.count - 1),
                                 with: .automatic)
    }

    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return questions.count
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return questions[section].count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "QnACell",
            for: indexPath
        )

        // Question TextView (only for first row)
        if indexPath.row == 0,
           let questionTextView = cell.viewWithTag(100) as? UITextView {
            questionTextView.text = "Enter Question"
        }

        // Option Text
        if let optionField = cell.viewWithTag(300) as? UITextView {
            optionField.text = questions[indexPath.section][indexPath.row]
            optionField.tag = (indexPath.section * 1000) + indexPath.row
            optionField.delegate = self
        }

        // Add Option Button
        if let addButton = cell.viewWithTag(200) as? UIButton {
            addButton.isHidden = indexPath.row != 0
            addButton.tag = indexPath.section
            addButton.addTarget(self,
                                action: #selector(addOption(_:)),
                                for: .touchUpInside)
        }

        return cell
    }

    // MARK: - Add Option
    @objc func addOption(_ sender: UIButton) {
        let section = sender.tag
        questions[section].append("")

        tableView.insertRows(
            at: [IndexPath(row: questions[section].count - 1,
                           section: section)],
            with: .automatic
        )
    }

    // MARK: - Delete Option
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            questions[indexPath.section].remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    // MARK: - Section Spacing
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return 16
    }

    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        UIView()
    }

    // MARK: - Actions
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func doneTapped(_ sender: Any) {
        print(questions)
    }
}

// MARK: - UITextView Delegate
extension QnAViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let section = textView.tag / 1000
        let row = textView.tag % 1000
        questions[section][row] = textView.text
    }
}

