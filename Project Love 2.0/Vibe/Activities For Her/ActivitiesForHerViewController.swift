//

import UIKit
import Foundation

class ActivitiesForHerViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var activityCollectionView: UICollectionView!
    
    var activitiesForHer: [Activity] {
        return DataStore.shared.getActivities()
    }
    var screenTitle: String = "Activities"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityCollectionView.dataSource = self
        activityCollectionView.delegate = self
        title = screenTitle

        registerCells()
       
    }

    func registerCells() {
        activityCollectionView.register(UINib(nibName: "ActivityCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "activity_cell")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityCollectionView.reloadData()
    }
}



extension ActivitiesForHerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activitiesForHer.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activity_cell", for: indexPath) as! ActivityCollectionViewCell
        cell.configureCells(activity: activitiesForHer[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedActivity = activitiesForHer[indexPath.row]
        let destinationVC = SmallModalViewController( nibName: "SmallModalViewController", bundle: nil )
        destinationVC.delegate = self

        destinationVC.selectedActivity = selectedActivity

        if let modalData = dataStore.smallmodal.first(where: { $0.title == selectedActivity.name }) {
            destinationVC.modalData = modalData
        }

        destinationVC.flowSource = .activitiesForHer
        destinationVC.modalPresentationStyle = .overFullScreen
        present(destinationVC, animated: false)

    }

}

extension ActivitiesForHerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 32
        let width = collectionView.bounds.width - padding
        let height: CGFloat = 115 
        return CGSize(width: width, height: height)
    }
}
extension ActivitiesForHerViewController: SmallModalDelegate {
    func didStartActivity() {
        activityCollectionView.reloadData()
    }
}
