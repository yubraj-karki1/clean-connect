import 'package:cleanconnect/core/error/failure.dart';
import 'package:dartz/dartz.dart';

abstract interface class UsecaseWithParams<SuccessType, Params>{
  Future<Either<Failure, SuccessType>> call(Params params);
}


abstract interface class UsecaseWithoutParams<SuccessType>{
  Future<Either<Failure, SuccessType>> call();
}