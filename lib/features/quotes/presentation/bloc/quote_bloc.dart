import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quotes/features/quotes/data/repository/quotes_repository.dart';

class QuoteBloc extends Cubit<Unit> {
  final QuoteRepository quoteRepository;
  QuoteBloc(this.quoteRepository) : super(unit);

  void create(String content) => quoteRepository.createQuote(content);
  void bookmark(int quoteId) => quoteRepository.bookmarkQuote(quoteId, true);
  void unbookmark(int quoteId) => quoteRepository.bookmarkQuote(quoteId, false);
}
