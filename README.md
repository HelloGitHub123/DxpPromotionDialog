# DxpPromotionDialog

DXP 营销弹框 iOS SDK，支持 **Swift** 与 **Objective-C** 宿主工程。

## 安装

```ruby
pod 'DxpPromotionDialog', '~> 1.0.10'
```

## Swift 集成

无需在宿主工程添加 Bridging Header 或手写 `DXPPromotionLifecycleDelegate` 适配类。

```swift
import DxpPromotionDialog

// 初始化
Promotion.initialize()

// 生命周期（协议方法均有默认空实现，按需重写）
final class MyPromotionListener: PromotionLifecycleDelegate {
    func promotionDidShow(_ popUp: PromotionPopUp) {
        print(popUp.transactionSn ?? "")
    }
}

Promotion.setLifecycleListener(MyPromotionListener())

// 查询与展示
Promotion.queryOnce()
// 或在 viewDidAppear 中：
Promotion.notifyViewDidAppear(self)

Promotion.refresh(on: self) { success in
    print("refresh: \(success)")
}
Promotion.show(on: self)
```

## Objective-C 集成

```objc
#import <DxpPromotionDialog/DXPPromotion.h>

[DXPPromotion initSDK];
[DXPPromotion setPromotionLifecycleListener:self];

[DXPPromotion queryDxpPromotionDialogOnce];
[DXPPromotion notifyViewControllerDidAppear:self];

[DXPPromotion refreshDataOnViewController:self completion:^(BOOL success) {
    NSLog(@"refresh: %d", success);
}];
[DXPPromotion showPromotionOnViewController:self];
```

实现 `DXPPromotionLifecycleDelegate` 可选方法即可接收弹窗回调。

## 高级能力

自定义弹窗 VC、网络层等仍使用 Pod 公开的 Objective-C 头文件（如 `DXPPromotionManager.h`、`DXPPromotionAPIClient.h`）。
