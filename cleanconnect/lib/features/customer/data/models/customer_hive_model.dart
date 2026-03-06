import 'package:cleanconnect/core/constants/hive_table_constant.dart';
import 'package:cleanconnect/features/customer/domain/entities/customer_entity.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'customer_hive_model.g.dart'; // dart run build_runner build -d

@HiveType(typeId: HiveTableConstant.customerTypeId)
class CustomerHiveModel extends HiveObject {
  @HiveField(0)
  final String? batchId;

  @HiveField(1)
  final String batchName;

  @HiveField(2)
  final String? status;

  CustomerHiveModel({String? batchId, required this.batchName, String? status})
    : batchId = batchId ?? Uuid().v4(),
      status = status ?? 'active';

  CustomerEntity toEntity() {
    return CustomerEntity(customerId: batchId, customerName: batchName, status: status);
  }

  // Convert Batch Entity to Model
  factory CustomerHiveModel.fromEntity(CustomerEntity entity) {
    return CustomerHiveModel(batchName: entity.customerName);
  }

  Null get customerId => null;

  // Convert List of Models to List of Batch Entities
  static List<CustomerEntity> toEntityList(List<CustomerHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
