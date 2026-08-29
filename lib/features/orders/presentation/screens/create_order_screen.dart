import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/api_enums.dart';
import '../../../client/presentation/widgets/client_bottom_nav_bar.dart';
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
              primary: Color(0xFFE65100),
              onPrimary: Colors.white,
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار نوع الخرسانة')),
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
          SnackBar(content: Text('❌ $message')),
        );
      case SubmissionInProgress():
      case SubmissionIdle():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final factoriesAsync = ref.watch(factoriesListProvider);
    final concreteTypesAsync = ref.watch(concreteTypesListProvider);
    final draft = ref.watch(orderCreationControllerProvider(widget.initialFactoryId));
    final controller = ref.read(orderCreationControllerProvider(widget.initialFactoryId).notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFFCF7F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'طلب خرسانة جديد',
          style: TextStyle(
            color: Color(0xFF9E4A06),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF5A4A42)),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Color(0xFF9E4A06)),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      bottomNavigationBar: const ClientBottomNavBar(currentIndex: 0),
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
                    color: Colors.black.withValues(alpha: 0.1),
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
                              Colors.black.withValues(alpha: 0.25),
                              Colors.black.withValues(alpha: 0.75),
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
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'أدخل تفاصيل الصبة والكميات المطلوبة بدقة',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.88),
                              fontSize: 12.5,
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEFE5DC)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
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
                                child: Text(f.factoryName, style: const TextStyle(fontSize: 13.5)),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val == null) return;
                        final selectedFactory = factories.firstWhere((f) => f.factoryId == val);
                        controller.updateDraft((d) => d.copyWith(
                              factoryId: val,
                              factoryName: selectedFactory.factoryName,
                            ));
                      },
                    ),
                    loading: () => const Center(child: LinearProgressIndicator()),
                    error: (_, __) => const Text('تعذر تحميل المصانع'),
                  ),
                  const SizedBox(height: 14),

                  // نوع الخرسانة (Concrete Type Dropdown)
                  const _FormLabel('نوع الخرسانة'),
                  concreteTypesAsync.when(
                    data: (types) => _CustomDropdown<int>(
                      hint: 'اختر النوع...',
                      value: draft.concreteTypeId,
                      items: types
                          .map((t) => DropdownMenuItem(
                                value: t.concreteTypeId,
                                child: Text('${t.name} (قوة ${t.strength})',
                                    style: const TextStyle(fontSize: 13.5)),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val == null) return;
                        final selectedType = types.firstWhere((t) => t.concreteTypeId == val);
                        controller.updateDraft((d) => d.copyWith(
                              concreteTypeId: val,
                              concreteTypeName: selectedType.name,
                              concreteUnitPrice: selectedType.unitPrice,
                            ));
                      },
                    ),
                    loading: () => const Center(child: LinearProgressIndicator()),
                    error: (_, __) => const Text('تعذر تحميل أنواع الخرسانة'),
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
                              onChanged: (val) => controller.updateDraft(
                                (d) => d.copyWith(quantity: double.tryParse(val)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

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
                                            style: const TextStyle(fontSize: 13.5)),
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
                      color: const Color(0xFFF9EDE2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFEEDCD0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_shipping_outlined, color: Color(0xFF8A3C04), size: 22),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'هل تحتاج مضخة؟',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C221E),
                            ),
                          ),
                        ),
                        Switch(
                          value: draft.needPump,
                          activeThumbColor: const Color(0xFFE65100),
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
                        color: const Color(0xFFFAF4EE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEFE5DC)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 18, color: Color(0xFF8C7A70)),
                          const SizedBox(width: 10),
                          Text(
                            _selectedDate != null
                                ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                                : 'اختر تاريخ الصب (mm/dd/yyyy)',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: _selectedDate != null
                                  ? const Color(0xFF2C221E)
                                  : const Color(0xFF8C7A70),
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
                        backgroundColor: const Color(0xFF8A3C04),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
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
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF5A4A42),
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
        color: const Color(0xFFFAF4EE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEFE5DC)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13.5, color: Color(0xFF2C221E)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFFA08E84)),
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
        color: const Color(0xFFFAF4EE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEFE5DC)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 12.5, color: Color(0xFFA08E84))),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF8C7A70)),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}