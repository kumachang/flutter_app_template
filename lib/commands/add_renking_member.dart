import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sort_key_generator/sort_key_generator.dart';
import 'package:uuid/uuid.dart';

import '../domain/my_ranking/entities/ranking_member.dart';
import '../domain/my_ranking/references/ranking_member_reference.dart';

final addRankingMember = Provider((ref) => const AddRankingMember());

/// Create new ranking member document by title.
class AddRankingMember {
  const AddRankingMember();

  Future<void> call({
    required String rankingId,
    required String title,
    required String description,
    File? imageFile,
    required int targetIndex,
    required List<QueryDocumentSnapshot<RankingMember>> memberDocs,
  }) async {
    assert(title.isNotEmpty);

    final previousIndex = targetIndex - 1;
    final previous = previousIndex.isNegative
        ? null
        : memberDocs[previousIndex].data().order;
    final nextIndex = targetIndex;
    final next = nextIndex >= memberDocs.length
        ? null
        : memberDocs[nextIndex].data().order;
    final order = generateSortKeyDouble(previous: previous, next: next);
    if (order == null) {
      // TODO(Riscait): Order生成が破綻。振り直しが必要
      return;
    }
    var newMember = RankingMember(
      title: title,
      description: description,
      order: order,
    );

    final memberId = const Uuid().v4();

    if (imageFile != null) {
      // 写真ファイルがある
      final ref = rankingMemberImageRef(
        rankingId: rankingId,
        memberId: memberId,
      );
      await ref.putFile(
        imageFile,
        SettableMetadata(cacheControl: 'public, max-age=31536000'),
      );
      newMember = newMember.copyWith(imageUrl: await ref.getDownloadURL());
    }

    await rankingMemberRef(
      rankingId: rankingId,
      memberId: memberId,
    ).set(newMember);
  }
}
