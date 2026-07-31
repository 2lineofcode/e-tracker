import 'package:flutter/material.dart';
import 'package:uicons_pro/uicons_pro.dart';

class ExpenseCategory {
  final String code;
  final String label;
  final String groupLabel;
  final IconData? icon;
  final Color? color;
  final bool isSystem;
  final int? defaultBudget;

  const ExpenseCategory({
    required this.code,
    required this.label,
    required this.groupLabel,
    this.icon,
    this.color,
    this.isSystem = true,
    this.defaultBudget,
  });
}

/// Wrapper that describes a category group and its children.
class ExpenseCategoryGroup {
  final String label;
  final List<ExpenseCategory> items;

  const ExpenseCategoryGroup({
    required this.label,
    required this.items,
  });
}

/// Master list of supported expense categories grouped for UI consumption.
List<ExpenseCategoryGroup> expenseCategoryGroups = [
  // Kebutuhan Pokok
  ExpenseCategoryGroup(
    label: 'Kebutuhan Pokok',
    items: [
      ExpenseCategory(
        code: 'expense:basic:groceries',
        label: 'Belanja Bulanan',
        groupLabel: 'Kebutuhan Pokok',
        icon: UIconsPro.solidRounded.shopping_basket,
        color: Color(0xFFE9A26A),
      ),
      ExpenseCategory(
        code: 'expense:basic:food',
        label: 'Makan (Restoran, GoFood)',
        groupLabel: 'Kebutuhan Pokok',
        icon: UIconsPro.solidRounded.restaurant,
        color: Color(0xFFD08C60),
      ),
      ExpenseCategory(
        code: 'expense:basic:snacks-coffee',
        label: 'Jajan (Camilan, Kopi)',
        groupLabel: 'Kebutuhan Pokok',
        icon: UIconsPro.solidRounded.coffee,
        color: Color(0xFFF28482),
      ),
      ExpenseCategory(
        code: 'expense:basic:smoke',
        label: 'Rokok / Vape',
        groupLabel: 'Kebutuhan Pokok',
        icon: UIconsPro.solidRounded.smoking,
        color: Color(0xFFB09A8C),
      ),
      ExpenseCategory(
        code: 'expense:basic:housing-rent',
        label: 'Sewa / Cicilan Rumah',
        groupLabel: 'Kebutuhan Pokok',
        icon: UIconsPro.solidRounded.house_chimney,
        color: Color(0xFF6D6875),
      ),
      ExpenseCategory(
        code: 'expense:basic:housing-needs',
        label: 'Kebutuhan Rumah Tangga (Listrik, Air, Laundry, dll)',
        groupLabel: 'Kebutuhan Pokok',
        icon: UIconsPro.solidRounded.plug_circle_bolt,
        color: Color(0xFFB5838D),
      ),
    ],
  ),
  
  ExpenseCategoryGroup(
    label: 'Transportasi',
    items: [
      ExpenseCategory(
        code: 'expense:transport:fuel',
        label: 'Bensin / Bahan Bakar',
        groupLabel: 'Transportasi',
        icon: UIconsPro.solidRounded.gas_pump,
        color: Color(0xFF4D908E),
      ),
      ExpenseCategory(
        code: 'expense:transport:ride-hailing',
        label: 'Transportasi, Taksi / Ojek Online',
        groupLabel: 'Transportasi',
        icon: UIconsPro.solidRounded.taxi,
        color: Color(0xFF43AA8B),
      ),
      ExpenseCategory(
        code: 'expense:transport:parking-toll',
        label: 'Parkir & Tol',
        groupLabel: 'Transportasi',
        icon: UIconsPro.solidRounded.parking_circle,
        color: Color(0xFF43AA8B),
      ),
      ExpenseCategory(
        code: 'expense:transport:maintenance',
        label: 'Servis & Perawatan Kendaraan',
        groupLabel: 'Transportasi',
        icon: UIconsPro.solidRounded.wrench_simple,
        color: Color(0xFF90BE6D),
      ),
    ],
  ),
  
  ExpenseCategoryGroup(
    label: 'Pribadi & Belanja',
    items: [
      ExpenseCategory(
        code: 'expense:personal:apparel',
        label: 'Pakaian & Aksesoris',
        groupLabel: 'Pribadi & Belanja',
        icon: UIconsPro.solidRounded.shirt,
        color: Color(0xFFE26D5C),
      ),
      ExpenseCategory(
        code: 'expense:personal:care',
        label: 'Perawatan Diri (Skincare, Potong Rambut, dll)',
        groupLabel: 'Pribadi & Belanja',
        icon: UIconsPro.solidRounded.spa,
        color: Color(0xFFE5989B),
      ),
      ExpenseCategory(
        code: 'expense:personal:health-supplements',
        label: 'Obat & Suplemen',
        groupLabel: 'Pribadi & Belanja',
        icon: UIconsPro.solidRounded.pills,
        color: Color(0xFF81B29A),
      ),
      ExpenseCategory(
        code: 'expense:personal:education',
        label: 'Pendidikan / Kursus',
        groupLabel: 'Pribadi & Belanja',
        icon: UIconsPro.solidRounded.graduation_cap,
        color: Color(0xFF9A8C98),
      ),
      ExpenseCategory(
        code: 'expense:personal:books',
        label: 'Buku & Majalah',
        groupLabel: 'Pribadi & Belanja',
        icon: UIconsPro.solidRounded.books,
        color: Color(0xFF77628C),
      ),
    ],
  ),
  
  ExpenseCategoryGroup(
    label: 'Hiburan',
    items: [
      ExpenseCategory(
        code: 'expense:entertainment:movies-streaming',
        label: 'Nonton Bioskop / Streaming',
        groupLabel: 'Hiburan',
        icon: UIconsPro.solidRounded.clapperboard_play,
        color: Color(0xFF00B4D8),
      ),
      ExpenseCategory(
        code: 'expense:entertainment:travel',
        label: 'Liburan & Jalan-jalan',
        groupLabel: 'Hiburan',
        icon: UIconsPro.solidRounded.airplane_journey,
        color: Color(0xFF0096C7),
      ),
      ExpenseCategory(
        code: 'expense:entertainment:hobbies',
        label: 'Hobi',
        groupLabel: 'Hiburan',
        icon: UIconsPro.solidRounded.puzzle_piece,
        color: Color(0xFF48CAE4),
      ),
      ExpenseCategory(
        code: 'expense:entertainment:social',
        label: 'Nongkrong, Sosial, Kencan',
        groupLabel: 'Hiburan',
        icon: UIconsPro.solidRounded.users,
        color: Color(0xFF64DFDF),
      ),
      ExpenseCategory(
        code: 'expense:entertainment:games',
        label: 'Game',
        groupLabel: 'Hiburan',
        icon: UIconsPro.solidRounded.gamepad,
        color: Color(0xFF90E0EF),
      ),
    ],
  ),
  
  ExpenseCategoryGroup(
    label: 'Tagihan',
    items: [
      ExpenseCategory(
        code: 'expense:bill:subscription',
        label: 'Tagihan / Langganan',
        groupLabel: 'Tagihan',
        icon: UIconsPro.solidRounded.expense_bill,
        color: Color(0xFFEF476F),
      ),
      ExpenseCategory(
        code: 'expense:bill:insurance',
        label: 'Asuransi',
        groupLabel: 'Tagihan',
        icon: UIconsPro.solidRounded.shield_check,
        color: Color(0xFFE63946),
      ),
      ExpenseCategory(
        code: 'expense:bill:tax',
        label: 'Pajak',
        groupLabel: 'Tagihan',
        icon: UIconsPro.solidRounded.tax,
        color: Color(0xFFEF476F),
      ),
    ],
  ),
  
  ExpenseCategoryGroup(
    label: 'Lain-lain',
    items: [
      ExpenseCategory(
        code: 'expense:misc:gifts-donations',
        label: 'Hadiah & Donasi',
        groupLabel: 'Lain-lain',
        icon: UIconsPro.solidRounded.gift,
        color: Color(0xFF219EBC),
      ),
      ExpenseCategory(
        code: 'expense:misc:household',
        label: 'Alat Rumah Tangga',
        groupLabel: 'Lain-lain',
        icon: UIconsPro.solidRounded.tool_box,
        color: Color(0xFF126782),
      ),
      ExpenseCategory(
        code: 'expense:misc:electronics',
        label: 'Elektronik & Gadget',
        groupLabel: 'Lain-lain',
        icon: UIconsPro.solidRounded.mobile,
        color: Color(0xFF023047),
      ),
      ExpenseCategory(
        code: 'expense:misc:medical',
        label: 'Kesehatan & Dokter',
        groupLabel: 'Lain-lain',
        icon: UIconsPro.solidRounded.stethoscope,
        color: Color(0xFF2A9D8F),
      ),
      ExpenseCategory(
        code: 'expense:misc:family',
        label: 'Keluarga',
        groupLabel: 'Lain-lain',
        icon: UIconsPro.solidRounded.family,
        color: Color(0xFF8ECAE6),
      ),
      ExpenseCategory(
        code: 'notes',
        label: 'Note',
        groupLabel: 'Lain-lain',
        icon: UIconsPro.solidRounded.note,
        color: Color(0xFFE9EDC9),
      ),
    ],
  ),
  
  ExpenseCategoryGroup(
    label: 'Belum diketahui',
    items: [
      ExpenseCategory(
        code: 'expense:unknown',
        label: 'Belum diketahui',
        groupLabel: 'Belum diketahui',
        icon: UIconsPro.solidRounded.question,
        color: Color(0xFFEAEDC9),
      ),
    ],
  ),
];

