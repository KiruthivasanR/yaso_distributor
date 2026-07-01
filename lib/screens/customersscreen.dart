import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../config/collections.dart';

class CustomersScreen extends StatefulWidget {
  final String distributorId;

  const CustomersScreen({
    super.key,
    required this.distributorId,
  });

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final searchController = TextEditingController();

  String search = "";
  Future<void> deleteCustomer(
  String customerId,
) async {

  await FirebaseFirestore.instance
      .collection(Collections.distributorCustomers)
      .doc(customerId)
      .delete();

  if (mounted) {

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Customer Deleted",
        ),
      ),
    );

  }
}

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection(Collections.distributorCustomers)
      .where(
        "distributorId",
        isEqualTo: widget.distributorId,
      )
      .snapshots(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const SizedBox();
    }

    final docs = snapshot.data!.docs;

    final total = docs.length;

    final active = docs.where((e) {
      return (e.data() as Map)["isActive"] == true;
    }).length;

    final inactive = total - active;

    return isMobile
    ? Column(
        children: [

          _summaryCard(
            icon: Icons.people,
            color: Colors.blue,
            title: "Total",
            value: "$total Customers",
          ),

          const SizedBox(height: 12),

          _summaryCard(
            icon: Icons.check_circle,
            color: Colors.green,
            title: "Active",
            value: "$active Customers",
          ),

          const SizedBox(height: 12),

          _summaryCard(
            icon: Icons.cancel,
            color: Colors.red,
            title: "Inactive",
            value: "$inactive Customers",
          ),

        ],
      )
    : Row(
        children: [

          Expanded(
            child: _summaryCard(
              icon: Icons.people,
              color: Colors.blue,
              title: "Total",
              value: "$total Customers",
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: _summaryCard(
              icon: Icons.check_circle,
              color: Colors.green,
              title: "Active",
              value: "$active Customers",
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: _summaryCard(
              icon: Icons.cancel,
              color: Colors.red,
              title: "Inactive",
              value: "$inactive Customers",
            ),
          ),

        ],
      );
  },
),

