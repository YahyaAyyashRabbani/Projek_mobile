import 'package:hive/hive.dart';

part 'user.g.dart'; // Hive code generator file

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final String username;

  @HiveField(1)
  final String password;

  User(this.username, this.password);
}
