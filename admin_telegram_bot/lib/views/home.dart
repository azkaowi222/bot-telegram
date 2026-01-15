import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> products = [
      {'name': 'Linode', 'sale': 8},
      {'name': 'Azure students', 'sale': 10},
      {'name': 'DigitalOcean', 'sale': 5},
    ];
    products.sort((a, b) => b['sale'].compareTo(a['sale']));

    return ListView(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              // mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 18,

                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                DropdownButton<String>(
                  elevation: 4,
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  value: 'Daily',
                  underline: SizedBox(),
                  // isDense: true,
                  items: const [
                    DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                  ],
                  onChanged: (val) {},
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CardBox(
                  colorGradient: [
                    Color.fromARGB(150, 16, 131, 254),
                    Color.fromARGB(100, 16, 131, 254),
                  ],
                  context: context,
                  label: 'Orders',
                ),
                CardBox(
                  colorGradient: [
                    Color.fromARGB(150, 124, 122, 221),
                    Color.fromARGB(100, 124, 122, 221),
                  ],
                  context: context,
                  label: 'Visits',
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CardBox(
                  colorGradient: [
                    Color.fromARGB(150, 124, 122, 221),
                    Color.fromARGB(100, 124, 122, 221),
                  ],
                  context: context,
                  label: 'Revenue',
                ),
                SizedBox(width: 10),
                CardBox(
                  colorGradient: [
                    Color.fromARGB(150, 16, 131, 254),
                    Color.fromARGB(100, 16, 131, 254),
                  ],
                  context: context,
                  label: 'User Active',
                ),
              ],
            ),
            SizedBox(height: 50),
            Container(
              margin: EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1.5,
                    color: Colors.grey.withValues(alpha: 0.7),
                  ),
                ),
              ),
              child: ChartOrderan(),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 20,
                  color: Colors.yellow,
                  // blendMode: BlendMode.screen,
                ),
                SizedBox(width: 5),
                Text('Top Sales', style: TextStyle(fontSize: 16)),
              ],
            ),
            ...List.generate(products.length, (index) {
              return Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 1.7,
                      color: const Color.from(
                        alpha: 0.5,
                        red: 0.62,
                        green: 0.62,
                        blue: 0.62,
                      ),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(products[index]['name']),
                    Text(products[index]['sale'].toString()),
                  ],
                ),
              );
            }),
          ],
        ),
      ],
    );
  }
}

Widget CardBox({
  required BuildContext context,
  required List<Color> colorGradient,
  required String label,
}) {
  final double deviceWidth = MediaQuery.of(context).size.width;
  return Card(
    elevation: 4,
    margin: EdgeInsets.all(0),
    clipBehavior: Clip.antiAlias,
    child: Container(
      padding: EdgeInsets.all(12),
      width: deviceWidth / 2 - 25,
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colorGradient,
          stops: [0.6, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: Colors.white)),
              Icon(Icons.trending_up_outlined, size: 20, color: Colors.white),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('720', style: TextStyle(color: Colors.white)),
              Text('+19.26%', style: TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    ),
  );
}

class ChartOrderan extends StatelessWidget {
  const ChartOrderan({super.key});

  @override
  Widget build(BuildContext context) {
    // Data dummy orderan (Senin - Minggu)
    // Index 0 = Senin, 6 = Minggu
    final List<double> DailyOrders = [5, 12, 8, 20, 15, 10, 25];

    return AspectRatio(
      aspectRatio: 1.6, // Mengatur rasio lebar:tinggi grafik
      child: BarChart(
        BarChartData(
          // 1. Mengatur tampilan Grid & Border
          gridData: FlGridData(show: false), // Hilangkan garis grid latar
          borderData: FlBorderData(show: false), // Hilangkan kotak border
          // 2. Mengatur Judul Sumbu (Kiri, Bawah, Kanan, Atas)
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            // Label Bawah (Hari)
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  const style = TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  );
                  String text;
                  switch (value.toInt()) {
                    case 0:
                      text = 'Mon';
                      break;
                    case 1:
                      text = 'Tue';
                      break;
                    case 2:
                      text = 'Wed';
                      break;
                    case 3:
                      text = 'Thu';
                      break;
                    case 4:
                      text = 'Fri';
                      break;
                    case 5:
                      text = 'Sat';
                      break;
                    case 6:
                      text = 'Sun';
                      break;
                    default:
                      text = '';
                  }

                  // PERBAIKAN DI SINI
                  return SideTitleWidget(
                    axisSide:
                        meta.axisSide, // Masukkan parameter meta yang didapat dari fungsi getTitlesWidget
                    space: 4,
                    child: Text(text, style: style),
                  );
                },
              ),
            ),
            // Label Kiri (Jumlah Order)
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30, // Ruang untuk angka
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  );
                },
              ),
            ),
          ),

          // 3. Memasukkan Data Batang
          barGroups:
              DailyOrders.asMap().entries.map((entry) {
                int index = entry.key;
                double value = entry.value;

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: value,
                      color: Color.fromARGB(150, 16, 131, 254), // Warna batang
                      width: 30, // Ketebalan batang
                      borderRadius: BorderRadius.circular(4), // Sudut tumpul
                      // Opsional: Membuat background batang (track)
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: 30, // Tinggi maksimal background (target order)
                        color: Colors.grey[200],
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }
}
