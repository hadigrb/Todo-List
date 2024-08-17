import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:task_list/data.dart';

const taskBoxName = 'tasks';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(PriorityAdapter());
  await Hive.openBox<TaskEntity>(taskBoxName);
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: primaryColor));
  runApp(const MyApp());
}

const primaryColor = Color(0xff5C0AFF);
const secondaryColor = Color(0xff794CFF);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final primaryTextColor = const Color(0xff1D2830);
  final secondaryTextColor = const Color(0xffAFBED0);

  // This widget is the root of your application.Ta
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xffe6ebfa),
        inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: secondaryTextColor),
            iconColor: secondaryTextColor,
            border: InputBorder.none,
            focusedBorder: InputBorder.none),
        colorScheme: ColorScheme.light(
            primary: primaryColor,
            secondary: secondaryColor,
            onBackground: primaryTextColor,
            surface: secondaryTextColor,
            onSurface: primaryTextColor,
            onSecondary: Colors.white,
            onPrimary: Colors.white),
        textTheme: const TextTheme(
            titleLarge: TextStyle(fontSize: 20),
            titleMedium: TextStyle(fontSize: 18)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<TaskEntity>(taskBoxName);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return EditTaskScreen();
              }));
            },
            label: const Text('Add a new task')),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 102,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
                  secondaryColor,
                  primaryColor,
                ]),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12, left: 8, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ToDo List',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .apply(color: Colors.white),
                        ),
                        Icon(CupertinoIcons.share,
                            color: Theme.of(context).colorScheme.onPrimary)
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                    child: Container(
                      height: 38,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(19),
                        color: Theme.of(context).colorScheme.onPrimary,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                            label: const Text('Search task..'),
                            prefixIcon: Icon(
                              CupertinoIcons.search,
                              color: Theme.of(context)
                                  .inputDecorationTheme
                                  .iconColor,
                            )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Today',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(fontWeight: FontWeight.w900),
                            ),
                            Container(
                              height: 4,
                              width: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          ],
                        ),
                        MaterialButton(
                          onPressed: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Delete all',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface),
                              ),
                              const SizedBox(
                                width: 3,
                              ),
                              Icon(
                                CupertinoIcons.trash,
                                color: Theme.of(context).colorScheme.surface,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Expanded(
                      child: ValueListenableBuilder<Box<TaskEntity>>(
                        builder: (context, value, child) {
                          return ListView.builder(
                              itemCount: box.values.length,
                              itemBuilder: (context, index) {
                                final TaskEntity task =
                                    box.values.toList()[index];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: TaskItem(task: task),
                                );
                              });
                        },
                        valueListenable: box.listenable(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskItem extends StatefulWidget {
  const TaskItem({
    super.key,
    required this.task,
  });

  final TaskEntity task;

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          widget.task.isCompleted = !widget.task.isCompleted;
        });
      },
      child: Container(
        height: 65,
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20),
        ], color: Colors.white, borderRadius: BorderRadius.circular(3)),
        child: Row(
          children: [
            MyTaskCheck(value: widget.task.isCompleted),
            Text(widget.task.name),
          ],
        ),
      ),
    );
  }
}

class MyTaskCheck extends StatelessWidget {
  final bool value;

  const MyTaskCheck({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Container(
        height: 24,
        width: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: value
              ? null
              : Border.all(color: Theme.of(context).colorScheme.surface),
          color: value ? Theme.of(context).colorScheme.primary : null,
        ),
        child: value
            ? const Icon(
                CupertinoIcons.check_mark,
                color: Colors.white,
                size: 16,
              )
            : null,
      ),
    );
  }
}

class EditTaskScreen extends StatelessWidget {
  EditTaskScreen({super.key});

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            final task = TaskEntity();
            task.name = _controller.text;
            task.priority = Priority.low;
            if (task.isInBox) {
              task.save();
            } else {
              final Box<TaskEntity> box = Hive.box(taskBoxName);
              box.add(task);
            }
            Navigator.of(context).pop();
          },
          label: const Text('save Changes')),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            decoration:
                const InputDecoration(label: Text('add a task for today...')),
          )
        ],
      ),
    );
  }
}
