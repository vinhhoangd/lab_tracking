import 'package:flutter/material.dart';
import 'package:lab_tracking/Scanning/mobile_scanner_page.dart';
import 'package:lab_tracking/Pages/settings_page.dart';
import 'package:lab_tracking/Pages/ai_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  bool _showAddButton = false;
  String? _scannedId;
  String? _itemName;
  String? _itemTimestamp;
  String? _itemLocation;
  int? _itemQuantity;
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(String? timestamp) {
    if (timestamp == null) return 'Unknown';
    try {
      final date = DateTime.parse(timestamp);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<void> _checkIdInDatabase(String scannedId) async {
    setState(() {
      _isLoading = true;
      _showAddButton = false;
      _scannedId = scannedId;
    });

    try {
      String trimmedId = scannedId.trim();
      print('Scanned ID: "$trimmedId" (length: ${trimmedId.length})');
      final response = await Supabase.instance.client
          .from('scanned_data')
          .select('code_id, item_name, timestamp, location, quantity')
          .eq('code_id', trimmedId)
          .maybeSingle();

      print('📊 Database response: $response');
      
      setState(() {
        _isLoading = false;
        if (response != null) {
          print('Found existing item: ${response['item_name']}');
          _showAddButton = false;
          _itemName = response['item_name'] as String?;
          _itemTimestamp = response['timestamp'] as String?;
          _itemLocation = response['location'] as String?;
          _itemQuantity = response['quantity'] as int?;
        } else {
          print('No existing item found');
          _showAddButton = true;
          _itemName = null;
          _itemTimestamp = null;
          _itemLocation = null;
          _itemQuantity = null;
        }
      });

      if (response != null) {
        // ID already exists in database
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Item found: ${_itemName ?? 'Unknown'} (Last modified: ${_formatDate(_itemTimestamp)})'),
            backgroundColor: Colors.blue,
          ),
        );
      } else {
        // ID doesn't exist - show the add button
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('New ID detected: $scannedId'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
        _showAddButton = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking database: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addIdToDatabase() async {
    if (_scannedId == null) return;

    // Show dialog to get item name
    final itemName = await _showItemNameDialog();
    if (itemName == null || itemName.isEmpty) {
      return; // User cancelled or entered empty name
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Supabase.instance.client
          .from('scanned_data')
          .insert({
            'code_id': _scannedId,
            'item_name': itemName,
            'timestamp': DateTime.now().toIso8601String(),
            // location will be added later
          });

      setState(() {
        _isLoading = false;
        _showAddButton = false; // Hide button after successful addition
        _scannedId = null; // Clear the scanned ID
        _itemName = null; // Clear item details
        _itemTimestamp = null; // Clear item details
        _itemLocation = null;
        _itemQuantity = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully added: $itemName (ID: $_scannedId)'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding to database: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _showItemNameDialog() async {
    final TextEditingController nameController = TextEditingController();
    
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add New Item',
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Scanned ID: $_scannedId',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  hintText: 'Enter the name of this item',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.greenAccent.shade400,
                      width: 2,
                    ),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, null); // Return null for cancel
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  Navigator.pop(context, name); // Return the entered name
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter an item name'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent.shade400,
                foregroundColor: Colors.black,
              ),
              child: const Text('Add Item'),
            ),
          ],
        );
      },
    );
  }

  void _showModifyDialog() {
    final nameController = TextEditingController(text: _itemName ?? '');
    final quantityController = TextEditingController(text: _itemQuantity?.toString() ?? '');
    final locationController = TextEditingController(text: _itemLocation ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modify Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              final newQuantity = int.tryParse(quantityController.text.trim());
              final newLocation = locationController.text.trim();

              if (newName.isEmpty || newQuantity == null || newLocation.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields correctly')),
                );
                return;
              }

              await Supabase.instance.client
                  .from('scanned_data')
                  .update({
                    'item_name': newName,
                    'quantity': newQuantity,
                    'location': newLocation,
                  })
                  .eq('code_id', _scannedId!);

              setState(() {
                _itemName = newName;
                _itemQuantity = newQuantity;
                _itemLocation = newLocation;
              });

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Item updated!'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _onBottomNavTapped(int index) async {
    if (index == 1) {
      // Scan: open scanner
      final scannedData = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MobileScannerPage(),
        ),
      );

      if (scannedData != null) {
        await _checkIdInDatabase(scannedData);
      }
      // Keep Home selected after scanning
      setState(() {
        _selectedIndex = 0;
      });
      return;
    }

    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      // Home: clear all fields to refresh
      setState(() {
        _searchController.clear();
        _scannedId = null;
        _itemName = null;
        _itemTimestamp = null;
        _itemLocation = null;
        _itemQuantity = null;
        _showAddButton = false;
      });
    } else if (index == 2) {
      // Settings: navigate to SettingsPage
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
    } else if (index == 3) {
      // AI: navigate to AI Page (to be created)
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AIPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        title: Text(
          'Home Page',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.greenAccent.shade400,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            // Display scanned ID if available
            if (_scannedId != null) ...[
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scanned ID:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _scannedId!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // Display item details if they exist
                      if (_itemName != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Item Name:',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _itemName!,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Quantity:',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_itemQuantity ?? 'Unknown'}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Location:',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_itemLocation ?? 'Unknown'}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Last Modified: ${_formatDate(_itemTimestamp)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(Icons.edit, color: Colors.greenAccent.shade400),
                          tooltip: 'Modify Item',
                          onPressed: _showModifyDialog,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Loading indicator
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                ),
              ),

            // Conditional Add Button - only shows if ID doesn't exist in database
            if (_showAddButton && !_isLoading)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addIdToDatabase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.shade400,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 3,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Add ID to Database',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        selectedItemColor: Colors.greenAccent.shade400,
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome), // Sparkle icon
            label: 'AI',
          ),
        ],
      ),
    );
  }
}