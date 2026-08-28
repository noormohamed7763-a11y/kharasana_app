import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/result.dart';
import '../../data/models/create_order_dto.dart';
import '../../domain/repositories/orders_repository.dart';
import 'order_draft.dart';

sealed class OrderSubmissionState {
  const OrderSubmissionState();
}

class SubmissionIdle extends OrderSubmissionState {
  const SubmissionIdle();
}

class SubmissionInProgress extends OrderSubmissionState {
  const SubmissionInProgress();
}

class SubmissionSuccess extends OrderSubmissionState {
  final int orderId;
  const SubmissionSuccess(this.orderId);
}

class SubmissionFailed extends OrderSubmissionState {
  final String message;
  const SubmissionFailed(this.message);
}

class OrderCreationController extends StateNotifier<OrderDraft> {
  OrderCreationController(
    this._repository,
    this._secureStorage, {
    int? initialFactoryId,
  }) : super(OrderDraft(factoryId: initialFactoryId));

  final OrdersRepository _repository;
  final SecureStorageService _secureStorage;

  void updateDraft(OrderDraft Function(OrderDraft) updater) {
    state = updater(state);
  }

  Future<OrderSubmissionState> submit() async {
    if (!state.isReadyToSubmit) {
      return const SubmissionFailed('يرجى إكمال جميع البيانات المطلوبة.');
    }

    final clientId = await _secureStorage.readUserId();
    if (clientId == null) {
      return const SubmissionFailed('تعذر التحقق من هويتك، يرجى تسجيل الدخول مرة أخرى.');
    }

    final dto = CreateOrderDto(
      clientId: clientId,
      factoryId: state.factoryId!,
      concreteTypeId: state.concreteTypeId!,
      projectName: state.projectName,
      projectOwnerName: state.projectOwnerName,
      siteArea: state.siteArea,
      siteDescription: state.siteDescription,
      slabType: state.slabType,
      quantity: state.quantity!,
      needPump: state.needPump,
      floorNumber: state.needPump ? state.floorNumber : null,
      pouringDate: state.pouringDate,
      transportMethod: state.transportMethod,
      notes: state.notes,
    );

    final result = await _repository.createOrder(dto);
    return switch (result) {
      Success(data: final orderId) => SubmissionSuccess(orderId),
      Error(failure: final failure) => SubmissionFailed(failure.messageAr),
    };
  }
}

final orderCreationControllerProvider = StateNotifierProvider.autoDispose
    .family<OrderCreationController, OrderDraft, int?>((ref, initialFactoryId) {
  return OrderCreationController(
    ref.watch(ordersRepositoryProvider),
    ref.watch(secureStorageProvider),
    initialFactoryId: initialFactoryId,
  );
});

final orderCreationStepProvider = StateProvider.autoDispose<int>((ref) => 0);