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
        
        activityCollectionView.register(UINib(nibName: "ScheduleCalendarCollectionViewCell", bundle: nil),forCellWithReuseIdentifier: "scheduleCalendar_cell")
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

        //SECTION 0 - CALENDAR
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "scheduleCalendar_cell",
                for: indexPath
            ) as! ScheduleCalendarCollectionViewCell

            let activityDates = DataStore.shared.allActivities.compactMap { $0.scheduledDate }

            cell.configure(
                selectedDate: selectedDate,
                activityDates: activityDates
            )

            cell.onDateChanged = { [weak self] date in
                self?.selectedDate = date
                self?.filterActivities()
            }

            return cell
        }

        // SECTION 1 - EMPTY STATE
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

        //SECTION 1 - ACTIVITY CELL
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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath ) -> CGSize {

               let sectionInset = self.collectionView( collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section )

               let width = collectionView.bounds.width - sectionInset.left - sectionInset.right

               // SECTION 0 — CALENDAR
               if indexPath.section == 0 {
                   return CGSize(width: width, height: 100)
               }

               // SECTION 1 — EMPTY STATE
               if activitiesForSelectedDate.isEmpty {
                   return CGSize(width: width, height: 400)
               }

               // SECTION 1 — ACTIVITY CELL
               return CGSize(width: width, height: 115)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int ) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int ) -> UIEdgeInsets {

        if section == 0 {
            return UIEdgeInsets(top: 0, left: 8, bottom: 10, right: 0)
        }

        // Activities section
        return UIEdgeInsets(top: 0, left: 16, bottom: 24, right: 10)
    }
}
extension CalendarViewController: ScheduleCalendarDelegate {
    func didSchedule(activity: Activity, on date: Date) {
        selectedDate = date
        filterActivities()

        // reload calendar section to show dot
        activityCollectionView.reloadSections(IndexSet(integer: 0))
    }
}
