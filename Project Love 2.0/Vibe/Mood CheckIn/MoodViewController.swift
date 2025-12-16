//
//  MoodViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class MoodViewController: UIViewController {

    @IBOutlet weak var MoodCheckIn: UICollectionView!
    var moods: [MoodCheckIn] = []
    override func viewDidLoad() {
        
        super.viewDidLoad()
        registerCells()
              
              MoodCheckIn.delegate = self
              MoodCheckIn.dataSource = self

        // Do any additional setup after loading the view.
    }
    func registerCells() {
        MoodCheckIn.register(UINib(nibName: "MoodCheckInCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "mood_cell")
    }
}
extension MoodViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return moods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mood_cell", for: indexPath) as! MoodCheckInCollectionViewCell
        
        cell.configureCells(mood: moods[indexPath.row])
        cell.layer.cornerRadius = 16
        cell.layer.masksToBounds = true
        
        return cell
    }
    
    // Cell size (two cells horizontally)
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = (collectionView.frame.width - 30) / 2
        return CGSize(width: width, height: width * 1.25)
    }
}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


