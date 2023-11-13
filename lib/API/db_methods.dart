import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';
import 'package:GamersGlint/API/db_classes.dart';

class Database {
  Future<Isar> open() async {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [AccountSchema],
      directory: dir.path,
    );
    return isar;
  }

  Future<void> close(isar) async {
    isar.close();
  }
}

class Methods {
  Future<void> insertUpdateAcc(user) async {
    Database db = Database();
    final isar = await db.open();
    isar.writeTxn(() => isar.accounts.put(user));
  
    await db.close(isar);
  }

  Future<Account?> getUserById(id) async {
    Database db = Database();
    final isar = await db.open();
    final user = await isar.accounts.get(id);
    db.close(isar);
    return user;
  }
}
