import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class EmployeDetails extends StatefulWidget {
  const EmployeDetails({super.key});

  @override
  State<EmployeDetails> createState() => _EmployeDetailsState();
}

class _EmployeDetailsState extends State<EmployeDetails> {
  int presentDays = 0;
  int absentDays = 0;
  int perDaySalary = 500;
  int totalPaidAmount = 0;

  // Sample data, replace with actual data loading
  void loadEmployeeData() {
    setState(() {
      presentDays = 20;
      absentDays = 10;
    });
  }

  @override
  void initState() {
    super.initState();
    loadEmployeeData();
  }

  int calculateTotalSalary() {
    return presentDays * perDaySalary;
  }

  int calculatePendingAmount() {
    return calculateTotalSalary() - totalPaidAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Attendance Summary",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              AspectRatio(
                aspectRatio: 1.5,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceEvenly,
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            switch (value.toInt()) {
                              case 0:
                                return const Text("Present");
                              case 1:
                                return const Text("Absent");
                              default:
                                return const Text("");
                            }
                          },
                        ),
                      ),
                    ),
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            toY: presentDays.toDouble(),
                            color: Colors.green,
                            width: 30,
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: absentDays.toDouble(),
                            color: Colors.red,
                            width: 30,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Salary Details",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    "Per Day Salary: ",
                    style: TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        perDaySalary += 50;
                      });
                    },
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                  ),
                  Text(
                    "₹ $perDaySalary",
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (perDaySalary > 50) perDaySalary -= 50;
                      });
                    },
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Salary: ₹ ${calculateTotalSalary()}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    "Paid: ₹ $totalPaidAmount",
                    style: const TextStyle(fontSize: 18, color: Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    totalPaidAmount = int.tryParse(value) ?? 0;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Enter Paid Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Pending Amount: ₹ ${calculatePendingAmount()}",
                style: const TextStyle(fontSize: 18, color: Colors.redAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
