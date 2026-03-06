import 'package:equatable/equatable.dart';

class CustomerEntity  extends Equatable{
  final String? customerId;
  final String customerName;
  final String? status;

  const CustomerEntity({this.customerId, required this.customerName, this.status});
  @override
  List<Object?> get props => [customerId, customerName, status];
}