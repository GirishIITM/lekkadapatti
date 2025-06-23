import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lekkadapatti/utils/ui/attendance_manager.dart';

class GroupDetails extends StatefulWidget {
  final String groupName;
  final AttendanceManager attendanceManager;

  const GroupDetails({
    super.key,
    required this.groupName,
    required this.attendanceManager,
  });

  @override
  State<GroupDetails> createState() => _GroupDetailsState();
}

class _GroupDetailsState extends State<GroupDetails> {
  Map<String, int> groupStats = {};
  double totalPaidAmount = 0.0;
  List<Map<String, dynamic>> paymentHistory = [];
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  Map<String, int> groupRates = {"male": 200, "female": 200};

  @override
  void initState() {
    super.initState();
    loadGroupData();
  }

  void loadGroupData() {
    setState(() {
      groupStats = widget.attendanceManager.getGroupStats(widget.groupName);
      totalPaidAmount = widget.attendanceManager.getTotalGroupPaidAmount(widget.groupName);
      paymentHistory = widget.attendanceManager.getGroupPaymentHistory(widget.groupName);
      groupRates = widget.attendanceManager.getGroupRates(widget.groupName);
    });
  }

  int calculateTotalAmount() {
    final maleCount = groupStats['male'] ?? 0;
    final femaleCount = groupStats['female'] ?? 0;
    final maleRate = groupRates['male'] ?? 200;
    final femaleRate = groupRates['female'] ?? 200;
    return (maleCount * maleRate) + (femaleCount * femaleRate);
  }

  double calculatePendingAmount() {
    return calculateTotalAmount() - totalPaidAmount;
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
                widget.attendanceManager.addGroupPayment(
                  groupName: widget.groupName,
                  amount: amount,
                  note: _noteController.text,
                  setState: setState,
                );
                loadGroupData();
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
                widget.attendanceManager.editGroupPayment(
                  groupName: widget.groupName,
                  paymentId: payment['id'],
                  newAmount: amount,
                  newNote: _noteController.text,
                  setState: setState,
                );
                loadGroupData();
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
        title: Text(widget.groupName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Group Statistics",
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
                                return const Text("Male");
                              case 1:
                                return const Text("Female");
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
                            toY: (groupStats['male'] ?? 0).toDouble(),
                            color: Colors.blue,
                            width: 30,
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: (groupStats['female'] ?? 0).toDouble(),
                            color: Colors.pink,
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
                "Payment Details",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    "Male Rate: ",
                    style: TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    onPressed: () {
                      final newRate = (groupRates['male'] ?? 200) + 50;
                      widget.attendanceManager.updateGroupRate(
                        groupName: widget.groupName,
                        type: 'male',
                        rate: newRate,
                        setState: setState,
                      );
                      loadGroupData();
                    },
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                  ),
                  Text(
                    "₹ ${groupRates['male'] ?? 200}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    onPressed: () {
                      final currentRate = groupRates['male'] ?? 200;
                      if (currentRate > 50) {
                        widget.attendanceManager.updateGroupRate(
                          groupName: widget.groupName,
                          type: 'male',
                          rate: currentRate - 50,
                          setState: setState,
                        );
                        loadGroupData();
                      }
                    },
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text(
                    "Female Rate: ",
                    style: TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    onPressed: () {
                      final newRate = (groupRates['female'] ?? 200) + 50;
                      widget.attendanceManager.updateGroupRate(
                        groupName: widget.groupName,
                        type: 'female',
                        rate: newRate,
                        setState: setState,
                      );
                      loadGroupData();
                    },
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                  ),
                  Text(
                    "₹ ${groupRates['female'] ?? 200}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    onPressed: () {
                      final currentRate = groupRates['female'] ?? 200;
                      if (currentRate > 50) {
                        widget.attendanceManager.updateGroupRate(
                          groupName: widget.groupName,
                          type: 'female',
                          rate: currentRate - 50,
                          setState: setState,
                        );
                        loadGroupData();
                      }
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
                    "Total Amount: ₹ ${calculateTotalAmount()}",
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
                                    widget.attendanceManager.deleteGroupPayment(
                                      groupName: widget.groupName,
                                      paymentId: payment['id'],
                                      setState: setState,
                                    );
                                    loadGroupData();
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
