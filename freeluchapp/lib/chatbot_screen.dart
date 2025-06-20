import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  late final GenerativeModel _model;
  late final ChatSession _chat;

  bool _isLoading = false;
  String? _userRole; // Variable to store the user's role
  String? _userName; // Variable to store the user's name

  // Firebase Instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Initialize the Gemini model.
    _model = GenerativeModel(
      model: 'gemini-1.5-flash', // ✅ Use a valid model
      apiKey: 'AIzaSyCczypulZKnwl6MAI3x87nIb18BRuyBG0U', // Replace with your API key
    );
    _chat = _model.startChat();

    // Fetch user role and name, then add the welcome message
    _fetchUserRoleAndName();
  }

  // Function to fetch user role and name from Firestore
  Future<void> _fetchUserRoleAndName() async {
    User? currentUser = _auth.currentUser;
    String fetchedUserName = 'Pengguna'; // Default name
    String fetchedUserRole = 'Tamu'; // Default role

    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          fetchedUserName = (userDoc.data() as Map<String, dynamic>)['name'] ?? currentUser.email ?? 'Pengguna';
          fetchedUserRole = (userDoc.data() as Map<String, dynamic>)['role'] ?? 'Tidak Diketahui';
        } else {
          fetchedUserName = currentUser.email ?? 'Pengguna';
          fetchedUserRole = "Tidak Diketahui";
        }
      } catch (e) {
        print("Error fetching user data: $e");
        fetchedUserName = currentUser.email ?? 'Pengguna';
        fetchedUserRole = "Tidak Diketahui";
      }
    }

    setState(() {
      _userName = fetchedUserName;
      _userRole = fetchedUserRole;
      // Add a welcome message from the chatbot after user data is fetched
      _messages.add({'role': 'bot', 'text': 'Halo, $_userName! Apakah ada yang bisa saya bantu?'});
    });
  }

  Future<void> _sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': input});
      _controller.clear();
      _isLoading = true; // Activate loading indicator
    });

    try {
      final response = await _chat.sendMessage(Content.text(input));
      final output = response.text ?? 'Tidak ada balasan dari Gemini.';

      setState(() {
        _messages.add({'role': 'bot', 'text': output});
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'bot', 'text': '❌ Error: $e'});
      });
    } finally {
      setState(() {
        _isLoading = false; // Deactivate loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Display only "Chatbot" in the AppBar title
        title: const Text(
          'Chatbot',
          style: TextStyle(color: Colors.white), // White text color
        ),
        backgroundColor: Colors.blueAccent, // AppBar background color
        iconTheme: const IconThemeData(color: Colors.white), // Icon color (e.g., back button)
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(message['text'] ?? ''),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) // Show loading indicator if _isLoading is true
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (value) => _sendMessage(), // Panggil _sendMessage saat Enter ditekan
                    decoration: const InputDecoration(
                      hintText: 'Ketik pesan...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isLoading ? null : _sendMessage, // Disable button while loading
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
