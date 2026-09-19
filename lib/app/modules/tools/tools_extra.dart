import 'dart:math' as math;

class ToolInput {
  const ToolInput(this.key, this.label, {this.initial = '', this.unit = 'money', this.min = 0, this.max = 999999999999});
  final String key;
  final String label;
  final String initial;
  final String unit;
  final num min;
  final num max;
}

class ToolOutput {
  const ToolOutput(this.label, this.value, {this.unit = 'money'});
  final String label;
  final Object value;
  final String unit;
}

class ExtraTool {
  const ExtraTool(this.id, this.title, this.inputs, this.note, this.calculate);
  final String id;
  final String title;
  final List<ToolInput> inputs;
  final String note;
  final List<ToolOutput> Function(Map<String, num>) calculate;
}

const extraTools = [
  ExtraTool('saving', 'Target tabungan', [
    ToolInput('target', 'Target dana', min: 1),
    ToolInput('saved', 'Saldo saat ini', initial: '0'),
    ToolInput('months', 'Tenggat dari sekarang', initial: '12', unit: 'bulan', min: 1, max: 600),
  ], 'Setoran tetap setiap bulan, tanpa imbal hasil.', _saving),
  ExtraTool('loan', 'Cicilan pinjaman', [
    ToolInput('principal', 'Pokok pinjaman', min: 1),
    ToolInput('rate', 'Bunga nominal per tahun', initial: '0', unit: '%', max: 100),
    ToolInput('months', 'Tenor', initial: '12', unit: 'bulan', min: 1, max: 600),
  ], 'Anuitas dengan bunga tetap atas sisa pokok, bunga bulanan = tahunan ÷ 12. Belum termasuk biaya/asuransi.', _loan),
  ExtraTool('debt', 'Pelunasan utang', [
    ToolInput('balance', 'Sisa utang', min: 1),
    ToolInput('rate', 'Bunga nominal per tahun', initial: '0', unit: '%', max: 100),
    ToolInput('payment', 'Pembayaran bulanan', min: 1),
    ToolInput('extra', 'Tambahan bayar per bulan', initial: '0'),
  ], 'Bunga atas sisa utang, pembayaran akhir bulan. Tanpa utang baru atau penalti pelunasan; maksimal simulasi 600 bulan.', _debt),
  ExtraTool('investment', 'Pertumbuhan investasi', [
    ToolInput('initial', 'Modal awal', initial: '0'),
    ToolInput('monthly', 'Setoran per bulan', initial: '0'),
    ToolInput('years', 'Durasi investasi', initial: '10', unit: 'tahun', min: 1, max: 100),
    ToolInput('rate', 'Return bersih per tahun', initial: '0', unit: '%', min: -20, max: 20),
  ], 'Return tahunan efektif setelah biaya/pajak, setoran tetap di akhir bulan. Proyeksi nominal, bukan jaminan.', _investment),
  ExtraTool('education', 'Dana pendidikan', [
    ToolInput('cost', 'Total biaya pendidikan saat ini', min: 1),
    ToolInput('years', 'Waktu sampai masuk sekolah/kuliah', initial: '5', unit: 'tahun', min: 0, max: 50),
    ToolInput('rate', 'Kenaikan biaya per tahun', initial: '0', unit: '%', max: 30),
    ToolInput('saved', 'Dana pendidikan saat ini', initial: '0'),
  ], 'Total biaya naik majemuk setiap tahun; tabungan tanpa imbal hasil. Isi seluruh biaya yang ingin disiapkan.', _education),
  ExtraTool('house', 'Dana beli rumah', [
    ToolInput('price', 'Harga rumah saat pembelian', min: 1),
    ToolInput('down', 'Uang muka', initial: '20', unit: '%', max: 100),
    ToolInput('fees', 'Biaya tambahan pembelian', initial: '0'),
    ToolInput('saved', 'Dana tersedia', initial: '0'),
    ToolInput('months', 'Tenggat dari sekarang', initial: '24', unit: 'bulan', min: 1, max: 600),
  ], 'Target uang muka + biaya tambahan yang kamu isi. Tanpa kenaikan harga dan imbal hasil; sisa harga rumah belum termasuk bunga kredit.', _house),
  ExtraTool('budget', 'Budget bulanan', [
    ToolInput('income', 'Pendapatan bersih bulanan', min: 1),
    ToolInput('needs', 'Kebutuhan wajib (di luar cicilan)', initial: '0'),
    ToolInput('debt', 'Cicilan bulanan', initial: '0'),
    ToolInput('saving', 'Target tabungan bulanan', initial: '0'),
  ], 'Sisa budget = pendapatan − kebutuhan wajib − cicilan − tabungan. Hindari menghitung pengeluaran yang sama dua kali.', _budget),
  ExtraTool('usage', 'Harga per pemakaian', [
    ToolInput('price', 'Harga barang', min: 1),
    ToolInput('frequency', 'Pemakaian per bulan', initial: '4', unit: 'kali', min: 1, max: 10000),
    ToolInput('months', 'Lama pemakaian', initial: '12', unit: 'bulan', min: 1, max: 600),
  ], 'Frekuensi tetap; belum termasuk biaya perawatan atau nilai jual kembali.', _usage),
];

