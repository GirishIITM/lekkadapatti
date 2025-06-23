import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lekkadapatti/utils/ui/attendance_manager.dart';

class EmployeDetails extends StatefulWidget {
  final String name;
  final AttendanceManager attendanceManager;

  const EmployeDetails({
    super.key, 
    required this.name,
    required this.attendanceManager,
  });

  @override
  State<EmployeDetails> createState() => _EmployeDetailsState();
}

class _EmployeDetailsState extends State<EmployeDetails> {
  Map<String, int> attendanceStats = {};
  int perDaySalary = 500;
  double totalPaidAmount = 0.0;
  List<Map<String, dynamic>> paymentHistory = [];
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadEmployeeData();
  }

  void loadEmployeeData() {
    setState(() {
      attendanceStats = widget.attendanceManager.getAttendanceStats(widget.name);
      totalPaidAmount = widget.attendanceManager.getTotalPaidAmount(widget.name);
      paymentHistory = widget.attendanceManager.getPaymentHistory(widget.name);
    });
  }

  int calculateTotalSalary() {
    final present = attendanceStats['present'] ?? 0;
    final halfDay = attendanceStats['halfDay'] ?? 0;
    return (present * perDaySalary) + ((halfDay * perDaySalary) ~/ 2);
  }

  double calculatePendingAmount() {
    return calculateTotalSalary() - totalPaidAmount;
  }

  void _showAddPaymentDialog() {
    _amountController.clear();
    _noteController.clear();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(_amountController.text);
              if (amount != null && amount > 0) {
                widget.attendanceManager.addPayment(
                  employeName: widget.name,
                  amount: amount,
                  note: _noteController.text,
                  setState: setState,
                );
                loadEmployeeData();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditPaymentDialog(Map<String, dynamic> payment) {
    _amountController.text = payment['amount'].toString();
    _noteController.text = payment['note'] ?? '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(_amountController.text);
              if (amount != null && amount > 0) {
                widget.attendanceManager.editPayment(
                  employeName: widget.name,
                  paymentId: payment['id'],
                  newAmount: amount,
                  newNote: _noteController.text,
                  setState: setState,
                );
                loadEmployeeData();
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
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
                              case 2:
                                return const Text("Half Day");
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
                            toY: (attendanceStats['present'] ?? 0).toDouble(),
                            color: Colors.green,
                            width: 30,
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: (attendanceStats['absent'] ?? 0).toDouble(),
                            color: Colors.red,
                            width: 30,
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 2,
                        barRods: [
                          BarChartRodData(
                            toY: (attendanceStats['halfDay'] ?? 0).toDouble(),
                            color: Colors.orange,
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
                    "Paid: ₹ ${totalPaidAmount.toStringAsFixed(0)}",
                    style: const TextStyle(fontSize: 18, color: Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "Pending Amount: ₹ ${calculatePendingAmount().toStringAsFixed(0)}",
                style: const TextStyle(fontSize: 18, color: Colors.redAccent),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Payment History",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddPaymentDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Payment'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              paymentHistory.isEmpty
                  ? const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'No payment history available',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: paymentHistory.length,
                      itemBuilder: (context, index) {
                        final payment = paymentHistory[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.payment, color: Colors.green),
                            title: Text('₹ ${payment['amount'].toStringAsFixed(0)}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Date: ${payment['date']}'),
                                if (payment['note'] != null && payment['note'].isNotEmpty)
                                  Text('Note: ${payment['note']}'),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: const Text('Edit'),
                                  onTap: () => _showEditPaymentDialog(payment),
                                ),
                                PopupMenuItem(
                                  child: const Text('Delete'),
                                  onTap: () {
                                    widget.attendanceManager.deletePayment(
                                      employeName: widget.name,
                                      paymentId: payment['id'],
                                      setState: setState,
                                    );
                                    loadEmployeeData();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
