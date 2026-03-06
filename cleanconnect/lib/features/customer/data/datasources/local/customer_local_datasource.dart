import 'package:cleanconnect/core/services/hive/hive_service.dart';
import 'package:cleanconnect/features/customer/data/datasources/batch_datasource.dart'; // Ensure this contains ICustomerDatasource
import 'package:cleanconnect/features/customer/data/models/customer_hive_model.dart';

class CustomerLocalDatasource implements ICustomerDatasource {
  final HiveService _hiveService;

  CustomerLocalDatasource({required HiveService hiveService})
      : _hiveService = hiveService;

  @override
  Future<bool> createCustomer(CustomerHiveModel entity) async {
    try {
      await _hiveService.createCustomer(entity);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<CustomerHiveModel>> getAllCustomers() async {
    try {
      return await _hiveService.getAllCustomers();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<CustomerHiveModel> getCustomerById(String customerId) async {
    try {
      final customers = await _hiveService.getAllCustomers();
      // Searching for the specific customer in the list
      return customers.firstWhere((element) => element.customerId == customerId);
    } catch (e) {
      throw Exception("Customer not found: $e");
    }
  }

  @override
  Future<bool> updateCustomer(CustomerHiveModel entity) async {
    try {
      await _hiveService.updateCustomer(entity);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteCustomer(String customerId) async {
    try {
      await _hiveService.deleteCustomer(customerId);
      return true;
    } catch (e) {
      return false;
    }
  }
}