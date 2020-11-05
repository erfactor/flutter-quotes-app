import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netguru/blocs/home_bloc.dart';
import 'package:netguru/exceptions/UnknownStateException.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  HomeBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = HomeBloc();
    _bloc.add(LoadHomeEvent());
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Netguru Core Values"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FractionallySizedBox(widthFactor: 0.8,
                child: Text(
                  state.quote,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline4.copyWith(
                    fontFamily: 'Gotham'
                  )
                )),
          ],
        ),
      ),
    );
  }
}
