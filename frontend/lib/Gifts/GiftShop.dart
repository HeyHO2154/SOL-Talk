import 'package:flutter/material.dart';

class GiftShopPage extends StatelessWidget {
  final List<Map<String, dynamic>> giftItems = [
    {
      'name': 'Chocolate Box',
      'price': 20.0,
      'description': 'Delicious assorted chocolates.',
      'image': 'assets/chocolate_box.png'
    },
    {
      'name': 'Flower Bouquet',
      'price': 35.0,
      'description': 'Beautiful bouquet of fresh flowers.',
      'image': 'assets/flower_bouquet.png'
    },
    {
      'name': 'Teddy Bear',
      'price': 25.0,
      'description': 'Soft and cuddly teddy bear.',
      'image': 'assets/teddy_bear.png'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gift Shop'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 두 개의 열로 구성된 그리드
            childAspectRatio: 0.75, // 카드의 가로세로 비율
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: giftItems.length,
          itemBuilder: (context, index) {
            final item = giftItems[index];
            return Card(
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Image.asset(
                      item['image'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text('\$${item['price']}',
                            style: TextStyle(
                                fontSize: 16, color: Colors.green)),
                        SizedBox(height: 4),
                        Text(
                          item['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // 구매 버튼 로직 추가
                      },
                      child: Text('Buy Now'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
