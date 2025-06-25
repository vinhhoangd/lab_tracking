import 'package:flutter/material.dart';
import 'package:lab_tracking/Scanning/mobile_scanner_page.dart';
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
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkIdInDatabase(String scannedId) async {
    setState(() {
      _isLoading = true;
      _showAddButton = false;
      _scannedId = scannedId;
    });

    try {
      // Check if code_id exists in scanned_data table
      final response = await Supabase.instance.client
          .from('scanned_data')
          .select('code_id')
          .eq('code_id', scannedId)
          .maybeSingle();

      setState(() {
        _isLoading = false;
        // Show button only if no matching ID was found
        _showAddButton = response == null;
      });

      if (response != null) {
        // ID already exists in database
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ID $scannedId already exists in database'),
            backgroundColor: Colors.orange,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            // Search bar with QR code scanner icon
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.qr_code_scanner),
                    onPressed: () async {
                      final scannedData = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MobileScannerPage(),
                        ),
                      );

                      if (scannedData != null) {
                        // Check if this ID exists in the database
                        await _checkIdInDatabase(scannedData);
                        
                        // Also populate the search field with scanned data
                        _searchController.text = scannedData;
                      }
                    },
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),

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
    );
  }
}