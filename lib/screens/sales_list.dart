import 'package:bio_boost/models/sales_model.dart';
import 'package:bio_boost/screens/detail.dart';
import 'package:flutter/material.dart';
import 'package:bio_boost/data/sales_service.dart';

class SalesListScreen extends StatefulWidget {
  const SalesListScreen({super.key});

  @override
  _SalesListScreenState createState() => _SalesListScreenState();
}

class _SalesListScreenState extends State<SalesListScreen> {
  late Future<List<Sales>> _salesFuture;
  final SalesService _salesService = SalesService();

  @override
  void initState() {
    super.initState();
    _salesFuture = _salesService.getSalesDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agricultural Waste Sales')),
      body: FutureBuilder<List<Sales>>(
        future: _salesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(child: Text("No sales available"));
          }

          final salesList = snapshot.data!;

          return ListView.builder(
            itemCount: salesList.length,
            itemBuilder: (context, index) {
              final sale = salesList[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(sale.s_type),
                  subtitle: Text("Price: ${sale.s_price}"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AgriWasteDetailPage(
                              saleId: sale.documentId,
                            ), // Pass document ID
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
