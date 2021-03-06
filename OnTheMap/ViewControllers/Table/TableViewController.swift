//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 01.05.18.
//  Copyright © 2018 Michael Wagner. All rights reserved.
//

import UIKit
import ReactiveSwift
import DataSource
import PKHUD

class TableViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var tableView: UITableView!

    // MARK: - Properties

    private let refreshControl = UIRefreshControl()
    var viewModel: LocationViewModel!

    lazy var dataSource: DataSource = {
        return DataSource(
            cellDescriptors: [
                StudentCell.descriptor
                    .didSelect{ (viewModel, _) -> SelectionResult in
                        if let url = URL(string: viewModel.url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: { (hasOpened) in
                                if !hasOpened {
                                    HUD.flash(.label(Strings.StudentInformation.errorMediaUrl), delay: 0.4)
                                }
                            })
                        } else {
                            HUD.flash(.label(Strings.StudentInformation.errorMediaUrl), delay: 0.4)
                        }

                        return .deselect
                    }
                    .willDisplay { [weak self] ( _, _, indexPath) in
                        guard let `self` = self else { return }

                        if let lastVisibleIndexPath = self.tableView.indexPathsForVisibleRows?.last,
                            indexPath == lastVisibleIndexPath {

                            let loadedStudentCount = self.viewModel.studentViewModels.value.count

                            if loadedStudentCount - indexPath.row < 50 {
                                self.viewModel.refreshStudentLocations.apply(false).start()
                            }
                        }
                    }
                    .height { 70 }
            ],
            sectionDescriptors: [
                SectionDescriptor<Void>("HeaderAndFooter")
                    .footerHeight {
                        .value(1)
                }
            ]
        )
    }()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let parentTabBar = tabBarController as! MainTabBarController
        viewModel = parentTabBar.viewModel

        tableView.dataSource = dataSource
        tableView.delegate = dataSource

        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshStudentInformations), for: .valueChanged)
        bindViewModel()
    }

    // MARK: Refresh Control

    @objc private func refreshStudentInformations() {
        viewModel.refreshStudentLocations.apply(true).startWithResult { [weak self] _ in
            self?.refreshControl.endRefreshing()
        }
    }

    // MARK: - Datasource

    private func bindViewModel() {
        viewModel.studentViewModels.producer.startWithValues { [weak self] (studentViewModels) in
            guard let `self` = self else { return }

            self.dataSource.sections = [Section(items: studentViewModels).with(identifier: "HeaderAndFooter")]
            self.dataSource.reloadData(self.tableView, animated: false)
        }
    }
}
