import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:netguru/models/quote.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuoteService {
  static final QuoteService _instance = QuoteService._internal();
  Random _random = new Random();
  final Duration _waitDuration = Duration(seconds: 4);
  final String _quoteListKey = "UniqueQuoteListKey";

  List<Quote> _initialQuotes = [
  Quote(1, "Exceed clients' and colleagues' expectations"),
  Quote(2, "Take ownership and question the status quo in a constructive manner"),
  Quote(3, "Be brave, curious and experiment. Learn from all successes and failures"),
  // Quote(4, "Act in a way that makes all of us proud"),
  // Quote(5, "Build an inclusive, transparent and socially responsible culture"),
  // Quote(6, "Be ambitious, grow yourself and the people around you"),
  // Quote(7, "Recognize excellence and engagement"),
  ];

  QuoteService._internal();

  factory QuoteService.get() {
    return _instance;
  }

  Stream<Quote> getQuotes() async*{
    var quotes = await _loadQuotes();
    if (quotes == null){
      _saveQuotes(_initialQuotes);
    }
    var lastUsedQuoteIndices = Queue<int>();
    while(true){
      var quotes = await _loadQuotes();

      var availableIndices = quotes.map((q) => q.id).where((qId) => !lastUsedQuoteIndices.contains(qId)).toList();
      var randomQuoteIndex = availableIndices[_random.nextInt(availableIndices.length)];
      var newQuote = quotes.firstWhere((element) => element.id == randomQuoteIndex);
      if(lastUsedQuoteIndices.length > 0){
        // TODO change to higher number
        lastUsedQuoteIndices.removeFirst();
      }
      lastUsedQuoteIndices.addLast(newQuote.id);
      yield newQuote;
      await Future.delayed(_waitDuration);
    }
  }

  Future<void> addNewQuote(String content) async {
    var quotes = await _loadQuotes();
    int maxQuoteId = -1;
    for (var quote in quotes) {
      if (quote.id > maxQuoteId)
        maxQuoteId = quote.id;
    }
    quotes.add(Quote(maxQuoteId + 1, content));
    await _saveQuotes(quotes);
  }

  Future<void> setQuoteAsFavorite(int quoteId, bool isFavorite) async {
    var quotes = await _loadQuotes();
    var quote = quotes.firstWhere((q) => q.id == quoteId);
    quote.isFavorite = isFavorite;
    await _saveQuotes(quotes);
  }

  Future<List<Quote>> _loadQuotes() async{
    var persistentStorage = await SharedPreferences.getInstance();
    var encodedQuoteList = persistentStorage.getStringList(_quoteListKey);
    if (encodedQuoteList == null) return null;
    return encodedQuoteList.map((s) => Quote.fromJson(jsonDecode(s))).toList();
  }

  Future _saveQuotes(List<Quote> quotes) async{
    var persistentStorage = await SharedPreferences.getInstance();
    var ok = await persistentStorage.setStringList(_quoteListKey, quotes.map((q) => jsonEncode(q.toJson())).toList());
    if (!ok){
      throw Exception("failed to save quotes");
    }
  }
}
