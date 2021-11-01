import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quotes/core/utilities/show_snack_bar.dart';
import 'package:quotes/features/quotes/domain/entities/quote.dart';
import 'package:quotes/features/quotes/presentation/bloc/bookmarked_quotes_bloc.dart';
import 'package:quotes/features/quotes/presentation/bloc/quote_bloc.dart';

class BookmarkedQuotesPage extends StatelessWidget {
  const BookmarkedQuotesPage();

  @override
  Widget build(BuildContext context) {
    final quotes = context.watch<BookmarkedQuotesBloc>().state;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quotes.length,
      itemBuilder: (BuildContext context, int index) {
        return buildBookmarkedQuoteView(context, quotes[index]);
      },
    );
  }

  Card buildBookmarkedQuoteView(BuildContext context, Quote quote) {
    return Card(
      child: ListTile(
        tileColor: Theme.of(context).bottomAppBarColor,
        title: Text(quote.content, style: Theme.of(context).textTheme.headline6),
        trailing: IconButton(
          icon: const Icon(Icons.favorite_outlined),
          onPressed: () {
            context.read<QuoteBloc>().unbookmark(quote.id);
            showSnackBar("Quote deleted from bookmarks!");
          },
        ),
      ),
    );
  }
}
