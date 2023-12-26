import 'package:flutter/material.dart';
import 'package:waitron_app/screens/Staff.dart';
import 'OrderPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}
  
class HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldMessengerState> noTableKey = GlobalKey<ScaffoldMessengerState>();
  final TextEditingController tableNumEntry = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: noTableKey,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(104, 23, 186, 1),
        appBar: AppBar(
          title: const Text('Restaurant App'),
          actions: [
            IconButton(
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
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      child: TextField(
                        controller: tableNumEntry,
                        decoration: const InputDecoration(labelText: 'Table Number'),
                        keyboardType: TextInputType.number,
                      ),
                    ),  
                  ),
                  const SizedBox(width: 15.0),
                  ElevatedButton(
                    onPressed: () {
                      if (tableNumEntry.text.isEmpty) {
                        // Show error message
                        noTableKey.currentState?.showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a table number.'),
                          ),
                        );
                      } else {
                        tableNumEntry.clear();
                        FocusScope.of(context).unfocus();
                        // Order page
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const OrderPage()),
                        );
                      }
                    },
                    child: const Text('Place Order'),
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
