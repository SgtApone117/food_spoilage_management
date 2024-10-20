import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
// import 'package:intl/intl.dart'; // For date formatting

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'food_expiration.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE food_items(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, expiration_min INTEGER, expiration_max INTEGER, date_received TEXT)',
        );
      },
    );
  }

  Future<void> deleteAllFoodItems() async {
    final db = await database;
    await db.delete('food_items'); // Deletes all rows from the food_items table
  }


  Future<void> insertFoodItem(String name, int minDays, int maxDays) async {
    final db = await database; // This should be the writable instance
    try {
      print('Inserting food item: $name');

      String currentDate = DateTime.now().toIso8601String();
      print('Current date: $currentDate');

      await db.insert(
        'food_items',
        {
          'name': name,
          'expiration_min': minDays,
          'expiration_max': maxDays,
          'date_received': currentDate
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('Inserted item: $name with expiration between $minDays and $maxDays days');
    } catch (e) {
      print('Error inserting food item: $e');
    }
  }



  Future<List<Map<String, dynamic>>> getSortedFoodItems() async {
    final db = await database;
    final foodItems = await db.query('food_items');

    // Create a list to hold mutable copies of food items
    List<Map<String, dynamic>> mutableFoodItems = [];

    // Add calculated expiration dates to each food item and sort
    for (var item in foodItems) {
      // Create a mutable copy of the item
      Map<String, dynamic> mutableItem = Map<String, dynamic>.from(item);

      DateTime receivedDate = DateTime.parse(mutableItem['date_received'].toString());
      DateTime expirationMinDate = receivedDate.add(Duration(days: int.parse(mutableItem['expiration_min'].toString())));

      // Add the calculated expirationMinDate to the mutable item map
      mutableItem['calculated_expiration_min'] = expirationMinDate;

      // Add the mutable item to the new list
      mutableFoodItems.add(mutableItem);
    }

    // Sort by the calculated expiration_min date
    mutableFoodItems.sort((a, b) {
      DateTime? aDate = a['calculated_expiration_min'] as DateTime?;
      DateTime? bDate = b['calculated_expiration_min'] as DateTime?;

      // If either date is null, consider it "larger" so it goes to the end of the list
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;

      return aDate.compareTo(bDate);
    });

    return mutableFoodItems; // Return the new list of mutable items
  }

}
