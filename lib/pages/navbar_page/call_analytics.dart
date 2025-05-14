import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_assist/utils/storage.dart';

class CallAnalytics extends StatefulWidget {
  const CallAnalytics({super.key});

  @override
  State<CallAnalytics> createState() => _CallAnalyticsState();
}

class _CallAnalyticsState extends State<CallAnalytics> {
  String selectedTimeRange = '1D';
  int selectedTabIndex = 0;
  int touchedIndex = -1;
  int _childButtonIndex = 0;

  bool _isLoading = true;
  Map<String, dynamic>? _dashboardData;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final token = await Storage.getToken();

      // Determine period parameter based on selection
      String periodParam = '';
      switch (_childButtonIndex) {
        case 1:
          periodParam = '?type=QTD';
          break;
        case 2:
          periodParam = '?type=YTD';
          break;
        default:
          periodParam = '?type=MTD';
      }

      final uri = Uri.parse(
          'https://dev.smartassistapp.in/api/users/dashboard/analytics$periodParam');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print(uri);
      print(response.body);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        // Check if the widget is still in the widget tree before calling setState
        if (mounted) {
          setState(() {
            _dashboardData = jsonData['data'];
            _isLoading = false;
          });
        }
      } else {
        // Handle unsuccessful status codes
        throw Exception(
            'Failed to load dashboard data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Check if the widget is still in the widget tree before calling setState
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // Handle different types of errors
      if (e is http.ClientException) {
        debugPrint('Network error: $e');
      } else if (e is FormatException) {
        debugPrint('Error parsing data: $e');
      } else {
        debugPrint('Unexpected error: $e');
      }
    }
  }

  final List<String> tabTitles = ['Summary-Enquiry', 'Summary-Cold Calls'];

  void _updateSelectedTimeRange(String range) {
    setState(() {
      selectedTimeRange = range;
    });
  }

  void _updateSelectedTab(int index) {
    setState(() {
      selectedTabIndex = index;
    });
  }

  // Get current data based on selected period
  Map<String, dynamic> get performanceCount {
    if (_dashboardData == null) {
      // Return empty data if API data isn't available yet
      return {};
    }
    return _dashboardData!['performance'] ?? {};
    // return _dashboardData!['dealerShipRank'] ??
    //     {}; // Fixed key from 'dealershipRank' to 'dealerShipRank'
  }

  Map<String, dynamic> get currentAllIndiaRank {
    if (_dashboardData == null) {
      // Return empty data if API data isn't available yet
      return {};
    }

    // Using allIndiaRank from API response - fixed key from 'allINDRank' to 'allIndiaRank'
    return _dashboardData!['allIndiaRank'] ?? {};
  }

  Map<String, dynamic> get allIndiaBestPerformace {
    if (_dashboardData == null) {
      // Return empty data if API data isn't available yet
      return {};
    }

    // Using allIndiaRank from API response - fixed key from 'allINDRank' to 'allIndiaRank'
    return _dashboardData!['allIndiaBestPerformace'] ?? {};
  }

  //new code remove us unused

  Map<String, dynamic> get dealershipRank {
    if (_dashboardData == null) {
      return {};
    }
    return _dashboardData!['dealerShipRank'] ?? {};
  }

  // Generate dynamic table rows based on API data
  List<List<String>> get tableData {
    final List<List<String>> data = [];

    if (_dashboardData == null) {
      return [];
    }

    // Add Enquiries row
    data.add([
      'All Calls',
      performanceCount['enquiry']?.toString() ?? '0', //performance
      allIndiaBestPerformace['enquiriesCount']?.toString() ??
          '0', //allIndiaRank
      dealershipRank['enquiriesRank']?.toString() ?? '0', //
    ]);

    // Add Lost Enquiries row
    data.add([
      'Connected',
      performanceCount['lostEnq']?.toString() ?? '0', //performance
      allIndiaBestPerformace['lostEnquiriesCount']?.toString() ??
          '0', //allIndiaRank
      dealershipRank['lostEnquiriesRank']?.toString() ?? '0', //
    ]);

    // Add Test drives row
    data.add([
      'Missed',
      performanceCount['testDriveData']?.toString() ?? '0', //performance
      allIndiaBestPerformace['testDrivesCount']?.toString() ??
          '0', //allIndiaRank
      dealershipRank['testDrivesRank']?.toString() ?? '0', //
    ]);

    // Add New Orders row
    data.add([
      'Rejected',
      performanceCount['orders']?.toString() ?? '0', //performance
      allIndiaBestPerformace['newOrdersCount']?.toString() ??
          '0', //allIndiaRank
      dealershipRank['newOrdersRank']?.toString() ?? '0', //
    ]);

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            FontAwesomeIcons.angleLeft,
            color: Colors.white,
          ),
        ),
        title: Text(
          'Call Ananlytitics',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTimeFilterRow(),
              _buildUserStatsCard(),
              const SizedBox(height: 16),
              _buildCallsSummary(),
              const SizedBox(height: 16),
              _buildHourlyAnalysis(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeFilterRow() {
    final timeRanges = ['1D', '1W', '1M', '1Q', '1Y'];

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(left: 15),
          width: 200,
          decoration: BoxDecoration(
            color: AppColors.backgroundLightGrey,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              for (final range in timeRanges)
                Expanded(
                  child:
                      _buildTimeFilterChip(range, range == selectedTimeRange),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeFilterChip(String label, bool isActive) {
    return GestureDetector(
      onTap: () => _updateSelectedTimeRange(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive ? Colors.blue : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: isActive ? Colors.blue : AppColors.fontColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildUserStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Abhey Dayal', style: AppFont.popupTitleBlack16(context)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: AppColors.homeContainerLeads,
                    borderRadius: BorderRadius.circular(30)),
                child: Text(
                  'Target: 30',
                  style: AppFont.mediumText14(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatBox('4', 'Total\nConnected', Colors.green, Icons.call),
              _buildVerticalDivider(50),
              _buildStatBox(
                  '13M', 'Conversation\ntime', Colors.blue, Icons.access_time),
              _buildVerticalDivider(50),
              _buildStatBox(
                  '3', 'Not\nConnected', Colors.red, Icons.call_missed),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String value, String label, Color color, IconData icon) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            const SizedBox(width: 3),
            Icon(icon, color: color, size: 20),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: AppFont.smallText12(context),
          textAlign: TextAlign.start,
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(double height) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: height,
      width: 0.1,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: AppColors.backgroundLightGrey)),
      ),
    );
  }

  Widget _buildCallsSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildTabBar(),
          const SizedBox(height: 10),
          // _buildCallsTable(),
          _buildAnalyticsTable(),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 30,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundLightGrey,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          for (int i = 0; i < tabTitles.length; i++)
            Expanded(
              child: _buildTab(tabTitles[i], i == selectedTabIndex, i),
            ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isActive, int index) {
    return GestureDetector(
      onTap: () => _updateSelectedTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
        // margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: isActive ? Colors.white : Colors.blue,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildHourlyAnalysis() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hourly Analysis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildCallStatsRows(),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: _buildCombinedBarChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildCallStatsRows() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column - Call counts
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('20',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              _buildCallStatRow('All calls', '10', '6 min 39 secs'),
              _buildCallStatRow('Incoming calls', '3', '3 min 02 secs'),
              _buildCallStatRow('Outgoing calls', '3', '3 min 02 secs'),
              _buildCallStatRow('Missed calls', '5', '02 secs'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCallStatRow(String label, String count, String duration) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            count,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            duration,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // New combined chart method
  Widget _buildCombinedBarChart() {
    return Column(
      children: [
        // Legend for the chart
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('All Calls', Colors.blue),
              const SizedBox(width: 16),
              _buildLegendItem('Incoming', Colors.green),
              const SizedBox(width: 16),
              _buildLegendItem('Outgoing', Colors.orange),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Combined chart
        Expanded(
          child: _buildCombinedLineChart(),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildCombinedLineChart() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              // tooltipBgColor: Colors.grey.shade800,
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((spot) {
                  String callType = '';
                  if (spot.barIndex == 0) {
                    callType = 'All Calls';
                  } else if (spot.barIndex == 1) {
                    callType = 'Incoming';
                  } else {
                    callType = 'Outgoing';
                  }
                  return LineTooltipItem(
                    '$callType: ${spot.y.toInt()} calls',
                    const TextStyle(color: Colors.white),
                  );
                }).toList();
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  const style = TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  );
                  String text;
                  switch (value.toInt()) {
                    case 0:
                      text = '9:00';
                      break;
                    case 2:
                      text = '10:00';
                      break;
                    case 4:
                      text = '11:00';
                      break;
                    case 6:
                      text = '12:00';
                      break;
                    case 8:
                      text = '13:00';
                      break;
                    case 10:
                      text = '14:00';
                      break;
                    default:
                      text = '';
                  }
                  return SideTitleWidget(
                    // axisSide: meta.axisSide,
                    space: 8,
                    child: Text(text, style: style),
                    meta: meta,
                  );
                },
                reservedSize: 28,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value == 0) {
                    return const SizedBox();
                  }
                  return SideTitleWidget(
                    // fitInside: ,
                    space: 8,
                    child: Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                    meta: meta,
                  );
                },
                reservedSize: 28,
                interval: 5,
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: true,
            horizontalInterval: 5,
            verticalInterval: 2,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade200,
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey.shade200,
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          minX: 0,
          maxX: 12,
          minY: 0,
          maxY: 15,
          lineBarsData: [
            // All Calls Line
            LineChartBarData(
              spots: const [
                FlSpot(0, 5),
                FlSpot(2, 3),
                FlSpot(4, 7),
                FlSpot(6, 8),
                FlSpot(8, 9),
                FlSpot(10, 11),
                FlSpot(12, 12),
              ],
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.2),
              ),
            ),
            // Incoming Calls Line
            LineChartBarData(
              spots: const [
                FlSpot(0, 2),
                FlSpot(2, 1),
                FlSpot(4, 4),
                FlSpot(6, 3),
                FlSpot(8, 5),
                FlSpot(10, 6),
                FlSpot(12, 7),
              ],
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withOpacity(0.2),
              ),
            ),
            // Outgoing Calls Line
            LineChartBarData(
              spots: const [
                FlSpot(0, 3),
                FlSpot(2, 2),
                FlSpot(4, 3),
                FlSpot(6, 5),
                FlSpot(8, 4),
                FlSpot(10, 5),
                FlSpot(12, 5),
              ],
              isCurved: true,
              color: Colors.orange,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.orange.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTable() {
    double screenWidth = MediaQuery.of(context).size.width;

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder(
          horizontalInside: BorderSide(
            color: Colors.grey.withOpacity(0.3),
            width: 0.5,
          ),
          verticalInside: BorderSide.none),
      columnWidths: {
        0: FixedColumnWidth(screenWidth * 0.3), // Metric
        1: FixedColumnWidth(screenWidth * 0.19), // My
        2: FixedColumnWidth(screenWidth * 0.19), // All India Best
        3: FixedColumnWidth(screenWidth * 0.19), // Dealership
      },
      children: [
        TableRow(
          children: [
            const SizedBox(), // Empty cell
            Center(
                child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Text('Calls', style: AppFont.smallText10(context)))),
            Center(
                child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Text('Duration',
                  textAlign: TextAlign.center,
                  style: AppFont.smallText10(context)),
            )),
            Center(
                child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Text('Unique client',
                        style: AppFont.smallText10(context)))),
          ],
        ),
        ...tableData.map((row) => _buildTableRow(row)).toList(),
      ],
    );
  }

  TableRow _buildTableRow(List<String> values) {
    return TableRow(
      children: values.map((value) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 5.0),
          child: Row(children: [
            // Icon(Icon , ),
            Text(
              value,
              style: AppFont.smallText(context),
              textAlign: values.indexOf(value) == 0
                  ? TextAlign.left
                  : TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ]),
        );
      }).toList(),
    );
  }
}
