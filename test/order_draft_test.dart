import 'package:flutter_test/flutter_test.dart';
import 'package:kharasana_app/features/orders/presentation/providers/order_draft.dart';

/// نوع خرسانة مختار من مصنع، بسعره.
OrderDraft _withType({
  required int factoryId,
  required int typeId,
  required double unitPrice,
}) {
  return OrderDraft(factoryId: factoryId).copyWith(
    concreteTypeId: typeId,
    concreteTypeName: 'C$typeId',
    concreteUnitPrice: unitPrice,
  );
}

void main() {
  group('OrderDraft.estimatedTotal', () {
    test('يحسب الكمية × سعر المتر المكعب', () {
      final draft = _withType(factoryId: 1, typeId: 25, unitPrice: 25000)
          .copyWith(quantity: 19.7);

      expect(draft.estimatedTotal, 492500.0);
    });

    test('null إن لم تُدخل الكمية بعد', () {
      final draft = _withType(factoryId: 1, typeId: 25, unitPrice: 25000);
      expect(draft.estimatedTotal, isNull);
    });

    test('null إن لم يُختر نوع خرسانة (لا سعر)', () {
      const draft = OrderDraft(factoryId: 1, quantity: 10);
      expect(draft.estimatedTotal, isNull);
    });
  });

  group('OrderDraft.copyWith — clearConcreteType', () {
    test('يُصفّر المعرّف والاسم والسعر معاً', () {
      final draft = _withType(factoryId: 1, typeId: 25, unitPrice: 25000);
      expect(draft.concreteUnitPrice, 25000);

      final cleared = draft.copyWith(clearConcreteType: true);

      expect(cleared.concreteTypeId, isNull);
      expect(cleared.concreteTypeName, isNull);
      expect(cleared.concreteUnitPrice, isNull);
      expect(cleared.estimatedTotal, isNull);
    });

    test('لا يمسّ بقية الحقول', () {
      final draft = _withType(factoryId: 1, typeId: 25, unitPrice: 25000)
          .copyWith(quantity: 12, projectName: 'برج السلام', needPump: true);

      final cleared = draft.copyWith(clearConcreteType: true);

      expect(cleared.factoryId, 1);
      expect(cleared.quantity, 12);
      expect(cleared.projectName, 'برج السلام');
      expect(cleared.needPump, isTrue);
    });

    test('تغيير المصنع مع تصفير النوع في نفس النسخة', () {
      // ما يفعله `OrderCreationController.selectFactory`: سعر المصنع القديم
      // لا يجوز أن يبقى محسوباً بعد الانتقال إلى مصنع آخر.
      final draft = _withType(factoryId: 1, typeId: 25, unitPrice: 25000)
          .copyWith(quantity: 10);
      expect(draft.estimatedTotal, 250000.0);

      final moved = draft.copyWith(
        factoryId: 2,
        factoryName: 'مصنع الامل',
        clearConcreteType: true,
      );

      expect(moved.factoryId, 2);
      expect(moved.concreteTypeId, isNull);
      expect(moved.estimatedTotal, isNull);
      expect(moved.isFactoryAndTypeValid, isFalse);
    });
  });

  group('OrderDraft.copyWith — clearQuantity', () {
    test('يُصفّر الكمية فعلاً', () {
      // بلا هذه الراية يُبقي `quantity ?? this.quantity` القيمة القديمة،
      // فيُحتسب سعر ويُرسل طلب بكمية محاها المستخدم من الحقل.
      final draft = _withType(factoryId: 1, typeId: 25, unitPrice: 25000)
          .copyWith(quantity: 19.7);

      final cleared = draft.copyWith(clearQuantity: true);

      expect(cleared.quantity, isNull);
      expect(cleared.estimatedTotal, isNull);
      expect(cleared.isReadyToSubmit, isFalse);
    });

    test('يُبقي السعر المختار كما هو', () {
      final cleared = _withType(factoryId: 1, typeId: 25, unitPrice: 25000)
          .copyWith(quantity: 19.7)
          .copyWith(clearQuantity: true);

      expect(cleared.concreteTypeId, 25);
      expect(cleared.concreteUnitPrice, 25000);
    });
  });

  group('OrderDraft — صلاحية الإرسال', () {
    OrderDraft valid() => _withType(factoryId: 1, typeId: 25, unitPrice: 25000)
        .copyWith(quantity: 10);

    test('مصنع ونوع وكمية موجبة تكفي للإرسال', () {
      expect(valid().isReadyToSubmit, isTrue);
    });

    test('كمية صفر غير صالحة', () {
      expect(valid().copyWith(quantity: 0).isReadyToSubmit, isFalse);
    });

    test('المضخة تُلزم رقم الدور', () {
      final pump = valid().copyWith(needPump: true);
      expect(pump.isReadyToSubmit, isFalse);
      expect(pump.copyWith(floorNumber: 3).isReadyToSubmit, isTrue);
    });

    test('إلغاء المضخة بعد إدخال الدور لا يمنع الإرسال', () {
      final draft = valid().copyWith(needPump: true, floorNumber: 3);
      expect(draft.copyWith(needPump: false).isReadyToSubmit, isTrue);
    });
  });
}
