import 'package:flutter_application_1/bloc/navigator/state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavCubit extends Cubit<NavigationState> {
  NavCubit() : super(NavigationState(selectedIndex: 0));

  void setSelectedIndex(int cam) => emit(NavigationState(selectedIndex: cam));
}
