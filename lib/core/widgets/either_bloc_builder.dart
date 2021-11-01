import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quotes/core/failures/failure.dart';
import 'package:quotes/core/widgets/shrink.dart';

class EitherBlocBuilder<TBloc extends BlocBase<Either<Failure, TState>>, TState> extends StatelessWidget {
  const EitherBlocBuilder({required this.builder});
  final Widget Function(BuildContext context, TState state) builder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: context.read<TBloc>(),
        builder: (BuildContext context, Either<Failure, TState> either) {
          return either.fold(
            (l) {
              if (l is LoadingFailure) return const Center(child: CircularProgressIndicator());

              return shrink;
            },
            (state) => builder(context, state),
          );
        });
  }
}

class EitherBlocListener<TBloc extends BlocBase<Either<Failure, TState>>, TState> extends StatelessWidget {
  const EitherBlocListener({required this.listener, required this.child});
  final void Function(BuildContext context, TState state) listener;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: context.read<TBloc>(),
      listener: (BuildContext context, Either<Failure, TState> either) {
        return either.fold(
          (failure) => debugPrint('Unhandled failure $failure'),
          (state) => listener(context, state),
        );
      },
      child: child,
    );
  }
}
