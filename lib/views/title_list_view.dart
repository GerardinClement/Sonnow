// import 'package:flutter/material.dart';
// import 'package:sonnow/models/release.dart';
// import 'package:sonnow/pages/release_page.dart';
//
// class TitleListView extends StatelessWidget {
//   final List<String> titles;
//
//   const TitleListView({Key? key, required this.titles}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 150,
//       child: titles.isEmpty
//           ? const Center(child: Text("No result"))
//           :  ListView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         itemCount: titles.length,
//         itemBuilder: (context, indx) {
//           return InkWell(
//             onTap: () {
//               // Navigator.push(
//               //   context,
//               //   MaterialPageRoute(
//               //     builder: (context) => ReleasePage(id: titles[index].id),
//               //   ),
//               // );
//               print("Title ID: ${titles[indx].id}");
//             },
//             child: ListTile(
//               leading: ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: Image.network(
//                   "https://coverartarchive.org/release/${titles[index].}/front-250",
//                   width: 50,
//                   height: 50,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) {
//                     return const SizedBox(width: 50, height: 50);
//                   },
//                 ),
//               ),
//               title: Text(titles[index]),
//               subtitle: Text(titles[index]),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }