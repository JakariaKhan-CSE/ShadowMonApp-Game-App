import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/pokemon.dart';
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