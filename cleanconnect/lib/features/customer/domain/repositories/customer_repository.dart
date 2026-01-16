import 'package:dartz/dartz.dart';
import 'package:cleanconnect/core/error/failure.dart';
import 'package:cleanconnect/features/customer/domain/entities/customer_entity.dart';

abstract interface class ICustomerRepository {
  Future<Either<Failure, List<CustomerEntity>>> getAllBatches();
  Future<Either<Failure, CustomerEntity>> getBatchById(String customerId);
  Future<Either<Failure, bool>> createBatch(CustomerEntity entity);
  Future<Either<Failure, bool>> updateBatch(CustomerEntity entity);
  Future<Either<Failure, bool>> deleteBatch(String customerId);
}