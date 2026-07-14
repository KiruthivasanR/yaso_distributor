import 'package:flutter/material.dart';
import '../../responsive_scaffold/responsive_scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/collections.dart';

class OrdersScreen extends StatefulWidget {
  final String distributorId;
  final Map<String, dynamic> distributorData;

  const OrdersScreen({
    super.key,
    required this.distributorId,
    required this.distributorData,
  });

  @override
  State<OrdersScreen> createState() => _OrdersScreenState(
    
  );

  
}

class _OrdersScreenState extends State<OrdersScreen> {

  Future<void> fetchCustomerByMobile(
  String mobile,
) async {
  if (mobile.length < 10) return;

  final snapshot = await FirebaseFirestore.instance
      .collection(Collections.distributorCustomers)
      .where(
        "distributorId",
        isEqualTo: widget.distributorId,
      )
      .where(
        "mobile",
        isEqualTo: mobile,
      )
      .limit(1)
      .get();

  if (snapshot.docs.isNotEmpty) {
    final customer = snapshot.docs.first.data();

    setState(() {
      customerNameController.text =
          customer["name"] ?? "";

      customerAddressController.text =
          customer["address"] ?? "";
    });
  }
}


double getProductsTotal(
  List<QueryDocumentSnapshot> docs,
) {
  double total = 0;

  for (final doc in docs) {

    final product =
        doc.data() as Map<String, dynamic>;

    final variants =
        variantQuantities[doc.id] ?? {};

    double qty = 0;

   variants.forEach((variant, count) {

  if (variant == "100ml" || variant == "100g") {
    qty += (100 * count) / 1000;
  }

  else if (variant == "250ml" || variant == "250g") {
    qty += (250 * count) / 1000;
  }

  else if (variant == "500ml" || variant == "500g") {
    qty += (500 * count) / 1000;
  }

  else if (variant == "1L" || variant == "1kg") {
    qty += count.toDouble();
  }

});

   double rate = getRate(qty, product);

double extraCharge = 0;

variants.forEach((variant, count) {
  if ((product["name"] ?? "")
          .toString()
          .toLowerCase()
          .contains("ghee") &&
      variant == "100ml") {
    extraCharge += 5 * count;
  }
});

final total = (qty * rate) + extraCharge;
  }

  return total;
}
double getTotalWeight() {

  double weight = 0;

  variantQuantities.forEach(
    (productId, variants) {

      variants.forEach(
        (variant, count) {

          if (variant == "250ml" ||
              variant == "250g") {
            weight +=
                (250 * count) / 1000;
          }

          else if (variant == "500ml" ||
              variant == "500g") {
            weight +=
                (500 * count) / 1000;
          }

          else if (variant == "1L" ||
              variant == "1kg") {
            weight +=
                count.toDouble();
          }
        },
      );
    },
  );

  return weight;
}

double getShippingCharge() {
  final weight = getTotalWeight();

  if (weight <= 0) return 0;

  if (weight < 10) {
    return weight * 40;
  }

  return weight * 30;
}

Map<String, Map<String, int>>
    variantQuantities = {};
  double getRate(
  double qty,
  Map<String, dynamic> product,
) {
  if (qty <= 5) {
    return (product["price1to5"] ?? 0).toDouble();
  }

  if (qty <= 10) {
    return (product["price5to10"] ?? 0).toDouble();
  }

  return (product["priceAbove10"] ?? 0).toDouble();
}

