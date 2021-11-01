import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quotes/core/failures/failure.dart';
import 'package:quotes/features/quotes/domain/entities/quote.dart';
import 'package:quotes/features/quotes/data/repository/quotes_repository.dart';

class FavoriteQuote extends Cubit<Unit> {
  FavoriteQuote() : super(unit);

  void
}

class QuoteState {
  QuoteState(this.lastQuote, this.quote);
  final Quote? lastQuote;
  final Quote quote;
}

class DeleteFavoriteEvent implements HomeEvent {
  final int id;

  DeleteFavoriteEvent(this.id);

  @override
  Stream<HomeState> mapEventToState(QuoteBloc bloc) async* {
    var currentState = bloc.state as QuoteState;
    if (currentState.quote.id == id) {
      currentState.quote.isFavorite = false;
    }
    await bloc._quoteRepository.setQuoteAsFavorite(id, false);
    var favoriteQuotes = await bloc._quoteRepository.getFavoriteQuotes();
    yield QuoteState(currentState.lastQuote, currentState.quote, favoriteQuotes);
  }
}

class FavoriteEvent implements HomeEvent {
  @override
  Stream<HomeState> mapEventToState(QuoteBloc bloc) async* {
    var currentState = bloc.state as QuoteState;
    var quote = Quote(currentState.quote.id, currentState.quote.content, isFavorite: !currentState.quote.isFavorite);
    await bloc._quoteRepository.setQuoteAsFavorite(quote.id, quote.isFavorite);
    var favoriteQuotes = await bloc._quoteRepository.getFavoriteQuotes();
    yield QuoteState(currentState.lastQuote, quote, favoriteQuotes);
  }
}

class QuoteBloc extends Cubit<Either<Failure, QuoteState>> {
  final QuoteRepository _quoteRepository;

  void createQuote(String content) => _quoteRepository.createQuote(content);

  QuoteBloc(this._quoteRepository) : super(right(HomeLoadingState())) {
    _quoteRepository.readQuotes().listen((quote) async {
      String? oldQuoteContent = "";

      final _state = state;
      if (_state is QuoteState) {
        oldQuoteContent = _state.quote.content;
      }
      var favoriteQuotes = await _quoteRepository.getFavoriteQuotes();
      emit(QuoteState(oldQuoteContent, quote, favoriteQuotes, animateText: true));
    });
  }
}
