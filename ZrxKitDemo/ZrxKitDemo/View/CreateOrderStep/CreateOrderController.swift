import UIKit
import BigInt
import Web3

class CreateOrderController: CardViewController {
  
  static func instance(_ side: EOrderSide, _ viewModel: MainViewModel) -> CreateOrderController {
    let view = CreateOrderController()
    view.side = side
    view.viewModel = viewModel
    return view
  }
  
  override var expandedHeight: CGFloat {
    return 300
  }
  
  override var collapsedHeight: CGFloat {
    return 0
  }
  
  override var animationDuration: TimeInterval {
    return 0.5
  }
  
  @IBOutlet weak var totalPriceLbl: UILabel!
  @IBOutlet weak var perTokenPriceField: UITextField!
  @IBOutlet weak var tokenAmountField: UITextField!
  @IBOutlet weak var titleLbl: UILabel!
  
  private var side: EOrderSide!
  private var viewModel: MainViewModel!
  
  private var amount: Decimal {
    return Decimal(string: tokenAmountField.text ?? "0.0") ?? 0.0
  }
  
  private var price: Decimal {
    return Decimal(string: perTokenPriceField.text ?? "0.0") ?? 0.0
  }
  
  private var totalPrice: Decimal {
    return price * amount
  }
  
  private init() {
    super.init(nibName: "CreateOrderController", bundle: nil)
  }
  
  internal required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    switch side! {
    case .ASK:
      titleLbl.text = "Place SELL order"
    case .BID:
      titleLbl.text = "Place BUY order"
    }
  }
  
  private func updatePrice() {
    totalPriceLbl.text = "Total price: \(totalPrice) WETH"
  }
  
  @IBAction func onEditTokenAmount(_ sender: UITextField) {
    print(amount)
    updatePrice()
  }
  
  @IBAction func onEditPerTokenPrice(_ sender: UITextField) {
    print(price)
    updatePrice()
  }
  
  @IBAction func onCreateAction(_ sender: Any) {
    viewModel.createOrder(amount, price, side)
  }
}
