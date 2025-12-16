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
}
extension ActivitiesForHerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 32 // 16 left + 16 right
        let width = collectionView.bounds.width - padding
        let height: CGFloat = 115 // Adjust this based on your cell's content
        return CGSize(width: width, height: height)
    }
}
