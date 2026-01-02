import 'package:cleanconnect/core/error/failure.dart';
import 'package:cleanconnect/features/customer/data/datasources/batch_datasource.dart';
import 'package:cleanconnect/features/customer/data/models/customer_hive_model.dart';
import 'package:cleanconnect/features/customer/domain/entities/customer_entity.dart';
import 'package:cleanconnect/features/customer/domain/repositories/customer_repository.dart';
import 'package:dartz/dartz.dart';

class CustomerRepository implements ICustomerRepository {
  final ICustomerDatasource _datasource;

  CustomerRepository({required ICustomerDatasource datasource})
      : _datasource = datasource;

  @override
  Future<Either<Failure, bool>> createBatch(CustomerEntity entity) async {
    try {
      // Convert Entity to Hive Model
      final model = CustomerHiveModel.fromEntity(entity);
      final result = await _datasource.createCustomer(model);
      if(result){
      return Right(result);
      }
      return left(LocalDataBaseFailure(message: 'Failed to create customer'));
    } catch (e) {
      return Left(LocalDataBaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CustomerEntity>>> getAllBatches() async {
    try {
      final models = await _datasource.getAllCustomers();
      final entities = CustomerHiveModel.toEntityList(models);
      return Right(entities);
    } catch (e) {
      return Left(LocalDataBaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> getBatchById(String customerId) async {
    try {
      final model = await _datasource.getCustomerById(customerId);
      return Right(model.toEntity());
    } catch (e) {
      return Left(LocalDataBaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateBatch(CustomerEntity entity) async {
    try {
      final model = CustomerHiveModel.fromEntity(entity);
      final result = await _datasource.updateCustomer(model);
      return Right(result);
    } catch (e) {
      return Left(LocalDataBaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteBatch(String customerId) async {
    try {
      final result = await _datasource.deleteCustomer(customerId);
      return Right(result);
    } catch (e) {
      return Left(LocalDataBaseFailure(message: e.toString()));
    }
  }
}