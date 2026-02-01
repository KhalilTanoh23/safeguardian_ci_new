import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class AlertsEvent extends Equatable {
  const AlertsEvent();

  @override
  List<Object> get props => [];
}

class LoadAlerts extends AlertsEvent {}

// States
abstract class AlertsState extends Equatable {
  const AlertsState();

  @override
  List<Object> get props => [];
}

class AlertsInitial extends AlertsState {}

class AlertsLoading extends AlertsState {}

class AlertsLoaded extends AlertsState {
  final List<dynamic> alerts;

  const AlertsLoaded(this.alerts);

  @override
  List<Object> get props => [alerts.length];
}

// Bloc
class AlertsBloc extends Bloc<AlertsEvent, AlertsState> {
  AlertsBloc() : super(AlertsInitial()) {
    on<LoadAlerts>(_onLoad);
  }

  Future<void> _onLoad(LoadAlerts event, Emitter<AlertsState> emit) async {
    emit(AlertsLoading());
    // Minimal implementation: emit empty list. Replace with real repository calls.
    emit(const AlertsLoaded([]));
  }
}
