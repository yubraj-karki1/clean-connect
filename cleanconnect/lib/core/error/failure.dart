import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable{
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}


class LocalDataBaseFailure extends Failure {
  const LocalDataBaseFailure({String message = "Local database opreation failure",
  }) : super(message);
}


class ApiFailure extends Failure{
  final int? statusCode;

  const ApiFailure({this.statusCode, required String message})
  :super(message);
}