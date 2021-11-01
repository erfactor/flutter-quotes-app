import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quotes/features/quotes/data/repository/quotes_repository.dart';
import 'package:quotes/features/quotes/presentation/bloc/bookmarked_quotes_bloc.dart';
import 'package:quotes/features/quotes/presentation/bloc/quote_bloc.dart';
import 'package:quotes/features/quotes/presentation/bloc/random_quote_bloc.dart';
import 'package:quotes/features/quotes/presentation/pages/bookmarked_quotes_page.dart';
import 'package:quotes/features/quotes/presentation/pages/random_quote_page/random_quote_page.dart';

import 'create_quote_bottom_sheet.dart';

part '_bottom_navigation_bar.dart';

class QuotesMainPage extends StatefulWidget {
  @override
  _QuotesMainPageState createState() => _QuotesMainPageState();
}

class _QuotesMainPageState extends State<QuotesMainPage> with SingleTickerProviderStateMixin {
  late PageController pageController;
  late ValueNotifier<int> pageNotifier;
  bool _showFab = true;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    pageNotifier = ValueNotifier(0);
  }

  @override
  void dispose() {
    pageController.dispose();
    pageNotifier.dispose();
    super.dispose();
  }

  void showFloatingActionButton(bool value) {
    setState(() => _showFab = value);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => RandomQuoteBloc(context.read<QuoteRepository>())),
        BlocProvider(create: (_) => QuoteBloc(context.read<QuoteRepository>())),
        BlocProvider(create: (_) => BookmarkedQuotesBloc(context.read<QuoteRepository>())),
      ],
      child: Scaffold(
        floatingActionButton: Visibility(visible: _showFab, child: buildCreateQuoteFab(context)),
        bottomNavigationBar: _BottomNavigationBar(pageController: pageController, pageNotifier: pageNotifier),
        appBar: AppBar(title: const Text("Your Quotes")),
        body: PageView(
          controller: pageController,
          onPageChanged: (index) => pageNotifier.value = index,
          children: const [
            RandomQuotePage(),
            BookmarkedQuotesPage(),
          ],
        ),
      ),
    );
  }

  buildCreateQuoteFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showFloatingActionButton(false);
        Scaffold.of(context).showBottomSheet((context) => const CreateQuoteBottomSheet()).closed.then((_) => {showFloatingActionButton(true)});
      },
      child: const Icon(Icons.add),
    );
  }
}
