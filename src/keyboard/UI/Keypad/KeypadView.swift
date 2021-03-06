

import UIKit


// MARK: - KeypadView

final class KeypadView: UIView {

  weak var switchDelegate: KeyboardSwitchProtocol?
  
  private let keyWidthMultiplier: CGFloat = 1/11
  
  private var shiftKeyView: SpecialKeyView?
  private var deleteKeyView: SpecialKeyView?
  private var altKeyView: SpecialKeyView?
  private var switchKeyView: SpecialKeyView?
  private var spaceKeyView: SpecialKeyView?
  private var returnKeyView: SpecialKeyView?
  private var dotKeyView: SpecialKeyView?
  
  
  // MARK: Life cycle
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    addObservers()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    addObservers()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: Drawing
  
  func updateShiftState(_ status: Key.State) {
    shiftKeyView?.isHighlighted = false
    switch status {
    case .locked:
      shiftKeyView?.configure(withImage: SymbolsManager.getImage(named: "shift.fill"), level: .primary)
      shiftKeyView?.isHighlighted = true
    case .on:
      shiftKeyView?.configure(withImage: SymbolsManager.getImage(named: "shift.fill"), level: .primary)
    case .off:
      shiftKeyView?.configure(withImage: SymbolsManager.getImage(named: "shift"), level: .secondary)
    }
    shiftKeyView?.updateAppearance()
  }
  
  func updateAltState(_ state: Key.State) {
    altKeyView?.isHighlighted = false
    switch state {
    case .locked:
      altKeyView?.configure(withImage: SymbolsManager.getImage(named: "option"), level: .primary)
      altKeyView?.isHighlighted = true
    case .on:
      altKeyView?.configure(withImage: SymbolsManager.getImage(named: "option"), level: .primary)
    case .off:
      altKeyView?.configure(withImage: SymbolsManager.getImage(named: "option"), level: .secondary)
    }
    altKeyView?.updateAppearance()
  }
  
  func updateAppearance() {
    shiftKeyView?.updateAppearance()
    deleteKeyView?.updateAppearance()
    altKeyView?.updateAppearance()
    switchKeyView?.updateAppearance()
    spaceKeyView?.updateAppearance()
    returnKeyView?.updateAppearance()
  }
  
  private func updateReturnKey(type: UIReturnKeyType) {
    switch type {
    case .default:
      returnKeyView?.isHighlighted = false
    default:
      returnKeyView?.isHighlighted = true
    }
    returnKeyView?.updateAppearance()
  }
  
  
  // MARK: View finding
  
  func view(for kind: Key.Kind) -> SpecialKeyView? {
    switch kind {
    case .shift:
      return shiftKeyView
    case .alt:
      return altKeyView
    case .delete:
      return deleteKeyView
    case .space:
      return spaceKeyView
    case .enter:
      return returnKeyView
    case .next:
      return switchKeyView
    default:
      UniversalLogger.error("This function should not be called for \(kind).")
      return nil
    }
  }
  
  // MARK: Loading
  
  func load(keySet: KeySet) {
    translatesAutoresizingMaskIntoConstraints = false
    backgroundColor = UIColor.gray.withAlphaComponent(0.001) // Gestures do not work on transparent view.
    heightAnchor.constraint(greaterThanOrEqualToConstant: 160).isActive = true
    let rowView1 = loadRow1(keySet)
    let rowView2 = loadRow2(keySet, rowView1: rowView1)
    let rowView3 = loadRow3(keySet, rowView2: rowView2)
    loadRow4(keySet, rowView3: rowView3)
  }
  
  private func loadRow1(_ keySet: KeySet) -> UIView {
    let rowView1 = addRowView(topAnchor: topAnchor)
    let lastKey = parse(keySet.rows[0], in: rowView1)
    lastKey.rightAnchor.constraint(equalTo: rowView1.rightAnchor).isActive = true
    return rowView1
  }
  
  private func loadRow2(_ keySet: KeySet, rowView1: UIView) -> UIView {
    let rowView2 = addRowView(topAnchor: rowView1.bottomAnchor)
    let lastKey = parse(keySet.rows[1], in: rowView2)
    lastKey.rightAnchor.constraint(equalTo: rowView2.rightAnchor).isActive = true
    return rowView2
  }
  
  private func loadRow3(_ keySet: KeySet, rowView2: UIView) -> UIView {
    let rowView3 = addRowView(topAnchor: rowView2.bottomAnchor)
    shiftKeyView = addSpecial(in: rowView3, widthMultiplier: keyWidthMultiplier*1.4, leftAnchor: rowView3.leftAnchor)
    updateShiftState(.off)
    let lastKey = parse(keySet.rows[2], in: rowView3, leftAnchor: shiftKeyView!.rightAnchor)
    deleteKeyView = addSpecial(in: rowView3, widthMultiplier: keyWidthMultiplier*1.4, leftAnchor: lastKey.rightAnchor)
    deleteKeyView!.rightAnchor.constraint(equalTo: rowView3.rightAnchor).isActive = true
    deleteKeyView!.configure(withImage: SymbolsManager.getImage(named: "delete.left"), level: .secondary) // völi .secondary
    return rowView3
  }
  