const SizedBox(height:20),

          /// Header

          Row(
            children: [

              const Expanded(
                child: Text(
                  "Customers",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              ElevatedButton.icon(
                onPressed: () {
                  showCustomerDialog();
                },
                icon: const Icon(Icons.add),
                label: const Text("Add Customer"),
              ),
            ],
          ),

          const SizedBox(height: 20),

          TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: "Search customer...",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                search = value.toLowerCase();
              });
            },
          ),

          const SizedBox(height: 20),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(Collections.distributorCustomers)
                  .where(
                    "distributorId",
                    isEqualTo: widget.distributorId,
                  )
                  // .orderBy("createdAt", descending: true)
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

                List<QueryDocumentSnapshot> docs =
                    snapshot.data!.docs;

                docs = docs.where((doc) {
                  final data =
                      doc.data() as Map<String, dynamic>;

                  final name =
                      (data["name"] ?? "")
                          .toString()
                          .toLowerCase();

                  final mobile =
                      (data["mobile"] ?? "")
                          .toString()
                          .toLowerCase();

                  return name.contains(search) ||
                      mobile.contains(search);
                }).toList();

                if (docs.isEmpty) {
                  return const Center(
                    child: Text("No Customers"),
                  );
                }

                if (isMobile) {
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {

                      final doc = docs[index];

                      final customer =
                          doc.data()
                              as Map<String, dynamic>;

                      return Card(
                        margin:
                            const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: ListTile(

                          title: Text(
                            customer["name"] ?? "",
                          ),

                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [

                              Text(
                                customer["mobile"] ??
                                    "",
                              ),
Text(
  "PIN: ${customer["pincode"] ?? ""}",
),

                              Text(
                                customer["address"] ??
                                    "",
                              ),
                            ],
                          ),

                          trailing: PopupMenuButton(
                           itemBuilder: (context) => [

  const PopupMenuItem(
    value: "edit",
    child: Text("Edit"),
  ),

  PopupMenuItem(
    value: "status",
    child: Text(
      customer["isActive"]
          ? "Deactivate"
          : "Activate",
    ),
  ),

  const PopupMenuItem(
    value: "delete",
    child: Text("Delete"),
  ),
],

                            onSelected: (value) {

                              if(value=="delete"){

showDialog(
context: context,
builder:(_){

return AlertDialog(

title:const Text("Delete Customer"),

content:const Text(
"Are you sure?"
),

actions:[

TextButton(
onPressed:(){

Navigator.pop(context);

},
child:const Text("Cancel"),
),

ElevatedButton(

onPressed:()async{

Navigator.pop(context);

await deleteCustomer(doc.id);

},

child:const Text("Delete"),

)

],

);

},
);
                              }

}
                            
                          ),
                        ),
                      );
                    },
                  );
                }

                return SingleChildScrollView(
                  child: DataTable(

                    columns: const [

                      DataColumn(
                        label: Text("Name"),
                      ),

                      DataColumn(
                        label: Text("Mobile"),
                      ),
DataColumn(
  label: Text("PIN Code"),
),

                      DataColumn(
                        label: Text("Status"),
                      ),

                      DataColumn(
                        label: Text("Actions"),
                      ),
                    ],

                    rows: docs.map((doc) {

                      final customer =
                          doc.data()
                              as Map<String, dynamic>;

                      return DataRow(
                        cells: [

                          DataCell(
                            Text(
                              customer["name"],
                            ),
                          ),

                          DataCell(
                            Text(
                              customer["mobile"],
                            ),
                          ),

DataCell(
  Text(
    customer["pincode"] ?? "",
  ),
),

                          DataCell(
                          Chip(

backgroundColor:

customer["isActive"]
? Colors.green.shade100
: Colors.red.shade100,

label:Text(

customer["isActive"]
? "Active"
: "Inactive",

style:TextStyle(

color:

customer["isActive"]
? Colors.green
: Colors.red,

fontWeight:FontWeight.bold,

),

),

)
                          ),

                          DataCell(
                            Row(
                              children: [

                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                  ),
                                  onPressed: () {
                                    showCustomerDialog(
                                      doc: doc,
                                    );
                                  },
                                ),

                                Switch(
                                  value:
                                      customer[
                                          "isActive"],
                                  onChanged:
                                      (value) {
                                    toggleStatus(
                                      doc.id,
                                      customer[
                                          "isActive"],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  Future<void> showCustomerDialog({
    QueryDocumentSnapshot? doc,
  }) async {
    final nameController = TextEditingController(
      text: doc?["name"] ?? "",
    );

    final mobileController = TextEditingController(
      text: doc?["mobile"] ?? "",
    );

    final addressController = TextEditingController(
      text: doc?["address"] ?? "",
    );

    final pinCodeController = TextEditingController(
  text: doc?["pincode"] ?? "",
);
    bool isActive = doc?["isActive"] ?? true;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                doc == null
                    ? "Add Customer"
                    : "Edit Customer",
              ),

              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Customer Name",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextField(
                        controller: mobileController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: "Mobile Number",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextField(
                        controller: addressController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: "Address",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 15),

                   TextField(
  controller: pinCodeController,
  keyboardType: TextInputType.number,
  maxLength: 6,
  decoration: const InputDecoration(
    labelText: "PIN Code",
    hintText: "Ex: 600116",
    counterText: "",
    prefixIcon: Icon(Icons.pin_drop_outlined),
    border: OutlineInputBorder(),
  ),
),
                      const SizedBox(height: 20),

                      SwitchListTile(
                        value: isActive,
                        title: const Text("Active"),
                        onChanged: (value) {
                          setDialogState(() {
                            isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              actions: [

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  onPressed: () async {

                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Enter customer name",
                          ),
                        ),
                      );
                      return;
                    }

                    if (mobileController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Enter mobile number",
                          ),
                        ),
                      );
                      return;
                    }

                    if (addressController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Enter address",
                          ),
                        ),
                      );
                      return;
                    }

                if (pinCodeController.text.trim().length != 6) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Enter a valid 6-digit PIN Code"),
    ),
  );
  return;
}

                    if (doc == null) {

                      await addCustomer(
                        name: nameController.text.trim(),
                        mobile: mobileController.text.trim(),
                        address: addressController.text.trim(),
                        pincode: pinCodeController.text.trim(),
                        isActive: isActive,
                      );

                    } else {

                      await updateCustomer(
                        customerId: doc.id,
                        name: nameController.text.trim(),
                        mobile: mobileController.text.trim(),
                        address: addressController.text.trim(),
                        pincode: pinCodeController.text.trim(),
                        isActive: isActive,
                      );

                    }

                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    doc == null ? "Save" : "Update",
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
    Future<void> addCustomer({
    required String name,
    required String mobile,
    required String address,
required String pincode,
    required bool isActive,
  }) async {
    try {
      final alreadyExists = await FirebaseFirestore.instance
    .collection(Collections.distributorCustomers)
    .where(
      "distributorId",
      isEqualTo: widget.distributorId,
    )
    .where(
      "mobile",
      isEqualTo: mobile,
    )
    .get();

if (alreadyExists.docs.isNotEmpty) {
  throw Exception(
    "Customer already exists with this mobile number",
  );
}
      await FirebaseFirestore.instance
          .collection(Collections.distributorCustomers)
          
          .add({
        "distributorId": widget.distributorId,
        "name": name,
        "mobile": mobile,
        "address": address,
        "pincode": pincode,
        "isActive": isActive,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Customer Added Successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> updateCustomer({
    required String customerId,
    required String name,
    required String mobile,
    required String address,
   required String pincode,
    required bool isActive,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection(Collections.distributorCustomers)
          .doc(customerId)
          .update({
        "name": name,
        "mobile": mobile,
        "address": address,
       "pincode": pincode,
        "isActive": isActive,
        "updatedAt": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Customer Updated Successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> toggleStatus(
    String customerId,
    bool currentStatus,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection(Collections.distributorCustomers)
          .doc(customerId)
          .update({
        "isActive": !currentStatus,
        "updatedAt": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              !currentStatus
                  ? "Customer Activated"
                  : "Customer Deactivated",
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  Widget _summaryCard({
  required IconData icon,
  required Color color,
  required String title,
  required String value,
}) {
  return Card(
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(value),
    ),
  );
}
}