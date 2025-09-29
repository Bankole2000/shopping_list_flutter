import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list/data/category.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/paginated_response.dart';
import 'package:shopping_list/models/grocery_item.dart';

class NewItem extends ConsumerStatefulWidget {
  const NewItem({super.key, this.groceryItem});

  final GroceryItem? groceryItem;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewItemState();
}

class _NewItemState extends ConsumerState<NewItem> {
  // ensures the form will keep its internal state
  final _formKey = GlobalKey<FormState>();
  var _id = '';
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables];
  var _isSending = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.groceryItem != null) {
      _id = widget.groceryItem!.id;
      _enteredName = widget.groceryItem!.name;
      _enteredQuantity = widget.groceryItem!.quantity;
      _selectedCategory = widget.groceryItem!.category;
    }
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // print(_enteredName);
      // print(_enteredQuantity);
      // print(_selectedCategory!.title);
      // final url = Uri.https('firebase-project-url.com', 'collection-name.json');
      final url = Uri.http(
        'localhost:8090',
        '/api/collections/shopping_list/records${_id.isEmpty ? '' : '/$_id'}',
      );
      // print(url);
      setState(() {
        _isSending = true;
      });
      final requestPayload = json.encode({
        'name': _enteredName,
        'quantity': _enteredQuantity,
        'category': _selectedCategory!.title,
      });
      final response = _id.isEmpty
          ? await http.post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: requestPayload,
            )
          : await http.patch(
              url,
              headers: {'Content-Type': 'application/json'},
              body: requestPayload,
            );
      // .then((response) {
      //   // do something with the response
      //   print(response);
      // })
      ;
      // print(response.body);

      final Map<String, dynamic> resData = json.decode(response.body);
      final ShoppingItem newItem = ShoppingItem.fromJson(resData);
      if (mounted) {
        Navigator.of(context).pop(
          GroceryItem(
            id: newItem.id,
            name: newItem.name,
            quantity: newItem.quantity,
            category: _selectedCategory!,
          ),
        );
      }
      // print(response.statusCode);
      // if (context.mounted) {
      //   Navigator.of(context).pop();
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    // build form here
    return Scaffold(
      appBar: AppBar(title: const Text('Add new item')),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // extended version of TextField()
              TextFormField(
                maxLength: 50,
                initialValue: _enteredName,
                decoration: const InputDecoration(
                  label: Text('Name'),
                  hintText: 'e.g. Milk',
                ),
                validator: (value) {
                  // display an error message after running validation
                  // should return null if validation succeeded
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must be text of less than 50 characters';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
              ), // check for Form types of fields
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(label: Text('Quantity')),
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) {
                        // display an error message after running validation
                        // should return null if validation succeeded
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Must be a valid positive number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        // we don't need to check the value because it's already validated
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      initialValue: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 6),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      // there's no need to implement the onSaved method because it's already handed by onChange
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSending
                        ? null
                        : () {
                            if (_id.isEmpty) {
                              _formKey.currentState!.reset();
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                    child: Text(_id.isEmpty ? 'Reset' : 'Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: _isSending ? null : _saveItem,
                    child: _isSending
                        ? SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : Text(_id.isEmpty ? 'Add Item' : 'Edit Item'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
