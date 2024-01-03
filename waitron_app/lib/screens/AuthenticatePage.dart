import 'package:flutter/material.dart';
import 'package:waitron_app/services/AuthenticateService.dart';

// Provides login for staff to access the staff pages
class AuthenticatePage extends StatefulWidget {
  const AuthenticatePage({super.key});

  @override
  AuthenticatePageState createState() => AuthenticatePageState();
}

class AuthenticatePageState extends State<AuthenticatePage> {
  final TextEditingController emailEntry = TextEditingController();
  final TextEditingController passwordEntry = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 85, 114, 88),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 85, 114, 88),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 125, 164, 129),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                ),
              ),
              child: const Center(
                child: Text('Login', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 150),
            SizedBox( // Textbox for email entry
              child: TextField(
                controller: emailEntry,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    color: Colors.black,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
                cursorColor: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            const SizedBox(height: 20.0),
            SizedBox( // Textbox for password entry
              child: TextField(
                controller: passwordEntry,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    color: Colors.black,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
                cursorColor: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton( // Login button 
              onPressed: () async {
                AuthenticateService().signIn(emailEntry.text, passwordEntry.text, context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 187, 85),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                )
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                child: Text('Login', style: TextStyle(fontWeight: FontWeight.w900,fontSize: 18.0,color: Color.fromARGB(255, 85, 114, 88)))
              )
            )
          ]
        )    
        )
    );
  }
}
