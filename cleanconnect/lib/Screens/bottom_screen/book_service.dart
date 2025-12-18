import 'package:cleanconnect/Screens/dashboard_screen.dart';
import 'package:flutter/material.dart';

class BookService extends StatefulWidget {
  const BookService({super.key});

  @override
  State<BookService> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookService> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String selectedService = "Home Cleaning";
  String selectedDuration = "2 hours";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER SECTION
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF61A8C7),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                     onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context)=> const DashboardScreen())
                      );
                  },
                    ),
                  ),
                  const Center(
                    child: Text(
                      "Book a Service",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ),

            // BODY INPUTS
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // Select Service
                  const Text(
                    "Select Service Type",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    value: selectedService,
                    decoration: const InputDecoration(border: InputBorder.none),
                    items: const [
                      DropdownMenuItem(
                        value: "Home Cleaning",
                        child: Row(
                          children: [
                            Icon(Icons.home, color: Colors.orange),
                            SizedBox(width: 8),
                            Text("Home Cleaning"),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Office Cleaning",
                        child: Row(
                          children: [
                            Icon(Icons.home_max, color: Colors.orange),
                            SizedBox(width: 8),
                            Text("Office Cleaning"),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Window Cleaning",
                        child: Row(
                          children: [
                            Icon(Icons.window, color: Colors.orange),
                            SizedBox(width: 8),
                            Text("Window Cleaning"),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Carpet Cleaning",
                        child: Row(
                          children: [
                            Icon(Icons.local_laundry_service, color: Colors.orange),
                            SizedBox(width: 8),
                            Text("Carpet Cleaning"),
                          ],
                          
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedService = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 25),

                 /// Choose Date
                  // const Text("Choose Date"),
                  // const SizedBox(height: 8),
                  // TextFormField(
                  //   controller: dateController,
                  //   readOnly: true,
                  //   decoration: InputDecoration(
                  //     hintText: "mm/dd/yyyy",
                  //     suffixIcon: Icon(Icons.calendar_today_outlined),
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(10),
                  //     ),
                  //   ),
                  //   onTap: () async {
                  //     DateTime? pickedDate = await showDatePicker(
                  //       context: context,
                  //       initialDate: DateTime.now(),
                  //       firstDate: DateTime(2020),
                  //       lastDate: DateTime(2100),
                  //     );
      
                  //     if (pickedDate != null) {
                  //       dateController.text =
                  //           "${pickedDate.month}/${pickedDate.day}/${pickedDate.year}";
                  //     }
                  //   },
                  // ),

                  // const SizedBox(height: 25),

                  // /// Choose Time
                  //  const Text("Choose Time"),
                  //  const SizedBox(height: 8),
                  //  TextFormField(
                  //    controller: timeController,
                  //    readOnly: true,
                  //    decoration: InputDecoration(
                  //      hintText: "--:-- --",
                  //      suffixIcon: Icon(Icons.access_time),
                  //      border: OutlineInputBorder(
                  //        borderRadius: BorderRadius.circular(10),
                  //      ),
                  //    ),
                  //    onTap: () async {
                  //      TimeOfDay? pickedTime = await showTimePicker(
                  //        context: context,
                  //        initialTime: TimeOfDay.now(),
                  //      );

                  //      if (pickedTime != null) {
                  //        timeController.text = pickedTime.format(context);
                  //      }
                  //    },
                  //  ),

                  // const SizedBox(height: 25),

                  // /// Service Address
                  // const Text("Service Address"),
                  // const SizedBox(height: 8),
                  // TextFormField(
                  //   controller: addressController,
                  //   decoration: InputDecoration(
                  //     hintText: "Enter your address",
                  //     suffixIcon: Icon(Icons.location_on_outlined),
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(10),
                  //           ),
                  //         ),
                  //       ),

                  // const SizedBox(height: 25),

                  // // Duration
                  // const Text("Duration (Hours)",
                  //     style: TextStyle(fontWeight: FontWeight.w600)),
                  // const SizedBox(height: 5),
                  // DropdownButtonFormField<String>(
                  //   value: selectedDuration,
                  //   decoration: const InputDecoration(border: InputBorder.none),
                  //   items: const [
                  //     DropdownMenuItem(
                  //       value: "2 hours",
                  //       child: Text("2 hours"),
                  //     ),
                  //     DropdownMenuItem(
                  //       value: "3 hours",
                  //       child: Text("3 hours"),
                  //     ),
                  //   ],
                  //   onChanged: (value) {
                  //     setState(() {
                  //       selectedDuration = value!;
                  //     });
                  //   },
                  // ),

                  // const SizedBox(height: 25),

                  // // PRICE BREAKDOWN BOX
                  // Container(
                  //   width: double.infinity,
                  //   padding: const EdgeInsets.all(15),
                  //   decoration: BoxDecoration(
                  //     color: const Color(0xFFD1F2F5),
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: const [
                  //       Text(
                  //         "💲 Price Breakdown",
                  //         style: TextStyle(
                  //           fontWeight: FontWeight.bold,
                  //           fontSize: 16,
                  //         ),
                  //       ),
                  //       SizedBox(height: 10),

                  //       Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           Text("Hourly rate"),
                  //           Text("\$35/hr"),
                  //         ],
                  //       ),
                  //       SizedBox(height: 5),

                  //       Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           Text("Duration"),
                  //           Text("2 hour(s)"),
                  //         ],
                  //       ),

                  //       Divider(),

                  //       Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           Text(
                  //             "Total",
                  //             style: TextStyle(
                  //                 fontWeight: FontWeight.bold, fontSize: 18),
                  //           ),
                  //           Text(
                  //             "\$70",
                  //             style: TextStyle(
                  //                 fontWeight: FontWeight.bold, fontSize: 18),
                  //           ),
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  const SizedBox(height: 550),

                  // Confirm Booking Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF61A8C7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Confirm Booking",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
