import UIKit
import Combine

class ViewController: UIViewController {

    enum Section: Int, CaseIterable {
        case main
        case popular

        var sectionHeader: String {
            switch self {
            case .main: return "Main"
            case .popular: return "Popular"
            }
        }
    }

    static let headerKind = "headerKind"

    enum SupplementaryElementKind {
        static let sectionHeader = "supplementary-section-header"
        static let unreadIndicator = "supplementary-unread-indicator"
    }

    private var cancellables: Set<AnyCancellable> = []
    private var dataLoader = DataLoader()

    private var dataSource: UICollectionViewDiffableDataSource<Section, Episode>!
    private var collectionView: UICollectionView!
    private var loadingIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Episodes"

        loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.hidesWhenStopped = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: loadingIndicator)

        configureCollectionView()
        configureDataSource()
        fetchData()
    }

    private func configureCollectionView() {
        let layout = LayoutManager().createLayout()

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.registerCell(cellClass: EpisodeCell.self)
        collectionView.registerCell(cellClass: TextCell.self)

        //header
        collectionView.register(UINib(nibName: "TitleView", bundle: nil),
                            forSupplementaryViewOfKind: ViewController.headerKind,
                            withReuseIdentifier: TitleView.reuseIdentifier)
    }

    private func configureDataSource() {

        dataSource = UICollectionViewDiffableDataSource<Section, Episode>(collectionView: collectionView) { collectionView, indexPath, episode -> UICollectionViewCell? in
            switch indexPath.section {
            case 0:
                guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: EpisodeCell.reuseIdentifier,
                    for: indexPath) as? EpisodeCell else { fatalError("Cannot create new cell") }
                cell.titleLabel.text = "\(indexPath.section) \(indexPath.item)"
                return cell
            default:
                guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: TextCell.reuseIdentifier,
                    for: indexPath) as? TextCell else { fatalError("Cannot create new cell") }
                cell.titleLabel.text = episode.title
                return cell
            }
        }

        setupHeader()
    }

    func setupHeader() {
        dataSource.supplementaryViewProvider = {(
            collectionView: UICollectionView,
            kind: String,
            indexPath: IndexPath) -> UICollectionReusableView? in

            // Get a supplementary view of the desired kind.
            if let titleView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TitleView.reuseIdentifier,
                for: indexPath) as? TitleView {

                switch kind {
                case ViewController.headerKind:
                    titleView.titleLbl.text = "Header"
                default:
                    ()
                }
                return titleView
            } else {
                fatalError("Cannot create new supplementary")
            }
        }
    }

    private func fetchData() {
        dataLoader.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)

        dataLoader.dataChanged
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateSnapshot()
            }
            .store(in: &cancellables)

        dataLoader.fetchData()
    }

    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Episode>()
        snapshot.appendSections(Section.allCases)
        let episodes = dataLoader.episodes
        snapshot.appendItems(Array(episodes[0...10]), toSection: .main)
        snapshot.appendItems(Array(episodes[11...20]), toSection: .popular)
        dataSource.apply(snapshot)
    }
}

