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
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  XFile? _selectedImage; // Ảnh đang được chọn để gửi

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    //final instructions = await rootBundle.loadString("assets/system_instruction.txt");
    //print(instructions.substring(0, 100));
    setState(() {
      _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: widget.apiKey,
        //systemInstruction: Content.system(instructions),
      );
    });
  }

  // Hàm chọn ảnh
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Giảm chất lượng một chút để tối ưu tốc độ upload
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

  // Hàm gửi tin nhắn
  Future<void> _sendMessage() async {
    final String text = _textController.text.trim();
    final XFile? imageToSend = _selectedImage;

    if (text.isEmpty && imageToSend == null) return;

    setState(() {
      // Thêm tin nhắn của user vào danh sách
      _messages.add(ChatMessage(text: text, isUser: true, image: imageToSend));
      _isLoading = true;
      _textController.clear();
      _selectedImage = null; // Reset ảnh đã chọn sau khi nhấn gửi
    });
    _scrollToBottom();

    try {
      // --- CHUẨN BỊ DỮ LIỆU GỬI ĐI ---
      final List<Content> content;

      if (imageToSend != null) {
        // Nếu có ảnh, cần đọc dữ liệu byte của ảnh
        final Uint8List imageBytes = await imageToSend.readAsBytes();
        // Xác định mimeType cơ bản (đơn giản hóa cho ví dụ)
        final String path = imageToSend.path.toLowerCase();
        String mimeType;
        if (path.endsWith('.png')) {
          mimeType = 'image/png';
        } else if (path.endsWith('.heic')) {
          mimeType = 'image/heic';
        } else {
          // Mặc định là jpeg cho các trường hợp còn lại (jpg, jpeg)
          mimeType = 'image/jpeg';
        }

        // Tạo Content multimodal (văn bản + ảnh)
        content = [
          Content.multi([
            TextPart(
              text.isEmpty
                  ? "Hãy giải bài toán này bằng hình ảnh này, Hãy giải bài toán này bằng Tiếng việt,"
                        " khi hiển thị latex, cố gắng xuống dòng các phép biến đổi, "
                        "hiện thị latex với markdown \$\$ , chỉ hiển thị kêt quả, không nhắc lại chỉ dẫn này"
                        "    "
                  : text,
            ),
            DataPart(mimeType, imageBytes),
          ]),
        ];
      } else {
        content = [
          Content.text(
            text +
                " Hãy giải bài toán này bằng Tiếng việt, khi hiển thị latex, "
                    "cố gắng xuống dòng các phép biến đổi, hiện thị latex với markdown \$\$ , "
                    "chỉ hiển thị kêt quả, không nhắc lại chỉ dẫn này",
          ),
        ];
      }
      final response = await _model?.generateContent(content);

      final String? responseTextRaw = response?.text;
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

  // --- PHẦN GIAO DIỆN NGƯỜI DÙNG ---
  @override
  Widget build(BuildContext context) {
    if (_model == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      body: Column(
        children: [
          // Danh sách tin nhắn chat
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
          // Hiển thị trạng thái đang loading
          if (_isLoading) const LinearProgressIndicator(),

          // Khu vực nhập liệu (Input Area)
          _buildInputArea(),
        ],
      ),
    );
  }

  // Widget hiển thị từng tin nhắn
  Widget _buildMessageItem(ChatMessage message) {
    print(message.text);
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
                    ? Colors
                          .grey
                          .shade800 // Nền tối cho AI khi Dark Mode
                    : Colors.grey.shade200), // Nền sáng cho AI khi Light Mode

          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: message.isUser ? Radius.zero : const Radius.circular(16),
            bottomLeft: !message.isUser ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị ảnh thumbnail nếu tin nhắn user có đính kèm ảnh
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
            // Hiển thị nội dung văn bản
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

  // Widget khu vực nhập liệu ở dưới cùng
  Widget _buildInputArea() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Vùng xem trước ảnh đã chọn (Image Preview Area)
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
                        // Nút xóa ảnh đã chọn
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

            // Hàng chứa TextField và các nút
            Row(
              children: [
                // Nút chọn ảnh từ thư viện
                IconButton(
                  icon: const Icon(Icons.image, color: Colors.deepPurple),
                  onPressed: _isLoading ? null : () => _pickImage(ImageSource.gallery),
                ),
                // Nút chụp ảnh
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.deepPurple),
                  onPressed: _isLoading ? null : () => _pickImage(ImageSource.camera),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Nhập tin nhắn hoặc mô tả ảnh...',
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
