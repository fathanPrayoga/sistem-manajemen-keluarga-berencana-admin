import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardLayout extends StatelessWidget {
  final Widget child;

  const DashboardLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Current route index handling would go here, 
    // for now just simple navigation
    final location = GoRouterState.of(context).uri.toString();
    
    int getSelectedIndex() {
      if (location.startsWith('/dashboard')) return 0;
      if (location.startsWith('/chat')) return 1;
      if (location.startsWith('/complaints')) return 2;
      if (location.startsWith('/info-kb')) return 3;
      return 0;
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: getSelectedIndex(),
            onDestinationSelected: (int index) {
              switch (index) {
                case 0:
                  context.go('/dashboard');
                  break;
                case 1:
                  context.go('/chat');
                  break;
                case 2:
                  context.go('/complaints');
                  break;
                case 3:
                  context.go('/info-kb');
                  break;
              }
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble),
                label: Text('Chat'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.assignment_outlined),
                selectedIcon: Icon(Icons.assignment),
                label: Text('Pengaduan'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.article_outlined),
                selectedIcon: Icon(Icons.article),
                label: Text('Info KB'),
              ),
            ],
            trailing: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  // Logout logic
                  context.go('/login');
                },
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
