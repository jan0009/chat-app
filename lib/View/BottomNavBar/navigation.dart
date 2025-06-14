import 'package:chatapp/Shared/Constants/theme.dart';
import 'package:chatapp/View/Pages/account_page.dart';
import 'package:chatapp/View/Pages/home_page.dart';
import 'package:chatapp/View/Pages/inbox_page.dart';
import 'package:chatapp/View/Pages/quotes_page.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class Navigation extends StatefulWidget {
  final String userId;
  final String token;
  const Navigation({super.key, required this.userId, required this.token});

  @override
  State<Navigation> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Navigation> {
  int currentIndexTab = 1;
  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      QuotesPage(),
      HomePage(userId: widget.userId),
      InboxPage(token: widget.token, userId: widget.userId),
      AccountPage(userId: widget.userId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.lightgreyTextBox,
        toolbarHeight: 132,
        elevation: 0.0,
        scrolledUnderElevation: 0,
        flexibleSpace: Builder(
          builder: (context) {
            final topPadding = MediaQuery.of(context).padding.top + 24; // Dynamisch + extra Abstand
            return Padding(
              padding: EdgeInsets.only(top: topPadding, left: 48),
              child: Align(
                alignment: Alignment.topLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'lib/images/Chatalyst-Icon.png',
                      width: 84,
                      height: 84,
                    ),
                    const SizedBox(width: 32),
                    Image.asset(
                      'lib/images/Chatalyst-Text.png',
                      width: 166,
                      height: 48,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      body: pages[currentIndexTab],
      bottomNavigationBar: GNav(
        backgroundColor: AppColors.lightgreyTextBox,
        color: AppColors.ligthgreyBackgroundcolor,
        activeColor: AppColors.black,
        gap: 8,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),

        tabMargin: const EdgeInsets.fromLTRB(0, 0, 0, 48),
        tabs: const [
          GButton(icon: Icons.today, iconSize: 48),
          GButton(icon: Icons.chat, iconSize: 48),
          GButton(icon: Icons.groups, iconSize: 48),
          GButton(icon: Icons.settings, iconSize: 48),
        ],
        selectedIndex: currentIndexTab,
        onTabChange: (index) {
          setState(() {
            currentIndexTab = index;
          });
        },
      ),
    );
  }
}