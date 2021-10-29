part of 'quotes_page.dart';

class _BottomNavigationBar extends StatelessWidget {
  const _BottomNavigationBar({required this.pageNotifier, required this.pageController});
  final ValueNotifier<int> pageNotifier;
  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: pageNotifier,
      builder: (context, page, _) {
        return BottomNavigationBar(
          currentIndex: page,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.format_quote_rounded), label: "Values"),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorites")
          ],
          onTap: (index) {
            pageController.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
          },
        );
      },
    );
  }
}
