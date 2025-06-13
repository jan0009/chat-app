import 'dart:math';

import 'package:chatapp/Shared/Constants/QuotesConstants.dart';
import 'package:chatapp/Shared/Constants/theme.dart';
import 'package:chatapp/infrastructur/ObjektKlassen/Quotes.dart';
import 'package:flutter/material.dart';

class QuotesPage extends StatelessWidget {
  const QuotesPage({super.key});
  final List<Quotes> allQuotes = QuotesConstants.allQuotes;

  List<Quotes> getRandomQuotes(int count) {
    final random = Random();
    final shuffled = List<Quotes>.from(allQuotes)..shuffle(random);
    return shuffled.take(count).toList();
  }

  @override
  Widget build(BuildContext context) {
    final randomQuotes = getRandomQuotes(7); // 5 zufällige Quotes

    return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.lightgreyTextBox,
            elevation: 0.0,
            scrolledUnderElevation: 0,
            toolbarHeight: 48,
            title: const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 16), // hier kannst du feinsteuern
                child: Text(
                  'Sprüche des Tages',
                  style: TextStyle(color: AppColors.greyTextColor ,fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          backgroundColor: AppColors.white,
          body: ListView.builder(
            itemCount: randomQuotes.length,
            itemBuilder: (context, index) {
              final quote = randomQuotes[index];
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: AppColors.lightgreyTextBox,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '"${quote.quote}"',
                          style: const TextStyle(fontSize: 20, color: AppColors.greyTextColor),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            '- ${quote.auhtor}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }  
}