/// Flattened list of categories for quick iteration (e.g. dropdowns).
final List<ExpenseCategory> expenseCategoryList = expenseCategoryGroups.expand((group) => group.items).toList(growable: false);

/// Lookup map by category code.
final Map<String, ExpenseCategory> expenseCategoryByCode = {
  for (final item in expenseCategoryList) item.code: item,
};

/// Lookup map by normalized label for backwards compatibility.
final Map<String, ExpenseCategory> expenseCategoryByLabel = {
  for (final item in expenseCategoryList) item.label.toLowerCase(): item,
  'belanja bulanan (groceries)': expenseCategoryByCode['expense:basic:groceries']!,
  'makan (restaurants, gofood)': expenseCategoryByCode['expense:basic:food']!,
  'jajan (snacks, coffee)': expenseCategoryByCode['expense:basic:snacks-coffee']!,
  'liburan & traveling': expenseCategoryByCode['expense:entertainment:travel']!,
  'hangout, sosial, dating': expenseCategoryByCode['expense:entertainment:social']!,
  'bill / subscription': expenseCategoryByCode['expense:bill:subscription']!,
  'notes': expenseCategoryByCode['notes']!,
  'catatan': expenseCategoryByCode['notes']!,
  'unknown': expenseCategoryByCode['expense:unknown']!,
};

/// Provides a safe fallback for unknown category codes.
final ExpenseCategory _unknownExpenseCategory = ExpenseCategory(
  code: 'expense:unknown',
  label: 'Belum diketahui',
  groupLabel: 'Belum diketahui',
  icon: UIconsPro.solidRounded.question_square,
  color: Color(0xFF9AA5B1),
  isSystem: true,
);

ExpenseCategory get unknownExpenseCategory => _unknownExpenseCategory;

ExpenseCategory resolveExpenseCategory(String? code) {
  if (code == null || code.isEmpty) return unknownExpenseCategory;
  final normalized = code.toLowerCase();
  final direct = expenseCategoryByCode[code] ?? expenseCategoryByCode[normalized];
  if (direct != null) return direct;
  return expenseCategoryByCode[normalized] ?? expenseCategoryByLabel[normalized] ?? unknownExpenseCategory;
}
