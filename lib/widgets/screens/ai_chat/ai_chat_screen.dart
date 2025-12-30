import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:markdown_widget/config/markdown_generator.dart';
import 'package:markdown_widget/widget/markdown.dart';

import '../../../common/latex.dart';

// --- MÔ HÌNH DỮ LIỆU ĐƠN GIẢN CHO TIN NHẮN ---
class ChatMessage {
  final String text;
  final bool isUser;
  final XFile? image;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.image,
  });
}

class AiChatScreen extends StatefulWidget {
  final String apiKey = dotenv.env['API_KEY'] ?? '';

  AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  GenerativeModel? _model;

  // THAY ĐỔI 1: Thêm biến ChatSession để quản lý hội thoại
  ChatSession? _chatSession;

  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    // Lưu ý: Đảm bảo file assets/system_instruction.txt tồn tại và đã khai báo trong pubspec.yaml
    String instructions = "";
    try {
      instructions = await rootBundle.loadString("assets/system_instruction.txt");
    } catch (e) {
      print("Không tìm thấy file instruction, dùng mặc định rỗng.");
    }

    setState(() {
      _model = GenerativeModel(
        // Lưu ý: Hiện tại model ổn định là 'gemini-1.5-flash' hoặc 'gemini-1.5-pro'
        // 'gemini-2.5-flash' có thể chưa khả dụng public, hãy đổi lại nếu gặp lỗi 404
        model: 'gemini-2.5-flash',
        apiKey: widget.apiKey,
        systemInstruction: Content.system(instructions),
      );

      // THAY ĐỔI 2: Bắt đầu một phiên chat (Session)
      _chatSession = _model!.startChat(history: []);
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi chọn ảnh: $e')),
      );
    }
  }

  Future<void> _sendMessage() async {
    final String text = _textController.text.trim();
    final XFile? imageToSend = _selectedImage;

    if (text.isEmpty && imageToSend == null) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, image: imageToSend));
      _isLoading = true;
      _textController.clear();
      _selectedImage = null;
    });
    _scrollToBottom();

    try {
      // --- THAY ĐỔI 3: Cấu trúc lại dữ liệu để dùng sendMessage ---
      final Content content; // sendMessage nhận vào 1 đối tượng Content, không phải List<Content>

      // Câu lệnh prompt kèm theo (giữ nguyên logic của bạn)
      String promptText = text.isEmpty
          ? "Giải bài toán trong ảnh bằng Tiếng Việt. "
                "Khi hiển thị latex, xuống dòng các phép biến đổi. "
                "Hiển thị latex với markdown \$\$, chỉ hiển thị kết quả."
          : "$text. Giải thích bằng Tiếng Việt, hiển thị latex với markdown \$\$, xuống dòng phép tính.";

      if (imageToSend != null) {
        final Uint8List imageBytes = await imageToSend.readAsBytes();
        final String path = imageToSend.path.toLowerCase();
        String mimeType = 'image/jpeg';
        if (path.endsWith('.png')) mimeType = 'image/png';
        if (path.endsWith('.heic')) mimeType = 'image/heic';
        if (path.endsWith('.webp')) mimeType = 'image/webp';

        content = Content.multi([
          TextPart(promptText),
          DataPart(mimeType, imageBytes),
        ]);
      } else {
        content = Content.text(promptText);
      }

      // --- THAY ĐỔI QUAN TRỌNG: Dùng _chatSession.sendMessage ---
      // ChatSession tự động lưu history vào bộ nhớ tạm
      if (_chatSession == null) {
        // Re-init nếu bị null (trường hợp hiếm)
        _chatSession = _model!.startChat();
      }

      final response = await _chatSession!.sendMessage(content);

      final String? responseTextRaw = response.text;
      String responseText = "";
      if (responseTextRaw != null) {
        responseText = responseTextRaw
            .replaceAll(r'\(', r'$')
            .replaceAll(r'\)', r'$')
            .replaceAll(r'\[', r'$$')
            .replaceAll(r'\]', r'$$');
      }

      setState(() {
        _isLoading = false;
        if (responseText != "") {
          _messages.add(ChatMessage(text: responseText, isUser: false));
        }
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.add(ChatMessage(text: "Lỗi: $e", isUser: false));
      });
      _scrollToBottom();
    }
  }

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
    // Nếu model chưa init xong thì loading
    if (_model == null) {
      return Scaffold(
        appBar: AppBar(title: Text("AI Chat")),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      // Thêm AppBar để có thể back hoặc clear chat nếu cần
      // appBar: AppBar(
      //   title: Text("Gia sư AI"),
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.refresh),
      //       onPressed: () {
      //         setState(() {
      //           _messages.clear();
      //           _chatSession = _model!.startChat(); // Reset hội thoại
      //         });
      //       },
      //     )
      //   ],
      // ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageItem(message);
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
        decoration: BoxDecoration(
          color: message.isUser
              ? Colors.deepPurple
              : (Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: message.isUser ? Radius.zero : const Radius.circular(16),
            bottomLeft: !message.isUser ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.isUser && message.image != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(message.image!.path),
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            if (message.isUser)
              Text(
                message.text,
                style: const TextStyle(color: Colors.white),
              )
            else
              MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
                child: MarkdownWidget(
                  data: message.text,
                  shrinkWrap: true,
                  markdownGenerator: MarkdownGenerator(
                    generators: [latexGenerator],
                    inlineSyntaxList: [LatexSyntax()],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (_selectedImage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                height: 80,
                child: Row(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_selectedImage!.path),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImage = null;
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    const Text("Đã đính kèm ảnh", style: TextStyle(fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image, color: Colors.deepPurple),
                  onPressed: _isLoading ? null : () => _pickImage(ImageSource.gallery),
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.deepPurple),
                  onPressed: _isLoading ? null : () => _pickImage(ImageSource.camera),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Hỏi bài toán tiếp theo...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    enabled: !_isLoading,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: _isLoading ? Colors.grey : Colors.deepPurple),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
