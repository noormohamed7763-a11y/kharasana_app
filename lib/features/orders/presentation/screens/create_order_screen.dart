import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/api_enums.dart';
import '../../../../core/utils/app_format.dart';
import '../providers/order_creation_controller.dart';
import 'order_success_screen.dart';

class CreateOrderScreen extends ConsumerStatefulWidget {
  const CreateOrderScreen({super.key, this.initialFactoryId});
  final int? initialFactoryId;

  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  final _projectNameCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _siteAreaCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _siteDescCtrl = TextEditingController();
  final _floorCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime? _selectedDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _projectNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _siteAreaCtrl.dispose();
    _quantityCtrl.dispose();
    _siteDescCtrl.dispose();
    _floorCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      ref.read(orderCreationControllerProvider(widget.initialFactoryId).notifier).updateDraft(
            (d) => d.copyWith(pouringDate: picked),
          );
    }
  }

  Future<void> _submitOrder() async {
    final draft = ref.read(orderCreationControllerProvider(widget.initialFactoryId));
    final controller = ref.read(orderCreationControllerProvider(widget.initialFactoryId).notifier);

    if (draft.factoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار المصنع')),
      );
      return;
    }
    if (draft.concreteTypeId == null) {
      // رسالة دقيقة: «اختر النوع» طريق مسدود إن كان المصنع لا يوفّر أنواعاً.
      final types =
          ref.read(concreteTypesByFactoryProvider(draft.factoryId!)).valueOrNull;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            types != null && types.isEmpty
                ? 'هذا المصنع لا يوفّر أنواع خرسانة حالياً، يرجى اختيار مصنع آخر'
                : 'يرجى اختيار نوع الخرسانة',
          ),
        ),
      );
      return;
    }
    if (draft.quantity == null || draft.quantity! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال الكمية بالمتر المكعب')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final result = await controller.submit();
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (result) {
      case SubmissionSuccess(orderId: final orderId):
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OrderSuccessScreen(
              orderId: orderId,
              factoryName: draft.factoryName ?? 'المصنع',
              concreteTypeName: draft.concreteTypeName ?? 'خرسانة جاهزة',
              pouringDate: draft.pouringDate,
            ),
          ),
        );
      case SubmissionFailed(message: final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: AppColors.textOnPrimary, size: AppSizes.iconSm),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: AppColors.error,
          ),
        );
      case SubmissionInProgress():
      case SubmissionIdle():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final factoriesAsync = ref.watch(factoriesListProvider);
    final draft = ref.watch(orderCreationControllerProvider(widget.initialFactoryId));
    final controller = ref.read(orderCreationControllerProvider(widget.initialFactoryId).notifier);

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'طلب خرسانة جديد',
          style: TextStyle(
            color: AppColors.brand700,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: AppColors.ink700),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: AppColors.brand700),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      // لا شريط تنقّل سفلي هنا عن قصد: هذه شاشة نموذج مدفوعة على المكدّس،
      // وليست إحدى وجهات التنقّل الثلاث. كان الشريط موجوداً بـ currentIndex: 0
      // فيُضيء "الرئيسية" بينما المستخدم في منتصف طلبه، ولمسة واحدة على أي
      // زر تستدعي context.go فتُبدّل المكدّس وتُتلف المسوّدة بلا إنذار.
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Hero Construction Banner Card
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/order_banner.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.shadow.withValues(alpha: 0.25),
                              AppColors.shadow.withValues(alpha: 0.75),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'بيانات الطلب',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'أدخل تفاصيل الصبة والكميات المطلوبة بدقة',
                            style: TextStyle(
                              color: AppColors.white.withValues(alpha: 0.88),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // 2. Form Container Card
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // المصنع (Factory Dropdown)
                  const _FormLabel('المصنع'),
                  factoriesAsync.when(
                    data: (factories) => _CustomDropdown<int>(
                      hint: 'اختر المصنع...',
                      value: draft.factoryId,
                      items: factories
                          .map((f) => DropdownMenuItem(
                                value: f.factoryId,
                                child: Text(f.factoryName, style: const TextStyle(fontSize: 14)),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val == null) return;
                        final selectedFactory = factories.firstWhere((f) => f.factoryId == val);
                        controller.selectFactory(
                          factoryId: val,
                          factoryName: selectedFactory.factoryName,
                        );
                      },
                    ),
                    loading: () => const Center(child: LinearProgressIndicator()),
                    error: (_, __) => const Text('تعذر تحميل المصانع'),
                  ),
                  const SizedBox(height: 14),

                  // نوع الخرسانة — الأنواع التابعة للمصنع المختار فقط
                  const _FormLabel('نوع الخرسانة'),
                  if (draft.factoryId == null)
                    const _InlineNotice(
                      icon: Icons.info_outline_rounded,
                      text: 'اختر المصنع أولاً لعرض أنواع الخرسانة المتاحة لديه',
                    )
                  else
                    ref.watch(concreteTypesByFactoryProvider(draft.factoryId!)).when(
                          loading: () => const Center(child: LinearProgressIndicator()),
                          error: (_, __) => const _InlineNotice(
                            icon: Icons.error_outline_rounded,
                            text: 'تعذر تحميل أنواع الخرسانة، حاول مرة أخرى',
                            isError: true,
                          ),
                          data: (types) {
                            if (types.isEmpty) {
                              return _InlineNotice(
                                icon: Icons.production_quantity_limits_rounded,
                                text:
                                    'لا يوفّر ${draft.factoryName ?? 'هذا المصنع'} أي نوع خرسانة حالياً — يرجى اختيار مصنع آخر.',
                                isError: true,
                              );
                            }

                            // حماية: لا نُسلّم DropdownButton قيمة غير موجودة في
                            // عناصره (يرمي استثناءً)، مثلاً لو أُلغي تنشيط النوع.
                            final selectedId =
                                types.any((t) => t.concreteTypeId == draft.concreteTypeId)
                                    ? draft.concreteTypeId
                                    : null;

                            return _CustomDropdown<int>(
                              hint: 'اختر النوع...',
                              value: selectedId,
                              items: types
                                  .map((t) => DropdownMenuItem(
                                        value: t.concreteTypeId,
                                        child: Text(
                                          '${t.name} · قوة ${t.strength} · '
                                          '${AppFormat.pricePerCubicMetre(t.unitPrice)}',
                                          style: const TextStyle(fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                if (val == null) return;
                                final selectedType =
                                    types.firstWhere((t) => t.concreteTypeId == val);
                                controller.selectConcreteType(
                                  concreteTypeId: selectedType.concreteTypeId,
                                  name: selectedType.name,
                                  unitPrice: selectedType.unitPrice,
                                );
                              },
                            );
                          },
                        ),
                  const SizedBox(height: 14),

                  // اسم المشروع
                  const _FormLabel('اسم المشروع'),
                  _CustomTextField(
                    controller: _projectNameCtrl,
                    hint: 'مثلاً: مشروع برج العليا',
                    onChanged: (val) => controller.updateDraft((d) => d.copyWith(projectName: val)),
                  ),
                  const SizedBox(height: 14),

                  // اسم مالك المشروع
                  const _FormLabel('اسم مالك المشروع'),
                  _CustomTextField(
                    controller: _ownerNameCtrl,
                    hint: 'الاسم الرباعي',
                    onChanged: (val) =>
                        controller.updateDraft((d) => d.copyWith(projectOwnerName: val)),
                  ),
                  const SizedBox(height: 14),

                  // Row: مساحة الموقع (م²) & الكمية (م³)
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FormLabel('مساحة الموقع (م²)'),
                            _CustomTextField(
                              controller: _siteAreaCtrl,
                              hint: '0',
                              keyboardType: TextInputType.number,
                              onChanged: (val) =>
                                  controller.updateDraft((d) => d.copyWith(siteArea: val)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FormLabel('الكمية (م³) *'),
                            _CustomTextField(
                              controller: _quantityCtrl,
                              hint: '0',
                              keyboardType: TextInputType.number,
                              onChanged: (val) {
                                // محو الحقل يجب أن يمحو الكمية فعلياً — وإلا بقيت
                                // القيمة القديمة في الطلب والسعر محسوباً عليها.
                                final parsed = double.tryParse(val.trim());
                                controller.updateDraft(
                                  (d) => parsed == null
                                      ? d.copyWith(clearQuantity: true)
                                      : d.copyWith(quantity: parsed),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // تقدير التكلفة — يظهر بمجرد اختيار نوع الخرسانة
                  if (draft.concreteUnitPrice != null) ...[
                    _PriceSummaryCard(
                      unitPrice: draft.concreteUnitPrice!,
                      quantity: draft.quantity,
                      total: draft.estimatedTotal,
                    ),
                    const SizedBox(height: 14),
                  ],

                  // وصف الموقع
                  const _FormLabel('وصف الموقع'),
                  _CustomTextField(
                    controller: _siteDescCtrl,
                    hint: 'الحي، الشارع، علامات مميزة',
                    onChanged: (val) =>
                        controller.updateDraft((d) => d.copyWith(siteDescription: val)),
                  ),
                  const SizedBox(height: 14),

                  // Row: نوع الصبة & رقم الدور
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FormLabel('نوع الصبة'),
                            _CustomDropdown<SlabType>(
                              hint: 'نوع الصبة',
                              value: draft.slabType,
                              items: SlabType.values
                                  .map((s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s.arabicLabel,
                                            style: const TextStyle(fontSize: 14)),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  controller.updateDraft((d) => d.copyWith(slabType: val));
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FormLabel('رقم الدور'),
                            _CustomTextField(
                              controller: _floorCtrl,
                              hint: 'أرضي - 0',
                              keyboardType: TextInputType.number,
                              onChanged: (val) => controller.updateDraft(
                                (d) => d.copyWith(floorNumber: int.tryParse(val)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // هل تحتاج مضخة؟ (Pump Switch Container)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSunken,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderWarm),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_shipping_outlined, color: AppColors.brand800, size: 22),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'هل تحتاج مضخة؟',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.ink900,
                            ),
                          ),
                        ),
                        Switch(
                          value: draft.needPump,
                          activeThumbColor: AppColors.brand500,
                          onChanged: (val) =>
                              controller.updateDraft((d) => d.copyWith(needPump: val)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // تاريخ الصب (Date Picker Field)
                  const _FormLabel('تاريخ الصب'),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 18, color: AppColors.ink300),
                          const SizedBox(width: 10),
                          Text(
                            _selectedDate != null
                                ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                                : 'اختر تاريخ الصب (mm/dd/yyyy)',
                            style: TextStyle(
                              fontSize: 14,
                              color: _selectedDate != null
                                  ? AppColors.ink900
                                  : AppColors.ink500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ملاحظات إضافية
                  const _FormLabel('ملاحظات إضافية'),
                  _CustomTextField(
                    controller: _notesCtrl,
                    hint: 'اكتب أي تعليمات خاصة هنا...',
                    maxLines: 3,
                    onChanged: (val) => controller.updateDraft((d) => d.copyWith(notes: val)),
                  ),
                  const SizedBox(height: 22),

                  // Submit Button
                  SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brand800,
                        foregroundColor: AppColors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'إرسال الطلب',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.send_rounded, size: 18),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// تنبيه سطري داخل النموذج — يحلّ محلّ حقل لا يمكن عرضه
/// (لم يُختر مصنع بعد، أو المصنع بلا أنواع خرسانة).
class _InlineNotice extends StatelessWidget {
  const _InlineNotice({
    required this.icon,
    required this.text,
    this.isError = false,
  });

  final IconData icon;
  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final fg = isError ? AppColors.brand800 : AppColors.ink300;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isError ? AppColors.surfaceSoftPink : AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError ? AppColors.borderError : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: fg, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// تقدير التكلفة قبل الإرسال: سعر المصنع للمتر المكعب × الكمية.
class _PriceSummaryCard extends StatelessWidget {
  const _PriceSummaryCard({
    required this.unitPrice,
    required this.quantity,
    required this.total,
  });

  final double unitPrice;
  final double? quantity;
  final double? total;

  @override
  Widget build(BuildContext context) {
    final qty = quantity;
    final sum = total;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderWarm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_rounded, size: 18, color: AppColors.brand800),
              SizedBox(width: 8),
              Text(
                'تقدير التكلفة',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _row(
            'سعر المتر المكعب',
            AppFormat.money(unitPrice),
          ),
          const SizedBox(height: 6),
          _row('الكمية', qty != null ? AppFormat.cubicMetres(qty) : '—'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: AppColors.borderAccent),
          ),
          if (sum != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'الإجمالي التقديري',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink900,
                  ),
                ),
                Text(
                  AppFormat.money(sum),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brand800,
                  ),
                ),
              ],
            )
          else
            const Text(
              'أدخل الكمية (م³) ليُحسب الإجمالي',
              style: TextStyle(fontSize: 12, color: AppColors.ink500),
            ),
          const SizedBox(height: 8),
          const Text(
            'تقدير مبني على سعر المصنع المعلن. يعتمد المصنع السعر النهائي بعد مراجعة الطلب.',
            style: TextStyle(fontSize: 12, color: AppColors.ink500, height: 1.5),
          ),
        ],
      ),
    );
  }

  static Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.ink700),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
      ],
    );
  }
}

class _FormLabel extends StatelessWidget {
  const _FormLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.ink700,
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  const _CustomTextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: AppColors.ink900),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: AppColors.ink200),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}

class _CustomDropdown<T> extends StatelessWidget {
  const _CustomDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 12, color: AppColors.ink200)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.ink300),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}