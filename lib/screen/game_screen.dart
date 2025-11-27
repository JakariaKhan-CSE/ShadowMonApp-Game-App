
// --- SCREEN 2 & 3: GAME SCREEN & RESULT ---
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadow_mon_app/utils/utils.dart';

import '../provider/game_provider.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Streak: ${provider.streak}"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Spacer(),
            // THE POKEMON IMAGE
            Stack(
              alignment: Alignment.center,
              children: [
                // Background Circle
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 5),
                  ),
                ),
                // The Silhouette Logic
                SizedBox(
                  width: 220,
                  height: 220,
                  child: ColorFiltered(
                    colorFilter: provider.isGuessed
                        ? const ColorFilter.mode(Colors.transparent, BlendMode.dst) // Show Color
                        : const ColorFilter.mode(Colors.black, BlendMode.srcIn), // Show Silhouette
                    child: CachedNetworkImage(
                      imageUrl: provider.currentPokemon!.imageUrl,
                      placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Result Text
            if (provider.isGuessed)
              Text(
                provider.guessResult
                    ? "Caught! It's ${provider.currentPokemon!.name.capitalize()}!"
                    : "Oh no! It was ${provider.currentPokemon!.name.capitalize()}.",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: provider.guessResult ? Colors.green : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),

            const Spacer(),

            // OPTION BUTTONS
            if (!provider.isGuessed)
              ...provider.options.map((pokemon) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => provider.makeGuess(pokemon),
                    child: Text(
                      pokemon.name.toUpperCase(),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ))
            else
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  onPressed: () => provider.startNewRound(),
                  child: const Text("NEXT POKÉMON", style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}