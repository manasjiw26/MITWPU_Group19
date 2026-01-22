//
//  ActivityStatsViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 12/01/26.
//

import UIKit

class ActivityStatsViewController: ViewController {
    private let ongoingActivityCountKey = "ongoingActivityCount"
    private let completedActivityCountKey = "completedActivityCount"
    private var statsData: [ActivityStats] = []

    @IBOutlet weak var collectionView: UICollectionView!

        override func viewDidLoad() {
            super.viewDidLoad()
            collectionView.delegate = self
                collectionView.dataSource = self

                statsData = [
                    ActivityStats(types: "Ongoing", imageName: "clock.arrow.circlepath", count: 0),
                    ActivityStats(types: "Scheduled", imageName: "calendar", count: 0),
                    ActivityStats(types: "Completed", imageName: "checkmark.circle", count: 0)
                ]
        }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Ongoing
        statsData[0].count = UserDefaults.standard.integer(
            forKey: ongoingActivityCountKey
        )

        // Completed
        statsData[2].count = UserDefaults.standard.integer(
            forKey: completedActivityCountKey
        )

        collectionView.reloadData()
    }

    }
    
    extension ActivityStatsViewController: UICollectionViewDataSource {

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return statsData.count
        }

        func collectionView(
            _ collectionView: UICollectionView,
            cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell {

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ActivityStatsCell",
                for: indexPath
            ) as! ActivityStatsProfileCollectionViewCell

            cell.configureCell(item: statsData[indexPath.row])
            return cell
        }
    }

extension ActivityStatsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.frame.width - 32   
        return CGSize(width: width, height: 100)
    }


        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 16
        }

        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 16
        }

        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }
}



