
// class PreviewMyPost extends StatelessWidget {
//   final PostModel mypost;
//   const PreviewMyPost({required this.mypost, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FutureProvider<bool?>(
//         create: (context) =>
//             context.read<PostProvider>().updatePost(context, mypost),
//         initialData: null,
//         child: Consumer<bool?>(builder: (context, isFinished, child) {
//           return PostDetailsScreen(
//             isMyPostPreview: true,
//             myPost: mypost,
//           );
//         }));
//   }
// }
