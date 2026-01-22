import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var viewForIcon: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
   
    private var user: UserProfile!
    private let sections = DataStore.shared.profileSections
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        user = DataStore.shared.userProfile
       
        nameLabel.text = user.name
        emailLabel.text = user.email
        profileImage.image = UIImage(named: user.profileImageName)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeButtonTapped)
        )
        
        user = DataStore.shared.userProfile
        setupUI()
       
    }

    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        
        nameLabel.text = user.name
        emailLabel.text = user.email
        
        profileImage.image = UIImage(named: user.profileImageName)
    }
    
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = sections[indexPath.section].items[indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.textLabel?.font = .systemFont(ofSize: 16)
        cell.textLabel?.textColor = .label
        cell.textLabel?.textAlignment = .left
        
        cell.accessoryType = item.showsChevron ? .disclosureIndicator : .none
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = sections[indexPath.section].items[indexPath.row]
        
        if item.title == "Personal Info" {
            let storyboard = UIStoryboard(name: "Profile_Info", bundle: nil)
            let vc = storyboard.instantiateViewController(
                withIdentifier: "Personal_InfoViewController"
            ) as! Personal_InfoViewController

            vc.title = "Personal Info"

            navigationController?.pushViewController(vc, animated: true)


        }
        if item.title == "Status" {
            let storyboard = UIStoryboard(name: "Activity_Status", bundle: nil)
            let vc = storyboard.instantiateViewController(
                withIdentifier: "ActivityStatsViewController"
            ) as! ActivityStatsViewController
            navigationController?.pushViewController(vc, animated: true)

        }

    }
    
}
