import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../logic/providers/medicine_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: Consumer<MedicineProvider>(
        builder: (context, provider, child) {
          final medicines = provider.medicines;

          if (medicines.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No medicines to track yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final totalMedicines = medicines.length;
          
          // Count medicines taken today - check both isTaken and takenHistory
          final now = DateTime.now();
          final takenToday = medicines.where((m) {
            // For recurring medicines, check if taken today in history
            if (m.isRecurring && m.takenHistory.isNotEmpty) {
              final lastTaken = m.takenHistory.last;
              return lastTaken.year == now.year &&
                     lastTaken.month == now.month &&
                     lastTaken.day == now.day;
            }
            // For one-time medicines, use isTaken status
            return m.isTaken;
          }).length;
          
          final pendingToday = totalMedicines - takenToday;
          final completionRate = totalMedicines > 0
              ? (takenToday / totalMedicines * 100).toStringAsFixed(0)
              : '0';

          // Calculate weekly statistics
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
          int takenThisWeek = 0;
          for (var medicine in medicines) {
            if (medicine.takenHistory.isNotEmpty) {
              takenThisWeek += medicine.takenHistory.where((date) => 
                date.isAfter(weekStartDate.subtract(const Duration(seconds: 1)))
              ).length;
            }
          }

          // Calculate monthly statistics
          final monthStart = DateTime(now.year, now.month, 1);
          int takenThisMonth = 0;
          for (var medicine in medicines) {
            if (medicine.takenHistory.isNotEmpty) {
              takenThisMonth += medicine.takenHistory.where((date) => 
                date.year == now.year && date.month == now.month
              ).length;
            }
          }

          // Calculate all-time total doses
          int totalDosesTaken = 0;
          for (var medicine in medicines) {
            totalDosesTaken += medicine.takenHistory.length;
          }

          // Calculate current streak (consecutive days with all medicines taken)
          int currentStreak = 0;
          DateTime checkDate = DateTime(now.year, now.month, now.day);
          while (true) {
            bool allTakenOnDate = true;
            for (var medicine in medicines) {
              // Check if medicine should have been taken on this date
              if (medicine.takenHistory.isEmpty) {
                allTakenOnDate = false;
                break;
              }
              
              bool takenOnDate = medicine.takenHistory.any((date) =>
                date.year == checkDate.year &&
                date.month == checkDate.month &&
                date.day == checkDate.day
              );
              
              if (!takenOnDate) {
                allTakenOnDate = false;
                break;
              }
            }
            
            if (!allTakenOnDate) break;
            currentStreak++;
            checkDate = checkDate.subtract(const Duration(days: 1));
            
            // Limit streak calculation to prevent infinite loop
            if (currentStreak > 365) break;
          }

          // Find most taken medicine
          String mostTakenMedicine = 'None';
          int maxDoses = 0;
          for (var medicine in medicines) {
            if (medicine.takenHistory.length > maxDoses) {
              maxDoses = medicine.takenHistory.length;
              mostTakenMedicine = medicine.name;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.medication,
                        title: 'Total',
                        value: totalMedicines.toString(),
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.check_circle,
                        title: 'Taken',
                        value: takenToday.toString(),
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.pending,
                        title: 'Pending',
                        value: pendingToday.toString(),
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.percent,
                        title: 'Rate',
                        value: '$completionRate%',
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Progress Indicator
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Today\'s Progress',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: totalMedicines > 0
                              ? takenToday / totalMedicines
                              : 0,
                          backgroundColor: Colors.grey[300],
                          color: Colors.teal,
                          minHeight: 8,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$takenToday of $totalMedicines medicines taken',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // All Time Tracking Section
                const Text(
                  'All Time Tracking',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.history,
                        title: 'Total Doses',
                        value: totalDosesTaken.toString(),
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.local_fire_department,
                        title: 'Streak',
                        value: '$currentStreak days',
                        color: Colors.deepOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.calendar_view_week,
                        title: 'This Week',
                        value: takenThisWeek.toString(),
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.calendar_month,
                        title: 'This Month',
                        value: takenThisMonth.toString(),
                        color: Colors.cyan,
                      ),
                    ),
                  ],
                ),

                if (mostTakenMedicine != 'None') ...[
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.amber,
                        child: Icon(Icons.star, color: Colors.white),
                      ),
                      title: const Text('Most Taken Medicine'),
                      subtitle: Text(mostTakenMedicine),
                      trailing: Text(
                        '$maxDoses doses',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Medicine List
                const Text(
                  'Medicine Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                ...medicines.map((medicine) {
                  final timeFormat = DateFormat('hh:mm a');
                  final formattedTime = timeFormat.format(medicine.time);
                  
                  // Check if taken today for recurring medicines
                  bool takenToday = medicine.isTaken;
                  if (medicine.isRecurring && medicine.takenHistory.isNotEmpty) {
                    final lastTaken = medicine.takenHistory.last;
                    takenToday = lastTaken.year == now.year &&
                                 lastTaken.month == now.month &&
                                 lastTaken.day == now.day;
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: takenToday
                            ? Colors.green
                            : Colors.orange.shade100,
                        child: Icon(
                          takenToday ? Icons.check : Icons.access_time,
                          color: takenToday ? Colors.white : Colors.orange,
                        ),
                      ),
                      title: Text(medicine.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${medicine.dose} • $formattedTime'),
                          if (medicine.takenHistory.isNotEmpty)
                            Text(
                              'Total: ${medicine.takenHistory.length} doses',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            takenToday ? 'Taken' : 'Pending',
                            style: TextStyle(
                              color: takenToday ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (medicine.isRecurring)
                            Text(
                              medicine.recurrenceType == 'daily' 
                                ? 'Daily' 
                                : '${medicine.recurrenceInterval}d',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
