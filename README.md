# خَرَسَانة — Kharasana

تطبيق Flutter لطلب الخرسانة الجاهزة ومتابعة شحناتها. يضمّ واجهتين:
**العميل** ينشئ الطلبات ويتابع حالتها، و**السائق** يستلم الشحنات المسندة إليه
ويحدّث حالة التوصيل.

- **الإصدار:** 1.0.0 (`1.0.0+1`)
- **الواجهة:** عربية، اتجاه RTL، خط Cairo
- **الأدوار المدعومة في التطبيق:** `Client` و `Driver` فقط. حسابات `Admin`
  و `FactoryEmployee` تُدار من لوحة تحكم منفصلة، ويُبلَّغ صاحبها عند محاولة
  الدخول من هنا.

---

## التقنيات

| الطبقة | الأداة |
|---|---|
| إدارة الحالة | `flutter_riverpod` |
| الشبكة | `dio` + معالجة أخطاء موحّدة (`Failure`) |
| التنقّل | `go_router` مع حارس أدوار |
| تخزين الجلسة | `flutter_secure_storage` (JWT) |
| التنسيق والترجمة | `intl` + `flutter_localizations` |

---

## التشغيل

```bash
flutter pub get
flutter run
```

### ربط التطبيق بالخادم

عنوان الخادم يُحدَّد في `AppConstants.baseUrlDev` بالترتيب التالي:

1. القيمة المُمرَّرة عبر `--dart-define` (تسبق كل ما بعدها):

   ```bash
   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:5000
   ```

2. الويب (Chrome) → `http://localhost:5000`
3. محاكي أندرويد → `http://10.0.2.2:5000`
4. جهاز حقيقي على الشبكة المحلية → العنوان المكتوب في
   [`app_constants.dart`](lib/core/constants/app_constants.dart)

> على جهاز حقيقي مرّر `API_BASE_URL` صراحةً، فعنوان الشبكة المحلّية يتغيّر.

---

## الاختبارات

```bash
flutter test        # 61 اختباراً
flutter analyze     # يجب أن يخرج "No issues found!"
```

تغطّي الاختبارات المواضع التي يكسر الخللُ فيها سلوكاً لا يظهر في المحلّل:

| الملف | ما يحميه |
|---|---|
| `auth_redirect_test.dart` | حارس الأدوار: منع كلّ دور من مسارات غيره |
| `orders_list_controller_test.dart` | أمان التخلّص من المزوّد، وعدد الطلبات الشبكية |
| `order_card_layout_test.dart` | بطاقة الطلب لا تتجاوز حدودها على 320/360/412dp |
| `order_draft_test.dart` | صلاحية مسوّدة الطلب وحساب التقدير |
| `concrete_types_by_factory_test.dart` | عرض أنواع المصنع المختار فقط |
| `driver_status_controller_test.dart` | تبديل حالة السائق والتراجع عند الفشل |
| `order_summary_dto_test.dart` | تحليل طلب غير مسعَّر (`totalPrice = null`) |

---

## هيكل المشروع

```
lib/
├── main.dart                  تهيئة التخزين الآمن و ProviderScope
├── app.dart                   MaterialApp.router واللغة والاتجاه
├── core/
│   ├── constants/             عنوان الخادم ومسارات الـAPI
│   ├── errors/                Failure ورسائلها العربية
│   ├── network/               DioClient وتحويل الأخطاء (mapDioError)
│   ├── providers/             مزوّدات مشتركة (تخزين، شبكة، مستودعات)
│   ├── router/                المسارات وحارس الأدوار
│   ├── session/               الجلسة وتسجيل الخروج الموحّد
│   ├── storage/               SecureStorageService
│   ├── theme/                 الألوان والقياسات وأنماط النصّ
│   ├── utils/                 التعدادات، التنسيق (AppFormat)، Result
│   └── widgets/               مكوّنات مشتركة
└── features/
    ├── authentication/        دخول، تسجيل، شاشة البداية
    ├── client/                رئيسية العميل وحسابه
    ├── concrete_types/        أنواع الخرسانة
    ├── driver/                لوحة السائق وحالة توفّره
    ├── factories/             المصانع
    ├── orders/                إنشاء الطلب، القائمة، التفاصيل
    └── users/                 الملف الشخصي وحالة السائق
```

كلّ خصيصة (feature) مقسومة إلى `data` (مصادر البيانات والـDTO) و
`domain` (عقود المستودعات) و `presentation` (الشاشات والمزوّدات).

---

## قواعد متّفق عليها في الكود

- **الأرقام لاتينية دائماً** عبر `AppFormat` — السعر والكمية والتاريخ.
  لا تُنسَّق الأرقام أو التواريخ في الشاشات مباشرةً.
- **الأخطاء تُرمى ككائن `Failure`** لا كنصّ، وتُعرض بـ`failureMessage(error)`،
  فتصل رسالة السبب الحقيقية إلى المستخدم.
- **الصفوف التي تحمل قيمة قادمة من الخادم** تُقيَّد بـ`Expanded`/`Flexible`،
  فأسماء المصانع والمشاريع بلا حدّ لطولها.
- **حالة السائق يملكها `DriverStatusController` وحده**، وتُقرأ من التخزين
  المحلّي لأن `GET /api/Users/{id}` يرجع 403 لدور Driver.

---

## قيود معروفة

- **البحث والتصفية في «طلباتي» يعملان على الصفحات المحمَّلة**، لا على الخادم.
  زرّ «تحميل طلبات أقدم» يجلب البقية. الخادم يدعم `Search` ولم يُوصَل بعد.
- **`GET /api/Users/me`** غير قابل للاستخدام (405)، و`GET /api/Users/{id}`
  يرجع 403 لدور Driver — لذا تُقرأ بيانات الجلسة من التخزين المحلّي.
- **عزل طلبات السائق غير مؤكَّد**: `GET /api/Orders` يُفلتر — على الأرجح —
  بالمصنع لا بالسائق. التفصيل في
  [`driver_providers.dart`](lib/features/driver/presentation/providers/driver_providers.dart).
- **`startDelivery` و `deliverOrder`** مبنيّان على أنّهما `PUT` بلا body،
  ولم يُتحقَّق منهما مقابل الخادم.
- **لا خدمة إشعارات** في الخادم بعد؛ زرّ الإشعارات يُبلّغ بذلك صراحةً.

---

## المساهمة

```bash
git checkout -b feat/اسم-الميزة
# التغييرات، ثم:
flutter analyze && flutter test
git commit -m "feat: وصف التغيير"
```

يُشترط قبل الدمج: `flutter analyze` بلا ملاحظات، ونجاح كلّ الاختبارات.
