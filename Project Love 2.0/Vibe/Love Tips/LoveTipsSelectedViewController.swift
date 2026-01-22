import UIKit

class LoveTipsSelectedViewController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showMoreLabel: UILabel!
    @IBOutlet weak var chevronImageView: UIImageView!
    @IBOutlet weak var showMoreStack: UIStackView!

    var selectedTips: [Tip] = []
    private var displayedTips: [Tip] = []
    private var isExpanded = false
    private var completedTipTitles: Set<String> = [] // Track which ones are selected
    
    weak var delegate: LoveTipsSelectionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let sheet = self.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.selectedDetentIdentifier = .medium
            }
        setupTableView()
        setupGestures()
        setupCloseButton()
        setDescriptionLabel()
        displayedTips = Array(selectedTips.prefix(3))
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .appBackground
    }

    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(showMoreTapped))
        showMoreStack.addGestureRecognizer(tap)
    }

    private func setupCloseButton() {
        closeButton.configuration = .glass()
        closeButton.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(weight: .medium)), for: .normal)
    }

    private func setDescriptionLabel() {
        descriptionLabel.text = "Select the tips you actually completed for your partner."
    }

    @IBAction func closeButtonTapped(_ sender: UIButton) {
        delegate?.didUpdateSelectedTips(selectedTips)
        dismiss(animated: true)
    }
    
    @IBAction func addMoreTipsTapped(_ sender: UIButton) {
        // Direct back to the selection screen
        let storyboard = UIStoryboard(name: "LoveTips", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoveTipsVC") as! LoveTipsViewController
        vc.delegate = delegate
        vc.selectedTips = selectedTips // Pass current list to skip duplicates
        present(vc, animated: true)
    }

    @IBAction func confirmSelectionTapped(_ sender: UIButton) {
        // Filter out the completed tips from the list
        let remainingTips = selectedTips.filter { !completedTipTitles.contains($0.title) }
        
        delegate?.didUpdateSelectedTips(remainingTips)
       
        self.view.window?.rootViewController?.dismiss(animated: true)
    }

    @objc private func showMoreTapped() {
        isExpanded.toggle()
            displayedTips = isExpanded ? selectedTips : Array(selectedTips.prefix(3))
            showMoreLabel.text = isExpanded ? "Show less" : "Show more"
            chevronImageView.image = UIImage(systemName: isExpanded ? "chevron.up" : "chevron.down")
            
            // Smooth transition between sheet sizes
            sheetPresentationController?.animateChanges {
                self.sheetPresentationController?.selectedDetentIdentifier = isExpanded ? .large : .medium
            }
            tableView.reloadData()
    }
}

extension LoveTipsSelectedViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedTips.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tipOptionSelected", for: indexPath) as! LoveTipsSelectedTableViewCell
        let tip = displayedTips[indexPath.row]
        let isDone = completedTipTitles.contains(tip.title)
        cell.configure(option: tip.title, isSelected: isDone)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tipTitle = displayedTips[indexPath.row].title
        if completedTipTitles.contains(tipTitle) {
            completedTipTitles.remove(tipTitle)
        } else {
            completedTipTitles.insert(tipTitle)
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let removedTip = displayedTips[indexPath.row]
            displayedTips.remove(at: indexPath.row)
            if let index = selectedTips.firstIndex(where: { $0.title == removedTip.title }) {
                selectedTips.remove(at: index)
            }
            completedTipTitles.remove(removedTip.title)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