  final customerNameController = TextEditingController();
final customerMobileController = TextEditingController();
final customerAddressController = TextEditingController();
final notesController = TextEditingController();

String brandingType = "Normal";
@override
Widget build(BuildContext context) {

    return Container(
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xffF4FFF2),
        Color(0xffE8F5E9),
      ],
    ),
  ),
  child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [

          // Distributor Details

         Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
    boxShadow: const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 12,
        offset: Offset(0,4),
      ),
    ],
  ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                 const Text(
  "Distributor Details",
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Color(0xff1B5E20),
  ),
),

                  const Divider(),

                  ListTile(
                   leading: CircleAvatar(
  radius: 22,
  backgroundColor: const Color(0xffE8F5E9),
  child: const Icon(
    Icons.person,
    color: Color(0xff1B5E20),
  ),
),
                    title: const Text("Name"),
                    subtitle: Text(
                      widget.distributorData["name"] ??
                          "",
                    ),
                  ),

                  ListTile(
                    leading:
                        const Icon(Icons.business),
                    title:
                        const Text("Company Name"),
                    subtitle: Text(
                      widget.distributorData[
                              "companyName"] ??
                          "",
                    ),
                  ),

                  ListTile(
                    leading:
                        const Icon(Icons.phone),
                    title:
                        const Text("Mobile Number"),
                    subtitle: Text(
                      widget.distributorData[
                              "mobile"] ??
                          "",
                    ),
                  ),

                  ListTile(
                    leading:
                        const Icon(Icons.location_on),
                    title: const Text("Area"),
                    subtitle: Text(
                      widget.distributorData[
                              "areas"] ??
                          "",
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Customer Details
if (brandingType != "Self")
          Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
    boxShadow: const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 12,
        offset: Offset(0,4),
      ),
    ],
  ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  const Text(
                    "Customer Details",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller:
                        customerNameController,
                    decoration:
                        const InputDecoration(
                      labelText:
                          "Customer Name",
                      border:
                          OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                 TextField(
  controller: customerMobileController,
  keyboardType: TextInputType.phone,
  maxLength: 10,
  onChanged: (value) {

    if (value.length == 10) {
      fetchCustomerByMobile(value);
    }

  },
  decoration: const InputDecoration(
    labelText: "Mobile Number",
    border: OutlineInputBorder(),
    counterText: "",
  ),
),

                  const SizedBox(height: 15),

                  TextField(
                    controller:
                        customerAddressController,
                    maxLines: 3,
                    decoration:
                        const InputDecoration(
                      labelText:
                          "Customer Address",
                      border:
                          OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Order Type

       Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
    boxShadow: const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 12,
        offset: Offset(0,4),
      ),
    ],
  ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  const Text(
                    "Order Type",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  DropdownButtonFormField(
                    value: brandingType,
                    decoration:
                        const InputDecoration(
                      border:
                          OutlineInputBorder(),
                    ),
                    items: const [
  DropdownMenuItem(
    value: "Self",
    child: Text("Self Pickup"),
  ),
  DropdownMenuItem(
    value: "Normal",
    child: Text("Regular Order"),
  ),
  DropdownMenuItem(
    value: "White Label",
    child: Text("White Label Order"),
  ),
],
                    onChanged: (value) {
                      setState(() {
                        brandingType =
                            value.toString();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Special Instructions

          Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
    boxShadow: const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 12,
        offset: Offset(0,4),
      ),
    ],
  ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  const Text(
                    "Special Instructions",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: notesController,
                    maxLines: 4,
                    decoration:
                        const InputDecoration(
                      hintText:
                          "Use distributor sticker / No invoice inside box / Urgent dispatch",
                      border:
                          OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
const SizedBox(height: 20),

buildProductsSection(),
const SizedBox(height: 20),

buildSummarySection(),
        ],
      ),
  ),
    );
    

}


Widget buildProductsSection() {
  return Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
    boxShadow: const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 12,
        offset: Offset(0,4),
      ),
    ],
  ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [

          const Text(
            "Products",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(
                  Collections.distributorProducts,
                )
                // .where("active", isEqualTo: true)
                // .orderBy("displayOrder")
                .snapshots(),
            builder: (context, snapshot) {

             if (snapshot.hasError) {
  return Center(
    child: Text(
      snapshot.error.toString(),
      style: const TextStyle(color: Colors.red),
    ),
  );
}

if (!snapshot.hasData) {
  return const Center(
    child: CircularProgressIndicator(),
  );
}

              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return const Text(
                  "No Products Available",
                );
              }
              final isMobile =
    MediaQuery.of(context).size.width < 600;

              return GridView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: docs.length,
  gridDelegate:
      SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: isMobile ? 1 : 2,
    childAspectRatio: isMobile ? 0.75 : 1.0,
    crossAxisSpacing: 15,
    mainAxisSpacing: 15,
  ),
                itemBuilder: (context, index) {

                  final doc = docs[index];

                  final product =
                      doc.data()
                          as Map<String, dynamic>;
final variants =
    variantQuantities[doc.id] ?? {};

double qty = 0;

variants.forEach((variant, count) {

  if (variant == "100ml" || variant == "100g") {
    qty += (100 * count) / 1000;
  }

  else if (variant == "250ml" || variant == "250g") {
    qty += (250 * count) / 1000;
  }

  else if (variant == "500ml" || variant == "500g") {
    qty += (500 * count) / 1000;
  }

  else if (variant == "1L" || variant == "1kg") {
    qty += count.toDouble();
  }

});
double rate = getRate(qty, product);

double extraCharge = 0;

variants.forEach((variant, count) {
  if ((product["name"] ?? "")
          .toString()
          .toLowerCase()
          .contains("ghee") &&
      variant == "100ml") {
    extraCharge += 5 * count;
  }
});

final total = (qty * rate) + extraCharge;

               return Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: Colors.green.shade100,
    ),
    boxShadow: const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 8,
      )
    ],
  ),
  child: Padding(
    padding: const EdgeInsets.all(12),
    child: Column(
      children: [
    
        SizedBox(
          height: 80,
          child: Image.network(
            product["imageUrl"] ?? "",
            fit: BoxFit.contain,
            errorBuilder:
                (context, error, stackTrace) {
              return const Icon(
                Icons.image_not_supported,
                size: 80,
              );
            },
          ),
        ),
    
                        const SizedBox(height: 10),
    
                        Text(
                          product["name"] ?? "",
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
    
                        Text(
                          product["unit"] ?? "",
                        ),
    
                        const SizedBox(height: 10),
    
    ...(product["variants"] ?? [])
        .map<Widget>((variant) {
    
      final qty =
    variantQuantities[doc.id]?[variant] ?? 0;
    
      return Padding(
        padding:
      const EdgeInsets.only(bottom: 8),
        child: Row(
    children: [
    
      Expanded(
        child: Text(
          variant,
          style: const TextStyle(
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ),
    
      IconButton(
        onPressed: () {
          setState(() {
    
            variantQuantities
                .putIfAbsent(
                  doc.id,
                  () => {},
                );
    
            if (qty > 0) {
              variantQuantities[
                  doc.id]![variant] =
                  qty - 1;
            }
          });
        },
        icon:
            const Icon(
      Icons.remove_circle,
      color: Colors.redAccent,
    )
      ),
    
      Text(
        qty.toString(),
        style:
            const TextStyle(
          fontSize: 18,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    
      IconButton(
        onPressed: () {
          setState(() {
    
            variantQuantities
                .putIfAbsent(
                  doc.id,
                  () => {},
                );
    
            variantQuantities[
                    doc.id]![variant] =
                qty + 1;
          });
        },
        icon:
           const Icon(
      Icons.add_circle,
      color: Color(0xff1B5E20),
    )
      ),
    ],
        ),
      );
    }).toList(),
    
                        const SizedBox(height: 10),
    Text(
      "Qty : ${qty.toStringAsFixed(2)} ${product["unit"]}",
    ),
                        Text(
                          "Rate : ₹${rate.toStringAsFixed(2)}",
                        ),
    
                        Text(
                          "Total : ₹${total.toStringAsFixed(2)}",
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
  ),
                  );
                },
              );
            },
          ),
        ],
      ),
    ),
  );



}

