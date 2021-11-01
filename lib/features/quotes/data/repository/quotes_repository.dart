import 'package:dartx/dartx.dart';
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:quotes/core/service_locator/sl.dart';
import 'package:quotes/features/quotes/domain/entities/quote.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuoteRepository {
  late final _sharedPreferences = sl<SharedPreferences>();
  final Random _random = Random();
  final Duration _waitDuration = const Duration(seconds: 5);
  final String _quotesKey = "UniqueQuoteListKey";

  final List<Quote> _initialQuotes = [
    Quote(1, "Exceed clients' and colleagues' expectations"),
    Quote(2, "Take ownership and question the status quo in a constructive manner"),
    Quote(3, "Be brave, curious and experiment. Learn from all successes and failures"),
    Quote(4, "Act in a way that makes all of us proud"),
    Quote(5, "Build an inclusive, transparent and socially responsible culture"),
    Quote(6, "Be ambitious, grow yourself and the people around you"),
    Quote(7, "Recognize excellence and engagement"),
  ];

  Stream<Quote> quotesStream() async* {
    final quotes = await _loadQuotes();
    if (quotes.isEmpty) {
      _saveQuotes(_initialQuotes);
    }
    final lastUsedQuoteIndices = Queue<int?>();
    while (true) {
      final quotes = await _loadQuotes();
      final availableIndices = quotes.map((quote) => quote.id).where((qId) => !lastUsedQuoteIndices.contains(qId)).toList();
      final randomQuoteIndex = availableIndices[_random.nextInt(availableIndices.length)];
      final newQuote = quotes.firstWhere((element) => element.id == randomQuoteIndex);
      if (lastUsedQuoteIndices.length > 4) {
        lastUsedQuoteIndices.removeFirst();
      }
      lastUsedQuoteIndices.addLast(newQuote.id);
      yield newQuote;
      await Future.delayed(_waitDuration);
    }
  }

  final bookmarkedQuotesStreamController = StreamController<List<Quote>>.broadcast();
  Stream<List<Quote>> bookmarkedQuotes() {
    refreshBookmarks();
    return bookmarkedQuotesStreamController.stream;
  }

  Future refreshBookmarks() async {
    final quotes = (await _loadQuotes()).where((quote) => quote.isBookmarked).toList();
    bookmarkedQuotesStreamController.add(quotes);
  }

  Future<void> createQuote(String content) async {
    final quotes = (await _loadQuotes());
    final maxQuoteId = quotes.maxBy((element) => element.id)?.id ?? -1;
    quotes.add(Quote(maxQuoteId + 1, content));
    await _saveQuotes(quotes);
  }

  Future<void> bookmarkQuote(int quoteId, bool isBookmarked) async {
    final quotes = await _loadQuotes();
    final quote = quotes.firstWhere((q) => q.id == quoteId);
    quote.isBookmarked = isBookmarked;
    await _saveQuotes(quotes);
    refreshBookmarks();
  }

  Future<List<Quote>> _loadQuotes() async {
    final encodedQuotes = _sharedPreferences.getStringList(_quotesKey);
    if (encodedQuotes == null) return [];
    return encodedQuotes.map((quote) => Quote.fromJson(jsonDecode(quote))).toList();
  }

  Future _saveQuotes(List<Quote> quotes) async {
    final wasSaveSuccessful = await _sharedPreferences.setStringList(_quotesKey, quotes.map((q) => jsonEncode(q.toJson())).toList());
    if (!wasSaveSuccessful) {
      throw Exception("failed to save quotes");
    }
  }
}
