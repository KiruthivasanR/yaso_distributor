import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../config/collections.dart';

class ReportsScreen extends StatefulWidget {
  final String distributorId;

  const ReportsScreen({
    super.key,
    required this.distributorId,
  });

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.of(context).size.width < 700;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(Collections.distributorOrders)
          .where(
            "distributorId",
            isEqualTo: widget.distributorId,
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final docs = snapshot.data!.docs;

        int totalOrders = docs.length;

        final customers = <String>{};

        int pending = 0;
        int packed = 0;
        int outDelivery = 0;
        int delivered = 0;
        int cancelled = 0;

        int todayOrders = 0;
        int weekOrders = 0;
        int monthOrders = 0;

        final now = DateTime.now();

        final Map<String, int> areaOrders = {};
        final Map<String, double> productSales = {};
        final Map<String, int> customerOrders = {};

        for (final doc in docs) {
          final order =
              doc.data() as Map<String, dynamic>;

          customers.add(
            order["customerMobile"] ?? "",
          );

          customerOrders[
                  order["customerMobile"] ?? ""]
              = (customerOrders[
                          order["customerMobile"] ??
                              ""] ??
                      0) +
                  1;

          switch (order["status"]) {
            case "Pending":
              pending++;
              break;

            case "Packed":
              packed++;
              break;

            case "Out For Delivery":
              outDelivery++;
              break;

            case "Delivered":
              delivered++;
              break;

            case "Cancelled":
              cancelled++;
              break;
          }

          if (order["createdAt"] != null) {
            final date =
                (order["createdAt"] as Timestamp)
                    .toDate();

            if (date.year == now.year &&
                date.month == now.month &&
                date.day == now.day) {
              todayOrders++;
            }

            if (now.difference(date).inDays <= 7) {
              weekOrders++;
            }

            if (date.year == now.year &&
                date.month == now.month) {
              monthOrders++;
            }
          }

          final area =
              order["customerAddress"] ?? "Unknown";

          areaOrders[area] =
              (areaOrders[area] ?? 0) + 1;

          final items =
              (order["items"] ?? []) as List;

          for (final item in items) {
            final name = item["name"];

            final qty =
                (item["quantity"] ?? 0).toDouble();

            productSales[name] =
                (productSales[name] ?? 0) + qty;
          }
        }

        final topProducts =
            productSales.entries.toList()
              ..sort(
                (a, b) =>
                    b.value.compareTo(a.value),
              );

        final topCustomers =
            customerOrders.entries.toList()
              ..sort(
                (a, b) =>
                    b.value.compareTo(a.value),
              );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              const Text(
                "Distributor Dashboard",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              GridView.count(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
               crossAxisCount: isMobile ? 2 : 4,
childAspectRatio: isMobile ? 0.9 : 1.5,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [

                  dashboardCard(
                    "Today's Orders",
                    todayOrders.toString(),
                    Icons.today,
                    Colors.blue,
                  ),

                  dashboardCard(
                    "This Week",
                    weekOrders.toString(),
                    Icons.calendar_view_week,
                    Colors.green,
                  ),

                  dashboardCard(
                    "This Month",
                    monthOrders.toString(),
                    Icons.calendar_month,
                    Colors.orange,
                  ),

                  dashboardCard(
                    "Customers",
                    customers.length.toString(),
                    Icons.people,
                    Colors.deepPurple,
                  ),
                                  ],
              ),

              const SizedBox(height: 30),

              const Text(
                "Order Status",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isMobile ? 2 : 5,
                childAspectRatio: isMobile ? 1.6 : 1.8,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [

                  statusCard(
                    "Pending",
                    pending,
                    Colors.orange,
                  ),

                  statusCard(
                    "Packed",
                    packed,
                    Colors.blue,
                  ),

                  statusCard(
                    "Out For Delivery",
                    outDelivery,
                    Colors.deepPurple,
                  ),

                  statusCard(
                    "Delivered",
                    delivered,
                    Colors.green,
                  ),

                  statusCard(
                    "Cancelled",
                    cancelled,
                    Colors.red,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                "Area Wise Orders",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Card(
                elevation: 2,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount: areaOrders.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {

                    final area =
                        areaOrders.entries.elementAt(index);

                    return ListTile(

                      leading: CircleAvatar(
                        backgroundColor:
                            Colors.red.shade100,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                        ),
                      ),

                      title: Text(area.key),

                      subtitle: Text(
                        "${area.value} Orders",
                      ),

                      trailing: Chip(
                        label: Text(
                          area.value.toString(),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Top Selling Products",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Card(
                elevation: 2,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount: topProducts.length > 5
                      ? 5
                      : topProducts.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {

                    final product = topProducts[index];

                    return ListTile(

                      leading: CircleAvatar(
                        backgroundColor:
                            Colors.green.shade100,
                        child: Text(
                          "${index + 1}",
                        ),
                      ),

                      title: Text(product.key),

                      subtitle: Text(
                        "${product.value.toStringAsFixed(2)} Sold",
                      ),

                      trailing: const Icon(
                        Icons.trending_up,
                        color: Colors.green,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),
                            const Text(
                "Top Customers",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Card(
                elevation: 2,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount: topCustomers.length > 5
                      ? 5
                      : topCustomers.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {

                    final customer =
                        topCustomers[index];

                    return ListTile(

                      leading: CircleAvatar(
                        backgroundColor:
                            Colors.blue.shade100,
                        child: Text(
                          "${index + 1}",
                        ),
                      ),

                      title: Text(customer.key),

                      subtitle: Text(
                        "${customer.value} Orders",
                      ),

                      trailing: const Icon(
                        Icons.workspace_premium,
                        color: Colors.orange,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Recent Orders",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Card(
                elevation: 2,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount:
                      docs.length > 10 ? 10 : docs.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {

                    final order =
                        docs[index].data()
                            as Map<String, dynamic>;

                    return ListTile(

                      leading: CircleAvatar(
                        child: Text(
                          "${index + 1}",
                        ),
                      ),

                      title: Text(
                        order["customerName"] ?? "",
                      ),

                      subtitle: Text(
                        order["status"] ?? "",
                      ),

                      trailing: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        crossAxisAlignment:
                            CrossAxisAlignment.end,
                        children: [

                          Text(
                            "${order["items"]?.length ?? 0} Items",
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          Text(
                            order["brandingType"] ??
                                "",
                          ),

                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                "Business Summary",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 7),

              SizedBox(
                height: 220,
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isMobile ? 2 : 4,
                childAspectRatio: isMobile ? 0.9 : 1.5,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  children: [
                    dashboardCard(
                      "Total Orders",
                      totalOrders.toString(),
                      Icons.receipt_long,
                      Colors.blue,
                    ),
                
                    dashboardCard(
                      "Repeat Customers",
                      topCustomers
                          .where((e) => e.value > 1)
                          .length
                          .toString(),
                      Icons.people_alt,
                      Colors.green,
                    ),
                
                    dashboardCard(
                      "Areas Served",
                      areaOrders.length.toString(),
                      Icons.location_city,
                      Colors.deepOrange,
                    ),
                
                    dashboardCard(
                      "Products Sold",
                      productSales.length.toString(),
                      Icons.inventory_2,
                      Colors.purple,
                    ),
                
                  ],
                ),
              ),

            ],
          ),
        );
      },
    );
  }

 Widget dashboardCard(
  String title,
  String value,
  IconData icon,
  Color color,
) {
  final isMobile = MediaQuery.of(context).size.width < 700;

  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 16,
        vertical: isMobile ? 12 : 18,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Icon(
            icon,
            color: color,
            size: isMobile ? 28 : 36,
          ),

          SizedBox(height: isMobile ? 8 : 1),

          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 22 : 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: isMobile ? 6 : 10),

          Flexible(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isMobile ? 13 : 15,
              ),
            ),
          ),

        ],
      ),
    ),
  );
}
  Widget statusCard(
    String title,
    int count,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(.08),
          borderRadius:
              BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [

              Text(
                count.toString(),
                style: TextStyle(
                  color: color,
                  fontSize: 30,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              //const SizedBox(height: 8),

              Text(
                title,
                textAlign: TextAlign.center,
              ),

            ],
          ),
        ),
      ),
    );
  }
}