Widget buildSummarySection() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection(
          Collections.distributorProducts,
        )
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const SizedBox();
      }

      final docs = snapshot.data!.docs;

      final productTotal =
          getProductsTotal(docs);

      final shipping =
          getShippingCharge();

      final grandTotal =
          productTotal + shipping;
          String customerName;
String customerMobile;
String customerAddress;

if (brandingType == "Self") {

  customerName =
      widget.distributorData["name"] ?? "";

  customerMobile =
      widget.distributorData["mobile"] ?? "";

  customerAddress =
      widget.distributorData["address"] ?? "";
} else {

  customerName =
      customerNameController.text.trim();

  customerMobile =
      customerMobileController.text.trim();

  customerAddress =
      customerAddressController.text.trim();
}

      return Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
    boxShadow: const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 12,
        offset: Offset(0,4),
      ),
    ],
  ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              const Text(
                "Order Summary",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              ListTile(
                title:
                    const Text("Products Total"),
                trailing: Text(
                  "₹${productTotal.toStringAsFixed(2)}",
                ),
              ),

              ListTile(
                title:
                    const Text("Shipping"),
                trailing: Text(
                  "₹${shipping.toStringAsFixed(2)}",
                ),
              ),

              Divider(
  color: Colors.green.shade100,
  thickness: 1.2,
),

              ListTile(
                title: const Text(
                  "Grand Total",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Text(
                  "₹${grandTotal.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xff1B5E20),
    foregroundColor: Colors.white,
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
                 onPressed: () async {
  try {
if (brandingType != "Self")
    if (customerNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Enter Customer Name",
          ),
        ),
      );
      return;
    }
if (brandingType != "Self")
    if (customerMobileController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Enter Mobile Number",
          ),
        ),
      );
      return;
    }
