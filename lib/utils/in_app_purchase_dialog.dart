import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:translation_app/providers/app_state_provider.dart';
// import 'package:translation_app/src/providers/running_state_provider.dart';
import 'package:translation_app/utils/utils.dart';

class InAppPurchaseDialog extends StatefulWidget {
  const InAppPurchaseDialog({super.key});

  @override
  _InAppPurchaseDialogState createState() => _InAppPurchaseDialogState();
}

class _InAppPurchaseDialogState extends State<InAppPurchaseDialog> {
  Future<void> _getProducts() async {
    try {
      print("$isTestAd, $testIAPId, $proIAPId");
      final ProductDetailsResponse response =
          await InAppPurchase.instance.queryProductDetails({isTestAd ? testIAPId : proIAPId});

      if (response.notFoundIDs.isNotEmpty) {
        // Handle not found products
        print("Product not found");

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Something went wrong, Please check your connection.',
            style: TextStyle(color: Colors.deepOrange[600]),
          ),
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 100),
          behavior: SnackBarBehavior.floating,
        ));
      }

      final ProductDetails productDetails = response.productDetails.first;

      // Use productDetails to display information about your pro version

      final bool purchaseDetails = await InAppPurchase.instance
          .buyNonConsumable(purchaseParam: PurchaseParam(productDetails: productDetails));

      if (mounted) {
        if (purchaseDetails) {
          // print(purchaseDetails);
          // Provider.of<RunningStateProvider>(context, listen: false).setPaid();

          print("Payment successful");
        } else {
          Provider.of<AppStateProvider>(context, listen: false).setUnpaid();
          print("Payment unsuccessful");
        }
        Navigator.pop(context);
      }
    } catch (err) {
      print("Error related to payment $err");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Container(
            height: 500,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Pro Version",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                ListTile(
                    title: const Text("No Advertising"),
                    leading: Icon(
                      Icons.check_box_outlined,
                      color: Colors.blueAccent[600],
                    )),
                ListTile(
                    title: const Text("Continuous scanning/Batch scan"),
                    leading: Icon(
                      Icons.check_box_outlined,
                      color: Colors.blueAccent[600],
                    )),
                ListTile(
                    title: const Text("Confirm scan manually"),
                    leading: Icon(
                      Icons.check_box_outlined,
                      color: Colors.blueAccent[600],
                    )),
                ListTile(
                    title: const Text("One time purchase"),
                    leading: Icon(
                      Icons.check_box_outlined,
                      color: Colors.blueAccent[600],
                    )),
                const Divider(height: 30),
                SizedBox(
                  // alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width, // Use full screen width
                  height: 40,
                  child: TextButton(
                    onPressed: _getProducts,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(const Color(0xD00584E0)),
                      // Additional styling for text button as needed
                    ),
                    child: const Text(
                      "Buy",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                )
              ],
            ))
        // Stack(
        //   children: [
        //     const Positioned(
        //       top: 20.0,
        //       left: 20.0,
        //       right: 20.0,
        //       child: Text(
        //         "asdqwer",
        //         style: TextStyle(fontSize: 20.0),
        //       ),
        //     ),
        //     Positioned(
        //       top: 60.0,
        //       left: 20.0,
        //       right: 20.0,
        //       child: TextButton(
        //         onPressed: _getProducts,
        //         child: const Text("Buy"),
        //       ),
        //     ),
        //     Positioned(
        //       bottom: 10.0,
        //       right: 10.0,
        //       child: TextButton(
        //         onPressed: () => Navigator.pop(context),
        //         child: const Text('Close'),
        //       ),
        //     ),
        //   ],
        // ),
        );
  }
}
