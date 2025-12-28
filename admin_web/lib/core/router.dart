import 'package:go_router/go_router.dart';
import '../features/auth/views/login_page.dart';
import '../layout/dashboard_layout.dart';
import '../features/dashboard/views/dashboard_page.dart';
import '../features/chat/views/chat_inbox_page.dart';
import '../features/chat/views/chat_room_page.dart';
import '../features/complaints/views/complaint_list_page.dart';
import '../features/info_kb/views/kb_list_page.dart';
import '../features/news/views/news_list_page.dart';
import '../features/news/views/add_news_page.dart';

final router = GoRouter(
  initialLocation: '/dashboard', // Temporary, change to /login later
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    ShellRoute(
      builder: (context, state, child) {
        return DashboardLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: '/chat',
          builder: (context, state) => const ChatInboxPage(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final userId = state.pathParameters['id']!;
                final userName = state.extra as String? ?? 'User';
                return ChatRoomPage(userId: userId, userName: userName);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/complaints',
          builder: (context, state) => const ComplaintListPage(),
        ),
        GoRoute(
          path: '/info-kb',
          builder: (context, state) => const KbListPage(),
        ),
        GoRoute(
          path: '/news',
          builder: (context, state) => const NewsListPage(),
          routes: [
             GoRoute(
              path: 'add',
              builder: (context, state) => const AddNewsPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
