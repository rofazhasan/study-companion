import 'package:isar/isar.dart';

part 'battle_history.g.dart';

@collection
class BattleHistory {
  Id id = Isar.autoIncrement;

  late String battleId;
  late String topic;
  late DateTime date;
  late int score;
  late int rank;
  late int totalPlayers;
  late bool isWinner;
  late String sessionJson; // Store full session data for detailed review
}
