import UIKit
import RxSwift
import EthereumKit

class BalanceControllerTable: UITableViewController {
  let disposeBag = DisposeBag()
  
  var viewModel: MainViewModel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(refresh))
    
    tableView.register(UINib(nibName: String(describing: BalanceCell.self), bundle: Bundle(for: BalanceCell.self)), forCellReuseIdentifier: String(describing: BalanceCell.self))
    tableView.tableFooterView = UIView()
    tableView.separatorInset = .zero
    
    for (index, adapter) in viewModel.adapters.enumerated() {
      Observable.merge([adapter.lastBlockHeightObservable, adapter.syncStateObservable, adapter.balanceObservable])
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { [weak self] in
          self?.update(index: index)
        })
        .disposed(by: disposeBag)
    }
    
    print(viewModel.ethereumKit.receiveAddress)
  }
  
  @objc func refresh() {
    viewModel.ethereumKit.refresh()
  }
  
  private func update(index: Int) {
    tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.adapters.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 140
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: String(describing: BalanceCell.self), for: indexPath)
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if let cell = cell as? BalanceCell {
      cell.bind(adapter: viewModel.adapters[indexPath.row])
    }
  }
}
