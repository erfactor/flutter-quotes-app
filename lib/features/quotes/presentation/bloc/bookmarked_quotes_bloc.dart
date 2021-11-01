import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quotes/features/quotes/data/repository/quotes_repository.dart';
import 'package:quotes/features/quotes/domain/entities/quote.dart';

class BookmarkedQuotesBloc extends Cubit<List<Quote>> {
  final QuoteRepository quoteRepository;

  BookmarkedQuotesBloc(this.quoteRepository) : super([]) {
    subscription = quoteRepository.bookmarkedQuotes().listen((quotes) {
      emit(quotes);
    });
  }
  late StreamSubscription<List<Quote>> subscription;

  @override
  Future<void> close() async {
    subscription.cancel();
    super.close();
  }
}
