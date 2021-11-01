import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quotes/core/widgets/either_bloc_builder.dart';
import 'package:quotes/features/quotes/presentation/bloc/random_quote_bloc.dart';
import 'package:quotes/features/quotes/presentation/pages/random_quote_page/animated_text.dart';

import 'bookmark_button.dart';

class RandomQuotePage extends StatelessWidget {
  const RandomQuotePage();

  @override
  Widget build(BuildContext context) {
    return EitherBlocBuilder<RandomQuoteBloc, RandomQuote>(
      builder: (context, quoteState) {
        return Column(children: const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: BookmarkButton(),
          ),
          Expanded(child: AnimatedText()),
        ]);
      },
    );
  }
}
