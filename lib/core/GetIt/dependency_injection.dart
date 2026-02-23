import 'package:flutter_application_1/repository/repository.dart';
import 'package:get_it/get_it.dart';
import 'package:repository/repository.dart';

import '../../bloc/barrel.dart';

var getIt = GetIt.instance;

Future<void> setup() async {
  getIt.registerLazySingleton<Repository>(() => Repository());
  getIt.registerLazySingleton<AbstractRepository>(() => AbstractRepository());

  getIt.registerFactory<PictureBloc>(
    () => PictureBloc(repository: getIt<Repository>()),
  );

  getIt.registerFactory<ConnectivityBloc>(
    () => ConnectivityBloc(abstractRepository: getIt<AbstractRepository>()),
  );
}
