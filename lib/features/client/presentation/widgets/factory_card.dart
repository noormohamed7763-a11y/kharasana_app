import 'package:flutter/material.dart';
import '../../../factories/data/models/factory_dto.dart';

class FactoryCard extends StatelessWidget {
  const FactoryCard({super.key, required this.factory, this.onTap});

  final FactoryDto factory;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEFE5DC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Name, Active Badge & Logo
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Factory Info (Name, Owner)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Active status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: factory.isActive ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        factory.isActive ? 'نشط' : 'غير نشط',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: factory.isActive ? const Color(0xFF2E7D32) : const Color(0xFF757575),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      factory.factoryName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C221E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (factory.ownerName != null && factory.ownerName!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'المالك: ${factory.ownerName}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF7A685E),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Factory Logo / Icon Container
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9EDE2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEEDCD0)),
                ),
                child: const Center(
                  child: Icon(
                    Icons.factory_rounded,
                    color: Color(0xFF8A3C04),
                    size: 28,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF0E5DC)),
          const SizedBox(height: 12),

          // Location & Phone
          Row(
            children: [
              if (factory.area != null || factory.address != null) ...[
                const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF8C7A70)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    factory.area ?? factory.address ?? '',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF7A685E)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              if (factory.phone != null) ...[
                const SizedBox(width: 12),
                const Icon(Icons.phone_outlined, size: 16, color: Color(0xFF8C7A70)),
                const SizedBox(width: 4),
                Text(
                  factory.phone!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7A685E),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 14),

          // Full width orange button "عرض التفاصيل >"
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE65100),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'عرض التفاصيل',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.chevron_left_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}