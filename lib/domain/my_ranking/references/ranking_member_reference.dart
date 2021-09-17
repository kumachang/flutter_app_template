import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';

import '../../../commons/json_converter/timestamp_supplementer.dart';
import '../entities/ranking_member.dart';
import 'my_ranking_reference.dart';

/// Reference
/// rankings/:rankingId/members コレクションの参照を取得する
final myRankingMemberColRefProvider =
    Provider.family<CollectionReference<RankingMember>, String>((
  ref,
  rankingId,
) {
  return ref
      .read(myRankingColRefProvider)
      .doc(rankingId)
      .collection('members')
      .withConverter(
        fromFirestore: (doc, _) => RankingMember.fromJson(doc.data()!),
        toFirestore: (entity, _) => entity.toJson().suppelementTimestamp(),
      );
});

/// Reference
/// rankings/:rankingId/members/:memberId ドキュメントの参照を取得する
final myRankingMemberDocRefProvider =
    Provider.family<DocumentReference<RankingMember>, Tuple2<String, String>>((
  ref,
  rankingIdAndMemberId,
) {
  return ref
      .read(myRankingDocRefProvider(rankingIdAndMemberId.item1))
      .collection('members')
      .doc(rankingIdAndMemberId.item2)
      .withConverter(
        fromFirestore: (doc, _) => RankingMember.fromJson(doc.data()!),
        toFirestore: (entity, _) => entity.toJson().suppelementTimestamp(),
      );
});

/// Firebase Storage: rankings/[rankingId]/members/[filePath]
/// if filePath is null, Generate uuid.
Reference myRankingMemberImageRef({
  required String rankingId,
  required String memberId,
  String? filePath,
}) {
  final path = filePath ?? const Uuid().v4();
  return FirebaseStorage.instance
      .ref('rankings')
      .child(rankingId)
      .child('members')
      .child(memberId)
      .child(path);
}
