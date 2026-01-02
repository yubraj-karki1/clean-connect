import 'package:cleanconnect/features/auth/data/models/auth_hive_model.dart';
import 'package:cleanconnect/features/customer/data/models/customer_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cleanconnect/core/constants/hive_table_constant.dart';
import 'package:hive/hive.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});
class HiveService {
  // Initialize Hive, Register Adapters, and Open Boxes
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);

    _registerAdaptors();
    await _openBoxes();
  }

  // Register Adaptors
  void _registerAdaptors() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.customerTypeId)) {
      Hive.registerAdapter(CustomerHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  // Open boxes
  Future<void> _openBoxes() async {
    await Hive.openBox<CustomerHiveModel>(HiveTableConstant.customerTable);
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
  }

  // Close Boxes
  Future<void> close() async {
    await Hive.close();
  }


  // =============== Customer Queries ===========

  // Getter for the Customer Box
  Box<CustomerHiveModel> get _customerBox =>
      Hive.box<CustomerHiveModel>(HiveTableConstant.customerTable);

  // Create or Add Customer
  Future<void> createCustomer(CustomerHiveModel model) async {
    // We use put() with an ID so we can easily update/delete it later
    await _customerBox.put(model.customerId, model);
  }

  // Get All Customers
  Future<List<CustomerHiveModel>> getAllCustomers() async {
    return _customerBox.values.toList();
  }

  // Update Customer
  Future<void> updateCustomer(CustomerHiveModel model) async {
    // In Hive, put() overwrites the existing value if the key exists
    await _customerBox.put(model.customerId, model);
  }

  // Delete Customer
  Future<void> deleteCustomer(String id) async {
    await _customerBox.delete(id);
  }
  
  // Clear all data from the customer box
  Future<void> clearAll() async {
    await _customerBox.clear();
  }

  // ====================Auth CRUD Operations=====================
  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.authTable);

  // Register user
  Future<AuthHiveModel> register(AuthHiveModel user) async {
    await _authBox.put(user.authId, user);
    return user;
  }

  // Login - find user by email and password
  AuthHiveModel? login(String email, String password) {
    try {
      return _authBox.values.firstWhere(
        (user) => user.email == email && user.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  // LogOut
  Future<void> logout() async {}

  // Get Current User
  AuthHiveModel? getCurrentUser(String authId) {
    return _authBox.get(authId);
  }

  // Get user by ID
  AuthHiveModel? getUserById(String authId) {
    return _authBox.get(authId);
  }

  // Get user by email
  AuthHiveModel? getUserByEmail(String email) {
    try {
      return _authBox.values.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  // Update user
  Future<bool> updateUser(AuthHiveModel user) async {
    if (_authBox.containsKey(user.authId)) {
      await _authBox.put(user.authId, user);
      return true;
    }
    return false;
  }

  // Delete user
  Future<void> deleteUser(String authId) async {
    await _authBox.delete(authId);
  }

  bool doesEmailExist(String email) {
    final users = _authBox.values.where((user) => user.email == email);
    return users.isNotEmpty;
  }
}

