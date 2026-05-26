Pod::Spec.new do |spec|
  spec.name         = "DxpPromotionDialog"
  spec.module_name  = "DxpPromotionDialog"
  spec.version      = "1.0.9"
  spec.summary      = "DXP Promotion Dialog"
  spec.description  = "DXP Promotion Dialog SDK"
  spec.homepage     = "https://github.com/HelloGitHub123/DxpPromotionDialog"
  spec.license      = "MIT"
  spec.author             = { "李标" => "li.biao3@iwhalecloud.com" }
  
  spec.platform     = :ios, "13.0"
  spec.swift_versions = ['5.0']
  spec.source       = { :git => "https://github.com/HelloGitHub123/DxpPromotionDialog.git", :tag => "1.0.9" }

  spec.source_files = "DxpPromotionDialog/**/*.{h,m,swift}"
  spec.public_header_files = [
    "DxpPromotionDialog/API/DXPChannelReq.h",
    "DxpPromotionDialog/API/DXPMktContactDto.h",
    "DxpPromotionDialog/API/DXPMktCreativeInfo.h",
    "DxpPromotionDialog/API/DXPPopupModel.h",
    "DxpPromotionDialog/API/DXPPromotionOrderingRequest.h",
    "DxpPromotionDialog/API/DXPQueryAllChannelsResp.h",
    "DxpPromotionDialog/API/DXPQueryPromotionsResp.h",
    "DxpPromotionDialog/Core/DXPPopUp.h",
    "DxpPromotionDialog/Core/DXPPromotion.h",
    "DxpPromotionDialog/Core/DXPPromotionDataListener.h",
    "DxpPromotionDialog/Core/DXPPromotionDialogDelegate.h",
    "DxpPromotionDialog/Core/DXPPromotionInfo.h",
    "DxpPromotionDialog/Core/DXPPromotionLifecycleDelegate.h",
    "DxpPromotionDialog/Core/DXPPromotionManager.h",
    "DxpPromotionDialog/Core/DXPWebPromotionInfo.h",
    "DxpPromotionDialog/Dialog/DXPBasePromotionViewController.h",
    "DxpPromotionDialog/Dialog/DXPImagePromotionViewController.h",
    "DxpPromotionDialog/Dialog/DXPMultiPromotionViewController.h",
    "DxpPromotionDialog/Dialog/DXPPopupPromotionViewController.h",
    "DxpPromotionDialog/Dialog/DXPWebJSBridgeHandler.h",
    "DxpPromotionDialog/Dialog/DXPWebPromotionViewController.h",
    "DxpPromotionDialog/Network/DXPPromotionAPIClient.h",
    "DxpPromotionDialog/Network/DXPToolsLoadingHelper.h",
    "DxpPromotionDialog/Utils/DXPGlobalStorage.h",
    "DxpPromotionDialog/Utils/DXPJSONHelper.h",
    "DxpPromotionDialog/Utils/DXPPromotionColorUtils.h",
    "DxpPromotionDialog/Utils/DXPPromotionImageLayoutHelper.h",
    "DxpPromotionDialog/Utils/DXPPromotionTags.h",
    "DxpPromotionDialog/Utils/DXPPromoUserData.h",
    "DxpPromotionDialog/View/DXPImagePromotionCell.h",
    "DxpPromotionDialog/View/DXPIndicatorCell.h",
    "DxpPromotionDialog/View/DXPWebPromotionCell.h"
  ]
  spec.requires_arc = true
  spec.static_framework = true

  # 启用模块定义
  spec.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'CLANG_ENABLE_MODULES' => 'YES',
    "BUILD_LIBRARY_FOR_DISTRIBUTION" => "YES"
  }
  spec.dependency 'DXPNetWorkingManagerLib'
  spec.dependency 'Masonry'
  spec.dependency 'DXPToolsLib'
  spec.dependency 'SDWebImage'
end
