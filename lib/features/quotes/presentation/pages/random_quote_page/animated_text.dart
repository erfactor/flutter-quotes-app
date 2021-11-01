import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:quotes/core/widgets/either_bloc_builder.dart';
import 'package:quotes/features/quotes/presentation/bloc/random_quote_bloc.dart';

class AnimatedText extends StatefulWidget {
  const AnimatedText({Key? key}) : super(key: key);

  @override
  State<AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText> with SingleTickerProviderStateMixin {
  late AnimationController textAnimationController;

  @override
  void initState() {
    super.initState();
    textAnimationController = AnimationController(vsync: this, duration: 500.milliseconds);
  }

  @override
  void dispose() {
    textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyText2!.color!;

    return EitherBlocListener<RandomQuoteBloc, RandomQuote>(
      listener: (_, __) {
        textAnimationController.reset();
        textAnimationController.forward();
      },
      child: EitherBlocBuilder<RandomQuoteBloc, RandomQuote>(
        builder: (context, state) {
          return AnimatedBuilder(
            animation: textAnimationController,
            builder: (context, _) {
              return Stack(children: [
                buildText(
                  context,
                  state.lastQuote?.content ?? '',
                  [0, textAnimationController.value, textAnimationController.value],
                  [Colors.transparent, Colors.transparent, textColor],
                ),
                buildText(
                  context,
                  state.quote.content,
                  [0, textAnimationController.value, textAnimationController.value, 1],
                  [textColor, textColor, Colors.transparent, Colors.transparent],
                ),
              ]);
            },
          );
        },
      ),
    );
  }

  Widget buildText(BuildContext context, String text, List<double> stops, List<Color> colors) {
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
      child: SizedBox(
        width: double.infinity,
        child: Text(text, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline4!.copyWith(fontFamily: 'Gotham')),
      ),
    );
  }
}
