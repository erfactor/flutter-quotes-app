import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netguru/blocs/home_bloc.dart';
import 'package:netguru/exceptions/UnknownStateException.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  HomeBloc _bloc;
  AnimationController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchTextController = TextEditingController();
  bool _showFab = true;
  PersistentBottomSheetController _bottomSheetController;
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _bloc = HomeBloc();
    _bloc.add(LoadHomeEvent());

    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        cubit: _bloc,
        builder: (context, state) {
          if (state is HomeLoadingState) {
            return Container(
              color: Colors.grey,
            );
          } else if (state is HomeLoadedState) {
            return _buildLayout(state);
          } else {
            throw (UnknownStateException("Unknown state from home bloc."));
          }
        });
  }

  Widget _buildLayout(HomeLoadedState state) {
    if (state.animateText) {
      _controller.reset();
      _controller.forward();
      state.animateText = false;
    }
    var textColor = Theme.of(context).textTheme.headline4.color;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
            key: _scaffoldKey,
            floatingActionButton: _showFab && state.bottomBarIndex == 0
                ? _addQuoteFab(context)
                : Container(),
            bottomNavigationBar: _bottomNavigationBar(context, state),
            appBar: AppBar(
              title: Text("Netguru Core Values"),
            ),
            body: PageView(
              children: [
                _quoteView(state, context, textColor),
                _favoritesView(state, context),
              ],
              controller: _pageController,
              onPageChanged: (index){
                if (index == 0) {
                  _bloc.add(LoadQuoteEvent());
                } else {
                  _bloc.add(LoadFavoritesEvent());
                  _bottomSheetController?.close();
                }
              },
            ));
      },
    );
  }

  BottomNavigationBar _bottomNavigationBar(
      BuildContext context, HomeLoadedState state) {
    return BottomNavigationBar(
      backgroundColor: Theme.of(context).bottomAppBarColor,
      currentIndex: state.bottomBarIndex,
      items: [
        BottomNavigationBarItem(
            icon: Icon(Icons.format_quote_rounded), label: "Values"),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorites")
      ],
      onTap: (index) {
        _pageController.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.easeOutCubic);
      },
    );
  }

  Widget _quoteView(
      HomeLoadedState state, BuildContext context, Color textColor) {
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
          FractionallySizedBox(
              widthFactor: 0.8,
              child: _textAnimation(context, state, textColor)),
        ],
      ),
    );
  }

  Widget _favoritesView(HomeLoadedState state, BuildContext context) {
    var quotes = state.favouriteQuotes;
    return ListView.builder(
        itemCount: quotes == null ? 0 : quotes.length,
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
                icon: Icon(Icons.favorite_outlined),
                onPressed: () {
                  _bloc.add(DeleteFavoriteEvent(quote.id));
                  _showSnack(context, "Quote deleted from favorites!");
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
        _searchTextController.clear();
        showFloatingActionButton(false);
        _bottomSheetController = _scaffoldKey.currentState
            .showBottomSheet((context) => _addQuoteBottomSheet(context));
        _bottomSheetController.closed.then((value) =>
            {_bottomSheetController = null, showFloatingActionButton(true)});
      },
      child: Icon(Icons.add),
    );
  }

  Widget _addQuoteBottomSheet(BuildContext context) {
    var focusNode = FocusNode();
    return Container(
      color: Theme.of(context).backgroundColor,
      height: 100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TextField(
              controller: _searchTextController,
              focusNode: focusNode,
            ),
            ElevatedButton(
              child: const Text('Add new quote'),
              onPressed: () {
                _bloc.add(NewQuoteEvent(_searchTextController.value.text));
                Navigator.pop(context);
                focusNode.unfocus();
                _showSnack(context, "New quote added!");
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _favoriteButton(HomeLoadedState state, BuildContext context) {
    return IconButton(
      iconSize: 60,
      icon: Icon(
        state.quote.isFavorite ? Icons.favorite : Icons.favorite_border,
      ),
      onPressed: () {
        _showSnack(
            context,
            state.quote.isFavorite
                ? "Quote deleted from favorites!"
                : "Quote added to favorites!");
        _bloc.add(FavoriteEvent());
      },
    );
  }

  Stack _textAnimation(
      BuildContext context, HomeLoadedState state, Color textColor) {
    return Stack(
      children: [
        _fadingText(
            context,
            state.oldQuoteContent,
            [0, _controller.value, _controller.value],
            [Colors.transparent, Colors.transparent, textColor]),
        _fadingText(
            context,
            state.quote.content,
            [0, _controller.value, _controller.value, 1],
            [textColor, textColor, Colors.transparent, Colors.transparent]),
      ],
    );
  }

  Widget _fadingText(BuildContext context, String text, List<double> stops,
      List<Color> colors) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect rect) {
        return LinearGradient(
          stops: stops,
          colors: colors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(rect);
      },
      child: Container(
        width: double.infinity,
        child: Text(text,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headline4
                .copyWith(fontFamily: 'Gotham')),
      ),
    );
  }

  void _showSnack(BuildContext context, String text) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(text),
      duration: Duration(milliseconds: 800),
    ));
  }
}
