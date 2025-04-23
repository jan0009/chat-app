import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:chatapp/Shared/Constants/ApiConstants.dart';
import 'package:chatapp/components/My_app_bar.dart';
import 'package:chatapp/View/Pages/home_page.dart';
import 'package:logger/logger.dart';

class InboxPage extends StatefulWidget {
  final String token;
  final String userId;

  const InboxPage({Key? key,
   required this.token,
   required this.userId,
  }) : super(key: key);



  @override
  State<InboxPage> createState() => _InviteInboxPageState();
}

class _InviteInboxPageState extends State<InboxPage> {
  final _logger = Logger();
  bool _loading = true;
  List<Map<String, dynamic>> _invites = [];

  @override
  void initState() {
    super.initState();
    _fetchInvites();
  }

  Future<void> _fetchInvites() async {
    final uri =
        Uri.parse('${ApiConstants.baseUrl}getinvites&token=${Uri.encodeQueryComponent(widget.token)}');
    
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
void goToHome(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage(userId: widget.userId)),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: CustomAppBar(
        title: 'Einladungen: ',
        onBackPressed: () => goToHome(context),
      ),
      backgroundColor: const Color(0xFFb9d0e2),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _invites.isEmpty
              ? const Center(child: Text('Keine offenen Einladungen.'))
              : ListView.builder(
                  itemCount: _invites.length,
                  itemBuilder: (_, i) {
                    final inv = _invites[i];
                    return ListTile(
                      leading: const Icon(Icons.mail_outline),
                      title: Text(inv['chatname'] ?? 'Chat ${inv['chatid']}'),
                      subtitle: Text('Von: ${inv['invitername'] ?? 'unbekannt'}'),
                    );
                  },
                ),
    );
  }
}