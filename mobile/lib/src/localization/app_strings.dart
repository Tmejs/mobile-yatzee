enum AppStringKey { homeTitle }

class AppStrings {
  static const _polish = <AppStringKey, String>{
    AppStringKey.homeTitle: 'Generał',
  };

  static String polish(AppStringKey key) => _polish[key]!;
}
