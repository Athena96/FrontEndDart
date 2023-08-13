import 'dart:math';

import '../constants.dart';
import '../data/price_point.dart';
import '../model/Recurring.dart';
import '../model/charge_type.dart';
import '../model/one_time.dart';

class AnnualExpensesIncome {
  final int startAge;
  final int endAge;
  final double annualExpensesIncome;

  AnnualExpensesIncome({
    required this.startAge,
    required this.endAge,
    required this.annualExpensesIncome,
  });

  @override
  String toString() {
    return 'AnnualExpensesIncome(startAge: $startAge, endAge: $endAge, annualExpensesIncome: $annualExpensesIncome)';
  }
}

class MonteCarloResults {
  final List<PricePoint> medianLine;
  final double successPercent;

  MonteCarloResults({required this.medianLine, required this.successPercent});
}

class MonteCarloService {

  // Number of simulations to run
  final int numberOfSimulations;

  // Constructor to initialize the number of simulations
  MonteCarloService({required this.numberOfSimulations});

  List<AnnualExpensesIncome> getAnnualSpendingIncome(
      List<Recurring> recurrings) {
    final List<AnnualExpensesIncome> expIncome = [];
    for (final recurring in recurrings) {
      expIncome.add(AnnualExpensesIncome(
        startAge: recurring.startAge,
        endAge: recurring.endAge,
        annualExpensesIncome: getIncomeExpenseFromRecurring(recurring) * 12.0,
      ));
    }
    return expIncome;
  }

  Map<int, double> convertOneTimesToMap(List<OneTime> oneTimes) {
    final Map<int, double> m = {};
    for (final oneTime in oneTimes) {
      if (oneTime.chargeType == ChargeType.EXPENSE) {
        m[oneTime.age] = (m[oneTime.age] ?? 0.0) - oneTime.lineItem.amount;
      } else {
        m[oneTime.age] = (m[oneTime.age] ?? 0.0) + oneTime.lineItem.amount;
      }
    }
    return m;
  }

  double getIncomeExpenseFromRecurring(Recurring recurring) {
    double v = 0;
    for (var i in recurring.lineItems) {
      if (recurring.chargeType == ChargeType.EXPENSE) {
        v -= i.amount; // Assuming getValue is a method in LineItem
      } else {
        v += i.amount; // Assuming getValue is a method in LineItem
      }
    }
    return v;
  }

  List<double> getNormalDistributionOfReturns(
      double mean, double variance, int size) {
    final random = Random();
    final List<double> sample = [];

    for (int i = 0; i < size; i++) {
      final u1 = random.nextDouble();
      final u2 = random.nextDouble();

      final z0 = sqrt(-2 * log(u1)) * cos(2 * pi * u2);
      final z1 = sqrt(-2 * log(u1)) * sin(2 * pi * u2);

      sample.add((mean + sqrt(variance) * z0) / 100.0);
      sample.add((mean + sqrt(variance) * z1) / 100.0);
    }

    return sample.sublist(0, size); // In case size is odd
  }

  List<double> adjustForFees(List<double> returns, double fees) {
    final List<double> adjustedReturns = [];
    for (int i = 0; i < returns.length; i++) {
      adjustedReturns.add(double.parse((returns[i] - fees).toStringAsFixed(3)));
    }
    return adjustedReturns;
  }

  List<double> getIncomesAndExpenses(
    int timeline,
    List<AnnualExpensesIncome> incomeExpList,
    int startingAge,
    Map<int, double> oneTime,
  ) {
    final List<double> incomesAndExpenses = [];
    for (int i = 0; i < timeline; i++) {
      final int currAge = startingAge + i;
      final double oneTimeExpensesIncome = oneTime[currAge] ?? 0.0;

      double sum = oneTimeExpensesIncome;
      for (final incomeExp in incomeExpList) {
        if (currAge >= incomeExp.startAge && currAge <= incomeExp.endAge) {
          sum +=
              double.parse(incomeExp.annualExpensesIncome.toStringAsFixed(2));
        }
      }

      incomesAndExpenses.add(sum);
    }
    return incomesAndExpenses;
  }

