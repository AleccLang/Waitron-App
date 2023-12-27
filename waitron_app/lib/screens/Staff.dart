import 'package:flutter/material.dart';
import 'package:waitron_app/screens/KitchenPage.dart';
import 'package:waitron_app/screens/MenuPage.dart';
import 'package:waitron_app/screens/WaitronPage.dart';

class Staff extends StatefulWidget {
  const Staff({super.key});

  @override
  StaffPageState createState() => StaffPageState();
}

class StaffPageState extends State<Staff> {

  int currentIndex = 0;
  PageController pageController = PageController(initialPage: 0);

  final navigationBarItems = [
    const BottomNavigationBarItem(icon: Icon(Icons.person, color: Color.fromARGB(255,97,166,171)), label: "Waitron",),
    const BottomNavigationBarItem(icon: Icon(Icons.kitchen, color: Color.fromARGB(255,97,166,171)), label: "Kitchen",),
    const BottomNavigationBarItem(icon: Icon(Icons.menu_book, color: Color.fromARGB(255,97,166,171)), label: "Menu",),
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
      children: const [
        WaitronPage(),
        KitchenPage(),
        MenuPage(),
      ],
    ),
    bottomNavigationBar: Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 246, 246, 233),
        border: Border(
          top: BorderSide(color: Colors.black.withOpacity(0.1), width: 1.0),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 246, 246, 233),
        selectedItemColor: const Color.fromARGB(255,97,166,171),
        unselectedItemColor: Colors.black,
        currentIndex: currentIndex,
        elevation: 4,
        onTap: (index){
          pageController.animateToPage(index, duration: const Duration(milliseconds: 350), curve: Curves.linear);
        },
        items: navigationBarItems, 
      ),
    )
  );
}