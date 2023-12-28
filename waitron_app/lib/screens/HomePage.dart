import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:waitron_app/models/Models.dart';
import 'package:waitron_app/screens/Staff.dart';
import 'package:waitron_app/services/db.dart';
import 'OrderPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}
  
class HomePageState extends State<HomePage> {
  final TextEditingController tableNumEntry = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255,85,114,88),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255,85,114,88),
          actions: [
            IconButton( // Route to the staff pages
              icon: const Icon(Icons.admin_panel_settings_rounded, size: 30, color: Color.fromARGB(255, 255, 255, 255),),
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
                  Expanded( // Textbox for Table Number entry.
                    child: SizedBox(
                      child: TextField(
                        controller: tableNumEntry,
                        decoration: 
                          const InputDecoration(labelText: 'Table Number', 
                            labelStyle: TextStyle(
                              color: Colors.black), 
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255))),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255)))
                          ),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.black),
                        cursorColor: const Color.fromARGB(255, 255, 255, 255)
                      ),
                    ),  
                  ),
                  const SizedBox(width: 15.0),
                  ElevatedButton( // Button to go to OrderPage
                    onPressed: () async {
                      print(tableNumEntry.text);
                      bool active = await DBs().isTableActive(Tables(tableNumber: tableNumEntry.text));
                      if (active){ // Error msg to notify the table is already in use
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Table ${tableNumEntry.text} is already in use.')
                          ),
                        );
                      }
                      if (tableNumEntry.text.isEmpty) { // Error msg if no table num is entered
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a table number.')
                          ),
                        );
                      }
                      if (!active){
                        DBs().addActiveTable(Tables(tableNumber: tableNumEntry.text));
                        Navigator.push( // Navigate to order page
                          context,
                          MaterialPageRoute(builder: (context) => OrderPage(tableNumber: tableNumEntry.text)),
                        );
                        FocusScope.of(context).unfocus();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)
                      ),
                    ),
                    child: const Text('Place Order', style: TextStyle(color: Colors.black)),
                  ),
                ]
              ),
            ],
          ),
        ),
      );
  }
}