import 'dart:math';

class QuoteService {
  static final QuoteService _instance = QuoteService._internal();
  List<String> quotes;
  Random _random = new Random();
  final Duration _waitDuration = Duration(seconds: 2);

  QuoteService._internal(){
    quotes = [
      "Exceed clients' and colleagues' expectations",
      "Take ownership and question the status quo in a constructive manner",
      "Be brave, curious and experiment. Learn from all successes and failures",
      "Act in a way that makes all of us proud",
      "Build an inclusive, transparent and socially responsible culture",
      "Be ambitious, grow yourself and the people around you",
      "Recognize excellence and engagement",
    ];
  }

  factory QuoteService.get() {
    return _instance;
  }

  Stream<String> getQuotes() async*{
    while(true){
      var randomQuoteIndex = _random.nextInt(quotes.length);
      yield quotes[randomQuoteIndex];
      await Future.delayed(_waitDuration);
    }
  }

}
