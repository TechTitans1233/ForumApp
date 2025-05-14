import 'package:flutter/material.dart';
import 'Telas/tela_login.dart';
import 'Telas/tela_admin.dart';
import 'Telas/tela_publicacoes.dart';
import 'Telas/tela_profile.dart';

class Routes {
  static Map<String, Widget Function(BuildContext)> list = <String, WidgetBuilder>{
    '/': (_) => const TelaLogin(),
    '/forum': (_) => const TelaPublicacoes(),
    '/admin': (_) => const TelaAdmin(),
    '/profile': (_) => const UserProfile(),
  };

  static String initial = '/';

  static GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();
}