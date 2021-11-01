import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quotes/core/utilities/show_snack_bar.dart';
import 'package:quotes/features/quotes/domain/entities/quote.dart';
import 'package:quotes/features/quotes/presentation/bloc/home_bloc.dart';

class FavoriteQuotesPage extends StatelessWidget {
  const FavoriteQuotesPage({ });

  @override
  Widget build(BuildContext context) {
    final quotes = context.watch<QuoteBloc>().state;
    return ListView.builder(
        itemCount: quotes.length,
        itemBuilder: (BuildContext context, int index) {
          final quote = quotes[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              tileColor: Theme.of(context).bottomAppBarColor,
              title: Text(quote.content, style: Theme.of(context).textTheme.headline6),
              trailing: IconButton(
                icon: const Icon(Icons.favorite_outlined),
                onPressed: () {
                  context.read<QuoteBloc>().add(DeleteFavoriteEvent(quote.id));
                  showSnackBar("Quote deleted from favorites!");
                },
              ),
            ),
          );
        });
  }
}
