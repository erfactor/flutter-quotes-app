import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netguru/models/quote.dart';
import 'package:netguru/services/quote_service.dart';

abstract class HomeEvent {}

abstract class HomeState {}

class HomeLoadingState extends HomeState {}

class QuotesLoadedState extends HomeState {
  final String oldQuoteContent;
  final Quote quote;
  final List<Quote> favouriteQuotes;
  int currentIndex;
  bool animateText;

  QuotesLoadedState(this.oldQuoteContent, this.quote, this.favouriteQuotes, this.currentIndex, {this.animateText = false});
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
class LoadFavoritesEvent extends HomeEvent {}
class LoadQuotesEvent extends HomeEvent {}

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
      var currentIndex = 0;
      var favoriteQuotes;
      if (state is QuotesLoadedState) {
        var currentState = state as QuotesLoadedState;
        oldQuoteContent = currentState.quote.content;
        currentIndex = currentState.currentIndex;
        favoriteQuotes = currentState.favouriteQuotes;
      }
      yield QuotesLoadedState(
          oldQuoteContent, event.quote, favoriteQuotes, currentIndex,
          animateText: true);
    } else if (event is NewQuoteEvent) {
      await _quoteService.addNewQuote(event.quoteContent);
    } else if (event is FavoriteEvent) {
      var currentState = state as QuotesLoadedState;
      var quote = Quote(currentState.quote.id, currentState.quote.content,
          isFavorite: !currentState.quote.isFavorite);
      await _quoteService.setQuoteAsFavorite(quote.id, quote.isFavorite);
      yield QuotesLoadedState(currentState.oldQuoteContent, quote, currentState.favouriteQuotes, currentState.currentIndex);
    } else if (event is DeleteFavoriteEvent) {
      await _quoteService.setQuoteAsFavorite(event.id, false);
      add(LoadFavoritesEvent());
    } else if (event is LoadFavoritesEvent) {
      var currentState = state as QuotesLoadedState;
      var favouriteQuotes = await _quoteService.getFavouriteQuotes();
      yield QuotesLoadedState( currentState.oldQuoteContent, currentState.quote, favouriteQuotes, 1);
    } else if (event is LoadQuotesEvent) {
      var currentState = state as QuotesLoadedState;
      yield QuotesLoadedState( currentState.oldQuoteContent, currentState.quote, currentState.favouriteQuotes, 0);
    }
  }
}
