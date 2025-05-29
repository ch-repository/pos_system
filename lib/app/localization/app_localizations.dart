import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// 应用国际化配置
///
/// 这个类负责：
/// 1. 定义支持的语言
/// 2. 配置本地化代理
/// 3. 提供语言切换功能
///
/// 注意：在实际项目中，你可能会使用 slang 来生成更完整的国际化支持
/// 这里提供基础配置，后续可以替换为 slang 生成的代码
class AppLocalizations {
  // 私有构造函数，防止实例化
  AppLocalizations._();

  // ==================== 支持的语言 ====================

  /// 中文（简体）
  static const Locale zh = Locale('zh', 'CN');

  /// 英文
  static const Locale en = Locale('en', 'US');

  /// 支持的语言列表
  static const List<Locale> supportedLocales = [
    zh,
    en,
  ];

  // ==================== 本地化代理 ====================

  /// 本地化代理列表
  ///
  /// 包含了Flutter框架和Material组件的本地化支持
  /// 在实际项目中，如果使用slang，会包含自定义的代理
  static const List<LocalizationsDelegate> localizationsDelegates = [
    // Flutter框架的本地化代理
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,

    // 如果使用slang，在这里添加：
    // AppLocalizationsDelegate(),
  ];

  // ==================== 语言工具方法 ====================

  /// 获取语言名称（用于设置页面显示）
  static String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'zh':
        return '中文';
      case 'en':
        return 'English';
      default:
        return locale.languageCode;
    }
  }

  /// 检查是否支持指定语言
  static bool isSupported(Locale locale) {
    return supportedLocales.any(
      (supportedLocale) =>
          supportedLocale.languageCode == locale.languageCode &&
          supportedLocale.countryCode == locale.countryCode,
    );
  }

  /// 获取最佳匹配的语言
  ///
  /// 如果用户的系统语言在支持列表中，返回该语言
  /// 否则返回默认语言（中文）
  static Locale getBestMatch(Locale userLocale) {
    // 首先尝试精确匹配（语言码+国家码）
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == userLocale.languageCode &&
          supportedLocale.countryCode == userLocale.countryCode) {
        return supportedLocale;
      }
    }

    // 然后尝试语言码匹配
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == userLocale.languageCode) {
        return supportedLocale;
      }
    }

    // 如果都不匹配，返回默认语言
    return zh;
  }

  /// 获取默认语言
  static Locale get defaultLocale => zh;

  /// 获取所有支持的语言选项（用于设置页面）
  static List<Map<String, dynamic>> get languageOptions => [
        {
          'locale': zh,
          'name': '中文',
          'nativeName': '中文',
        },
        {
          'locale': en,
          'name': 'English',
          'nativeName': 'English',
        },
      ];
}

// 移除所有临时的本地化代理实现，因为现在使用了真正的 flutter_localizations 包
