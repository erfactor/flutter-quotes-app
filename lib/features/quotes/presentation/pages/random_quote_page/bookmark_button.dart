import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quotes/core/utilities/show_snack_bar.dart';
import 'package:quotes/core/widgets/either_bloc_builder.dart';
import 'package:quotes/features/quotes/presentation/bloc/quote_bloc.dart';
import 'package:quotes/features/quotes/presentation/bloc/random_quote_bloc.dart';

class BookmarkButton extends StatelessWidget {
  const BookmarkButton();

  @override
  Widget build(BuildContext context) {
    return EitherBlocBuilder<RandomQuoteBloc, RandomQuote>(
      builder: (context, quoteState) {
        final quote = quoteState.quote;
        return IconButton(
          iconSize: 60,
          icon: Icon(quote.isBookmarked ? Icons.favorite : Icons.favorite_border),
          onPressed: () {
            showSnackBar(quote.isBookmarked ? "Quote deleted from bookmarks!" : "Quote added to bookmarks!");
            final quoteBloc = context.read<QuoteBloc>();
            quote.isBookmarked ? quoteBloc.unbookmark(quote.id) : quoteBloc.unbookmark(quote.id);
          },
        );
      },
    );
  }
}
