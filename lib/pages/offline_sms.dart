import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: const Color(0xFF007AFF),
      ),
      home: const HybridVoiceSMSPage(),
    );
  }
}

class HybridVoiceSMSPage extends StatefulWidget {
  const HybridVoiceSMSPage({super.key});

  @override
  State<HybridVoiceSMSPage> createState() => _HybridVoiceSMSPageState();
}

class _HybridVoiceSMSPageState extends State<HybridVoiceSMSPage> {
  
  // ===== SMS =====
  final Telephony telephony = Telephony.instance;
  TextEditingController numberCtrl = TextEditingController();
  TextEditingController messageCtrl = TextEditingController();
  String status = "";

  @override
  void initState() {
    super.initState();

    // Listen for incoming SMS
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        // Handle incoming messages if needed
      },
      onBackgroundMessage: backgroundHandler,
    );
  }

  static backgroundHandler(SmsMessage message) {
    debugPrint("Background SMS received: ${message.address}: ${message.body}");
  }

  // ===== Send SMS =====
  Future<void> sendSms(String number, String message) async {
    if (number.isEmpty || message.isEmpty) {
      setState(() {
        status = "Please enter both number and message";
      });
      return;
    }

    bool? permissionsGranted = await telephony.requestSmsPermissions;
    if (permissionsGranted ?? false) {
      await telephony.sendSms(to: number, message: message);
      setState(() {
        status = "Message sent successfully";
      });
      // Clear message field after sending
      messageCtrl.clear();
    } else {
      setState(() {
        status = "Permission denied - cannot send SMS";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),

                  // logo
                  Image.asset(
                    'assets/person.png', // Using same logo as login
                    height: 150,
                    width: 150,
                    fit: BoxFit.contain,
                  ),

                  const Text(
                    "Send SMS Offline",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF007AFF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // welcome message
                  const Text(
                    "Compose your message.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF007AFF),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // phone number textfield
                  MyTextField(
                    controller: numberCtrl,
                    hintText: 'Phone Number',
                    obscureText: false,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 10),

                  // message textfield
                  MyTextField(
                    controller: messageCtrl,
                    hintText: 'Type your message here...',
                    obscureText: false,
                    maxLines: 4,
                  ),

                  const SizedBox(height: 25),

                  // send button
                  MyButton(
                    text: "Send SMS",
                    onTap: () => sendSms(numberCtrl.text, messageCtrl.text),
                  ),

                  const SizedBox(height: 25),

                  // status message
                  Text(
                    status,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: status.contains("successfully") 
                          ? Colors.green
                          : status.contains("Permission") 
                              ? Colors.red
                              : const Color(0xFF007AFF),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Reusing your custom components
class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF007AFF)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF007AFF)),
        ),
        fillColor: Colors.grey[900],
        filled: true,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),
    );
  }
}

class MyButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const MyButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF007AFF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}