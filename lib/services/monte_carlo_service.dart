import 'dart:math';

import '../constants.dart';
import '../data/price_point.dart';
import '../model/Recurring.dart';
import '../model/charge_type.dart';
import '../model/one_time.dart';
import '../utils.dart';

class MonteCarloServiceRequest {
  final List<OneTime> oneTimes;
  final List<Recurring> recurrings;
  final int period;
  final double startingBalance;
  final DateTime currentDate;
  final int currentAge;
  final double mean;
  final double variance;
  final double fees;
  final int numberOfSimulations;

  MonteCarloServiceRequest({
    required this.oneTimes,
    required this.recurrings,
    required this.period,
    required this.startingBalance,
    required this.currentDate,
    required this.currentAge,
    required this.mean,
    required this.variance,
    required this.fees,
    required this.numberOfSimulations,
  });
}

class MonteCarloServiceResponse {
  final List<PricePoint> median;
  final double successPercent;

  MonteCarloServiceResponse({
    required this.median,
    required this.successPercent,
  });

  List<PricePoint> getMedian() {
    return median;
  }

  double getSuccessPercent() {
    return successPercent;
  }
}

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
        annualExpensesIncome: getLineItemsTotalFromRecurring(recurring) * 12.0,
      ));
    }
    return expIncome;
  }

  double getLineItemsTotalFromRecurring(Recurring recurring) {
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
  MonteCarloServiceResponse getMonteCarloResponse(
      {required MonteCarloServiceRequest request}) {
    Map<int, double> oneTimeMap =
        OneTime.convertOneTimesToMap(request.oneTimes);

    List<AnnualExpensesIncome> annualContribution =
        getAnnualSpendingIncome(request.recurrings);

    double current_year_progress = (request.currentDate.month + 1) / 12.0;
    int successCount = 0;

    List<List<double>> simulationData =
        List.generate(numberOfSimulations, (i) => []);

    for (int i = 0; i < numberOfSimulations; i++) {
      var distributionOfReturns = getNormalDistributionOfReturns(
          request.mean, request.variance, request.period);
      var effectiveDistOfReturns = adjustForFees(distributionOfReturns, FEES);
      var incomesAndExpenses = getIncomesAndExpenses(
          request.period, annualContribution, request.currentAge, oneTimeMap);

      // generate projection
      var projection = calculateFutureValue(request.startingBalance,
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

    for (int k = 0; k < request.period; k++) {
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

    MonteCarloServiceResponse response = MonteCarloServiceResponse(
      successPercent: (successCount / numberOfSimulations) * 100.0,
      median: medLine,
    );

    return response;
  }
}
