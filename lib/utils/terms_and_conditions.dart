import 'package:flutter/material.dart';

import 'custom_fonts.dart';

class TermsAndConditionsWidget extends StatelessWidget {
  const TermsAndConditionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Terms & conditions:",
            textAlign: TextAlign.left,
            style: MontserratFont.heading4
                .copyWith(color: Colors.red, fontWeight: FontWeight.bold)),
        const Divider(color: Colors.red),
        Text("1. काम करत असताना फोन बंद होऊ शकतो.",
            textAlign: TextAlign.left,
            style:
                MontserratFont.paragraphSemiBold1.copyWith(color: Colors.red)),
        Text("2. पावती नसल्यास ओळखपत्र सादर करावे लागेल.",
            textAlign: TextAlign.left,
            style:
                MontserratFont.paragraphSemiBold1.copyWith(color: Colors.red)),
        Text("3. ३० दिवसात फोन गोळा करा.",
            textAlign: TextAlign.left,
            style:
                MontserratFont.paragraphSemiBold1.copyWith(color: Colors.red)),
        Text("4. फोन दोनदा दाखवल्यावर पुन्हा शुल्क लागू होईल.",
            textAlign: TextAlign.left,
            style:
                MontserratFont.paragraphSemiBold1.copyWith(color: Colors.red)),
        Text("5. दुकान सोडण्यापूर्वी फोन तपासा.",
            textAlign: TextAlign.left,
            style:
                MontserratFont.paragraphSemiBold1.copyWith(color: Colors.red)),
        Text("6. डिस्प्ले किंवा टचपॅडवर कोणतीही हमी किंवा वॉरंटी नाही.",
            textAlign: TextAlign.left,
            style:
                MontserratFont.paragraphSemiBold1.copyWith(color: Colors.red)),
        Text(
            "7. फोन दुरुस्त करण्याचा खर्च वाढल्यास, ते आधी सूचित केल्याशिवाय करणार नाही.",
            textAlign: TextAlign.left,
            style:
                MontserratFont.paragraphSemiBold1.copyWith(color: Colors.red)),
        Text(
            "8. सॉफ्टवेअरवर कोणतीही हमी किंवा हमी नाही. सॉफ्टवेअर करताना डेटा पुसला जाईल.",
            textAlign: TextAlign.left,
            style:
                MontserratFont.paragraphSemiBold1.copyWith(color: Colors.red)),
        Text("9. मागितलेली दुरुस्तीच केली जाईल. बाकी काहीही तपासले जाणार नाही.",
            textAlign: TextAlign.left,
            style:
                MontserratFont.paragraphSemiBold1.copyWith(color: Colors.red)),
      ],
    );
  }
}
