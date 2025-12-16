//

import UIKit
import Foundation

class ActivitiesForHerViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var activityCollectionView: UICollectionView!
    
    var activitiesForHer = dataStore.getActivities()
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Count:", activitiesForHer.count)
        // Do any additional setup after loading the view.
        activityCollectionView.dataSource = self
        activityCollectionView.delegate = self
//        if let layout = activityCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            layout.itemSize = CGSize(width: view.bounds.width - 32, height: 120)
//            layout.minimumLineSpacing = 12
//            layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
//        }
        registerCells()
    }
   


    func registerCells() {
        activityCollectionView.register(UINib(nibName: "ActivityCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "activity_cell")
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
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let destinationVC = SmallModalViewController()
//        destinationVC.modalPresentationStyle = .overFullScreen
//        destinationVC.modalTransitionStyle = .crossDissolve
//        present(destinationVC, animated: true)
//    }
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let destinationVC = SmallModalViewController()
//        // MATCH activity and modal data by title
//        let selectedActivity = activitiesForHer[indexPath.row]
//        if let modalData = dataStore.smallmodal.first(where: { $0.title == selectedActivity.name }) {
//            destinationVC.selectedActivity = modalData
//        }
//
//        destinationVC.modalPresentationStyle = .overFullScreen
//        //destinationVC.modalTransitionStyle = .coverVertical
//        
//        present(destinationVC, animated: false)
//    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//
//        let destinationVC = storyboard.instantiateViewController(withIdentifier: "SmallModalViewController") as! SmallModalViewController
        let destinationVC = SmallModalViewController(nibName: "SmallModalViewController", bundle: nil)

        let selectedActivity = activitiesForHer[indexPath.row]

        if let modalData = dataStore.smallmodal.first(where: { $0.title == selectedActivity.name }) {
            destinationVC.selectedActivity = modalData
        }

        destinationVC.modalPresentationStyle = .overFullScreen
        present(destinationVC, animated: false)
    }




}

extension ActivitiesForHerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 32 // 16 left + 16 right
        let width = collectionView.bounds.width - padding
        let height: CGFloat = 115 // Adjust this based on your cell's content
        return CGSize(width: width, height: height)
    }
}
