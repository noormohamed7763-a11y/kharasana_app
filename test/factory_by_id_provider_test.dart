import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kharasana_app/core/errors/failure.dart';
import 'package:kharasana_app/core/providers/core_providers.dart';
import 'package:kharasana_app/features/factories/data/datasources/factories_remote_data_source.dart';
import 'package:kharasana_app/features/factories/data/models/factory_dto.dart';

FactoryDto _factory({
  required int id,
  required String name,
  required bool isActive,
}) {
  return FactoryDto(
    factoryId: id,
    factoryName: name,
    ownerName: null,
    phone: null,
    whatsApp: null,
    email: null,
    area: null,
    address: null,
    latitude: null,
    longitude: null,
    logo: null,
    isActive: isActive,
    hasAccount: false,
  );
}

/// مصدر مزوّف لا يمسّ الشبكة: `getFactoryById` يجيب من قاموس، وعدم وجود
/// المعرّف يرمي خطأً كما يفعل الخادم عند 404.
class _FakeFactoriesSource extends FactoriesRemoteDataSource {
  _FakeFactoriesSource(this.byId) : super(Dio());

  final Map<int, FactoryDto> byId;

  @override
  Future<FactoryDto> getFactoryById(int id) async {
    final factory = byId[id];
    if (factory != null) return factory;
    throw Exception('المصنع غير موجود أو غير متاح الآن.');
  }
}

final _factories = {
  1: _factory(id: 1, name: 'مصنع عدن', isActive: true),
  7: _factory(id: 7, name: 'مصنع تعز', isActive: false),
};

ProviderContainer _containerWith(_FakeFactoriesSource source) {
  final container = ProviderContainer(
    overrides: [factoriesRemoteDataSourceProvider.overrideWith((ref) => source)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('factoryByIdProvider', () {
    test('يُرجع المصنع المطلوب بالمعرّف من المصدر نفسه', () async {
      final container = _containerWith(_FakeFactoriesSource(_factories));

      final factory = await container.read(factoryByIdProvider(1).future);

      expect(factory.factoryId, 1);
      expect(factory.factoryName, 'مصنع عدن');
    });

    test('كل معرّف يُجلب بشكل مستقل عن الآخرين', () async {
      final container = _containerWith(_FakeFactoriesSource(_factories));

      final first = await container.read(factoryByIdProvider(1).future);
      final second = await container.read(factoryByIdProvider(7).future);

      expect(first.factoryId, 1);
      expect(second.factoryId, 7);
      expect(second.factoryName, 'مصنع تعز');
      expect(second.isActive, isFalse);
    });

    test('مصنع غير موجود يُبقي الخطأ ظاهراً ولا يمحوه', () async {
      final container = _containerWith(_FakeFactoriesSource(_factories));

      expect(
        container.read(factoryByIdProvider(99).future),
        throwsA(isA<Failure>()),
      );
    });
  });
}