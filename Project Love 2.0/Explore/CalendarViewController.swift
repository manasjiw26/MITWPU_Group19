//
//  CalendarViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 12/01/26.
//

import UIKit

class CalendarViewController: UIViewController {

    @IBOutlet var activityCollectionView: UICollectionView!
    
    
    private var selectedDate = Date()
    private var activitiesForSelectedDate: [Activity] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityCollectionView.dataSource = self
        activityCollectionView.delegate = self

        registerCell()
        filterActivities()
        
        
    }
    func registerCell() {
        
        activityCollectionView.register(UINib(nibName: "ActivityCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "activity_cell")
        
        activityCollectionView.register(UINib(nibName: "EmptyStateCollectioViewCellCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "empty_cell")
        
        activityCollectionView.register(
            UINib(nibName: "CalendarCell", bundle: nil),
            forCellWithReuseIdentifier: "CalendarCell"
        )
    }
    
    func filterActivities() {
        activitiesForSelectedDate = DataStore.shared.allActivities.filter {
            guard let date = $0.scheduledDate else { return false }
            return Calendar.current.isDate(date, inSameDayAs: selectedDate)
        }

        activityCollectionView.reloadSections(IndexSet(integer: 1))
    }
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        filterActivities()
    }
    
}
extension CalendarViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           if section == 0 {
               return 1
           }
        
           return activitiesForSelectedDate.isEmpty ? 1 : activitiesForSelectedDate.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // Calendar
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "CalendarCell",
                for: indexPath
            ) as! CalendarCell

            let activityDates = Set(
                DataStore.shared.allActivities.compactMap {
                    $0.scheduledDate.map {
                        Calendar.current.startOfDay(for: $0)
                    }
                }
            )

            cell.delegate = self
            cell.configure(
                with: selectedDate,
                exerciseDays: activityDates,
                selectedDay: selectedDate
            )

            return cell
        }

        // Empty state
        if activitiesForSelectedDate.isEmpty {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "empty_cell",
                for: indexPath
            ) as! EmptyStateCollectioViewCellCollectionViewCell

            cell.configure(
                title: "No scheduled activities",
                subtitle: "Pick an activity and set a time to enjoy it together.",
                imageName: "empty_scheduled"
            )
            return cell
        }

        //activity cell
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "activity_cell",
            for: indexPath
        ) as! ActivityCollectionViewCell

        let activity = activitiesForSelectedDate[indexPath.row]
        cell.configureCells(activity: activity)

        return cell
    }
}
extension CalendarViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath ) -> CGSize {

        let sectionInset = self.collectionView(
            collectionView,
            layout: collectionViewLayout,
            insetForSectionAt: indexPath.section
        )

        let width = collectionView.bounds.width
                   - sectionInset.left
                   - sectionInset.right

        if indexPath.section == 0 {
            return CGSize(width: width, height: 360)
        }

        if activitiesForSelectedDate.isEmpty {
            return CGSize(width: width, height: 400)
        }

        return CGSize(width: width, height: 115)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int ) -> UIEdgeInsets {

        // SAME inset for calendar & activity cells
        return UIEdgeInsets(top: 0, left: 16, bottom: 24, right: 16)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int ) -> CGFloat {
        return 16
    }
}
extension CalendarViewController: CalendarCellDelegate {

    func calendarCell(_ cell: CalendarCell, didSelectDate date: Date) {
        selectedDate = date
        filterActivities()
    }

    func calendarCell(_ cell: CalendarCell, didChangeTo date: Date) {
        selectedDate = date
        filterActivities()
    }

    func calendarCellDidTapHeader(_ cell: CalendarCell) {
        // optional
    }
}
