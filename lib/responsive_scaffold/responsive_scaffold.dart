import 'package:flutter/material.dart';
import '../responsive/responsive.dart';
import '../screens/customersscreen.dart';
import '../screens/orderscreen.dart';
import '../screens/reportsscreen.dart';

class ResponsiveScaffold extends StatefulWidget {
  final int initialIndex;

  final String distributorId;
  final Map<String, dynamic> distributorData;

  const ResponsiveScaffold({
    super.key,
    this.initialIndex = 0,
    required this.distributorId,
    required this.distributorData,
  });

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {

  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {

    final pages = [

      OrdersScreen(
        distributorId: widget.distributorId,
        distributorData: widget.distributorData,
      ),

      CustomersScreen(
        distributorId: widget.distributorId,
      ),

      ReportsScreen(
        distributorId: widget.distributorId,
      ),
    ];

    final titles = [
      "Orders",
      "Customers",
      "Reports",
    ];

    if (Responsive.isMobile(context)) {
      return Scaffold(
        appBar: AppBar(
          title: Text(titles[selectedIndex]),
        ),
        drawer: AppDrawer(
          selectedIndex: selectedIndex,
          onSelected: (index) {
            setState(() {
              selectedIndex = index;
            });
            Navigator.pop(context);
          },
        ),
        body: pages[selectedIndex],
      );
    }

    return Scaffold(
      body: Row(
        children: [

          SizedBox(
            width: 250,
            child: AppDrawer(
              selectedIndex: selectedIndex,
              onSelected: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
            ),
          ),

          Expanded(
            child: Column(
              children: [

                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    titles[selectedIndex],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Divider(height: 1),

                Expanded(
                  child: pages[selectedIndex],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelected;

  const AppDrawer({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff6FC36A),
              Color(0xffBFE8B9),
            ],
          ),
        ),
        child: Column(
          children: [

            const SizedBox(height: 35),

            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.orange,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage:
                    AssetImage("assets/images/yaso_logo.png"),
              ),
            ),

           

            const SizedBox(height: 20),

            const Text(
              "Yaso Distributor",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            _menuTile(
              icon: Icons.receipt_long,
              title: "Orders",
              index: 0,
            ),

            const SizedBox(height: 10),

            _menuTile(
              icon: Icons.people,
              title: "Customers",
              index: 1,
            ),

            const SizedBox(height: 10),

            _menuTile(
              icon: Icons.bar_chart,
              title: "Reports",
              index: 2,
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.all(18),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize:
                      const Size(double.infinity, 55),
                  side: const BorderSide(
                    color: Colors.red,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                label: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final selected = selectedIndex == index;

    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => onSelected(index),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withOpacity(.35)
                    : Colors.transparent,
                border: selected
                    ? Border.all(
                        color: Colors.orange,
                        width: 2,
                      )
                    : null,
                borderRadius:
                    BorderRadius.circular(18),
              ),
              child: Row(
                children: [

                  const SizedBox(width: 18),

                  Icon(
                    icon,
                    color: selected
                        ? Colors.green.shade800
                        : Colors.white,
                  ),

                  const SizedBox(width: 18),

                  Text(
                    title,
                    style: TextStyle(
                      color: selected
                          ? Colors.black87
                          : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),

                ],
              ),
            ),
          ),
        );
      },
    );
  }
}