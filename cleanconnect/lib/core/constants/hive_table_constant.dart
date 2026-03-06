class HiveTableConstant {

  // private constructor to prevent instantiation
  HiveTableConstant._();

  // Database Name
  static const String dbName = 'cleanconnect_db';

  // Customer Table
  static const int customerTypeId = 0;
  static const String customerTable = 'customer_table';

  static const int itemTypeId = 1;
  static const String itemTable = 'item_table';

  static const int authTypeId = 2;
  static const String authTable = 'auth_table';

  static const int categoryTypeId = 3;
  static const String categoryTable = 'category_table';

  static const int serviceTypeId = 4;
  static const String serviceTable = 'service_table';

}
