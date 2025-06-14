import 'dart:async';
import 'dart:convert';
import 'package:chatapp/Shared/Constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:chatapp/Shared/Constants/ApiConstants.dart';

class InboxPage extends StatefulWidget {
  final String token;
  final String userId;

  const InboxPage({Key? key, required this.token, required this.userId})
    : super(key: key);

  @override
  State<InboxPage> createState() => _InviteInboxPageState();
}

class _InviteInboxPageState extends State<InboxPage> {
  final _logger = Logger();
  Timer? _refreshTimer;
  bool _loading = true;
  List<Map<String, dynamic>> _invites = [];

  @override
  void initState() {
    super.initState();
    _fetchInvites();

    _refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _fetchInvites(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchInvites() async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}getinvites&token=${Uri.encodeQueryComponent(widget.token)}',
    );

    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map && decoded['invites'] is List) {
          setState(() {
            _invites = List<Map<String, dynamic>>.from(decoded['invites']);
            _loading = false;
          });
        } else {
          _logger.e('Formatfehler: $decoded');
          setState(() => _loading = false);
        }
      } else {
        _logger.e('HTTP-Fehler ${res.statusCode}');
        setState(() => _loading = false);
      }
    } catch (e) {
      _logger.e('getinvites-Fehler: $e');
      setState(() => _loading = false);
    }
  }

  // join Chat
  Future<bool> _joinChat(String chatId) async {
    try {
      String apiUrl =
          '${ApiConstants.baseUrl}'
          '${ApiConstants.joinChat}'
          '&token=${widget.token}'
          '&chatid=$chatId';

      final uri = Uri.parse(apiUrl);

      final res = await http.get(uri);
      if (res.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      _logger.e('getinvites-Fehler: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.lightgreyTextBox,
        elevation: 0.0,
        scrolledUnderElevation: 0,
        toolbarHeight: 48,
        title: const Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 16),
            child: Text(
              'Einladungen',
              style: TextStyle(
                color: AppColors.greyTextColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      backgroundColor: AppColors.white,
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _invites.isEmpty
              ? const Center(child: Text('Keine offenen Einladungen.'))
              : ListView.builder(
                itemCount: _invites.length,
                itemBuilder: (_, i) {
                  final inv = _invites[i];
                  return Container(
                    margin: EdgeInsets.only(
                      top: i == 0 ? 20 : 8,
                      bottom: 8,
                      left: 16,
                      right: 16,
                    ),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: AppColors.lightgreyTextBox,
                      borderRadius: BorderRadius.circular(48.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.mail_outline, size: 32),
                      title: Text(
                        inv['chatname'] ?? 'Chat ${inv['chatid']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          final success = await _joinChat(
                            inv['chatid'].toString(),
                          );
                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Erfolgreich beigetreten!'
                                    : 'Beitritt fehlgeschlagen.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor:
                                  success ? Colors.green : Colors.red,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.blue, // Hier deine Wunschfarbe
                          foregroundColor: Colors.white, // Textfarbe
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(48),
                          ),
                        ),
                        child: const Text(
                          "Annehmen",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
