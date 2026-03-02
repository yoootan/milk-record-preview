class AppStrings {
  // ===== Japanese =====
  static const ja = _JaStrings();
  // ===== English =====
  static const en = _EnStrings();

  static AppStringBase forLocale(String locale) {
    switch (locale) {
      case 'en':
        return en;
      default:
        return ja;
    }
  }
}

abstract class AppStringBase {
  String get appTitle;
  String get breastMilk;
  String get formula;
  String get whichSide;
  String get left;
  String get right;
  String feedingLeft(String side);
  String get stop;
  String get touchToAdjust;
  String get releaseToRecord;
  String get recorded;
  String get spitUp;
  String get spitUpSmall;
  String get spitUpMedium;
  String get spitUpLarge;
  String spitUpRecorded(String amount);
  String formulaRecorded(int ml);
  String breastRecorded(String side, String duration);
  String get today;
  String get yesterday;
  String get noRecords;
  String get deleteTitle;
  String get deleteMessage;
  String get cancel;
  String get delete;
  String get settingsColorTheme;
  String get settingsNightMode;
  String get settingsNightModeSub;
  String get settingsDefaultTab;
  String get settingsDefaultTabSub;
  String get settingsLanguage;
  String get settingsLanguageSub;
  String get langJapanese;
  String get langEnglish;
  String get langPreparing;
  String get themePink;
  String get themeOrange;
  String get themeBlue;
  String get themeDark;
  String liveBanner(int count);
  String get cannotSwitchTab;
  String dailyBreastTotal(String duration);
  String dailyFormulaTotal(int ml);
  String elapsedSinceLastFeed(String time);
}

class _JaStrings implements AppStringBase {
  const _JaStrings();

  @override String get appTitle => '授乳きろく';
  @override String get breastMilk => '母乳';
  @override String get formula => 'ミルク';
  @override String get whichSide => 'どちら側ですか？';
  @override String get left => 'ひだり';
  @override String get right => 'みぎ';
  @override String feedingLeft(String side) => '$sideで授乳中...';
  @override String get stop => 'ストップ';
  @override String get touchToAdjust => 'タッチして量を調整';
  @override String get releaseToRecord => '指をはなすと記録';
  @override String get recorded => '✓ 記録しました！';
  @override String get spitUp => '吐き戻し';
  @override String get spitUpSmall => '少量';
  @override String get spitUpMedium => '中量';
  @override String get spitUpLarge => '大量';
  @override String spitUpRecorded(String amount) => '吐き戻し（$amount）記録しました';
  @override String formulaRecorded(int ml) => 'ミルク ${ml}ml 記録しました';
  @override String breastRecorded(String side, String duration) => '$side $duration 記録しました';
  @override String get today => 'きょう';
  @override String get yesterday => 'きのう';
  @override String get noRecords => 'まだ記録がありません';
  @override String get deleteTitle => '記録を削除';
  @override String get deleteMessage => 'この記録を削除しますか？';
  @override String get cancel => 'キャンセル';
  @override String get delete => '削除する';
  @override String get settingsColorTheme => 'カラーテーマ';
  @override String get settingsNightMode => 'ナイトモード';
  @override String get settingsNightModeSub => '20:00〜6:00 自動ダーク';
  @override String get settingsDefaultTab => 'デフォルトのタブ';
  @override String get settingsDefaultTabSub => 'アプリ起動時に表示するタブ';
  @override String get settingsLanguage => '言語 / Language';
  @override String get settingsLanguageSub => '';
  @override String get langJapanese => '日本語';
  @override String get langEnglish => 'English';
  @override String get langPreparing => '準備中';
  @override String get themePink => 'ピンク';
  @override String get themeOrange => 'オレンジ';
  @override String get themeBlue => 'ブルー';
  @override String get themeDark => 'ダーク';
  @override String liveBanner(int count) => 'いま$count人が授乳中';
  @override String get cannotSwitchTab => '計測中はタブを切り替えられません';
  @override String dailyBreastTotal(String duration) => '母乳 $duration';
  @override String dailyFormulaTotal(int ml) => 'ミルク ${ml}ml';
  @override String elapsedSinceLastFeed(String time) => '前回から $time';
}

class _EnStrings implements AppStringBase {
  const _EnStrings();

  @override String get appTitle => 'Feeding Log';
  @override String get breastMilk => 'Breast';
  @override String get formula => 'Formula';
  @override String get whichSide => 'Which side?';
  @override String get left => 'Left';
  @override String get right => 'Right';
  @override String feedingLeft(String side) => 'Feeding on $side...';
  @override String get stop => 'Stop';
  @override String get touchToAdjust => 'Touch to adjust amount';
  @override String get releaseToRecord => 'Release to record';
  @override String get recorded => '✓ Recorded!';
  @override String get spitUp => 'Spit Up';
  @override String get spitUpSmall => 'Small';
  @override String get spitUpMedium => 'Medium';
  @override String get spitUpLarge => 'Large';
  @override String spitUpRecorded(String amount) => 'Spit up ($amount) recorded';
  @override String formulaRecorded(int ml) => 'Formula ${ml}ml recorded';
  @override String breastRecorded(String side, String duration) => '$side $duration recorded';
  @override String get today => 'Today';
  @override String get yesterday => 'Yesterday';
  @override String get noRecords => 'No records yet';
  @override String get deleteTitle => 'Delete Record';
  @override String get deleteMessage => 'Delete this record?';
  @override String get cancel => 'Cancel';
  @override String get delete => 'Delete';
  @override String get settingsColorTheme => 'Color Theme';
  @override String get settingsNightMode => 'Night Mode';
  @override String get settingsNightModeSub => 'Auto dark 8PM–6AM';
  @override String get settingsDefaultTab => 'Default Tab';
  @override String get settingsDefaultTabSub => 'Tab shown when app opens';
  @override String get settingsLanguage => '言語 / Language';
  @override String get settingsLanguageSub => '';
  @override String get langJapanese => '日本語';
  @override String get langEnglish => 'English';
  @override String get langPreparing => 'Coming soon';
  @override String get themePink => 'Pink';
  @override String get themeOrange => 'Orange';
  @override String get themeBlue => 'Blue';
  @override String get themeDark => 'Dark';
  @override String liveBanner(int count) => '$count people feeding now';
  @override String get cannotSwitchTab => 'Cannot switch tabs while recording';
  @override String dailyBreastTotal(String duration) => 'Breast $duration';
  @override String dailyFormulaTotal(int ml) => 'Formula ${ml}ml';
  @override String elapsedSinceLastFeed(String time) => '$time since last feed';
}
