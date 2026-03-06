import 'package:cleanconnect/features/customer/data/models/customer_hive_model.dart';

abstract interface class ICustomerDatasource {
  Future< List<CustomerHiveModel>> getAllCustomers();
  Future< CustomerHiveModel> getCustomerById(String customerId);
  Future< bool> createCustomer(CustomerHiveModel model);
  Future< bool> updateCustomer(CustomerHiveModel model);
  Future< bool> deleteCustomer(String customerId);
}