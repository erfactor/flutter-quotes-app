import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
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
    _controller.reset();
    _controller.forward();
    var textColor = Theme.of(context).textTheme.headline4.color;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // TODO Add new quote modal with snackbar on save
              _bloc.add(NewQuoteEvent("super quotation just added"));
            },
            child: Icon(Icons.add),
          ),
          appBar: AppBar(
            title: Text("Netguru Core Values"),
          ),
          body: Center(
            child: Column(
              children: <Widget>[
                Container(height: 80,),
                IconButton(
                  icon: Icon(
                    Icons.favorite_border,
                    size: 60,
                  ),
                  onPressed: () {
                    // TODO add favorite
                  },
                ),
                Container(height: 80,),
                FractionallySizedBox(
                    widthFactor: 0.8,
                    child: Stack(
                      children: [
                        _fadingText(context, state.oldQuote, [
                          0,
                          _controller.value,
                          0.5 + _controller.value * 2
                        ], [
                          Colors.transparent,
                          Colors.transparent,
                          textColor
                        ]),
                        _fadingText(context, state.newQuote, [
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
