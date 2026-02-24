import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/api_service.dart';
import '../providers/theme_provider.dart';
import 'note_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Note>> _futureNotes;
  DateTime _selectedDate = DateTime.now();
  bool _isWeeklyView = false;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() {
    setState(() {
      _futureNotes = _apiService.getNotes();
    });
  }

  List<Note> _getNotesForDate(List<Note> notes, DateTime date) {
    return notes.where((note) {
      try {
        final noteDate = DateTime.parse(note.createdAt);
        return noteDate.year == date.year &&
               noteDate.month == date.month &&
               noteDate.day == date.day;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  List<DateTime> _getWeekDays(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Calendario',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: Icon(
                _isWeeklyView ? Icons.calendar_month : Icons.view_week,
                color: isDarkMode ? Colors.white : Colors.blue,
                size: 22,
              ),
              onPressed: () {
                setState(() {
                  _isWeeklyView = !_isWeeklyView;
                });
              },
              tooltip: _isWeeklyView ? 'Vista mensual' : 'Vista semanal',
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Note>>(
        future: _futureNotes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
                strokeWidth: 3,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Error al cargar el calendario',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode ? Colors.white70 : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loadNotes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final notes = snapshot.data ?? [];

          return Column(
            children: [
              // Selector de fecha
              Container(
                padding: const EdgeInsets.all(16),
                color: isDarkMode ? Colors.grey[850] : Colors.white,
                child: Column(
                  children: [
                    // Mes y año
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.chevron_left,
                            color: isDarkMode ? Colors.white70 : Colors.grey[800],
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedDate = DateTime(
                                _selectedDate.year,
                                _selectedDate.month - 1,
                                1,
                              );
                            });
                          },
                        ),
                        Text(
                          '${_months[_selectedDate.month - 1]} ${_selectedDate.year}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.chevron_right,
                            color: isDarkMode ? Colors.white70 : Colors.grey[800],
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedDate = DateTime(
                                _selectedDate.year,
                                _selectedDate.month + 1,
                                1,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Vista del calendario
                    _isWeeklyView
                        ? _buildWeeklyView(notes, isDarkMode)
                        : _buildMonthlyView(notes, isDarkMode),
                  ],
                ),
              ),
              
              // Lista de notas del día seleccionado
              Expanded(
                child: _buildNotesForSelectedDay(notes, isDarkMode),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMonthlyView(List<Note> notes, bool isDarkMode) {
    final daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final startingWeekday = firstDayOfMonth.weekday;

    return Column(
      children: [
        // Días de la semana
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['L', 'M', 'M', 'J', 'V', 'S', 'D']
              .map((day) => Expanded(
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ))
              .toList(),
        ),
        
        const SizedBox(height: 8),
        
        // Días del mes
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: 42,
          itemBuilder: (context, index) {
            final day = index - startingWeekday + 2;
            final date = DateTime(_selectedDate.year, _selectedDate.month, day);
            
            if (day < 1 || day > daysInMonth) {
              return Container();
            }
            
            final notesForDay = _getNotesForDate(notes, date);
            final isSelected = date.year == _selectedDate.year &&
                               date.month == _selectedDate.month &&
                               date.day == _selectedDate.day;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = date;
                });
              },
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.blue 
                      : (isDarkMode ? Colors.grey[800] : null),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        day.toString(),
                        style: TextStyle(
                          color: isSelected 
                              ? Colors.white 
                              : (isDarkMode ? Colors.white70 : Colors.black87),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (notesForDay.isNotEmpty)
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWeeklyView(List<Note> notes, bool isDarkMode) {
    final weekDays = _getWeekDays(_selectedDate);
    
    return Column(
      children: [
        // Días de la semana
        SizedBox(
          height: 90,
          child: Row(
            children: weekDays.map((date) {
              final notesForDay = _getNotesForDate(notes, date);
              final isSelected = date.year == _selectedDate.year &&
                                 date.month == _selectedDate.month &&
                                 date.day == _selectedDate.day;
              
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.blue 
                          : (isDarkMode ? Colors.grey[800] : Colors.grey[100]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _weekDays[date.weekday - 1],
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected 
                                ? Colors.white 
                                : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected 
                                ? Colors.white 
                                : (isDarkMode ? Colors.white70 : Colors.black87),
                          ),
                        ),
                        if (notesForDay.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesForSelectedDay(List<Note> notes, bool isDarkMode) {
    final notesForDay = _getNotesForDate(notes, _selectedDate);
    
    if (notesForDay.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
              size: 60,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay notas para este día',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notesForDay.length,
      itemBuilder: (context, index) {
        final note = notesForDay[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: isDarkMode ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            title: Text(
              note.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(
              note.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                _formatTime(note.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.white70 : Colors.grey[600],
                ),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteDetailScreen(note: note),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatTime(String date) {
    try {
      if (date.length >= 16) {
        return date.substring(11, 16);
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  static const List<String> _months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  static const List<String> _weekDays = [
    'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'
  ];
}