import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netguru/models/quote.dart';
import 'package:netguru/services/quote_service.dart';

abstract class HomeEvent {}

abstract class HomeState {}

class HomeLoadingState extends HomeState {}

class QuoteLoadedState extends HomeState {
  final String oldQuoteContent;
  final Quote quote;
  bool animateText;

  QuoteLoadedState(this.oldQuoteContent, this.quote, {this.animateText = false});
}

class LoadHomeEvent extends HomeEvent {}

class QuoteLoadedEvent extends HomeEvent {
  final Quote quote;

  QuoteLoadedEvent(this.quote);
}

class FavoriteEvent extends HomeEvent {}

class NewQuoteEvent extends HomeEvent {
  final String quoteContent;

  NewQuoteEvent(this.quoteContent);
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  QuoteService _quoteService;

  HomeBloc() : super(HomeLoadingState()){
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
      var oldQuoteContent = state is QuoteLoadedState ? (state as QuoteLoadedState).quote.content : "";
      yield QuoteLoadedState(oldQuoteContent, event.quote, animateText: true);
    } else if (event is NewQuoteEvent) {
      await _quoteService.addNewQuote(event.quoteContent);
    } else if (event is FavoriteEvent) {
      var currentState = state as QuoteLoadedState;
      var quote = Quote(currentState.quote.id, currentState.quote.content, isFavorite: !currentState.quote.isFavorite);
      await _quoteService.setQuoteAsFavorite(quote.id, quote.isFavorite);
      yield QuoteLoadedState(currentState.oldQuoteContent, quote);
    }
  }
}
