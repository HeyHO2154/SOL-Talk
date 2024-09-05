import 'package:flutter/material.dart';

class FinanceReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finance Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Overview',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildFinanceItem('Total Balance', '\$15,000'),
            _buildFinanceItem('Monthly Expenses', '\$1,200'),
            _buildFinanceItem('Monthly Income', '\$3,000'),
            _buildFinanceItem('Savings', '\$8,000'),
            _buildFinanceItem('Investments', '\$5,000'),
            Divider(),
            SizedBox(height: 16),
            Text(
              'Financial Analysis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Based on your current financial data, your spending is well within '
                  'your monthly income, and you are saving 40% of your earnings. '
                  'Consider increasing your investment for long-term growth.',
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // 이전 화면으로 돌아가기
              },
              child: Text('Back to Profile'),
            ),
          ],
        ),
      ),
    );
  }

  // 금융 상태 항목 표시하는 위젯
  Widget _buildFinanceItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
