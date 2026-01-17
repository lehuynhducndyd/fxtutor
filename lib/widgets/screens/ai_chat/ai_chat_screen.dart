import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:markdown_widget/config/markdown_generator.dart';
import 'package:markdown_widget/widget/markdown.dart';

// --- IMPORT CÁC FILE CỦA BẠN ---
import '../../../common/enum/load_status.dart';
import '../../../common/latex.dart'; // File cấu hình Latex (đã tạo ở bài trước)
import 'ai_chat_cubit.dart';
import 'ai_chat_state.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key}); // Thêm const cho constructor

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker(); // Instance ImagePicker
  XFile? _selectedImage;

  // Hàm cuộn xuống dưới cùng
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gia sư AI (RAG)"),
        elevation: 2,
      ),
      body: Column(
        children: [
          // KHU VỰC HIỂN THỊ TIN NHẮN
          Expanded(
            child: BlocConsumer<AiChatCubit, AiChatState>(
              listener: (context, state) {
                // 1. Tự động cuộn khi có tin nhắn mới hoặc đang load
                if (state.status == LoadStatus.Loading || state.status == LoadStatus.Done) {
                  _scrollToBottom();
                }
                // 2. Hiện lỗi nếu có
                if (state.status == LoadStatus.Error && state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage!),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                // Hiển thị màn hình trống nếu chưa có tin nhắn
                if (state.messages.isEmpty && state.status != LoadStatus.Loading) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  // Thêm 1 item loading nếu đang chờ
                  itemCount: state.messages.length + (state.status == LoadStatus.Loading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.messages.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    print(">>>messages: ${state.messages[index].text}");
                    return _buildMessageTile(state.messages[index]);
                  },
                );
              },
            ),
          ),

          // KHU VỰC NHẬP LIỆU
          _buildInputArea(),
        ],
      ),
    );
  }

  // Widget hiển thị khi chưa có tin nhắn
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Hỏi tôi cách bấm máy tính\nhoặc giải toán nhé!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị từng tin nhắn
  Widget _buildMessageTile(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
        decoration: BoxDecoration(
          color: msg.isUser ? Colors.blue[100] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12).copyWith(
            bottomRight: msg.isUser ? Radius.zero : const Radius.circular(12),
            bottomLeft: !msg.isUser ? Radius.zero : const Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị ảnh nếu User gửi
            if (msg.image != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    msg.image!, // Dữ liệu Uint8List
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            // Hiển thị nội dung
            if (msg.isUser)
              Text(msg.text, style: const TextStyle(fontSize: 16))
            else
              // AI trả lời: Dùng Markdown + Latex
              MarkdownWidget(
                data: msg.text,
                shrinkWrap: true,
                markdownGenerator: MarkdownGenerator(
                  generators: [latexGenerator], // Kích hoạt Latex (file common/latex.dart)
                  inlineSyntaxList: [LatexSyntax()],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Khu vực nhập liệu (Input)
  Widget _buildInputArea() {
    final isLoading = context.watch<AiChatCubit>().state.status == LoadStatus.Loading;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
      ),
      child: Column(
        children: [
          // Preview ảnh đã chọn (có nút xóa)
          if (_selectedImage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              height: 60,
              child: Row(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_selectedImage!.path),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedImage = null),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  const Text("Đã đính kèm ảnh", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),

          // Hàng Input
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.image_outlined, color: Colors.blue),
                onPressed: isLoading
                    ? null
                    : () async {
                        final img = await _picker.pickImage(source: ImageSource.gallery);
                        if (img != null) setState(() => _selectedImage = img);
                      },
              ),
              IconButton(
                icon: const Icon(Icons.camera_alt_outlined, color: Colors.blue),
                onPressed: isLoading
                    ? null
                    : () async {
                        final img = await _picker.pickImage(source: ImageSource.camera);
                        if (img != null) setState(() => _selectedImage = img);
                      },
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Nhập câu hỏi...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onSubmitted: (_) => _handleSend(), // Gửi khi nhấn Enter
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.send, color: isLoading ? Colors.grey : Colors.blue),
                onPressed: isLoading ? null : _handleSend,
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
  }
}
