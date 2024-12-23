import 'package:equatable/equatable.dart';

import '../../../models/address_list_response.dart';

class ChangeAddressState extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class FetchAddressInitialState extends ChangeAddressState {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class FetchAddressLoadingState extends ChangeAddressState {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class FetchAddressState extends ChangeAddressState {
  List<AddressData> addresslist;
  FetchAddressState(this.addresslist);
  @override
  // TODO: implement props
  List<Object?> get props => [addresslist];
}

class SelectAddressState extends ChangeAddressState {
  AddressData addressData;
  SelectAddressState({required this.addressData});
  @override
  List<Object?> get props => [addressData];
}
