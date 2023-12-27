import 'package:flutter/material.dart';
import 'package:waitron_app/screens/Staff.dart';
import 'OrderPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}
  
class HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldMessengerState> tableNumKey = GlobalKey<ScaffoldMessengerState>();
  final TextEditingController tableNumEntry = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: tableNumKey,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255,97,166,171),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255,97,166,171),
          actions: [
            IconButton( // Route to the staff pages
              icon: const Icon(Icons.admin_panel_settings_rounded, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Staff()),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Image.asset('lib/assets/logo.png', width: 300, height: 300),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      child: TextField(
                        controller: tableNumEntry,
                        decoration: 
                          const InputDecoration(labelText: 'Table Number', 
                            labelStyle: TextStyle(
                              color: Colors.black), 
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color.fromARGB(255, 246, 246, 233))),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color.fromARGB(255, 246, 246, 233)))
                          ),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.black)
                      ),
                    ),  
                  ),
                  const SizedBox(width: 15.0),
                  ElevatedButton(
                    onPressed: () {
                      if (tableNumEntry.text.isEmpty) { // Error msg if no table num is entered
  
                        tableNumKey.currentState?.showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a table number.')
                          ),
                        );
                      } else {
                        Navigator.push( // Navigate to order page
                          context,
                          MaterialPageRoute(builder: (context) => OrderPage(tableNumber: tableNumEntry.text)),
                        );
                        FocusScope.of(context).unfocus();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 246, 246, 233)
                    ),
                    child: const Text('Place Order', style: TextStyle(color: Colors.black)),
                  ),
                ]
              ),
            ],
          ),
        ),
      ),
    );
  }
}