  private func loadRow4(_ keySet: KeySet, rowView3: UIView) {
    let rowView4 = addRowView(topAnchor: rowView3.bottomAnchor, bottomAnchor: bottomAnchor)
    var spaceLeftAnchor: NSLayoutXAxisAnchor!
    if KeyboardSettings.shared.needsInputModeSwitchKey {
      altKeyView = addSpecial(in: rowView4, widthMultiplier: keyWidthMultiplier*1.5, leftAnchor: rowView4.leftAnchor)
      updateAltState(.off)
      switchKeyView = addSpecial(in: rowView4, widthMultiplier: keyWidthMultiplier*1.5, leftAnchor: altKeyView!.rightAnchor)
      switchKeyView?.configure(withImage: SymbolsManager.getImage(named: "globe"), level: .secondary)
      spaceLeftAnchor = switchKeyView!.rightAnchor
      switchDelegate?.switchKeyAdded(switchKeyView!)
    } else {
      altKeyView = addSpecial(in: rowView4, widthMultiplier: keyWidthMultiplier*3, leftAnchor: rowView4.leftAnchor)
      updateAltState(.off)
      spaceLeftAnchor = altKeyView!.rightAnchor
    }
    spaceKeyView = addSpecial(in: rowView4, widthMultiplier: keyWidthMultiplier*5, leftAnchor: spaceLeftAnchor)
    spaceKeyView!.configure(withText: " ", level: .primary)
    //dotKeyView = addSpecial(in: rowView4, widthMultiplier: keyWidthMultiplier*1, leftAnchor: spaceLeftAnchor)
    //dotKeyView!.configure(withText: ".", level: .primary)

    returnKeyView = addSpecial(in: rowView4, widthMultiplier: keyWidthMultiplier*3, leftAnchor: spaceKeyView!.rightAnchor)
    returnKeyView!.rightAnchor.constraint(equalTo: rowView4.rightAnchor).isActive = true
    returnKeyView!.configure(withImage: SymbolsManager.getImage(named: "return"), level: .secondary)
  }
  
  private func addRowView(topAnchor: NSLayoutYAxisAnchor, bottomAnchor: NSLayoutYAxisAnchor? = nil) -> UIView {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    addSubview(view)
    view.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.25).isActive = true
    view.topAnchor.constraint(equalTo: topAnchor).isActive = true
    view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
    view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    if let bottomAnchor = bottomAnchor {
      view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    return view
  }
  
  private func parse(_ row: Row, in rowView: UIView, leftAnchor: NSLayoutXAxisAnchor? = nil) -> LetterKeyView {
    var leftAnchor = leftAnchor ?? rowView.leftAnchor
    for key in row {
      add(key, in: rowView, leftAnchor: leftAnchor)
      leftAnchor = key.view.rightAnchor
    }
    return row.last!.view
  }
  
  private func add(_ key: Key, in row: UIView, leftAnchor: NSLayoutXAxisAnchor) {
    key.view.translatesAutoresizingMaskIntoConstraints = false
    row.addSubview(key.view)
    key.view.widthAnchor.constraint(equalTo: row.widthAnchor, multiplier: Constants.keySlotMultiplier).isActive = true
    key.view.topAnchor.constraint(equalTo: row.topAnchor).isActive = true
    key.view.bottomAnchor.constraint(equalTo: row.bottomAnchor).isActive = true
    key.view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
  }
  
  private func addSpecial(in rowView: UIView, widthMultiplier: CGFloat, leftAnchor: NSLayoutXAxisAnchor) -> SpecialKeyView {
    let specialKeyView = SpecialKeyView()
    specialKeyView.translatesAutoresizingMaskIntoConstraints = false
    rowView.addSubview(specialKeyView)
    specialKeyView.widthAnchor.constraint(equalTo: rowView.widthAnchor, multiplier: widthMultiplier).isActive = true
    specialKeyView.topAnchor.constraint(equalTo: rowView.topAnchor).isActive = true
    specialKeyView.bottomAnchor.constraint(equalTo: rowView.bottomAnchor).isActive = true
    specialKeyView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
    return specialKeyView
  }
  
  
  // MARK: Notifications
  
  private func addObservers() {
    NotificationCenter.default.addObserver(self, selector: #selector(returnKeyTypeDidChange(_:)), name: .returnKeyTypeDidChange, object: nil)
  }
  
  @objc private func returnKeyTypeDidChange(_ notification: Notification) {
    updateReturnKey(type: KeyboardSettings.shared.returnKeyType)
  }
  
}
