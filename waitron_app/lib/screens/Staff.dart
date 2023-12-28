import 'package:flutter/material.dart';
import 'package:waitron_app/screens/KitchenPage.dart';
import 'package:waitron_app/screens/MenuPage.dart';
import 'package:waitron_app/screens/WaitronPage.dart';

// Controls navigation between the Waitron, Kitchen and Menu pages
class Staff extends StatefulWidget {
  const Staff({super.key});

  @override
  StaffPageState createState() => StaffPageState();
}

class StaffPageState extends State<Staff> {

  int currentIndex = 0;
  PageController pageController = PageController(initialPage: 0);

  final navigationBarItems = [ 
    const BottomNavigationBarItem(icon: Icon(Icons.person), label: "Waitron",),
    const BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: "Kitchen",),
    const BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Menu",),
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
        color: const Color.fromARGB(255, 255, 255, 255),
        border: Border(
          top: BorderSide(color: Colors.black.withOpacity(0.1), width: 1.0),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        selectedItemColor: const Color.fromARGB(255,255,187,85),
        unselectedItemColor: const Color.fromARGB(255,85,114,88),
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