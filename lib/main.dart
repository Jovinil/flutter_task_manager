import 'package:task_manager/bloc/task_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/task_bloc.dart';
import 'services/api_service.dart';
import 'views/task_list.dart';

void main() {
 runApp(MyApp());
}

class MyApp extends StatelessWidget {
 @override
 Widget build(BuildContext context) {
   return MultiBlocProvider(
     providers: [
       BlocProvider(
         create: (context) => TaskBloc(ApiService())..add(LoadTasks()), // Initialize with LoadTasks event
       ),
     ],
     child: MaterialApp(
       debugShowCheckedModeBanner: false,
       title: "Flutter BLoC CRUD",
       theme: ThemeData(primarySwatch: Colors.blue),
       home: TaskList(),
     ),
   );
 }
}
