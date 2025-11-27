// --- SCREEN 1: THE LAB (HOME) ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/game_provider.dart';
import '../widget/home_button.dart';
import 'collection_screen.dart';
import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.redAccent, Colors.red],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.catching_pokemon, size: 100, color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                "SHADOWMON",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const Text(
                "Who's that Pokémon?",
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 50),
              HomeButton(
                title: "START HUNT",
                icon: Icons.play_arrow_rounded,
                onTap: () {
                  // Reset round before entering
                  Provider.of<GameProvider>(context, listen: false).startNewRound();
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen()));
                },
              ),
              const SizedBox(height: 20),
              HomeButton(
                title: "MY COLLECTION",
                icon: Icons.grid_view_rounded,
                color: Colors.orangeAccent,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CollectionScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
