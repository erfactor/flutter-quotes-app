import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:quotes/core/utilities/show_snack_bar.dart';
import 'package:quotes/features/quotes/presentation/bloc/home_bloc.dart';

class CreateQuoteBottomSheet extends StatefulWidget {
  const CreateQuoteBottomSheet({Key? key}) : super(key: key);

  @override
  _CreateQuoteBottomSheetState createState() => _CreateQuoteBottomSheetState();
}

class _CreateQuoteBottomSheetState extends State<CreateQuoteBottomSheet> {
  late FocusNode focusNode;
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    textController = TextEditingController();
  }

  @override
  void dispose() {
    focusNode.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      height: 100,
      child: Center(
        child: Column(
          children: [
            TextField(controller: textController, focusNode: focusNode),
            const Spacer(),
            ElevatedButton(
              child: const Text('Add new quote'),
              onPressed: () {
                context.read<HomeBloc>().add(NewQuoteEvent(textController.value.text));
                Navigator.pop(context);
                focusNode.unfocus();
                showSnackBar("New quote added!");
              },
            )
          ],
        ),
      ),
    );
  }
}
