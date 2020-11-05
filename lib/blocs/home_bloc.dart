import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netguru/services/quote_service.dart';

abstract class HomeEvent {}

abstract class HomeState {}

class HomeLoadingState extends HomeState {}

class QuoteLoadedState extends HomeState {
  final String quote;

  QuoteLoadedState(this.quote);
}

class LoadHomeEvent extends HomeEvent {}

class QuoteLoadedEvent extends HomeEvent {
  final String quote;

  QuoteLoadedEvent(this.quote);
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeLoadingState());

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if (event is LoadHomeEvent) {
      yield HomeLoadingState();
      QuoteService.get().getQuotes().listen((quote) {
        add(QuoteLoadedEvent(quote));
      });
    } else if (event is QuoteLoadedEvent) {
      yield QuoteLoadedState(event.quote);
    }
  }
}
