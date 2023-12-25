import 'package:flutter/material.dart';
import 'package:waitron_app/screens/KitchenPage.dart';
import 'package:waitron_app/screens/MenuPage.dart';
import 'package:waitron_app/screens/WaitronPage.dart';

class Staff extends StatefulWidget {
  const Staff({Key? key}) : super(key: key);

  @override
  StaffPageState createState() => StaffPageState();
}

class StaffPageState extends State<Staff> {

  int currentIndex = 0;
  PageController pageController = PageController(initialPage: 0);

  final navigationBarItems = [
    const BottomNavigationBarItem(icon: Icon(Icons.person, color: Colors.blueGrey,), label: "Waitron",),
    const BottomNavigationBarItem(icon: Icon(Icons.kitchen, color: Colors.blueGrey), label: "Kitchen",),
    const BottomNavigationBarItem(icon: Icon(Icons.menu_book, color: Colors.blueGrey), label: "Menu",),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: PageView(
      controller: pageController,
      onPageChanged: (newIndex){
        setState(() {
          currentIndex = newIndex;
        });
      },
      children: [
        WaitronPage(),
        KitchenPage(),
        MenuPage(),
      ],
    ),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index){
        pageController.animateToPage(index, duration: const Duration(milliseconds: 350), curve: Curves.linear);
      },
      items: navigationBarItems, 
    ),
  );
}