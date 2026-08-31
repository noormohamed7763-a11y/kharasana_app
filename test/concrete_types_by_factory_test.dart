import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kharasana_app/core/providers/core_providers.dart';
import 'package:kharasana_app/features/concrete_types/data/models/concrete_type_dto.dart';

ConcreteTypeDto _type({
  required int id,
  required int factoryId,
  double unitPrice = 25000,
}) {
  return ConcreteTypeDto(
    concreteTypeId: id,
    factoryId: factoryId,
    name: 'C$id',
    strength: id,
    unitPrice: unitPrice,
    imageUrl: null,
    description: null,
    isActive: true,
    factoryName: 'مصنع $factoryId',
  );
}

/// `/api/ConcreteTypes` تُرجع أنواع كل المصانع مرة واحدة.
final _allTypes = [
  _type(id: 25, factoryId: 1, unitPrice: 25000),
  _type(id: 30, factoryId: 1, unitPrice: 31000),
  _type(id: 35, factoryId: 2, unitPrice: 40000),
];

ProviderContainer _containerWith(List<ConcreteTypeDto> types) {
  final container = ProviderContainer(
    overrides: [concreteTypesListProvider.overrideWith((ref) => types)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('concreteTypesByFactoryProvider', () {
    test('يُرجع أنواع المصنع المطلوب فقط', () async {
      final container = _containerWith(_allTypes);

      final types =
          await container.read(concreteTypesByFactoryProvider(1).future);

      expect(types.map((t) => t.concreteTypeId), [25, 30]);
      expect(types.every((t) => t.factoryId == 1), isTrue);
    });

    test('لا يخلط أنواع مصنع بآخر', () async {
      final container = _containerWith(_allTypes);

      final types =
          await container.read(concreteTypesByFactoryProvider(2).future);

      expect(types, hasLength(1));
      expect(types.single.concreteTypeId, 35);
    });

    test('مصنع بلا أنواع يُرجع قائمة فارغة، لا أنواع المصانع الأخرى', () async {
      // هذا جوهر الإصلاح: سابقاً كانت الشاشة تعرض كل الأنواع، فيطلب العميل
      // نوعاً لا يوفّره المصنع المختار.
      final container = _containerWith(_allTypes);

      final types =
          await container.read(concreteTypesByFactoryProvider(99).future);

      expect(types, isEmpty);
    });

    test('قائمة أنواع فارغة من الخادم تُرجع فارغاً لكل مصنع', () async {
      final container = _containerWith([]);

      expect(await container.read(concreteTypesByFactoryProvider(1).future),
          isEmpty);
    });

    test('يحفظ سعر كل نوع كما هو (المصنع يحدّد سعره)', () async {
      final container = _containerWith(_allTypes);

      final types =
          await container.read(concreteTypesByFactoryProvider(1).future);

      expect(
        {for (final t in types) t.concreteTypeId: t.unitPrice},
        {25: 25000.0, 30: 31000.0},
      );
    });

    test('يُمرّر خطأ التحميل بدل إخفائه بقائمة فارغة', () async {
      final container = ProviderContainer(
        overrides: [
          concreteTypesListProvider.overrideWith(
            (ref) => Future<List<ConcreteTypeDto>>.error(
              Exception('انقطع الاتصال'),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(concreteTypesByFactoryProvider(1).future),
        throwsA(isA<Exception>()),
      );
    });
  });
}
