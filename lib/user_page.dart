import 'package:flutter/material.dart';
import 'package:flutter_application_1/bloc/navigator/nav.dart';
import 'package:flutter_application_1/bloc/navigator/state.dart';
import 'package:flutter_application_1/core/GetIt/dependency_injection.dart';
import 'package:flutter_application_1/pages/home_page.dart';
import 'package:flutter_application_1/pages/picture_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/barrel.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => NavCubit())],
      child: Scaffold(
        bottomNavigationBar: BlocBuilder<NavCubit, NavigationState>(
          builder: (context, state) {
            return BottomNavigationBar(
              currentIndex: state.selectedIndex,
              onTap: (value) =>
                  context.read<NavCubit>().setSelectedIndex(value),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(
                  icon: Icon(Icons.photo_size_select_actual_rounded),
                  label: "Pictures",
                ),
              ],
            );
          },
        ),
        appBar: AppBar(
          title: const Text(
            'Flutter App',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
        ),
        body: BlocBuilder<NavCubit, NavigationState>(
          builder: (context, state) {
            switch (state.selectedIndex) {
              case 0:
                return HomePage();
              case 1:
                return PicturePage();
              default:
                return Container();
            }
          },
        ),
      ),
    );
  }
}
