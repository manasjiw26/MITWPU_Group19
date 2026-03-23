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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleActivitiesSynced),
            name: .activitiesSynced,
            object: nil
        )
        
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            guard $0.status == .scheduled else { return false }
            return Calendar.current.isDate(date, inSameDayAs: selectedDate)
        }

        activityCollectionView.reloadSections(IndexSet(integer: 1))
    }

    @objc private func handleActivitiesSynced() {
        filterActivities()
        activityCollectionView.reloadSections(IndexSet(integer: 0))
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

            let activityDates: Set<Date> = Set(
                DataStore.shared.allActivities.compactMap {
                    guard $0.status == .scheduled else { return nil }
                    guard let scheduledDate = $0.scheduledDate else { return nil }
                    return Calendar.current.startOfDay(for: scheduledDate)
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
extension CalendarViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Section 0 is the calendar, section 1 is activities
        guard indexPath.section == 1, !activitiesForSelectedDate.isEmpty else { return }

        let activity = activitiesForSelectedDate[indexPath.row]

        let destinationVC = SmallModalViewController(nibName: "SmallModalViewController", bundle: nil)
        destinationVC.selectedActivity = activity
        destinationVC.modalData = DataStore.shared.getSmallModalData(for: activity)
        destinationVC.flowSource = .explore
        destinationVC.modalPresentationStyle = .overFullScreen
        present(destinationVC, animated: false)
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
