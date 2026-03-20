import 'dart:convert'; // BẮT BUỘC THÊM ĐỂ PARSE JSON
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:image_picker/image_picker.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/widget/blocks/leaf/paragraph.dart';
import 'package:markdown_widget/widget/markdown.dart';

// Nếu bạn có file flutter_math.dart thì import vào đây
// import 'package:flutter_math_fork/flutter_math.dart';

import '../../../common/enum/load_status.dart';
import '../../../common/key_mapper.dart';
// Import KeyMapper của bạn
// import '../../../common/key_mapper.dart';
import '../content_manager/guide_content/guide_detail_screen.dart';
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  const Text("Trợ lý AI"),
                ],
              ),
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
                "Hãy gửi cho tôi một bài toán hoặc thắc mắc về máy tính, tôi sẽ hướng dẫn bạn.",
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.onSurfaceVariant, height: 1.5),
              ),
              Text(
                "Kết quả chỉ mang tính chất tham khảo, hãy kiểm tra khi cần thiết.",
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
            bottomLeft: Radius.circular(4),
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
        crossAxisAlignment:
            CrossAxisAlignment.start, // Sửa thành start để avatar không bị tụt xuống
        children: [
          // Avatar AI (Nếu không phải User)
          // if (!isUser) ...[
          //   CircleAvatar(
          //     radius: 16,
          //     backgroundColor: colorScheme.primaryContainer,
          //     child: Icon(Icons.auto_awesome, size: 18, color: colorScheme.primary),
          //   ),
          //   const SizedBox(width: 8),
          // ],

          // Khung bong bóng chat
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isUser ? colorScheme.primary : colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
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
                          width: 200,
                        ),
                      ),
                    ),

                  // 2. Hiển thị Text
                  if (msg.text.isNotEmpty)
                    if (isUser)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          msg.text,
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      )
                    else
                      Column(
                        children: [
                          _buildAiContent(context, msg),
                        ],
                      ),
                  // Tách logic AI ra hàm riêng
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 0),
        ],
      ),
    );
  }

  // =====================================================================
  // HÀM MỚI: Xử lý chuỗi JSON từ AI thành các Block giao diện tương ứng
  // =====================================================================
  Widget _buildAiContent(BuildContext context, ChatMessage msg) {
    final colorScheme = Theme.of(context).colorScheme;

    try {
      // --- BƯỚC 1: LÀM SẠCH VÀ BÓC TÁCH JSON ---
      String cleanJson = msg.text.trim();

      // Bóc tách đúng phần lõi mảng JSON [ ... ]
      final startIndex = cleanJson.indexOf('[');
      final endIndex = cleanJson.lastIndexOf(']');

      if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
        cleanJson = cleanJson.substring(startIndex, endIndex + 1);
      }

      // --- BƯỚC 2: ĐẶC TRỊ LỖI LATEX TRONG JSON ---
      // 1. Nhân đôi toàn bộ dấu \ để JSON không bị lỗi Unrecognized escape
      cleanJson = cleanJson.replaceAll(r'\', r'\\');

      // 2. Trả lại \n (xuống dòng) và \" (dấu ngoặc kép) cho JSON format
      cleanJson = cleanJson.replaceAll(r'\\n', r'\n');
      cleanJson = cleanJson.replaceAll(r'\\"', r'\"');

      // 3. Phục hồi nếu AI đã ngoan ngoãn gõ sẵn \\ mà bị biến thành \\\\
      cleanJson = cleanJson.replaceAll(r'\\\\', r'\\');

      // --- BƯỚC 3: DECODE VÀ VẼ UI ---
      final List<dynamic> blocks = jsonDecode(cleanJson);
      return Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: blocks.map((block) {
              final type = block['type']?.toString() ?? '';
              final data = block['data']?.toString() ?? '';
              final url = block['url']?.toString();
              final caption = block['caption']?.toString();

              switch (type) {
                case 'text':
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: MarkdownWidget(
                      data: data,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      config: MarkdownConfig(
                        configs: [
                          PConfig(
                            textStyle: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                case 'latex':
                  // 1. Dọn dẹp dấu $ thừa nếu AI lỡ nhét vào
                  final cleanLatex = data.replaceAll(r'$', '').trim();

                  return Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Math.tex(
                        cleanLatex, // Dùng chuỗi đã làm sạch
                        textStyle: TextStyle(
                          fontSize: 18,
                          color: colorScheme.onSurface, // 2. Ép màu chữ rõ nét, chống chìm màu
                        ),
                        // 3. BẢO HIỂM: Nếu công thức quá phức tạp thư viện không vẽ được,
                        // nó sẽ hiện chữ thô ra cho người dùng đọc chứ không bị trắng màn hình.
                        onErrorFallback: (FlutterMathException e) {
                          return Text(
                            cleanLatex,
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSurface,
                              fontFamily: 'Courier',
                            ),
                          );
                        },
                      ),
                    ),
                  );

                case 'image':
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 400),
                            color: colorScheme.surfaceContainerHighest,
                            child: Image.network(
                              url ?? '',
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 200,
                                  width: double.infinity,
                                  color: colorScheme.surfaceContainerHighest,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 150,
                                width: double.infinity,
                                color: colorScheme.errorContainer.withOpacity(0.5),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image_rounded,
                                      size: 50,
                                      color: colorScheme.error,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Không tải được ảnh",
                                      style: TextStyle(color: colorScheme.error),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (caption != null && caption.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              caption,
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  );

                case '580keylog':
                case '880keylog':
                  final is580 = type == '580keylog';
                  final text = is580 ? KeyMapper.convert(data) : KeyMapper.convert2(data);

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
                    ),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: is580 ? 'Casio580' : 'Casio880',
                          fontSize: 28,
                          color: colorScheme.onSurface,
                          height: 1.5,
                        ),
                        children: [TextSpan(text: text)],
                      ),
                    ),
                  );

                default:
                  return const SizedBox.shrink();
              }
            }).toList(),
          ),
          if (msg.guide != null)
            FilledButton.tonalIcon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // Truyền object guide sang màn hình chi tiết
                    builder: (context) => GuideDetailScreen(guide: msg.guide!),
                  ),
                );
              },
              icon: const Icon(Icons.auto_stories_rounded, size: 20),
              label: const Text("Xem bài hướng dẫn gốc"),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      );
    } catch (e) {
      print("❌ LỖI PARSE JSON TỪ AI: $e");

      // Fallback hiển thị Markdown như cũ
      return MarkdownWidget(
        data: msg.text,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        config: MarkdownConfig(
          configs: [
            PConfig(
              textStyle: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      );
    }
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
        bottom: MediaQuery.of(context).padding.bottom + 12,
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
                mainAxisSize: MainAxisSize.min,
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
              IconButton(
                icon: Icon(Icons.camera_alt_outlined, color: colorScheme.primary),
                onPressed: isLoading
                    ? null
                    : () async {
                        final img = await _picker.pickImage(source: ImageSource.camera);
                        if (img != null) setState(() => _selectedImage = img);
                      },
              ),
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
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  decoration: InputDecoration(
                    hintText: "Nhập nội dung...",
                    hintStyle: TextStyle(color: colorScheme.outline),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                margin: const EdgeInsets.only(bottom: 2),
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

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _selectedImage == null) return;

    final imageBytes = _selectedImage != null ? await _selectedImage!.readAsBytes() : null;

    context.read<AiChatCubit>().sendMessage(
      text: text.isEmpty ? null : text,
      image: imageBytes,
    );

    _controller.clear();
    setState(() => _selectedImage = null);
    _scrollToBottom();
  }
}
