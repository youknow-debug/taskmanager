import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

enum TaskPriority { low, medium, high }

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime deadline;
  final TaskPriority priority;
  final String category;
  final bool isCompleted;
  final String userId;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.priority,
    required this.category,
    required this.isCompleted,
    required this.userId,
  });

  Task copyWith({bool? isCompleted}) => Task(
        id: id,
        title: title,
        description: description,
        deadline: deadline,
        priority: priority,
        category: category,
        isCompleted: isCompleted ?? this.isCompleted,
        userId: userId,
      );

  Color get priorityColor {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }
}

class AuthProvider extends ChangeNotifier {
  String? _userId;
  bool get isAuth => _userId != null;
  String? get userId => _userId;

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _userId = 'user123';
    notifyListeners();
    return true;
  }

  Future<bool> register(String email, String password, String name) async {
    await Future.delayed(const Duration(seconds: 1));
    _userId = 'user123';
    notifyListeners();
    return true;
  }

  void logout() {
    _userId = null;
    notifyListeners();
  }
}

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  String _searchQuery = '';

  List<Task> get tasks {
    if (_searchQuery.isEmpty) return _tasks;
    return _tasks
        .where(
            (t) => t.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  List<Task> get pendingTasks => _tasks.where((t) => !t.isCompleted).toList();
  List<Task> get completedTasks => _tasks.where((t) => t.isCompleted).toList();

  void loadTasks(String userId) {
    _tasks = [
      Task(
        id: const Uuid().v4(),
        title: 'Завершить проект',
        description: 'Сделать TaskManager приложение',
        deadline: DateTime.now().add(const Duration(days: 1)),
        priority: TaskPriority.high,
        category: 'Работа',
        isCompleted: false,
        userId: userId,
      ),
      Task(
        id: const Uuid().v4(),
        title: 'Купить продукты',
        description: 'Молоко, хлеб, яйца',
        deadline: DateTime.now().add(const Duration(days: 2)),
        priority: TaskPriority.medium,
        category: 'Личное',
        isCompleted: false,
        userId: userId,
      ),
    ];
    notifyListeners();
  }

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void updateTask(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void toggleTask(Task task) {
    updateTask(task.copyWith(isCompleted: !task.isCompleted));
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;
  ThemeMode get mode => _mode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _mode = prefs.getBool('isDark') == true ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggleTheme() async {
    _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _mode == ThemeMode.dark);
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, tp, _) => MaterialApp(
          title: 'TaskManager',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(useMaterial3: true).copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            appBarTheme: const AppBarTheme(centerTitle: true),
          ),
          darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple, brightness: Brightness.dark),
          ),
          themeMode: tp.mode,
          home: const SplashScreen(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/add': (context) => const AddTaskScreen(),
          },
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.deepPurple.shade700],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.task_alt, size: 80, color: Colors.white),
              SizedBox(height: 24),
              Text('TaskManager',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              SizedBox(height: 48),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _form,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.task_alt, size: 64, color: Colors.deepPurple),
                const SizedBox(height: 32),
                Text(_isLogin ? 'Добро пожаловать!' : 'Создать аккаунт',
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _email,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Введите email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pass,
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  obscureText: true,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Введите пароль' : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_form.currentState!.validate()) {
                        final success = _isLogin
                            ? await auth.login(_email.text, _pass.text)
                            : await auth.register(
                                _email.text, _pass.text, 'User');
                        if (success && mounted) {
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      }
                    },
                    child: Text(_isLogin ? 'Войти' : 'Зарегистрироваться'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(_isLogin
                      ? 'Нет аккаунта? Создать'
                      : 'Уже есть аккаунт? Войти'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final tasks = Provider.of<TaskProvider>(context, listen: false);
    tasks.loadTasks(auth.userId!);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final tasks = Provider.of<TaskProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskManager'),
        actions: [
          IconButton(
            icon: Icon(theme.mode == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: theme.toggleTheme,
          ),
          PopupMenuButton<String>(
            onSelected: (_) {
              auth.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text('Выйти')
                    ],
                  )),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: const [DashboardScreen(), TasksScreen(), SettingsScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Главная'),
          NavigationDestination(icon: Icon(Icons.list), label: 'Задачи'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Настройки'),
        ],
      ),
      floatingActionButton: _tab <= 1
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, '/add'),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = Provider.of<TaskProvider>(context);
    final now = DateTime.now();

    return RefreshIndicator(
      onRefresh: () async => tasks.loadTasks('user123'),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Главная',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildCard('Всего', tasks._tasks.length.toString(), Icons.task,
                  Colors.deepPurple),
              _buildCard('Выполнено', tasks.completedTasks.length.toString(),
                  Icons.check_circle, Colors.green),
              _buildCard('В работе', tasks.pendingTasks.length.toString(),
                  Icons.pending, Colors.orange),
              _buildCard(
                  'Просрочено',
                  tasks.pendingTasks
                      .where((t) => t.deadline.isBefore(now))
                      .length
                      .toString(),
                  Icons.warning,
                  Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color),
            ),
            Text(value,
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text(title,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final tasks = Provider.of<TaskProvider>(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _search,
            decoration: InputDecoration(
              hintText: 'Поиск задач...',
              prefixIcon: const Icon(Icons.search),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: _search.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _search.clear();
                        tasks.setSearchQuery('');
                      })
                  : null,
            ),
            onChanged: tasks.setSearchQuery,
          ),
        ),
        Expanded(
          child: tasks.tasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                          _search.text.isEmpty
                              ? 'Нет задач'
                              : 'Ничего не найдено',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.tasks.length,
                  itemBuilder: (_, i) => TaskCard(task: tasks.tasks[i]),
                ),
        ),
      ],
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;
  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final tasks = Provider.of<TaskProvider>(context, listen: false);
    final overdue = !task.isCompleted && task.deadline.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/add', arguments: task),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => tasks.toggleTask(task),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: task.isCompleted
                            ? Colors.green
                            : (overdue ? Colors.red : Colors.grey)),
                    color: task.isCompleted ? Colors.green : Colors.transparent,
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isCompleted ? Colors.grey : null,
                        )),
                    const SizedBox(height: 4),
                    Text(DateFormat('d MMM yyyy, HH:mm').format(task.deadline),
                        style: TextStyle(
                            fontSize: 12,
                            color:
                                overdue ? Colors.red : Colors.grey.shade600)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: task.priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: Text(
                  task.priority.toString().split('.').last.toUpperCase(),
                  style: TextStyle(
                      fontSize: 12,
                      color: task.priorityColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== ИСПРАВЛЕННЫЙ AddTaskScreen ====================

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();

  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = TimeOfDay.now();
  TaskPriority _priority = TaskPriority.medium;
  Task? _editing;

  bool get _isEdit => _editing != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Task) {
      // Проверяем, изменилась ли задача
      if (_editing?.id != args.id) {
        _editing = args;
        _title.text = args.title;
        _desc.text = args.description;
        _date = args.deadline;
        _time = TimeOfDay.fromDateTime(args.deadline);
        _priority = args.priority;
      }
    } else {
      // Сброс для новой задачи
      if (_editing != null) {
        _editing = null;
        _title.clear();
        _desc.clear();
        _date = DateTime.now().add(const Duration(days: 1));
        _time = TimeOfDay.now();
        _priority = TaskPriority.medium;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_isEdit ? 'Редактировать задачу' : 'Новая задача')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Название',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Введите название' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _desc,
              decoration: const InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Дата'),
              subtitle: Text(DateFormat('d MMM yyyy').format(_date)),
              trailing: TextButton(
                onPressed: _pickDate,
                child: const Text('Изменить'),
              ),
            ),
            ListTile(
              title: const Text('Время'),
              subtitle: Text(_time.format(context)),
              trailing: TextButton(
                onPressed: _pickTime,
                child: const Text('Изменить'),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Приоритет',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildPriorityBtn(TaskPriority.low, 'Низкий', Colors.green),
                const SizedBox(width: 8),
                _buildPriorityBtn(
                    TaskPriority.medium, 'Средний', Colors.orange),
                const SizedBox(width: 8),
                _buildPriorityBtn(TaskPriority.high, 'Высокий', Colors.red),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveTask,
              child: Text(_isEdit ? 'Обновить задачу' : 'Создать задачу'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBtn(TaskPriority p, String label, Color color) {
    return Expanded(
      child: Material(
        color: _priority == p ? color.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => setState(() => _priority = p),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: _priority == p ? color : Colors.grey.shade300,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: _priority == p ? color : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) {
      setState(() {
        _time = picked;
      });
    }
  }

  void _saveTask() async {
    if (_form.currentState!.validate()) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final tasks = Provider.of<TaskProvider>(context, listen: false);

      final deadline = DateTime(
        _date.year,
        _date.month,
        _date.day,
        _time.hour,
        _time.minute,
      );

      final task = Task(
        id: _editing?.id ?? const Uuid().v4(),
        title: _title.text,
        description: _desc.text,
        deadline: deadline,
        priority: _priority,
        category: 'Работа',
        isCompleted: _editing?.isCompleted ?? false,
        userId: auth.userId!,
      );

      if (_isEdit) {
        tasks.updateTask(task);
      } else {
        tasks.addTask(task);
      }

      if (context.mounted) Navigator.pop(context);
    }
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Темная тема'),
                  value: theme.mode == ThemeMode.dark,
                  onChanged: (_) => theme.toggleTheme(),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.1),
                        shape: BoxShape.circle),
                    child: Icon(
                        theme.mode == ThemeMode.dark
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        color: Colors.deepPurple),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: const Text('Пользователь'),
                  subtitle: Text(auth.userId ?? 'user@example.com'),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.logout, color: Colors.red),
                  ),
                  title:
                      const Text('Выйти', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    auth.logout();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text('TaskManager v1.0',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Организуй свои задачи эффективно'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
