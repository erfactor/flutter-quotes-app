import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netguru/models/quote.dart';
import 'package:netguru/services/quote_service.dart';

abstract class HomeEvent {
  Stream<HomeState> mapEventToState(HomeBloc bloc) async* {}
}

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

class LoadHomeEvent implements HomeEvent {
  @override
  Stream<HomeState> mapEventToState(HomeBloc bloc) async* {
    yield HomeLoadingState();
    bloc._quoteService.getQuotes().listen((quote) {
      bloc.add(QuoteLoadedEvent(quote));
    });
  }
}

class QuoteLoadedEvent implements HomeEvent {
  final Quote quote;
  QuoteLoadedEvent(this.quote);

  @override
  Stream<HomeState> mapEventToState(HomeBloc bloc) async* {
    var oldQuoteContent = "";
    if (bloc.state is HomeLoadedState) {
      var currentState = bloc.state as HomeLoadedState;
      oldQuoteContent = currentState.quote.content;
    }
    var favoriteQuotes = await bloc._quoteService.getFavoriteQuotes();
    yield HomeLoadedState(oldQuoteContent, quote, favoriteQuotes,
        animateText: true);
  }
}

class DeleteFavoriteEvent implements HomeEvent {
  final int id;

  DeleteFavoriteEvent(this.id);

  @override
  Stream<HomeState> mapEventToState(HomeBloc bloc) async* {
    var currentState = bloc.state as HomeLoadedState;
    if (currentState.quote.id == id) {
      currentState.quote.isFavorite = false;
    }
    await bloc._quoteService.setQuoteAsFavorite(id, false);
    var favoriteQuotes = await bloc._quoteService.getFavoriteQuotes();
    yield HomeLoadedState(
        currentState.oldQuoteContent, currentState.quote, favoriteQuotes);

  }
}

class FavoriteEvent implements HomeEvent {
  @override
  Stream<HomeState> mapEventToState(HomeBloc bloc) async* {
    var currentState = bloc.state as HomeLoadedState;
    var quote = Quote(currentState.quote.id, currentState.quote.content,
        isFavorite: !currentState.quote.isFavorite);
    await bloc._quoteService.setQuoteAsFavorite(quote.id, quote.isFavorite);
    var favoriteQuotes = await bloc._quoteService.getFavoriteQuotes();
    yield HomeLoadedState(
        currentState.oldQuoteContent, quote, favoriteQuotes);

  }
}

class NewQuoteEvent implements HomeEvent {
  final String quoteContent;

  NewQuoteEvent(this.quoteContent);

  @override
  Stream<HomeState> mapEventToState(HomeBloc bloc) async* {
    await bloc._quoteService.addNewQuote(quoteContent);
  }
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  QuoteService _quoteService;

  HomeBloc() : super(HomeLoadingState()) {
    _quoteService = QuoteService.get();
  }

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    yield* event.mapEventToState(this);
  }
}
