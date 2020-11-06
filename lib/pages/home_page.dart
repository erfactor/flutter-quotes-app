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
            return Center(child: CircularProgressIndicator());
          } else if (state is QuotesLoadedState) {
            return _buildLayout(state);
          } else {
            throw (UnknownStateException("Unknown state from home bloc."));
          }
        });
  }

  Widget _buildLayout(QuotesLoadedState state) {
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
          floatingActionButton: _showFab && state.currentIndex == 0
              ? _addQuoteFab(context)
              : Container(),
          bottomNavigationBar: _bottomNavigationBar(context, state),
          appBar: AppBar(
            title: Text("Netguru Core Values"),
          ),
          body: state.currentIndex == 0
              ? _quotesView(state, context, textColor)
              : _favoritesView(state, context),
        );
      },
    );
  }

  BottomNavigationBar _bottomNavigationBar(
      BuildContext context, QuotesLoadedState state) {
    return BottomNavigationBar(
      backgroundColor: Theme.of(context).bottomAppBarColor,
      currentIndex: state.currentIndex,
      items: [
        BottomNavigationBarItem(
            icon: Icon(Icons.format_quote_rounded), label: "Values"),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorites")
      ],
      onTap: (index) {
        if (index == 0) {
          _bloc.add(LoadQuotesEvent());
        } else {
          _bloc.add(LoadFavoritesEvent());
        }
      },
    );
  }

  Widget _quotesView(
      QuotesLoadedState state, BuildContext context, Color textColor) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 80,
          ),
          _favoriteButton(state),
          Container(
            height: 80,
          ),
          FractionallySizedBox(
              widthFactor: 0.8,
              child: _textAnimation(context, state, textColor)),
        ],
      ),
    );
  }

  Widget _favoritesView(QuotesLoadedState state, BuildContext context) {
    var quotes = state.favouriteQuotes;
    return ListView.builder(
        itemCount: quotes.length,
        itemBuilder: (BuildContext context, int index) {
          var quote = quotes[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              tileColor: Theme.of(context).bottomAppBarColor,
              title: Text( quote.content),
              trailing: IconButton(
                  icon: Icon(Icons.favorite_outlined), onPressed: () {
                    _bloc.add(DeleteFavoriteEvent(quote.id));
                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text("Quote deleted from favorites!"),
                      duration: Duration(seconds: 1),
                    ));
              },),
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
        var bottomSheetController = _scaffoldKey.currentState
            .showBottomSheet((context) => _addQuoteBottomSheet(context));
        bottomSheetController.closed
            .then((value) => {showFloatingActionButton(true)});
      },
      child: Icon(Icons.add),
    );
  }

  Widget _addQuoteBottomSheet(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      height: 100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TextField(
              controller: _searchTextController,
            ),
            ElevatedButton(
              child: const Text('Add new quote'),
              onPressed: () {
                _bloc.add(NewQuoteEvent(_searchTextController.value.text));
                Navigator.pop(context);
                _scaffoldKey.currentState.showSnackBar(SnackBar(
                  content: Text("New quote added!"),
                  duration: Duration(seconds: 1),
                ));
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _favoriteButton(QuotesLoadedState state) {
    return IconButton(
      iconSize: 60,
      icon: Icon(
        state.quote.isFavorite ? Icons.favorite : Icons.favorite_border,
      ),
      onPressed: () {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(state.quote.isFavorite
              ? "Quote deleted from favorites!"
              : "Quote added to favorites!"),
          duration: Duration(seconds: 1),
        ));
        _bloc.add(FavoriteEvent());
      },
    );
  }

  Stack _textAnimation(
      BuildContext context, QuotesLoadedState state, Color textColor) {
    return Stack(
      children: [
        _fadingText(
            context,
            state.oldQuoteContent,
            [0, _controller.value, 0.5 + _controller.value * 2],
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
      child: Text(text,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .headline4
              .copyWith(fontFamily: 'Gotham')),
    );
  }
}
