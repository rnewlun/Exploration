//
//  DashboardViewController.swift
//  Exploration
//
//  Created by Ryan Newlun on 1/30/22.
//

import UIKit
import Combine

class DashboardViewController: UIViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Dashboard.Section, Dashboard.Module>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Dashboard.Section, Dashboard.Module>
    
    private lazy var dataSource: DataSource = makeDataSource()
    private lazy var layout: DashboardLayout = {
        let layout = DashboardLayout { sectionIndex in
            self.dataSource.sectionIdentifier(for: sectionIndex)
        }
        return layout
    }()
    
    private var currentSnapshot: Snapshot = Snapshot() {
        didSet {
            dataSource.apply(currentSnapshot, animatingDifferences: true)
        }
    }
    
    private let viewModel: DashboardViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemPink
        view.register(ReusableDashboardCollectionViewCell.self, forCellWithReuseIdentifier: ReusableDashboardCollectionViewCell.reuseIdentifier)
        return view
    }()
    
    init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        subscribeToViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureHierarchy()
        configureConstraints()
        
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    private func subscribeToViewModel() {
        self.viewModel.modulesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] modules in
                if let snapshot = self?.makeSnapshot(usingModules: modules) {
                    self?.currentSnapshot = snapshot
                }
            }
            .store(in: &cancellables)
    }
    
    private func configureHierarchy() {
        view.addSubview(collectionView)
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .reusableTile(let id):
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReusableDashboardCollectionViewCell.reuseIdentifier, for: indexPath) as? ReusableDashboardCollectionViewCell {
                    cell.backgroundColor = .systemMint
                    cell.configureWith(module: itemIdentifier)
                    return cell
                }
            case .module1(_):
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReusableDashboardCollectionViewCell.reuseIdentifier, for: indexPath) as? ReusableDashboardCollectionViewCell {
                    cell.backgroundColor = .systemMint
                    cell.configureWith(module: itemIdentifier)
                    return cell
                }
            case .module2(_):
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReusableDashboardCollectionViewCell.reuseIdentifier, for: indexPath) as? ReusableDashboardCollectionViewCell {
                    cell.backgroundColor = .systemMint
                    cell.configureWith(module: itemIdentifier)
                    return cell
                }
            case .module3(_):
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReusableDashboardCollectionViewCell.reuseIdentifier, for: indexPath) as? ReusableDashboardCollectionViewCell {
                    cell.backgroundColor = .systemMint
                    cell.configureWith(module: itemIdentifier)
                    return cell
                }
            }
            return nil
        }
        return dataSource
    }
    
    private func makeSnapshot(usingModules modules: [Dashboard.Module]) -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([.fractionalWidth(1.0)])
        modules.forEach { module in
            switch module {
                
            case .reusableTile(let id):
                snapshot.appendItems([module], toSection: .fractionalWidth(1.0))
            case .module1(_):
                snapshot.appendSections([.leftColumn])
                snapshot.appendItems([module], toSection: .leftColumn)

            case .module2(_):
                snapshot.appendSections([.rightColumn])
                snapshot.appendItems([module], toSection: .rightColumn)

            case .module3(_):
                snapshot.appendItems([module], toSection: .rightColumn)

            }
        }
        return snapshot
    }
}
