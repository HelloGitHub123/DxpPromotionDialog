import Foundation

/// 内部桥接：将 `DXPPromotionLifecycleDelegate` 回调转发为 Swift `PromotionLifecycleDelegate`。
final class PromotionLifecycleBridge: NSObject, DXPPromotionLifecycleDelegate {
    weak var swiftDelegate: PromotionLifecycleDelegate?

    func promotionDidShow(_ popUp: DXPPopUp!) {
        forward(popUp) { $0.promotionDidShow($1) }
    }

    func promotionDidClick(_ popUp: DXPPopUp!) {
        forward(popUp) { $0.promotionDidClick($1) }
    }

    func promotionDidClose(_ popUp: DXPPopUp!) {
        forward(popUp) { $0.promotionDidClose($1) }
    }

    func promotionDidButtonClick(_ popUp: DXPPopUp!) {
        forward(popUp) { $0.promotionDidButtonClick($1) }
    }

    func promotionDidPrimaryButtonClick(_ popUp: DXPPopUp!) {
        forward(popUp) { $0.promotionDidPrimaryButtonClick($1) }
    }

    func promotionDidSecondaryButtonClick(_ popUp: DXPPopUp!) {
        forward(popUp) { $0.promotionDidSecondaryButtonClick($1) }
    }

    private func forward(
        _ popUp: DXPPopUp?,
        _ handler: (PromotionLifecycleDelegate, PromotionPopUp) -> Void
    ) {
        guard let popUp, let delegate = swiftDelegate else { return }
        handler(delegate, PromotionPopUp(popUp))
    }
}