if (brandingType != "Self")
    if (customerAddressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Enter Address",
          ),
        ),
      );
      return;
    }

    final productsSnapshot =
        await FirebaseFirestore.instance
            .collection(
              Collections.distributorProducts,
            )
            .get();

    List<Map<String, dynamic>> items = [];

    double productTotal = 0;

    for (final doc in productsSnapshot.docs) {

      final product = doc.data();

   final variants =
    variantQuantities[doc.id] ?? {};

if (variants.isEmpty) continue;

double qty = 0;

variants.forEach((variant, count) {

  if (variant == "100ml" || variant == "100g") {
    qty += (100 * count) / 1000;
  }

  else if (variant == "250ml" || variant == "250g") {
    qty += (250 * count) / 1000;
  }

  else if (variant == "500ml" || variant == "500g") {
    qty += (500 * count) / 1000;
  }

  else if (variant == "1L" || variant == "1kg") {
    qty += count.toDouble();
  }

});

double rate = getRate(qty, product);

double extraCharge = 0;

variants.forEach((variant, count) {
  if ((product["name"] ?? "")
          .toString()
          .toLowerCase()
          .contains("ghee") &&
      variant == "100ml") {
    extraCharge += 5 * count;
  }
});

final total = (qty * rate) + extraCharge;

      productTotal += total;

      items.add({
  "productId": doc.id,
  "name": product["name"],
  "unit": product["unit"],
  "quantity": qty,
  "variants": variants,
  "rate": rate,
   "extraCharge": extraCharge,
  "total": total,
});
    }

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Select at least one product",
          ),
        ),
      );
      return;
    }

    final shipping =
        getShippingCharge();

    final grandTotal =
        productTotal + shipping;

    await FirebaseFirestore.instance
        .collection(
          Collections.distributorOrders,
        )
        .add({

      "distributorId":
          widget.distributorId,

      "distributorName":
          widget.distributorData["name"],

      "companyName":
          widget.distributorData[
              "companyName"],

      "distributorMobile":
          widget.distributorData[
              "mobile"],

     "customerName": customerName,
"customerMobile": customerMobile,
"customerAddress": customerAddress,

      "brandingType":
          brandingType,

      "notes":
          notesController.text.trim(),

      "items": items,

      "productTotal":
          productTotal,

      "shippingCharge":
          shipping,

      "grandTotal":
          grandTotal,

      "status": "Pending",

      "createdAt":
          FieldValue.serverTimestamp(),
          
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Order Placed Successfully",
        ),
      ),
    );

    customerNameController.clear();
    customerMobileController.clear();
    customerAddressController.clear();
    notesController.clear();

    setState(() {
      variantQuantities.clear();
    });

  } catch (e) {
    final existingCustomer = await FirebaseFirestore.instance
    .collection(Collections.distributorCustomers)
    .where(
      "distributorId",
      isEqualTo: widget.distributorId,
    )
    .where(
      "mobile",
      isEqualTo: customerMobile,
    )
    .limit(1)
    .get();

if (existingCustomer.docs.isEmpty) {
  await FirebaseFirestore.instance
      .collection(Collections.distributorCustomers)
      .add({
    "distributorId": widget.distributorId,
    "name": customerName,
    "mobile": customerMobile,
    "address": customerAddress,
    "area": "",
    "isActive": true,
    "createdAt": FieldValue.serverTimestamp(),
    "updatedAt": FieldValue.serverTimestamp(),
  });
}

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          e.toString(),
        ),
      ),
    );
  }
},
                  icon:
                      const Icon(Icons.shopping_cart),
                  label: const Text(
                    "PLACE ORDER",
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
}