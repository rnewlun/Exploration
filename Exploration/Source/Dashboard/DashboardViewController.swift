//
//  DashboardViewController.swift
//  Exploration
//
//  Created by Ryan Newlun on 1/30/22.
//

import UIKit
import Combine

class DashboardViewController: UIViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Dashboard.SemanticSection, Dashboard.Module>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Dashboard.SemanticSection, Dashboard.Module>
    
    private lazy var dataSource: DataSource = makeDataSource()
    private lazy var layout: DashboardLayout = {
        let layout = DashboardLayout { sectionIndex, traits in
            guard let semanticSection = self.dataSource.sectionIdentifier(for: sectionIndex) else { return .fractionalWidth(1.0) }
            
            switch traits.horizontalSizeClass {
            case .regular:
                switch semanticSection {
                case .header:
                    return .fractionalWidth(1.0)
                case .mainWalletNonSplit:
                    // not valid
                    return nil
                case .mainWalletSplit:
                    return .split
                case .footer:
                    return .fractionalWidth(1.0)
                }
                
            default:
                // Compact layout uses full width items for all sections
                return .fractionalWidth(1.0)
            }
        } splitItemLayoutProvider: { indexPath in
            guard let module = self.dataSource.itemIdentifier(for: indexPath) else { return nil }

            switch module {
            case .greeting(_):
                return nil
            case .wallet(let viewModel):
                if viewModel.accountID == 456 { return .right }
                return .left
            case .snapshot(_):
                return nil
            case .disclosures(_):
                return nil
            }
        }
        return layout
    }()
    
    private var currentModules: [Dashboard.Module] = []
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
                self?.currentModules = modules
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
            case .greeting(_):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReusableDashboardCollectionViewCell.reuseIdentifier, for: indexPath)
                (cell as? ReusableDashboardCollectionViewCell)?.configureWith(module: itemIdentifier)
                return cell
                
            case .wallet(_):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReusableDashboardCollectionViewCell.reuseIdentifier, for: indexPath)
                (cell as? ReusableDashboardCollectionViewCell)?.configureWith(module: itemIdentifier)
                return cell

            case .snapshot(_):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReusableDashboardCollectionViewCell.reuseIdentifier, for: indexPath)
                (cell as? ReusableDashboardCollectionViewCell)?.configureWith(module: itemIdentifier)
                return cell

            case .disclosures(_):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReusableDashboardCollectionViewCell.reuseIdentifier, for: indexPath)
                (cell as? ReusableDashboardCollectionViewCell)?.configureWith(module: itemIdentifier)
                return cell

            }
        }
        return dataSource
    }
    
    private func makeSnapshot(usingModules modules: [Dashboard.Module]) -> Snapshot {
        var snapshot = Snapshot()
        // Add all sections initially
        let sections = Dashboard.LayoutInfo.getPreferredSectionOrder(forTraitCollection: self.traitCollection)
        snapshot.appendSections(sections)
        
        // TODO: Enforce ordering based on size class
        // TODO: Define a structure that is a blueprint for product/design requirements
        // TODO: Map modules to preferred section
        modules.forEach { module in
            let preferredSection = Dashboard.LayoutInfo.getPreferredSection(forModule: module, usingTraitCollection: self.traitCollection)
            snapshot.appendItems([module], toSection: preferredSection)
        }
        
        // Remove any sections that are empty
        let emptySections = snapshot.sectionIdentifiers.filter { section in
            return snapshot.numberOfItems(inSection: section) == 0
        }
        snapshot.deleteSections(emptySections)
        return snapshot
    }
}

extension DashboardViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if previousTraitCollection?.horizontalSizeClass != self.traitCollection.horizontalSizeClass {
            collectionView.collectionViewLayout.invalidateLayout()
//            self.currentSnapshot = makeSnapshot(usingModules: currentModules)
        }
    }
}
