import 'package:equatable/equatable.dart';

import '../../../models/address_list_response.dart';

class ChangeAddressEvent extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class FetchAddressLoadingEvent extends ChangeAddressEvent {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class FetchAddressEvent extends ChangeAddressEvent {
  List<AddressData> addresslist;
  FetchAddressEvent(this.addresslist);
  @override
  // TODO: implement props
  List<Object?> get props => [addresslist];
}

class SelectAddressEvent extends ChangeAddressEvent {
  AddressData addressdata;
  SelectAddressEvent(this.addressdata);
  @override
  List<Object?> get props => [addressdata];
}

// class UpdateAddressEvent extends ChangeAddressEvent {
//   List<Map<String, dynamic>> addresslist;
//   UpdateAddressEvent(this.addresslist);
//   @override
//   // TODO: implement props
//   List<Object?> get props => [addresslist];
// }
//
// class DeleteAddressEvent extends ChangeAddressEvent {
//   List<Map<String, dynamic>> addresslist;
//   DeleteAddressEvent(this.addresslist);
//   @override
//   // TODO: implement props
//   List<Object?> get props => [addresslist];
// }
