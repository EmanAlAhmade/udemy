import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:udemy/modules/archived/archived.dart';
import 'package:udemy/modules/done/done.dart';
import 'package:udemy/modules/tasks/tasks.dart';
import 'package:udemy/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates>{


  AppCubit(AppStates AppInitialState) : super(AppInitialState);

  static AppCubit get(context) => BlocProvider.of(context);

  int bottmindex=0;

  List <String>titles=[
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

  List <Widget> screens=[
    Tasks(),
    Done(),
    Archived(),
  ];
  
  void changeIndex(int index){
    bottmindex=index;
    emit(AppChangeBottomNavBarState());
  }

  Database? database;
  //List<Map> tasks=[];
  List <Map> newTasks=[];
  List <Map> doneTasks=[];
  List <Map> archivedTasks=[];

  void createDataBase(){
    openDatabase(
        'todo.db',
        version: 1,
        onCreate:(database,version){
          // id integer
          // title String
          // date String
          // time String
          // status String

          print('database created');
          //executeترجع SQL Future عشان كذا بستخدم
          //async ,await والا استخدم الطريقة الثانية
          //اللى استخدمتها هنا then
          database.execute
            ('CREATE TABLE  tasks(id INTEGER PRIMARY KEY,title TEXT,date TEXT,time TEXT,status TEXT)')
              .then((value) {
            print('table created');

          }).catchError((error){
            print('error when Creating Table ${error.toString})');
          });
        },
        onOpen: (database){
          getDataBase(database);
          print('database opened');

        }
        ).then((value) {
      database=value;
      emit(AppCreateDatabaseStates());
    });

  }
  //طريقة للاضافة لقاعدة البيانات
  // void insertDataBase() async{
  //  await database?.transaction((txn) {
  //     return txn.rawInsert('INSERT INTO tasks (title,date,time,status) VALUES("3","2","1","new")');
  //   });
  //}

  Future insertDataBase({required String title,required String data,required String time}) async{
    database?.transaction((txn) {
      return txn.rawInsert('INSERT INTO tasks (title,date,time,status) '
          'VALUES("$title","$data","$time","new")')
          .then((value) {
        print('$value inserted successfully');
        emit(AppInsertDatabaseStates());

        getDataBase(database);

      }).catchError((error){print('error is inserting  ${error.toString()}');});
    });
  }





  void getDataBase(database)
  {
     newTasks=[];
     doneTasks=[];
     archivedTasks=[];
    emit(AppGetDatabaseLoadingStates());
     database.rawQuery('SELECT *FROM tasks').then((value) {

       value.forEach((element) {
         if (element['status'] == 'new') {
           newTasks.add(element);
         }
         else if (element['status'] =="done") {
          doneTasks.add(element);
        } else {
          archivedTasks.add(element);
          print('arch');
        }
       // print(element['status']) ;
      }
       );


       emit(AppGetDatabaseStates());
     });

  }



  bool isOpen=false;
  IconData iconSheet=Icons.edit;

  void changeBottomSheetStates({required bool isShow,  required IconData icon}){
    isOpen=isShow;
    iconSheet=icon;
    emit(AppChangeBottomSheetState());
  }


//id int يكتب بدون اقواس
  void updateData({required String status,required int id})async
  {
    database!.rawUpdate(
        'UPDATE tasks SET status = ? WHERE id = ?',
        ['$status',id]).then((value) {

             getDataBase(database);
          emit(AppUpdateDatabaseStates());
    });
  }


void deleteData({required int id})
{

  database!.rawDelete('DELETE FROM tasks WHERE id=?',[id]).then((value) {

   getDataBase(database) ;
   emit(AppDeleteDatabaseStates());
} );
}


}