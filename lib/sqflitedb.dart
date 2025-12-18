import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlDb {

  static Database? _db ; 
  
  Future<Database?> get db async {
      if (_db == null){
        _db  = await intialDb() ;
        return _db ;  
      }else {
        return _db ; 
      }
  }


intialDb() async {
  String databasepath = await getDatabasesPath() ; 
  String path = join(databasepath , 'graduate .db') ;   
  Database mydb = await openDatabase(path , onCreate: _onCreate , version: 1  , onUpgrade:_onUpgrade ) ;  
  return mydb ; 
}

_onUpgrade(Database db , int oldversion , int newversion ) {


 print("onUpgrade =====================================") ; 
  
}

_onCreate(Database db , int version) async {
  await db.execute('''
  CREATE TABLE "users" (
    "user_id" INTEGER  NOT NULL PRIMARY KEY  AUTOINCREMENT,
    "email" TEXT NOT NULL,
    "password" TEXT NOT  NULL,
    "fname" TEXT NOT  NULL,
    "lname" TEXT NOT  NULL,
    "admin" BOOLAN DEFAULT FALSE
  )
 ''') ;


 await db.execute('''
  CREATE TABLE "projects" (
    "project_id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "technologies" TEXT NOT NULL,
    "github_url" TEXT, 
    "pdf_url" TEXT,
    "image_url" TEXT,
    "year" TEXT NOT NULL,
    "user_id" INTEGER NOT NULL,
    FOREIGN KEY ("user_id") REFERENCES "users" ("user_id") ON DELETE CASCADE
  )
  ''');

  await db.execute('''
  CREATE TABLE "saved_projects" (
    "sp_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "project_id" INTEGER NOT NULL,
    "user_id" INTEGER NOT NULL,
    saved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("user_id") REFERENCES "users" ("user_id")
    FOREIGN KEY ("project_id") REFERENCES "projects" ("project_id")
  )
  ''');

  await db.execute('''
  CREATE TABLE comments (
    comment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    comment TEXT NOT NULL,
    rating REAL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects (project_id),
    FOREIGN KEY (user_id) REFERENCES users (user_id)
  )
''');



}

readData(String sql) async {
  Database? mydb = await db ; 
  List<Map> response = await  mydb!.rawQuery(sql);
  return response ; 
}
insertData(String sql) async {
  Database? mydb = await db ; 
  int  response = await  mydb!.rawInsert(sql);
  return response ; 
}
updateData(String sql) async {
  Database? mydb = await db ; 
  int  response = await  mydb!.rawUpdate(sql);
  return response ; 
}
deleteData(String sql) async {
  Database? mydb = await db ; 
  int  response = await  mydb!.rawDelete(sql);
  return response ; 
}
 

// delete database
mydeletetabase()
  async {
  String databasepath = await getDatabasesPath() ; 
  String path = join(databasepath , 'graduate .db') ;   
  await deleteDatabase(path);

}


// SELECT 
// DELETE 
// UPDATE 
// INSERT 
 

}