List<ToolOutput> calculateExtraTool(ExtraTool tool, Map<String, num> values) {
  for (final input in tool.inputs) {
    final value = values[input.key];
    if (value == null || !value.isFinite || value < input.min || value > input.max ||
        (input.unit != '%' && value != value.truncateToDouble())) {
      throw ArgumentError('Invalid ${tool.id}.${input.key}');
    }
  }
  return tool.calculate(values);
}

List<ToolOutput> _saving(Map<String, num> v) => _savingPlan(v['target']!, v['saved']!, v['months']!.toInt());

List<ToolOutput> _savingPlan(num target, num saved, int months) {
  final remaining = math.max(0, target - saved);
  return [
    ToolOutput('Target dana', target),
    ToolOutput('Kekurangan dana', remaining),
    ToolOutput('Setoran per bulan', remaining == 0 ? 0 : months == 0 ? 'Perlu dana langsung' : (remaining / months).ceilToDouble()),
  ];
}

List<ToolOutput> _loan(Map<String, num> v) {
  final principal = v['principal']!;
  final months = v['months']!.toInt();
  final rate = v['rate']! / 1200;
  final payment = rate == 0 ? principal / months : principal * rate / (1 - math.pow(1 + rate, -months));
  final total = payment * months;
  return [
    ToolOutput('Cicilan per bulan', payment),
    ToolOutput('Total bunga', math.max(0, total - principal)),
    ToolOutput('Total pembayaran', total),
  ];
}

({int months, num interest, num total})? _payoff(num balance, num rate, num payment) {
  if (payment <= balance * rate) return null;
  num interest = 0;
  num total = 0;
  for (var month = 1; month <= 600; month++) {
    final charge = balance * rate;
    final paid = math.min(payment, balance + charge);
    interest += charge;
    total += paid;
    balance += charge - paid;
    if (balance <= 0.000001) return (months: month, interest: interest, total: total);
  }
  return null;
}

List<ToolOutput> _debt(Map<String, num> v) {
  final rate = v['rate']! / 1200;
  final normal = _payoff(v['balance']!, rate, v['payment']!);
  final faster = _payoff(v['balance']!, rate, v['payment']! + v['extra']!);
  if (faster == null) {
    return [const ToolOutput('Status', 'Pembayaran belum cukup untuk lunas dalam 600 bulan. Tambah pembayaran bulanan.')];
  }
  return [
    ToolOutput('Waktu lunas dengan tambahan', faster.months, unit: 'bulan'),
    ToolOutput('Total bunga dengan tambahan', faster.interest),
    ToolOutput('Total pembayaran dengan tambahan', faster.total),
    if (normal != null) ...[
      ToolOutput('Waktu lunas tanpa tambahan', normal.months, unit: 'bulan'),
      ToolOutput('Lebih cepat', normal.months - faster.months, unit: 'bulan'),
      ToolOutput('Hemat bunga', math.max(0, normal.interest - faster.interest)),
    ] else const ToolOutput('Tanpa tambahan', 'Belum lunas dalam 600 bulan'),
  ];
}

List<ToolOutput> _investment(Map<String, num> v) {
  final months = v['years']!.toInt() * 12;
  final growth = math.pow(1 + v['rate']! / 100, 1 / 12);
  num balance = v['initial']!;
  for (var month = 0; month < months; month++) {
    balance = balance * growth + v['monthly']!;
  }
  final capital = v['initial']! + v['monthly']! * months;
  return [
    ToolOutput('Proyeksi saldo akhir', balance),
    ToolOutput('Total modal disetor', capital),
    ToolOutput('Estimasi keuntungan / kerugian', balance - capital),
  ];
}

List<ToolOutput> _education(Map<String, num> v) {
  final target = v['cost']! * math.pow(1 + v['rate']! / 100, v['years']!);
  return _savingPlan(target, v['saved']!, v['years']!.toInt() * 12);
}

List<ToolOutput> _house(Map<String, num> v) {
  final down = v['price']! * v['down']! / 100;
  return [
    ..._savingPlan(down + v['fees']!, v['saved']!, v['months']!.toInt()),
    ToolOutput('Uang muka rumah', down),
    ToolOutput('Sisa harga rumah', v['price']! - down),
  ];
}

List<ToolOutput> _budget(Map<String, num> v) {
  final allocated = v['needs']! + v['debt']! + v['saving']!;
  final remaining = v['income']! - allocated;
  return [
    ToolOutput(remaining < 0 ? 'Defisit bulanan' : 'Sisa budget bulanan', remaining.abs()),
    ToolOutput('Total alokasi', allocated),
    ToolOutput('Porsi tabungan', v['saving']! / v['income']! * 100, unit: '%'),
    ToolOutput('Porsi cicilan', v['debt']! / v['income']! * 100, unit: '%'),
  ];
}

List<ToolOutput> _usage(Map<String, num> v) {
  final uses = v['frequency']! * v['months']!;
  return [
    ToolOutput('Biaya per pemakaian', v['price']! / uses),
    ToolOutput('Total pemakaian', uses, unit: 'kali'),
    ToolOutput('Biaya rata-rata per bulan', v['price']! / v['months']!),
  ];
}