  double getPercentile(List<double> values, double percent) {
    final int percentileIdx = (values.length * percent).floor();
    return values[percentileIdx];
  }

  List<double> getColumnFromMatrix(List<List<double>> matrix, int colIdx) {
    final List<double> col = [];
    for (int i = 0; i < matrix.length; i++) {
      col.add(matrix[i][colIdx]);
    }
    return col;
  }

  List<double> calculateFutureValue(
    double startingBalance,
    List<double> annualInterestRates,
    List<double> annualIncomesAndExpenses,
    double currentYearProgress,
  ) {
    final double remainingYearProgress = 1.0 - currentYearProgress;
    final List<double> projection = [];
    double futureValue = startingBalance;
    for (int i = 0; i < annualInterestRates.length; i++) {
      if (i == 0) {
        futureValue = futureValue +
            futureValue * annualInterestRates[i] +
            annualIncomesAndExpenses[i] * remainingYearProgress;
      } else {
        futureValue = futureValue +
            futureValue * annualInterestRates[i] +
            annualIncomesAndExpenses[i];
      }
      projection.add(futureValue);
    }
    return projection;
  }

  // Simulate method to run the Monte Carlo simulation
  MonteCarloResults simulate(
      {required double mean,
      required double variance,
      required List<Recurring> recurrings,
      required List<OneTime> oneTimes,
      required int numberOfYears,
      required double startingBalance,
      required int numberOfSimulations,
      required int startAge,
      required DateTime currentDate}) {
    Map<int, double> oneTimeMap = convertOneTimesToMap(oneTimes);

    List<AnnualExpensesIncome> annualContribution =
        getAnnualSpendingIncome(recurrings);

    double current_year_progress = (currentDate.month + 1) / 12.0;
    int successCount = 0;

    List<List<double>> simulationData =
        List.generate(numberOfSimulations, (i) => []);

    for (int i = 0; i < numberOfSimulations; i++) {

      var distributionOfReturns =
          getNormalDistributionOfReturns(mean, variance, numberOfYears);
      var effectiveDistOfReturns = adjustForFees(distributionOfReturns, FEES);
      var incomesAndExpenses = getIncomesAndExpenses(
          numberOfYears, annualContribution, startAge, oneTimeMap);

      // generate projection
      var projection = calculateFutureValue(startingBalance,
          effectiveDistOfReturns, incomesAndExpenses, current_year_progress);
      simulationData[i] = [];
      for (int id = 0; id < projection.length; id++) {
        simulationData[i].add(projection[id]);
      }

      // success percent
      if (projection[projection.length - 1] > 0) {
        successCount += 1;
      }
    }

    // List<double> twoFive = [];
    List<PricePoint> medLine = [];
    // List<double> sevenFive = [];
    // List<double> nineFive = [];

    for (int k = 0; k < numberOfYears; k++) {
      List<double> col = getColumnFromMatrix(simulationData, k);
      col.sort((a, b) => a.compareTo(b));

      List<double> adjCol = [];
      for (int l = 0; l < col.length; l++) {
        adjCol.add(col[l]);
      }

      // double tf = getPercentile(adjCol, 0.25);
      double med = getPercentile(adjCol, 0.5);
      // double sf = getPercentile(adjCol, 0.75);
      // double nf = getPercentile(adjCol, 0.95);
      // twoFive.add(tf);
      medLine.add(PricePoint(x: k.toDouble(), y: med));
      // sevenFive.add(sf);
      // nineFive.add(nf);
    }

    MonteCarloResults results = MonteCarloResults(
      successPercent: (successCount / numberOfSimulations) * 100.0,
      medianLine: medLine,
    );

    return results;
  }
}