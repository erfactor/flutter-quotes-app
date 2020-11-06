import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netguru/services/quote_service.dart';

abstract class HomeEvent {}

abstract class HomeState {}

class HomeLoadingState extends HomeState {}

class QuoteLoadedState extends HomeState {
  final String oldQuote;
  final String newQuote;

  QuoteLoadedState(this.oldQuote, this.newQuote);
}

class LoadHomeEvent extends HomeEvent {}

class QuoteLoadedEvent extends HomeEvent {
  final String quote;

  QuoteLoadedEvent(this.quote);
}

class NewQuoteEvent extends HomeEvent {
  final String quote;

  NewQuoteEvent(this.quote);
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
      var oldQuote = state is QuoteLoadedState ? (state as QuoteLoadedState).newQuote : "";
      yield QuoteLoadedState(oldQuote, event.quote);
    } else if (event is NewQuoteEvent) {
      await _quoteService.addNewQuote(event.quote);
    }
  }
}
