import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../main_cubit.dart';

class SettingScreen extends StatelessWidget {
  static const String route = 'SettingScreen';

  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: BlocBuilder<MainCubit, MainState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // ================= TIÊU ĐỀ KHU VỰC =================
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                child: Row(
                  children: [
                    Text(
                      "Giao diện ứng dụng",
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // ================= CARD TÙY CHỌN THEME =================
              Card(
                elevation: 0,
                color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    // Tùy chọn Sáng (Light Mode)
                    RadioListTile<bool>(
                      value: true,
                      groupValue: state.isLightTheme,
                      activeColor: colorScheme.primary,
                      title: const Text(
                        'Chế độ Sáng',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      onChanged: (bool? value) {
                        if (value != null) {
                          context.read<MainCubit>().setTheme(value);
                        }
                      },
                    ),

                    const Divider(height: 1, indent: 16, endIndent: 16), // Đường kẻ mỏng ngăn cách
                    // Tùy chọn Tối (Dark Mode)
                    RadioListTile<bool>(
                      value: false,
                      groupValue: state.isLightTheme,
                      activeColor: colorScheme.primary,
                      title: const Text(
                        'Chế độ Tối',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                      ),
                      onChanged: (bool? value) {
                        if (value != null) {
                          context.read<MainCubit>().setTheme(value);
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Bạn có thể dễ dàng thêm các khu vực cài đặt khác ở đây sau này
              // Ví dụ: Ngôn ngữ, Thông báo, v.v.
            ],
          );
        },
      ),
    );
  }
}
