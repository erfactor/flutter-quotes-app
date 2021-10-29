import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quotes/core/service_locator/sl.dart';
import 'package:quotes/core/utilities/show_snack_bar.dart';
import 'package:quotes/features/quotes/presentation/bloc/home_bloc.dart';
import 'package:quotes/core/exceptions/unknown_state_exception.dart';
import 'package:quotes/features/quotes/presentation/pages/quotes_page/create_quote_bottom_sheet.dart';

part '_bottom_navigation_bar.dart';

class QuotesPage extends StatefulWidget {
  @override
  _QuotesPageState createState() => _QuotesPageState();
}

class _QuotesPageState extends State<QuotesPage> with SingleTickerProviderStateMixin {
  late PageController pageController;
  late AnimationController animationController;
  late ValueNotifier<int> pageNotifier;
  bool _showFab = true;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    pageNotifier = ValueNotifier(0);
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    pageController.dispose();
    pageNotifier.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuoteBloc(sl()),
      child: BlocBuilder(
        bloc: context.read<QuoteBloc>(),
        builder: (context, dynamic state) {
          if (state is HomeLoadingState) {
            return Container(color: Colors.grey);
          } else if (state is HomeLoadedState) {
            return _buildLayout(state);
          } else {
            throw (UnknownStateException("Unknown state from home bloc."));
          }
        },
      ),
    );
  }

  Widget _buildLayout(HomeLoadedState state) {
    if (state.animateText) {
      animationController.reset();
      animationController.forward();
      state.animateText = false;
    }
    var textColor = Theme.of(context).textTheme.headline4!.color;

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, _) {
        return Scaffold(
          floatingActionButton: _showFab ? _addQuoteFab(context) : Container(),
          bottomNavigationBar: _BottomNavigationBar(pageController: pageController, pageNotifier: pageNotifier),
          appBar: AppBar(title: const Text("Your Quotes")),
          body: PageView(
            children: [
              _quoteView(state, context, textColor),
              _favoritesView(state, context),
            ],
            controller: pageController,
            onPageChanged: (index) => pageNotifier.value = index,
          ),
        );
      },
    );
  }

  Widget _quoteView(HomeLoadedState state, BuildContext context, Color? textColor) {
    var gapHeight = MediaQuery.of(context).size.height * 0.05;
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            height: gapHeight,
          ),
          _favoriteButton(state, context),
          Container(
            height: gapHeight,
          ),
          FractionallySizedBox(widthFactor: 0.8, child: _textAnimation(context, state, textColor)),
        ],
      ),
    );
  }

  Widget _favoritesView(HomeLoadedState state, BuildContext context) {
    var quotes = state.favoriteQuotes;
    return ListView.builder(
        itemCount: quotes.length,
        itemBuilder: (BuildContext context, int index) {
          var quote = quotes[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              tileColor: Theme.of(context).bottomAppBarColor,
              title: Text(
                quote.content,
                style: Theme.of(context).textTheme.headline6,
              ),
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

  void showFloatingActionButton(bool value) {
    setState(() {
      _showFab = value;
    });
  }

  _addQuoteFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showFloatingActionButton(false);
        Scaffold.of(context).showBottomSheet((context) => const CreateQuoteBottomSheet()).closed.then((_) => {showFloatingActionButton(true)});
      },
      child: const Icon(Icons.add),
    );
  }

  Widget _favoriteButton(HomeLoadedState state, BuildContext context) {
    return IconButton(
      iconSize: 60,
      icon: Icon(state.quote.isFavorite ? Icons.favorite : Icons.favorite_border),
      onPressed: () {
        showSnackBar(state.quote.isFavorite ? "Quote deleted from favorites!" : "Quote added to favorites!");
        context.read<QuoteBloc>().add(FavoriteEvent());
      },
    );
  }

  Stack _textAnimation(BuildContext context, HomeLoadedState state, Color? textColor) {
    return Stack(
      children: [
        _fadingText(
            context, state.oldQuoteContent!, [0, animationController.value, animationController.value], [Colors.transparent, Colors.transparent, textColor]),
        _fadingText(context, state.quote.content, [0, animationController.value, animationController.value, 1],
            [textColor, textColor, Colors.transparent, Colors.transparent]),
      ],
    );
  }

  Widget _fadingText(BuildContext context, String text, List<double> stops, List<Color?> colors) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect rect) {
        return LinearGradient(
          stops: stops,
          colors: colors as List<Color>,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(rect);
      },
      child: SizedBox(
        width: double.infinity,
        child: Text(text, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline4!.copyWith(fontFamily: 'Gotham')),
      ),
    );
  }
}
