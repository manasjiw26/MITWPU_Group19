import UIKit

// For Selected Tips Flow
protocol LoveTipsSelectionDelegate: AnyObject {
    func didUpdateSelectedTips(_ tips: [Tip])
}

class VibeViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var vibeCollectionView: UICollectionView!
    var days: [DayInfo] = []
    var makeSmileData: [MakeSmile] = []
    var didScrollToMiddle = false
    var BuildBond: [BuildYourBond] = []
    var selectedbondOption: BuildYourBond?
    
    // For Love Tips - Source of Truth
    var selectedTips: [Tip] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        makeSmileData = [
            MakeSmile(types: "Send Lovenote", imageName: "pencil.and.list.clipboard"),
            MakeSmile(types: "Love Tips", imageName: "lightbulb.max"),
            MakeSmile(types: "Activities for Her", imageName: "checklist")
        ]
        days = dataStore.getLastAndNext15Days()
        BuildBond = dataStore.loadBuildYourbond()
        registerCell()
        vibeCollectionView.setCollectionViewLayout(generateLayout(), animated: true)
        vibeCollectionView.dataSource = self
        vibeCollectionView.delegate = self
        
        if !didScrollToMiddle {
            let mid = days.count / 2
            let indexPath = IndexPath(item: mid, section: 0)
            didScrollToMiddle = true
        }
    }
    
    func registerCell() {
        vibeCollectionView.register(UINib(nibName: "CalendarCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "calendar_cell")
        vibeCollectionView.register(UINib(nibName: "MoodCardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "mood_cell")
        vibeCollectionView.register(UINib(nibName: "MakeHerSmileCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "makeSmile_cell")
        vibeCollectionView.register(UINib(nibName: "BuildYourBondCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "bond_cell")
        vibeCollectionView.register(UINib(nibName: "TitleCollectionResuableView", bundle: nil), forSupplementaryViewOfKind: "title", withReuseIdentifier: "title_cell")
    }
    
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { section, env in
            let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(57))
            let titleItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: titleSize, elementKind: "title", alignment: .top)
            
            if section == 0 {
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(52), heightDimension: .absolute(72))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(2200), heightDimension: .absolute(72))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(20)
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 0)
                return section
            } else if section == 1 {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(160))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(160))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 15, trailing: 16)
                return section
            } else if section == 2 {
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(100), heightDimension: .absolute(120))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(120))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .flexible(15)
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 30, bottom: 25, trailing: 30)
                section.boundarySupplementaryItems = [titleItem]
                return section
            } else {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(260), heightDimension: .absolute(290))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                section.interGroupSpacing = 16
                section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 16, bottom: 12, trailing: 16)
                section.boundarySupplementaryItems = [titleItem]
                return section
            }
        }
        return layout
    }
    
    @IBAction func profileTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "HomePageProfileNew", bundle: nil)
        let profileVC = storyboard.instantiateInitialViewController()!
        let navVC = UINavigationController(rootViewController: profileVC)
        navVC.modalPresentationStyle = .pageSheet
        present(navVC, animated: true)
    }
}

extension VibeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { return 4 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return 0 }
        else if section == 1 { return 1 }
        else if section == 2 { return makeSmileData.count }
        else { return BuildBond.count }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = vibeCollectionView.dequeueReusableCell(withReuseIdentifier: "calendar_cell", for: indexPath) as! CalendarCollectionViewCell
            let dayInfo = days[indexPath.row]
            if Int(dayInfo.date) == Calendar.current.component(.day, from: Date()) { cell.configureTodayCell(day: dayInfo) }
            else { cell.configureCell(day: dayInfo) }
            return cell
        } else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mood_cell", for: indexPath) as! MoodCardCollectionViewCell
            cell.configureCell()
            return cell
        } else if indexPath.section == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "makeSmile_cell", for: indexPath) as! MakeHerSmileCollectionViewCell
            cell.configureCell(item: makeSmileData[indexPath.row])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bond_cell", for: indexPath) as! BuildYourBondCollectionViewCell
            cell.configureCell(bond: BuildBond[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let title = collectionView.dequeueReusableSupplementaryView(ofKind: "title", withReuseIdentifier: "title_cell", for: indexPath) as! TitleCollectionResuableView
        if indexPath.section == 2 { title.configureTitle(title: "Make Her Smile", subtitle: "") }
        else if indexPath.section == 3 { title.configureTitle(title: "Build Your Bond", subtitle: "Focus on one theme, grow as a couple.") }
        return title
    }
}

extension VibeViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let storyboard = UIStoryboard(name: "MoodCheckIn", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "MoodViewController") as? MoodViewController {
                navigationController?.pushViewController(vc, animated: true)
            }
            return
        }

        if indexPath.section == 2 {
            switch indexPath.row {
            case 0: performSegue(withIdentifier: "openLoveNote", sender: nil)
                // Inside didSelectItemAt for Case 1 (Love Tips)
                case 1:
                    let vc: UIViewController
                    if selectedTips.isEmpty {
                        let storyboard = UIStoryboard(name: "LoveTips", bundle: nil)
                        let loveTipsVC = storyboard.instantiateViewController(withIdentifier: "LoveTipsVC") as! LoveTipsViewController
                        loveTipsVC.selectedTips = self.selectedTips
                        loveTipsVC.delegate = self
                        vc = loveTipsVC
                    } else {
                        let selectedVC = UIStoryboard(name: "LoveTipsSelected", bundle: nil)
                            .instantiateViewController(withIdentifier: "LoveTipsSelectedViewController") as! LoveTipsSelectedViewController
                        selectedVC.selectedTips = self.selectedTips
                        selectedVC.delegate = self
                        vc = selectedVC
                    }

                    // Configure the Sheet for both ViewControllers
                    if let sheet = vc.sheetPresentationController {
                        sheet.detents = [.medium(), .large()] // Starts at medium, allows large
                        sheet.prefersGrabberVisible = true     // Optional: shows the little bar at the top
                        sheet.selectedDetentIdentifier = .medium // Force it to start small
                    }
                    
                    present(vc, animated: true)
            case 2: performSegue(withIdentifier: "ActivityForHerShow", sender: self)
            default: break
            }
            return
        }

        if indexPath.section == 3 {
            selectedbondOption = BuildBond[indexPath.row]
            performSegue(withIdentifier: "BUBSheet", sender: nil)
            return
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BUBSheet" {
            if let dest = segue.destination as? BuildYourBondViewController {
                dest.selectedbondOption = selectedbondOption
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vibeCollectionView.reloadData()
    }
}

extension VibeViewController: LoveTipsSelectionDelegate {
    func didUpdateSelectedTips(_ tips: [Tip]) {
        self.selectedTips = tips
        self.vibeCollectionView.reloadData()
    }
}
