import UIKit

class LoveTipsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showMoreLabel: UILabel!
    @IBOutlet weak var chevronImageView: UIImageView!
    @IBOutlet weak var showMoreStack: UIStackView!

    var tips: [Tip] = []
    private var allTips: [Tip] = []
    private var isExpanded = false
    var selectedOptions: Set<Int> = []
    
    weak var delegate: LoveTipsSelectionDelegate?
    var selectedTips: [Tip] = [] // Passed from VibeVC

    override func viewDidLoad() {
        super.viewDidLoad()
        // Ensure the sheet starts at medium
            if let sheet = self.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.selectedDetentIdentifier = .medium
            }
        setupTableView()
        setDescriptionLabel()

        // Filter out tips that are already selected to avoid duplicates
        let fullList = dataStore.getAllTips()
        allTips = fullList.filter { tip in
            !selectedTips.contains(where: { $0.title == tip.title })
        }
        
        tips = Array(allTips.prefix(3))

        let tap = UITapGestureRecognizer(target: self, action: #selector(showMoreTapped))
        showMoreStack.addGestureRecognizer(tap)

        closeButton.configuration = .glass()
        closeButton.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(weight: .medium)), for: .normal)
    }

    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction func confirmSelectionTapped(_ sender: UIButton) {
        let newlySelected = selectedOptions.map { tips[$0] }
        
        // Update the master list
        selectedTips.append(contentsOf: newlySelected)
        delegate?.didUpdateSelectedTips(selectedTips)

        // Show the summary/review screen
        let vc = UIStoryboard(name: "LoveTipsSelected", bundle: nil).instantiateViewController(withIdentifier: "LoveTipsSelectedViewController") as! LoveTipsSelectedViewController
        vc.selectedTips = selectedTips
        vc.delegate = delegate
        
        // Present review screen
        present(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tips.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tipOption", for: indexPath) as! TipTableViewCell
        let tip = tips[indexPath.row]
        let isSelected = selectedOptions.contains(indexPath.row)
        cell.configure(option: tip.title, isSelected: isSelected)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedOptions.contains(indexPath.row) {
            selectedOptions.remove(indexPath.row)
        } else {
            selectedOptions.insert(indexPath.row)
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }

    @objc func showMoreTapped() {
        isExpanded.toggle()
            tips = isExpanded ? allTips : Array(allTips.prefix(3))
            showMoreLabel.text = isExpanded ? "Show less" : "Show more"
            chevronImageView.image = UIImage(systemName: isExpanded ? "chevron.up" : "chevron.down")

            // This triggers the sheet to grow/shrink smoothly
            sheetPresentationController?.animateChanges {
                self.sheetPresentationController?.selectedDetentIdentifier = isExpanded ? .large : .medium
            }
            tableView.reloadData()
    }

    func setDescriptionLabel() {
        descriptionLabel.text = "Here are a few quick ways to brighten her day. Pick one that feels right!"
    }

    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
}
