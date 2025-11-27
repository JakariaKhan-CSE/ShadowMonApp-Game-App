import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

// --- MAIN ENTRY POINT ---
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: const ShadowMonApp(),
    ),
  );
}

class ShadowMonApp extends StatelessWidget {
  const ShadowMonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShadowMon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color(0xFFF2F2F2),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// --- DATA MODEL ---
class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;

  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'],
      name: json['name'],
      // Official artwork is higher res, fallback to front_default if needed
      imageUrl: json['sprites']['other']['official-artwork']['front_default'] ??
          json['sprites']['front_default'],
      types: (json['types'] as List)
          .map((t) => t['type']['name'].toString())
          .toList(),
    );
  }
}

// --- STATE MANAGEMENT (PROVIDER) ---
class GameProvider extends ChangeNotifier {
  Pokemon? currentPokemon;
  List<Pokemon> options = [];
  bool isLoading = false;
  bool isGuessed = false;
  bool guessResult = false; // true if correct, false if wrong

  List<String> collectedIds = [];
  int streak = 0;

  GameProvider() {
    loadCollection();
  }

  // Fetch a new round (1 correct + 3 wrong)
  Future<void> startNewRound() async {
    isLoading = true;
    isGuessed = false;
    notifyListeners();

    try {
      final random = Random();
      // Generate 4 unique random IDs between 1 and 1010
      Set<int> randomIds = {};
      while (randomIds.length < 4) {
        randomIds.add(random.nextInt(1010) + 1);
      }

      // Fetch data for all 4
      List<Pokemon> fetchedPokemon = [];
      for (int id in randomIds) {
        final poke = await _fetchPokemonById(id);
        if (poke != null) fetchedPokemon.add(poke);
      }

      if (fetchedPokemon.length < 4) throw Exception("Failed to load pokemon");

      options = fetchedPokemon;
      // Pick one as the correct answer
      currentPokemon = options[random.nextInt(options.length)];

    } catch (e) {
      debugPrint("Error fetching data: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Pokemon?> _fetchPokemonById(int id) async {
    final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/$id');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return Pokemon.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint("API Error: $e");
    }
    return null;
  }

  void makeGuess(Pokemon selected) {
    isGuessed = true;
    if (selected.id == currentPokemon!.id) {
      guessResult = true;
      streak++;
      _addToCollection(currentPokemon!);
    } else {
      guessResult = false;
      streak = 0;
    }
    notifyListeners();
  }

  // Persistence Logic
  Future<void> loadCollection() async {
    final prefs = await SharedPreferences.getInstance();
    collectedIds = prefs.getStringList('collection') ?? [];
    notifyListeners();
  }

  Future<void> _addToCollection(Pokemon p) async {
    // We store minimal data stringified: "ID|Name|ImageURL" to avoid full DB for this demo
    final prefs = await SharedPreferences.getInstance();
    String dataString = "${p.id}|${p.name}|${p.imageUrl}";

    if (!collectedIds.any((element) => element.startsWith("${p.id}|"))) {
      collectedIds.add(dataString);
      await prefs.setStringList('collection', collectedIds);
    }
  }
}

// --- SCREEN 1: THE LAB (HOME) ---
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
              _HomeButton(
                title: "START HUNT",
                icon: Icons.play_arrow_rounded,
                onTap: () {
                  // Reset round before entering
                  Provider.of<GameProvider>(context, listen: false).startNewRound();
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen()));
                },
              ),
              const SizedBox(height: 20),
              _HomeButton(
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

class _HomeButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _HomeButton({required this.title, required this.icon, required this.onTap, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 60,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: color == Colors.white ? Colors.red : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 5,
        ),
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// --- SCREEN 2 & 3: GAME SCREEN & RESULT ---
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

// --- SCREEN 4: COLLECTION ---
class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);
    final collection = provider.collectedIds;

    return Scaffold(
      appBar: AppBar(title: const Text("My PC")),
      body: collection.isEmpty
          ? const Center(child: Text("Your PC is empty.\nGo catch some Pokémon!", textAlign: TextAlign.center))
          : GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.8,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: collection.length,
        itemBuilder: (context, index) {
          // Parse the stored string "ID|Name|URL"
          final parts = collection[index].split('|');
          final name = parts[1];
          final url = parts[2];

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4, spreadRadius: 1)
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                  ),
                  child: Text(
                    name.capitalize(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- HELPER EXTENSION ---
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}