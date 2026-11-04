import 'package:app_core/app/enum.dart';
import 'package:app_core/bootstrap.dart';
import 'package:app_core/app/app.dart';

Future<void> main() async {
  await bootstrap(App.new, Env.development);
}
