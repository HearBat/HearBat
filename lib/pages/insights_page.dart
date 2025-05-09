import 'package:flutter/material.dart';
import 'package:hearbat/widgets/top_bar_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'missed_words_page.dart';
import 'missed_sounds_page.dart';

class InsightsPage extends StatefulWidget {
  @override
  InsightsPageState createState() => InsightsPageState();
}

class InsightsPageState extends State<InsightsPage> {
  DateTime _focusedDay = DateTime.now(); // Current day

  // Navigate to previous month
  void _goToPreviousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
    });
  }

  // Navigate to next month
  void _goToNextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
    });
  }

  // Get month name and year as string
  String _formattedMonthYear(DateTime date) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${monthNames[date.month - 1]} ${date.year}';
  }

  // Progress bar header
  String _formattedToday(DateTime date) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    String suffix(int day) {
      if (day >= 11 && day <= 13) return 'th';
      switch (day % 10) {
        case 1: return 'st';
        case 2: return 'nd';
        case 3: return 'rd';
        default: return 'th';
      }
    }

    return 'Today, ${monthNames[date.month - 1]} ${date.day}${suffix(date.day)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: 'INSIGHTS'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildCalendar(),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

Widget _buildCalendar() {
  DateTime today = DateTime.now();
  double progressBarValue = 0.6;
  int timePracticed = 40;
  int speechAccuracy = 78;
  int noiseAccuracy = 8;

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 7, 45, 78),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _goToPreviousMonth,
                      child: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Text(
                      _formattedMonthYear(_focusedDay),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    GestureDetector(
                      onTap: _goToNextMonth,
                      child: Icon(Icons.arrow_forward, color: Colors.white),
                    ),
                  ],
                ),
              ),

              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                onPageChanged: (newFocusedDay) {
                  setState(() {
                    _focusedDay = newFocusedDay;
                  });
                },
                startingDayOfWeek: StartingDayOfWeek.sunday,
                headerVisible: false,
                daysOfWeekHeight: 16,
                daysOfWeekStyle: DaysOfWeekStyle(
                  dowTextFormatter: (date, locale) {
                    final weekday = date.weekday;
                    return ['S', 'M', 'T', 'W', 'T', 'F', 'S'][weekday % 7];
                  },
                  weekdayStyle: TextStyle(
                    color: Color.fromARGB(179, 0, 0, 0),
                    fontWeight: FontWeight.bold,
                  ),
                  weekendStyle: TextStyle(
                    color: Color.fromARGB(179, 0, 0, 0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  cellMargin: EdgeInsets.zero,
                  cellPadding: EdgeInsets.symmetric(vertical: 4),
                  todayDecoration: BoxDecoration(
                    color: Color.fromARGB(255, 7, 45, 78),
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  weekendTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Daily tracker page
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            // Dark blue tracker header
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 7, 45, 78),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: 
                Center(
                  child: Text(
                  _formattedToday(today),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18, 
                    ),
                  ),
                ),
              ),

              // Tracker content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Time practiced',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${timePracticed}m',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                    value: progressBarValue,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromARGB(255, 110, 211, 97),
                    ),
                    minHeight: 12,
                  ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(progressBarValue * 100).toInt()}% of daily goal achieved',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),

                      // Accuracy Box
                  const SizedBox(height: 16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center, // ensure same height across both boxes
                  children: [
                    Expanded(
                      child: Container(
                        height: 80,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 7, 45, 78),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Left-aligned
                          children: [
                            Text(
                              '$speechAccuracy%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Speech Accuracy',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(width: 12), // space between the two boxes

                    // Noise Accuracy Box
                    Expanded(
                      child: Container(
                        height: 80,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 7, 45, 78),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Left-aligned
                          children: [
                            Text(
                              '$noiseAccuracy%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Noise Challenge',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),            
                  ]
                ),      
              ]
            ),
          )
        ],
      ),
    ),

    const SizedBox(height: 16), 

    // View Most Missed Words
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MissedWordsPage()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 7, 45, 78),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'View Most Missed Words',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    ),

    SizedBox(height: 16),

    // View Most Missed Sounds
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MissedSoundsPage()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 7, 45, 78),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'View Most Missed Sounds',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    ),

        
    const SizedBox(height: 16),

    // Speech Overtime
    Container(            
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 7, 45, 78),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: 
            Center(
              child: Text(
              'Speech Overtime',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18, 
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 16),
                      // Add graph/trend line here potentially
                    ],
                  ),
                )
              ]
            )
          )
        ]
      )
    );
  }
}

