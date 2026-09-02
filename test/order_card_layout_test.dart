import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kharasana_app/core/utils/api_enums.dart';
import 'package:kharasana_app/features/orders/data/models/order_summary_dto.dart';
import 'package:kharasana_app/features/orders/presentation/widgets/order_card.dart';

/// بطاقة الطلب هي أكثر عنصر يراه العميل، وكانت تتجاوز حدودها على كلّ عرض
/// جهاز: ١٤px عند ٤١٢dp باسم نوع قصير، و٢٦٥px عند ٣٢٠dp باسم طويل. السبب
/// ثلاث `Row` غير مقيّدة داخل صفّ واحد بـ `spaceBetween`.
///
/// أضيق عرض شائع اليوم ٣٢٠dp، والاختبار يشمله مع ٣٦٠ و٤١٢.
OrderSummaryDto _order({
  String concreteTypeName = 'خرسانة مسلحة C30',
  String factoryName = 'مصنع الخرسانة الجاهزة الحديث',
  double quantity = 19.75,
}) {
  return OrderSummaryDto(
    orderId: 1,
    orderNumber: 'KH-2026-000123',
    clientName: 'محمد النور',
    factoryName: factoryName,
    concreteTypeName: concreteTypeName,
    quantity: quantity,
    totalPrice: 492500,
    transportMethod: TransportMethod.factoryTransport,
    status: OrderStatus.onTheWay,
    createdAt: DateTime(2026, 1, 15),
  );
}

/// مندوبو الترجمة مطلوبون: `AppFormat.date` يقرأ أسماء الشهور العربية من
/// `intl`، ويهيّئها `GlobalMaterialLocalizations` كما في `app.dart`.
Widget _app(Widget child) {
  return MaterialApp(
    locale: const Locale('ar', 'YE'),
    supportedLocales: const [Locale('ar', 'YE')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: child,
      ),
    ),
  );
}

Future<void> _pumpAt(WidgetTester tester, double width, Widget child) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_app(child));
  await tester.pump();
}

void main() {
  group('OrderCard — لا تجاوز للحدود', () {
    for (final width in [320.0, 360.0, 412.0]) {
      testWidgets('عرض ${width.toInt()}dp باسم نوع طويل', (tester) async {
        await _pumpAt(
          tester,
          width,
          OrderCard(
            order: _order(concreteTypeName: 'خرسانة مسلحة عالية المقاومة C40'),
            onTap: () {},
          ),
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('عرض ${width.toInt()}dp باسم نوع قصير', (tester) async {
        await _pumpAt(
          tester,
          width,
          OrderCard(order: _order(concreteTypeName: 'C25'), onTap: () {}),
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('نصّ متطرّف الطول لا يفيض أيضاً', (tester) async {
      await _pumpAt(
        tester,
        320,
        OrderCard(
          order: _order(
            concreteTypeName: 'خرسانة ' * 12,
            factoryName: 'مصنع ' * 12,
            quantity: 123456.75,
          ),
          onTap: () {},
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('البيانات الثلاثة معروضة ولم يحذفها التقييد', (tester) async {
      await _pumpAt(
        tester,
        360,
        OrderCard(order: _order(), onTap: () {}),
      );

      expect(find.text('طلب رقم #KH-2026-000123'), findsOneWidget);
      expect(find.text('خرسانة مسلحة C30'), findsOneWidget);
      // الكمية والتاريخ بأرقام لاتينية عبر `AppFormat`، لا هندية.
      expect(find.text('19.75 م³'), findsOneWidget);
      expect(find.text('15 يناير 2026'), findsOneWidget);
    });
  });
}
