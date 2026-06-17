// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Airstyle';

  @override
  String get myDevicesTab => '我的设备';

  @override
  String get userInfoTab => '用户信息';

  @override
  String get devicesHeadline => '把卷发棒连接体验，收进一块克制的黑白界面。';

  @override
  String get devicesSubhead => '聚焦设备发现、连接与回连，不做多余干扰。';

  @override
  String get addProduct => '添加产品';

  @override
  String get searchNearbyDevices => '搜索附近设备';

  @override
  String get scanToAddDevice => '扫码添加设备';

  @override
  String get productSerialNumber => '产品序列号';

  @override
  String get featureAvailableSoon => '该入口即将开放。';

  @override
  String get savedSerialNumberLabel => '已保存序列号';

  @override
  String get noSavedSerialNumber => '还没有录入产品序列号。';

  @override
  String get manualSerialHint => '手动输入产品机身上的序列号，保存后可作为后续配对和售后识别依据。';

  @override
  String get serialNumberInputHint => '输入产品序列号';

  @override
  String get serialNumberHelper => '支持字母、数字和连字符。';

  @override
  String get serialNumberRequired => '请输入有效的产品序列号。';

  @override
  String get saveSerialNumber => '保存序列号';

  @override
  String get serialNumberSaved => '序列号已保存。';

  @override
  String get scanSerialHint => '调用相机拍摄产品序列号区域，系统会自动识别并回填结果。';

  @override
  String get openCamera => '打开相机';

  @override
  String get retakePhoto => '重新拍摄';

  @override
  String get recognizedSerialNumber => '识别结果';

  @override
  String get recognizedText => '识别原文';

  @override
  String get editSerialBeforeSave => '你可以修改识别结果后再保存。';

  @override
  String get serialNotDetected => '未识别到有效序列号，请调整角度后重试，或改为手动输入。';

  @override
  String get scanUnsupportedBody => '当前预览环境暂不支持相机识别，请在手机真机中使用该功能。';

  @override
  String get serialRecognitionError => '暂时无法识别序列号，请稍后重试。';

  @override
  String get primaryDevice => '主设备';

  @override
  String get noDeviceTitle => '还没有连接设备';

  @override
  String get noDeviceBody => '从扫描附近卷发棒开始。';

  @override
  String get scanPageTitle => '附近的卷发棒';

  @override
  String get scanHint => '正在搜索周围可连接的蓝牙设备。';

  @override
  String get scanAgain => '重新扫描';

  @override
  String get scanning => '扫描中';

  @override
  String get bluetoothOffTitle => '蓝牙暂不可用';

  @override
  String get bluetoothOffBody => '请先开启蓝牙，再搜索附近设备。';

  @override
  String get permissionTitle => '需要蓝牙权限';

  @override
  String get permissionBody => '允许蓝牙访问后，才能搜索并连接卷发棒设备。';

  @override
  String get openSystemSettings => '打开系统设置';

  @override
  String get emptyScanTitle => '没有找到附近设备';

  @override
  String get emptyScanBody => '请将卷发棒靠近手机后重试。';

  @override
  String get connect => '连接';

  @override
  String get disconnect => '断开连接';

  @override
  String get reconnect => '重新连接';

  @override
  String get connecting => '连接中';

  @override
  String get connected => '已连接';

  @override
  String get disconnected => '未连接';

  @override
  String get connectFailed => '连接失败';

  @override
  String get retry => '重试';

  @override
  String get deviceSignal => '信号';

  @override
  String get savedDeviceLabel => '已保存设备';

  @override
  String get profileTitle => '用户信息';

  @override
  String get profileSubhead => '这里只保留隐私、协议和必要的系统设置。';

  @override
  String get privacyPolicy => '隐私条款';

  @override
  String get userAgreement => '用户协议';

  @override
  String get systemSettings => '系统设置';

  @override
  String get language => '语言';

  @override
  String get softwareVersion => '软件版本';

  @override
  String get languagePageTitle => '语言';

  @override
  String get simplifiedChinese => '简体中文';

  @override
  String get english => 'English';

  @override
  String get legalPlaceholderFooter => '首版本地占位法务文案。';

  @override
  String get statusReady => '可以开始连接';

  @override
  String get statusUnauthorized => '需要授权';

  @override
  String get statusUnavailable => '蓝牙不可用';

  @override
  String get statusScanning => '正在搜索附近设备';

  @override
  String get statusConnected => '设备已连接';

  @override
  String get statusDisconnected => '已保存，可随时回连';

  @override
  String get back => '返回';

  @override
  String get hairProfileTitle => '头发明细';

  @override
  String get saveButton => '保存';

  @override
  String get hairTypeQuestion => '您属于那种发型？';

  @override
  String get hairTypeDescription => '如果您觉得自己属于混合发型，那么请选择最主要的类型';

  @override
  String get hairTypeStraight => '直发';

  @override
  String get hairTypeWavy => '波浪卷';

  @override
  String get hairTypeCurly => '卷发';

  @override
  String get hairTypeCoily => '爆炸头';

  @override
  String get hairLengthQuestion => '您的头发有多长？';

  @override
  String get hairLengthDescription => '观察头发，并感受它的长短';

  @override
  String get hairLengthVeryShort => '非常短';

  @override
  String get hairLengthVeryShortHint => '寸头至及耳';

  @override
  String get hairLengthShort => '短';

  @override
  String get hairLengthShortHint => '过耳至及下巴';

  @override
  String get hairLengthMedium => '中';

  @override
  String get hairLengthMediumHint => '过下巴至及肩';

  @override
  String get hairLengthLong => '长';

  @override
  String get hairLengthLongHint => '过肩至及腋下';

  @override
  String get hairLengthVeryLong => '非常长';

  @override
  String get hairLengthVeryLongHint => '过腋下';

  @override
  String get hairThicknessQuestion => '您的头发有多细？';

  @override
  String get hairThicknessDescription => '观察头发，并用指尖感受它的粗细';

  @override
  String get hairThicknessFine => '细';

  @override
  String get hairThicknessFineHint => '很难看清或感受到';

  @override
  String get hairThicknessMedium => '中';

  @override
  String get hairThicknessMediumHint => '可以看清，不难感受到';

  @override
  String get hairThicknessCoarse => '粗';

  @override
  String get hairThicknessCoarseHint => '很容易看清和感受到';

  @override
  String get unsureOption => '不确定';

  @override
  String get styleRetentionQuestion => '您的头发是否能保持住造型？';

  @override
  String get styleRetentionDescription => '头发定型后，观察多久会恢复';

  @override
  String get styleRetentionShort => '保持不了多久';

  @override
  String get styleRetentionShortHint => '造型能保持一个多小时';

  @override
  String get styleRetentionMedium => '保持一会儿';

  @override
  String get styleRetentionMediumHint => '造型最多能保持半天';

  @override
  String get styleRetentionLong => '保持相当长时间';

  @override
  String get styleRetentionLongHint => '造型能保持一整天或更久';

  @override
  String get stylingExperienceQuestion => '您对头发造型经验丰富吗？';

  @override
  String get stylingExperienceDescription => '请选择您的造型经验类别';

  @override
  String get stylingExperienceBeginner => '新手';

  @override
  String get stylingExperienceBeginnerHint => '我可以做简单的造型，但学习新技巧有时会比较费力';

  @override
  String get stylingExperienceIntermediate => '有一定经验';

  @override
  String get stylingExperienceIntermediateHint => '我能自信地打造几种造型，也很愿意尝试新的造型方式';

  @override
  String get stylingExperienceAdvanced => '高手';

  @override
  String get stylingExperienceAdvancedHint => '我能轻松打造复杂的造型，学习新技巧也很快';

  @override
  String get stylingGoalsQuestion => '您的造型目标是什么？';

  @override
  String get stylingGoalsDescription => '用于为您提供打造这些造型的个性化建议';

  @override
  String get stylingGoalVolumeCurls => '丰盈卷发';

  @override
  String get stylingGoalStraight => '直发';

  @override
  String get stylingGoalSleek => '服帖造型';

  @override
  String get stylingGoalFrizzControl => '控制毛躁的情况';

  @override
  String get stylingGoalFlyawayManagement => '管理飞行';

  @override
  String get stylingGoalNaturalFinish => '打造更好的自然造型';

  @override
  String get stylingGoalQuickStyle => '日常快速造型';

  @override
  String get stylingGoalLongLasting => '造型持久度';

  @override
  String get stylingGoalHairHealth => '呵护头发健康';

  @override
  String get deviceOverviewTab => '概览';

  @override
  String get deviceSupportTab => '支持';

  @override
  String get deviceSettingsTab => '设置';

  @override
  String get deviceAbnormalStatus => '异常';

  @override
  String get deviceNoAttachmentTitle => '未检测到风嘴';

  @override
  String get deviceNoAttachmentBody => '安装风嘴配件开始造型';

  @override
  String get deviceAttachmentDetectedTitle => '检测到风嘴';

  @override
  String get deviceAttachmentDetectedBody => '查看风嘴配件使用指南';

  @override
  String get deviceAttachmentRequiresBluetooth => '请先连接蓝牙设备';

  @override
  String get deviceAutoCurlTitle => '自动卷发';

  @override
  String get deviceReadyTitle => '准备就绪';

  @override
  String get deviceReadyBody => '向上滑动电源按钮，然后松开';

  @override
  String get deviceAdjustTime => '调整时间';

  @override
  String get deviceStatusSectionTitle => '状态';

  @override
  String get deviceWindLow => '低';

  @override
  String get deviceWindSpeedLabel => '风速';

  @override
  String get deviceCoolAir => '冷风';

  @override
  String get deviceTemperatureLabel => '温度';

  @override
  String get deviceTutorialTitle => '新手教程';

  @override
  String get deviceSupportGuideTitle => '使用指南';

  @override
  String get deviceSupportGuideBody => '查看设备功能、造型步骤和常见问题。';

  @override
  String get deviceSupportCareTitle => '维护与保养';

  @override
  String get deviceSupportCareBody => '了解附件清洁、收纳和日常护理建议。';

  @override
  String get deviceBluetoothStatusTitle => '蓝牙连接状态';

  @override
  String get deviceCurlTimeLabel => '卷发';

  @override
  String get deviceStyleTimeLabel => '造型';

  @override
  String get deviceCoolShotTimeLabel => '一键冷风';

  @override
  String get deviceResetButton => '重置';

  @override
  String get deviceTimingSaved => '时间设置已保存。';

  @override
  String get deviceGuidePageTitle => '使用指南';

  @override
  String get attachmentPreStylingDryer => '预干发风嘴 2x';

  @override
  String get attachmentRoundVolumisingBrush => '圆筒梳 2x';

  @override
  String get attachmentAirSmooth => 'AirSmooth2x风嘴';

  @override
  String get attachmentAntiTangleLoopBrush => '防缠绕环形梳 2x';

  @override
  String get attachmentCoanda30 => '30毫米Co-anda2x卷筒';

  @override
  String get attachmentCoanda40 => '40毫米Co-anda2x卷筒';

  @override
  String get deleteDeviceDataTitle => '删除设备数据';

  @override
  String get deleteDeviceDataMessage => '长按删除会清除这台设备的本地连接记录和已保存设置。';

  @override
  String get cancelAction => '取消';

  @override
  String get deleteAction => '删除';

  @override
  String get deviceDataDeleted => '设备数据已删除。';
}
