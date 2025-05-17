// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/auth_model.dart';
import '../models/user_model.dart';
import 'login_screen.dart';
import 'admin_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  // 실제 버전으로 교체하세요
  static const String _appVersion = 'v1.0.0';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthModel>();
    final user = auth.user;
    final isAdmin = context
        .watch<UserModel>()
        .isAdmin;

    return Scaffold(
      // 4910 앱처럼 연회색 배경
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // — 상단 로그인/회원가입 또는 인사 + 로그아웃/관리자
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: user == null
                  ? SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    '로그인 / 회원가입',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '안녕하세요,\n${user.email}',
                    style: Theme
                        .of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.logout, color: Colors.black54),
                    title: const Text('로그아웃'),
                    onTap: () => auth.signOut(),
                  ),
                  if (isAdmin)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.admin_panel_settings,
                          color: Colors.black54),
                      title: const Text('관리자 모드'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AdminScreen()),
                        );
                      },
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // — 도움말 섹션 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '도움말',
                style: Theme
                    .of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(height: 8),

            // — 도움말 항목들
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _HelpTile(
                      title: '고객센터',
                      onTap: () =>
                          _showInfoDialog(
                            context,
                            '고객센터',
                            '고객센터 페이지로 이동합니다.',
                          ),
                    ),
                    const Divider(height: 1),
                    _HelpTile(
                      title: '공지사항',
                      onTap: () =>
                          _showInfoDialog(
                            context,
                            '공지사항',
                            '공지사항 페이지로 이동합니다.',
                          ),
                    ),
                    const Divider(height: 1),
                    _HelpTile(
                      title: '버전 정보',
                      trailing: _appVersion,
                      onTap: () =>
                          _showInfoDialog(
                            context,
                            '버전 정보',
                            '현재 버전: $_appVersion',
                          ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
    );
  }
}

/// 단일 도움말 타일
class _HelpTile extends StatelessWidget {
  final String title;
  final String? trailing;
  final VoidCallback onTap;

  const _HelpTile({
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: trailing != null
          ? Text(trailing!,
          style: const TextStyle(color: Colors.black38, fontSize: 14))
          : const Icon(Icons.chevron_right, color: Colors.black38),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minLeadingWidth: 0,
      visualDensity: const VisualDensity(vertical: -1),
    );
  }
}
