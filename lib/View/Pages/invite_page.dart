// invite_page.dart
import 'dart:convert';
import 'package:chatapp/components/My_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:chatapp/View/Pages/home_page.dart';


import 'package:chatapp/Shared/Constants/ApiConstants.dart';

class InvitePage extends StatefulWidget {
  final String token;
  final String chatId;
  final String userId;

  const InvitePage({
    Key? key,
    required this.token,
    required this.chatId,
    required this.userId,
  }) : super(key: key);

  @override
  State<InvitePage> createState() => _InvitePageState();
}

class _InvitePageState extends State<InvitePage> {
  final logger = Logger();
  bool _isLoading = true;
  List<Map<String, dynamic>> _profiles = [];

  @override
  void initState() {
    super.initState();
    _fetchProfiles();
  }


  Future<void> _fetchProfiles() async {
  
    final url = '${ApiConstants.baseUrl}'
          '${ApiConstants.getprofiles}'
          '&token=${widget.token}';

    try {
     
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        
        // Beispiel: erwarte {"profiles": [...]}
        if (decoded is Map && decoded.containsKey('profiles')) {
          final List profilesList = decoded['profiles'];
          setState(() {
            _profiles = profilesList.map<Map<String, dynamic>>((p) {
              return {
                'hash': p['hash'].toString(),
                'nickname': p['nickname'] ?? 'User',
                // Weitere Felder je nach Bedarf
              };
            }).toList();
            _isLoading = false;
          });
        } else {
          logger.e("Keine 'profiles' in der Antwort gefunden.");
          setState(() => _isLoading = false);
        }
      } else {
        logger.e("Fehler beim Laden der Profile: ${response.statusCode}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      logger.e("Fehler bei getprofiles: $e");
      setState(() => _isLoading = false);
    }
  }
void goToHome(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage(userId: widget.userId)),
    );
  }

  Future<void> _inviteUser(String invitedHash) async {
    // invite&token=...&chatid=...&invitedhash=...
    final url = '${ApiConstants.baseUrl}invite'
        '&token=${widget.token}'
        '&chatid=${widget.chatId}'
        '&invitedhash=$invitedHash';
        

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        logger.i("User $invitedHash eingeladen!");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User $invitedHash wurde eingeladen.")),
        );
      } else {
        logger.e("Fehler beim Einladen: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Fehler: ${response.statusCode}")),
        );
      }
    } catch (e) {
      logger.e("Fehler beim inviteUser: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fehler beim Einladen: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Einladen in Chat #${widget.chatId}',
        onBackPressed: () => goToHome(context),
      ),

      backgroundColor: const Color(0xFFb9d0e2),

      
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profiles.isEmpty
              ? const Center(child: Text("Keine Profile gefunden."))
              : ListView.builder(
                  itemCount: _profiles.length,
                  itemBuilder: (context, index) {
                    final user = _profiles[index];
                    return ListTile(
                      title: Text(user['nickname']),
                      subtitle: Text("Hash: ${user['hash']}"),
                      trailing: ElevatedButton(
                        onPressed: () => _inviteUser(user['hash']),
                        child: const Text("Einladen"),
                      ),
                    );
                  },
                ),
    );
  }
}