import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list/data/category.dart';
// import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/models/paginated_response.dart';
import 'package:shopping_list/screens/new_item.dart';
import 'package:shopping_list/widgets/shopping_list_item.dart';

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});
  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  // NOTE: Use with future builder
  // late Future<List<GroceryItem>> _loadedItems;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
    // Use with FutureBuilder;
    // _loadedItems = _loadItems();
  }

  void _loadItems() async {
    // Future<List<GroceryItem>> _loadItems() async {
    final url = Uri.http(
      'localhost:8090',
      '/api/collections/shopping_list/records',
      {'sort': 'created'},
    );
    // NOTE: with FutureBuilder you don't need try catch
    // try {
    final response = await http.get(url);
    if (response.statusCode >= 400) {
      setState(() {
        _error = 'Failed to fetch data. Please try again later';
      });
      // Use only with FutureBuilder
      // throw Exception('Failed to fetch shopping list: please try again later');
    }

    // NOTE: to prevent errors if request returns null in the body
    // if (response.body == 'null') {
    //   setState(() {
    //     _isLoading = false;
    //   });
    //   return;
    // }
    // final Map<String, dynamic> responseData = json.decode(response.body);
    final Map<String, dynamic> jsonMap = json.decode(response.body);
    final PaginatedResponse<ShoppingItem> responseData =
        PaginatedResponse.fromJson(
          jsonMap,
          (itemJson) => ShoppingItem.fromJson(itemJson),
        );
    final List<GroceryItem> loadedItems = [];
    for (final item in responseData.items) {
      final category = categories.entries
          .firstWhere((element) => element.value.title == item.category)
          .value;
      loadedItems.add(
        GroceryItem(
          id: item.id,
          name: item.name,
          quantity: item.quantity,
          category: category,
        ),
      );
      // print(item);
      // print(category);
    }

    setState(() {
      _groceryItems = loadedItems;
      _isLoading = false;
    });
    // NOTE: Use with FutureBuilder;
    // return loadedItems;
    // print(responseData);
    // } catch (err) {
    //   setState(() {
    //     _error = 'Something went wrong';
    //   });
    // } finally {}
  }

  void _addItem() async {
    // NOTE: this is if we were saving locally from the route
    final newItem = await Navigator.of(
      context,
    ).push<GroceryItem>(MaterialPageRoute(builder: (ctx) => const NewItem()));

    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
    // NOTE: this is if you want to fetch all items from scratch new item added
    // await Navigator.of(
    //   context,
    // ).push(MaterialPageRoute(builder: (ctx) => const NewItem()));

    // _loadItems();
  }

  void _editItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    final updatedItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(builder: (ctx) => NewItem(groceryItem: item)),
    );
    if (updatedItem == null) {
      return;
    }
    setState(() {
      _groceryItems[index] = updatedItem;
    });
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.http(
      'localhost:8090',
      '/api/collections/shopping_list/records/${item.id}',
    );

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      // Optional: Show error message here
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent = const Center(
      child: Text('No items on your grocery list - Add Some'),
    );

    if (_isLoading) {
      mainContent = const Center(child: CircularProgressIndicator());
    }

    if (_groceryItems.isNotEmpty) {
      mainContent = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          key: ValueKey(_groceryItems[index]),
          // Custom dismiss thresholds (optional)
          dismissThresholds: const {
            DismissDirection.startToEnd: 0.3, // Need to swipe 40% for edit
            DismissDirection.endToStart: 0.5, // Need to swipe 60% for delete
          },
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              _editItem(_groceryItems[index]);
              return false;
            } else {
              return true;
            }
          },
          background: _buildSwipeBackground(
            color: Colors.blue,
            icon: Icons.edit,
            alignment: Alignment.centerLeft,
            text: 'Edit',
          ),
          secondaryBackground: _buildSwipeBackground(
            color: Colors.red,
            icon: Icons.delete,
            alignment: Alignment.centerRight,
            text: 'Delete',
          ),
          child: ShoppingListItem(groceryItem: _groceryItems[index]),
          onDismissed: (direction) {
            if (direction == DismissDirection.endToStart) {
              _removeItem(_groceryItems[index]);
            }
            // else if (direction == DismissDirection.endToStart) {
            //   _editItem(_groceryItems[index]);
            // }
          },
        ),
        // padding: const EdgeInsets.symmetric(vertical: 10),
        // children: [
        //   ...groceryItems.map(
        //     (groceryItem) => ShoppingListItem(groceryItem: groceryItem),
        //   ),
        // ],
      );
    }

    if (_error != null) {
      mainContent = Center(child: Text(_error!));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Groceries'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body:
          // FutureBuilder(
          //   future: _loadItems(),
          //   builder: (context, snapshot) {
          //     if (snapshot.connectionState == ConnectionState.waiting) {
          //       return const Center(child: CircularProgressIndicator());
          //     }
          //     if (snapshot.hasError) {
          //       return Center(child: Text(snapshot.error.toString()));
          //     }
          //     if (snapshot.data!.isEmpty) {
          //       return const Center(
          //         child: Text('No items on your grocery list - Add Some'),
          //       );
          //     }
          //     ListView.builder(
          //       itemCount: snapshot.data!.length,
          //       itemBuilder: (ctx, index) => Dismissible(
          //         key: ValueKey(snapshot.data![index]),
          //         background: Container(
          //           color: Theme.of(
          //             context,
          //           ).colorScheme.error.withValues(alpha: 200),
          //           // margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //         ),
          //         child: ShoppingListItem(groceryItem: snapshot.data![index]),
          //         onDismissed: (direction) {
          //           _removeItem(snapshot.data![index]);
          //         },
          //       ),
          //       // padding: const EdgeInsets.symmetric(vertical: 10),
          //       // children: [
          //       //   ...groceryItems.map(
          //       //     (groceryItem) => ShoppingListItem(groceryItem: groceryItem),
          //       //   ),
          //       // ],
          //     );
          //   },
          // ),
          mainContent,
      // ListView.builder(
      //   itemCount: _groceryItems.length,
      //   itemBuilder: (ctx, index) => Dismissible(
      //     key: ValueKey(_groceryItems[index]),
      //     child: ShoppingListItem(groceryItem: _groceryItems[index]),
      //   ),
      //   // padding: const EdgeInsets.symmetric(vertical: 10),
      //   // children: [
      //   //   ...groceryItems.map(
      //   //     (groceryItem) => ShoppingListItem(groceryItem: groceryItem),
      //   //   ),
      //   // ],
      // ),
    );
  }
}

Widget _buildSwipeBackground({
  required Color color,
  required IconData icon,
  required Alignment alignment,
  required String text,
}) {
  return Container(
    color: color,
    alignment: alignment,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
