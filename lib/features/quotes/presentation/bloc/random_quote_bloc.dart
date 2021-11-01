import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quotes/core/failures/failure.dart';
import 'package:quotes/features/quotes/data/repository/quotes_repository.dart';
import 'package:quotes/features/quotes/domain/entities/quote.dart';

class RandomQuoteBloc extends Cubit<Either<Failure, RandomQuote>> {
  final QuoteRepository _quoteRepository;

  RandomQuoteBloc(this._quoteRepository) : super(left(LoadingFailure())) {
    _quoteRepository.quotesStream().listen((quote) async {
      final lastQuote = state.fold((l) => null, (quoteState) => quoteState.quote);
      emit(right(RandomQuote(lastQuote, quote)));
    });
  }
}

class RandomQuote {
  RandomQuote(this.lastQuote, this.quote);
  final Quote? lastQuote;
  final Quote quote;
}
