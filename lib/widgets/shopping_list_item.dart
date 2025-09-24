import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list/models/grocery_item.dart';

class ShoppingListItem extends ConsumerWidget {
  const ShoppingListItem({super.key, required this.groceryItem});

  final GroceryItem groceryItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(groceryItem.name),
      leading: Container(
        width: 24,
        height: 24,
        color: groceryItem.category.color,
      ),
      trailing: Text(groceryItem.quantity.toString()),
    );
    // Padding(
    //   padding: EdgeInsetsGeometry.symmetric(vertical: 10, horizontal: 20),
    //   child: Row(
    //     crossAxisAlignment: CrossAxisAlignment.center,
    //     children: [
    //       Container(height: 30, width: 30, color: groceryItem.category.color),
    //       SizedBox(width: 40),
    //       Text(groceryItem.name, style: TextStyle(fontSize: 20)),
    //       Spacer(),
    //       Text(groceryItem.quantity.toString(), style: TextStyle(fontSize: 20)),
    //     ],
    //   ),
    // );
  }
}
