// invite_page.dart
import 'dart:convert';
import 'package:chatapp/Shared/Constants/theme.dart';
import 'package:chatapp/components/My_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:chatapp/Shared/Constants/ApiConstants.dart';

class InvitePage extends StatefulWidget {
  final String token;
  final String chatId;
  final String userId;
  final String chatName;

  const InvitePage({
    Key? key,
    required this.token,
    required this.chatId,
    required this.userId,
    required this.chatName,
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
    final url =
        '${ApiConstants.baseUrl}'
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
            _profiles =
                profilesList.map<Map<String, dynamic>>((p) {
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

  void goToBack(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> _inviteUser(String invitedHash) async {
    // invite&token=...&chatid=...&invitedhash=...
    final url =
        '${ApiConstants.baseUrl}invite'
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
          SnackBar(content: Text("Leider haben Sie keine Berechtigungen Leute einzuladen.")),
        );
      }
    } catch (e) {
      logger.e("Fehler beim inviteUser: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Fehler beim Einladen: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Einladen in den Chat: ${widget.chatName}',
        onBackPressed: () => goToBack(context),
      ),

      backgroundColor: AppColors.white,

      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _profiles.isEmpty
              ? const Center(child: Text("Keine Profile gefunden."))
              : ListView.builder(
                itemCount: _profiles.length,
                itemBuilder: (context, index) {
                  final user = _profiles[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: AppColors.lightgreyTextBox, // Hintergrundfarbe der Box
                      borderRadius: BorderRadius.circular(48.0), // runde Ecken
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(user['nickname']),
                      subtitle: Text("Hash: ${user['hash']}"),
                      trailing: ElevatedButton(
                        onPressed: () => _inviteUser(user['hash']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue, // Hier deine Wunschfarbe
                          foregroundColor: Colors.white, // Textfarbe
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(48), // Button runden
                          ),
                        ),
                        child: const Text(
                          "Einladen",
                          style: TextStyle(
                            fontWeight: FontWeight.bold, // oder FontWeight.w700, w800, etc.
                            fontSize: 16,                // optional: größere Schrift
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
