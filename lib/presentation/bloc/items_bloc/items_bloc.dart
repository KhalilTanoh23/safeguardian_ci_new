import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class ItemsEvent extends Equatable {
  const ItemsEvent();

  @override
  List<Object> get props => [];
}

class LoadItems extends ItemsEvent {}

// States
abstract class ItemsState extends Equatable {
  const ItemsState();

  @override
  List<Object> get props => [];
}

class ItemsInitial extends ItemsState {}

class ItemsLoading extends ItemsState {}

class ItemsLoaded extends ItemsState {
  final List<dynamic> items;

  const ItemsLoaded(this.items);

  @override
  List<Object> get props => [items.length];
}

// Bloc
class ItemsBloc extends Bloc<ItemsEvent, ItemsState> {
  ItemsBloc() : super(ItemsInitial()) {
    on<LoadItems>(_onLoad);
  }

  Future<void> _onLoad(LoadItems event, Emitter<ItemsState> emit) async {
    emit(ItemsLoading());
    // Minimal implementation: emit empty list. Replace with real repository calls.
    emit(const ItemsLoaded([]));
  }
}
