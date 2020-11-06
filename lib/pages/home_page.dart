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
  bool showFab = true;

  @override
  void initState() {
    super.initState();
    _bloc = HomeBloc();
    _bloc.add(LoadHomeEvent());

    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 700));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        cubit: _bloc,
        builder: (context, state) {
          if (state is HomeLoadingState) {
            return Center(child: CircularProgressIndicator());
          } else if (state is QuoteLoadedState) {
            return _buildLayout(state);
          } else {
            throw (UnknownStateException("Unknown state from home bloc."));
          }
        });
  }

  Widget _buildLayout(QuoteLoadedState state) {
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
          floatingActionButton: showFab ? _newQuoteFab(context) : Container(),
          appBar: AppBar(
            title: Text("Netguru Core Values"),
          ),
          body: Center(
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
                    child: Stack(
                      children: [
                        _fadingText(context, state.oldQuoteContent, [
                          0,
                          _controller.value,
                          0.5 + _controller.value * 2
                        ], [
                          Colors.transparent,
                          Colors.transparent,
                          textColor
                        ]),
                        _fadingText(context, state.quote.content, [
                          0,
                          _controller.value,
                          _controller.value,
                          1
                        ], [
                          textColor,
                          textColor,
                          Colors.transparent,
                          Colors.transparent
                        ]),
                      ],
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  void showFloatingActionButton(bool value) {
    setState(() {
      showFab = value;
    });
  }

  _newQuoteFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showFloatingActionButton(false);
        var bottomSheetController = _scaffoldKey.currentState
            .showBottomSheet((context) => _newQuoteModal(context));
        bottomSheetController.closed
            .then((value) => {showFloatingActionButton(true)});
      },
      child: Icon(Icons.add),
    );
  }

  Widget _newQuoteModal(BuildContext context) {
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
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text("New quote was added!"),
                  duration: Duration(seconds: 1),
                ));
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _favoriteButton(QuoteLoadedState state) {
    return IconButton(
      iconSize: 60,
      icon: Icon(
        state.quote.isFavorite ? Icons.favorite : Icons.favorite_border,
      ),
      onPressed: () {
        _bloc.add(FavoriteEvent());
      },
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
