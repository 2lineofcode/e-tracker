import 'package:expense_tracker/app/modules/home/home_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cash until payday excludes pay-cycle spending and scheduled bills', () {
    expect(calculateCashUntilPayday(10000000, 2500000, 1500000), 6000000);
    expect(payCycleStartAt(DateTime(2026, 8, 1), 28), DateTime(2026, 7, 28));
    expect(nextPaydayAt(DateTime(2026, 8, 28), 28), DateTime(2026, 9, 28));
    expect(
      dailyExpenseTotals({
        DateTime(2026, 7, 2): ['100000', '50000'],
        DateTime(2026, 8, 2): ['999999'],
      }, DateTime(2026, 7)),
      hasLength(31),
    );
    expect(
      dailyExpenseTotals({
        DateTime(2026, 7, 2): ['100000', '50000'],
      }, DateTime(2026, 7))[1],
      150000,
    );
    final stats = monthlyExpenseStats([0, 100000, 0, 300000]);
    expect(stats.activeDays, 2);
    expect(stats.average, 200000);
    expect(stats.highest, 300000);
    expect(stats.highestDay, 4);
    expect(
      weeklyExpenseTotals([100000, 200000, 0, 0, 0, 0, 0, 400000]),
      [300000, 400000],
    );
  });
}
