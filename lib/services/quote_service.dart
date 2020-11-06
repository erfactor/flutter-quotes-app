import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:netguru/models/quote.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuoteService {
  static final QuoteService _instance = QuoteService._internal();
  Random _random = new Random();
  final Duration _waitDuration = Duration(seconds: 3);
  final String _quoteListKey = "UniqueQuoteListKey";

  List<Quote> _quotes = [
  Quote(1, "Exceed clients' and colleagues' expectations"),
  Quote(2, "Take ownership and question the status quo in a constructive manner"),
  Quote(3, "Be brave, curious and experiment. Learn from all successes and failures"),
  Quote(4, "Act in a way that makes all of us proud"),
  Quote(5, "Build an inclusive, transparent and socially responsible culture"),
  Quote(6, "Be ambitious, grow yourself and the people around you"),
  Quote(7, "Recognize excellence and engagement"),
  ];

  QuoteService._internal();

  factory QuoteService.get() {
    return _instance;
  }

  Stream<String> getQuotes() async*{
    var lastUsedQuotes = Queue<int>();
    while(true){
      // List<int> availableNumbers = Enumerable.Range(1, NumOfDifferent).Except(UsedNumbers).ToList();
      // Dialog result = SmallTalks.Where(d => availableNumbers.Contains(d.file_name.NumberOfSmalltalk())).GetRandomElement();
      // lastUsedQuotes.removeFirst()
      // lastUsedQuotes.addLast(value)
      // UsedNumbers.Enqueue(result.file_name.NumberOfSmalltalk());
      var randomQuoteIndex = _random.nextInt(_quotes.length);
      yield _quotes[randomQuoteIndex].content;
      await Future.delayed(_waitDuration);
    }
  }

  Future<void> addNewQuote(String quote) async {
    var prefs = await SharedPreferences.getInstance();

    var ok = await prefs.setStringList(_quoteListKey, _quotes.map((q) => jsonEncode(q.toJson())).toList());

    var listString = await prefs.getStringList(_quoteListKey);

    var list = listString.map((s) => Quote.fromJson(jsonDecode(s))).toList();
    print(list.length);
  }

}
