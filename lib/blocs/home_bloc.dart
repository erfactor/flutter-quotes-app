import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netguru/models/quote.dart';
import 'package:netguru/services/quote_service.dart';

abstract class HomeEvent {}

abstract class HomeState {}

class HomeLoadingState extends HomeState {}

class HomeLoadedState extends HomeState {
  final String oldQuoteContent;
  final Quote quote;
  final List<Quote> favoriteQuotes;
  bool animateText;

  HomeLoadedState(this.oldQuoteContent, this.quote, this.favoriteQuotes,
      {this.animateText = false});
}

class LoadHomeEvent extends HomeEvent {}

class QuoteLoadedEvent extends HomeEvent {
  final Quote quote;

  QuoteLoadedEvent(this.quote);
}

class DeleteFavoriteEvent extends HomeEvent {
  final int id;

  DeleteFavoriteEvent(this.id);
}

class FavoriteEvent extends HomeEvent {}

class NewQuoteEvent extends HomeEvent {
  final String quoteContent;

  NewQuoteEvent(this.quoteContent);
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  QuoteService _quoteService;

  HomeBloc() : super(HomeLoadingState()) {
    _quoteService = QuoteService.get();
  }

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if (event is LoadHomeEvent) {
      yield HomeLoadingState();
      _quoteService.getQuotes().listen((quote) {
        add(QuoteLoadedEvent(quote));
      });
    } else if (event is QuoteLoadedEvent) {
      var oldQuoteContent = "";
      if (state is HomeLoadedState) {
        var currentState = state as HomeLoadedState;
        oldQuoteContent = currentState.quote.content;
      }
      var favoriteQuotes = await _quoteService.getFavoriteQuotes();
      yield HomeLoadedState(oldQuoteContent, event.quote, favoriteQuotes,
          animateText: true);
    } else if (event is NewQuoteEvent) {
      await _quoteService.addNewQuote(event.quoteContent);
    } else if (event is FavoriteEvent) {
      var currentState = state as HomeLoadedState;
      var quote = Quote(currentState.quote.id, currentState.quote.content,
          isFavorite: !currentState.quote.isFavorite);
      await _quoteService.setQuoteAsFavorite(quote.id, quote.isFavorite);
      var favoriteQuotes = await _quoteService.getFavoriteQuotes();
      yield HomeLoadedState(
          currentState.oldQuoteContent, quote, favoriteQuotes);
    } else if (event is DeleteFavoriteEvent) {
      var currentState = state as HomeLoadedState;
      if (currentState.quote.id == event.id) {
        currentState.quote.isFavorite = false;
      }
      await _quoteService.setQuoteAsFavorite(event.id, false);
      var favoriteQuotes = await _quoteService.getFavoriteQuotes();
      yield HomeLoadedState(
          currentState.oldQuoteContent, currentState.quote, favoriteQuotes);
    }
  }
}
