import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/config/markdown_generator.dart';
import 'package:markdown_widget/widget/blocks/leaf/paragraph.dart';
import 'package:markdown_widget/widget/markdown.dart';

import '../../../common/enum/load_status.dart';
import '../../../common/latex.dart';
import 'ai_chat_cubit.dart';
import 'ai_chat_state.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Hàm cuộn xuống dưới cùng mượt mà
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, color: colorScheme.primary),
            const SizedBox(width: 8),
            const Text("Trợ lý AI", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1, // Hiệu ứng đổ bóng nhẹ khi cuộn nội dung lên
      ),
      body: Column(
        children: [
          // ================= KHU VỰC HIỂN THỊ TIN NHẮN =================
          Expanded(
            child: BlocConsumer<AiChatCubit, AiChatState>(
              listener: (context, state) {
                if (state.status == LoadStatus.Loading || state.status == LoadStatus.Done) {
                  _scrollToBottom();
                }
                if (state.status == LoadStatus.Error && state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage!),
                      backgroundColor: colorScheme.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              builder: (context, state) {
                // Màn hình trống (Empty State)
                if (state.messages.isEmpty && state.status != LoadStatus.Loading) {
                  return _buildEmptyState(context);
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  // Thêm 1 item loading giả lập AI đang gõ
                  itemCount: state.messages.length + (state.status == LoadStatus.Loading ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Nếu là item cuối cùng và đang loading -> Hiển thị "AI typing..."
                    if (index == state.messages.length) {
                      return _buildTypingIndicator(context);
                    }
                    return _buildMessageBubble(context, state.messages[index]);
                  },
                );
              },
            ),
          ),

          // ================= KHU VỰC NHẬP LIỆU =================
          _buildBottomInputArea(context),
        ],
      ),
    );
  }

  // Widget hiển thị khi chưa có đoạn chat nào
  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Text(
                "Xin chào! Tôi có thể giúp gì cho bạn?",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Hãy gửi cho tôi một bài toán hoặc chụp ảnh phương trình, tôi sẽ hướng dẫn bạn cách giải và bấm máy tính chi tiết.",
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.onSurfaceVariant, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Bong bóng hiển thị "AI đang gõ phím"
  Widget _buildTypingIndicator(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 24),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(4), // Góc nhọn chỉa về avatar AI
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "AI đang suy nghĩ...",
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị từng bong bóng tin nhắn (Message Bubble)
  Widget _buildMessageBubble(BuildContext context, ChatMessage msg) {
    final colorScheme = Theme.of(context).colorScheme;
    final isUser = msg.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar AI (Nếu không phải User)
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(Icons.auto_awesome, size: 18, color: colorScheme.primary),
            ),
            const SizedBox(width: 8),
          ],

          // Khung bong bóng chat
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  // Góc nhọn thay đổi tùy theo người gửi
                  bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Hiển thị Ảnh đính kèm (nếu có)
                  if (msg.image != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: msg.text.isNotEmpty ? 12.0 : 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          msg.image!,
                          fit: BoxFit.cover,
                          width: 200, // Giới hạn chiều rộng ảnh
                        ),
                      ),
                    ),

                  // 2. Hiển thị Text
                  if (msg.text.isNotEmpty)
                    if (isUser)
                      Text(
                        msg.text,
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onPrimary, // Chữ trắng trên nền primary
                        ),
                      )
                    else
                      // Trả lời của AI: Parse Markdown và Latex
                      MarkdownWidget(
                        data: msg.text,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        markdownGenerator: MarkdownGenerator(
                          generators: [latexGenerator],
                          inlineSyntaxList: [LatexSyntax()],
                        ),
                        // Custom màu chữ cho Markdown để tiệp với nền
                        config: MarkdownConfig(
                          configs: [
                            PConfig(
                              textStyle: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                ],
              ),
            ),
          ),

          // Khoảng trống bù trừ nếu là User (để không cần Avatar)
          if (isUser) const SizedBox(width: 24),
        ],
      ),
    );
  }

  // Khu vực thanh công cụ nhập liệu (Bottom Input Bar)
  Widget _buildBottomInputArea(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLoading = context.watch<AiChatCubit>().state.status == LoadStatus.Loading;

    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 12,
        bottom:
            MediaQuery.of(context).padding.bottom +
            12, // Né vùng màn hình bo cong (tai thỏ, home bar)
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= PREVIEW ẢNH ĐÍNH KÈM =================
          if (_selectedImage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12, left: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, // Bo gọn lại
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.file(
                      File(_selectedImage!.path),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text("Đã đính kèm ảnh", style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.close_rounded, size: 20, color: colorScheme.error),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(() => _selectedImage = null),
                  ),
                ],
              ),
            ),

          // ================= HÀNG NHẬP TEXT VÀ NÚT BẤM =================
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Nút Chụp ảnh
              IconButton(
                icon: Icon(Icons.camera_alt_outlined, color: colorScheme.primary),
                onPressed: isLoading
                    ? null
                    : () async {
                        final img = await _picker.pickImage(source: ImageSource.camera);
                        if (img != null) setState(() => _selectedImage = img);
                      },
              ),
              // Nút Thư viện ảnh
              IconButton(
                icon: Icon(Icons.image_outlined, color: colorScheme.primary),
                onPressed: isLoading
                    ? null
                    : () async {
                        final img = await _picker.pickImage(source: ImageSource.gallery);
                        if (img != null) setState(() => _selectedImage = img);
                      },
              ),

              const SizedBox(width: 4),

              // Khung nhập liệu (TextField)
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: 4, // Cho phép khung nhập dài ra tối đa 4 dòng
                  minLines: 1,
                  textInputAction: TextInputAction.send, // Nút Enter trên bàn phím biến thành Send
                  decoration: InputDecoration(
                    hintText: "Nhắn tin cho trợ lý AI...",
                    hintStyle: TextStyle(color: colorScheme.outline),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _handleSend(), // Bấm Enter trên bàn phím ảo
                ),
              ),

              const SizedBox(width: 8),

              // Nút Gửi (Màu nổi bật)
              Container(
                margin: const EdgeInsets.only(bottom: 2), // Căn chỉnh cho đều với viền TextField
                decoration: BoxDecoration(
                  color: isLoading ? colorScheme.surfaceContainerHighest : colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.send_rounded,
                    color: isLoading ? colorScheme.outline : colorScheme.onPrimary,
                  ),
                  onPressed: isLoading ? null : _handleSend,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Logic gửi tin nhắn
  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _selectedImage == null) return;

    // Đọc bytes ảnh
    final imageBytes = _selectedImage != null ? await _selectedImage!.readAsBytes() : null;

    // Gọi Cubit
    context.read<AiChatCubit>().sendMessage(
      text: text.isEmpty ? null : text,
      image: imageBytes,
    );

    // Dọn dẹp
    _controller.clear();
    setState(() => _selectedImage = null);

    // Tự động cuộn xuống ngay sau khi nhấn Gửi
    _scrollToBottom();
  }
}
