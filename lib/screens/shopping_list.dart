import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/widgets/shopping_list_item.dart';

class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Groceries'),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.add))],
      ),
      body: ListView.builder(
        itemCount: groceryItems.length,
        itemBuilder: (ctx, index) =>
            ShoppingListItem(groceryItem: groceryItems[index]),
        // padding: const EdgeInsets.symmetric(vertical: 10),
        // children: [
        //   ...groceryItems.map(
        //     (groceryItem) => ShoppingListItem(groceryItem: groceryItem),
        //   ),
        // ],
      ),
    );
  }
}
