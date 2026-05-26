import Foundation
import UIKit

// MARK: - PromotionPopUp

/// Swift 侧弹窗回调数据，对应 `DXPPopUp`。
public struct PromotionPopUp {
    public let jumpUrl: String?
    public let transactionSn: String?
    public let popupData: [String: Any]?
    /// 解析后的弹窗配置模型（Objective-C `DXPPopupModel`）。
    public let popupModel: DXPPopupModel?

    init(_ popUp: DXPPopUp) {
        jumpUrl = popUp.jumpUrl
        transactionSn = popUp.transactionSn
        popupData = popUp.popupData as? [String: Any]
        popupModel = popUp.popupModel
    }
}

// MARK: - PromotionLifecycleDelegate

/// Swift 生命周期监听，对应 `DXPPromotionLifecycleDelegate`。
public protocol PromotionLifecycleDelegate: AnyObject {
    func promotionDidShow(_ popUp: PromotionPopUp)
    func promotionDidClick(_ popUp: PromotionPopUp)
    func promotionDidClose(_ popUp: PromotionPopUp)
    func promotionDidButtonClick(_ popUp: PromotionPopUp)
    func promotionDidPrimaryButtonClick(_ popUp: PromotionPopUp)
    func promotionDidSecondaryButtonClick(_ popUp: PromotionPopUp)
}

public extension PromotionLifecycleDelegate {
    func promotionDidShow(_ popUp: PromotionPopUp) {}
    func promotionDidClick(_ popUp: PromotionPopUp) {}
    func promotionDidClose(_ popUp: PromotionPopUp) {}
    func promotionDidButtonClick(_ popUp: PromotionPopUp) {}
    func promotionDidPrimaryButtonClick(_ popUp: PromotionPopUp) {}
    func promotionDidSecondaryButtonClick(_ popUp: PromotionPopUp) {}
}

// MARK: - Promotion

/// Swift 门面 API，对应 Objective-C `DXPPromotion`。
public enum Promotion {
    private static let lifecycleBridge = PromotionLifecycleBridge()

    public static func initialize() {
        DXPPromotion.initSDK()
    }

    public static func setLifecycleListener(_ listener: (any PromotionLifecycleDelegate)?) {
        lifecycleBridge.swiftDelegate = listener
        DXPPromotion.setPromotionLifecycleListener(listener != nil ? lifecycleBridge : nil)
    }

    public static func refresh(
        on viewController: UIViewController,
        completion: ((Bool) -> Void)? = nil
    ) {
        DXPPromotion.refreshData(on: viewController, completion: { success in
            completion?(success)
        })
    }

    public static func show(on viewController: UIViewController) {
        DXPPromotion.show(on: viewController)
    }

    public static func queryOnce() {
        DXPPromotion.queryDxpPromotionDialogOnce()
    }

    public static func queryPoll() {
        DXPPromotion.queryDxpPromotionDialogPoll()
    }

    public static func notifyViewDidAppear(_ viewController: UIViewController) {
        DXPPromotion.notifyViewControllerDidAppear(viewController)
    }
}
