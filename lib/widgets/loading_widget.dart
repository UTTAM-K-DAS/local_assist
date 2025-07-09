import 'package:flutter/material.dart';
import '../utils/app_theme.dart'; // Make sure this import is correct

class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
          if (message != null) ...[
            const SizedBox(height: AppTheme.defaultPadding), // Uses defaultPadding
            Text(
              message!,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ],
      ),
    );
  }
}

// Example of other widgets that might use padding (adjust as needed)
class ExampleCard extends StatelessWidget {
  const ExampleCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppTheme.defaultPadding), // Uses defaultPadding
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.largePadding), // Uses largePadding
        child: Column(
          children: [
            const Text('Some content'),
            const SizedBox(height: AppTheme.defaultPadding), // Uses defaultPadding
            Row(
              children: [
                const Text('Item 1'),
                const SizedBox(width: AppTheme.defaultPadding), // Uses defaultPadding
                const Text('Item 2'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ExampleGrid extends StatelessWidget {
  const ExampleGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppTheme.defaultPadding), // Uses defaultPadding
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppTheme.defaultPadding, // Uses defaultPadding
        mainAxisSpacing: AppTheme.defaultPadding,   // Uses defaultPadding
        childAspectRatio: 3 / 2,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          color: Colors.blueAccent,
          alignment: Alignment.center,
          child: Text('Grid Item $index'),
        );
      },
    );
  }
}

class ExampleListTile extends StatelessWidget {
  const ExampleListTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(AppTheme.defaultPadding), // Uses defaultPadding
      title: const Text('List Tile Title'),
      subtitle: const Text('List Tile Subtitle'),
      onTap: () {},
    );
  }
}

class CustomLoadingIndicator extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;
  final EdgeInsets? margin;

  const CustomLoadingIndicator({
    Key? key,
    this.size = 50.0,
    this.color = AppTheme.primaryColor,
    this.strokeWidth = 4.0,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(AppTheme.smallPadding), // Uses smallPadding
      padding: const EdgeInsets.all(AppTheme.defaultPadding), // Uses defaultPadding
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(color),
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: CustomLoadingIndicator(
                margin: const EdgeInsets.all(AppTheme.defaultPadding), // Uses defaultPadding
              ),
            ),
          ),
      ],
    );
  }
}