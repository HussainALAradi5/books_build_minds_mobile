import 'package:socket_io_client/socket_io_client.dart' as io;

class BookRealtimeService {
  BookRealtimeService(Uri origin, this.slug, this.onChange) {
    _socket = io.io(
      origin.toString(),
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableForceNew()
          .enableReconnection()
          .build(),
    );
    _socket.onConnect((_) => _socket.emit('join_book', {'slug': slug}));
    _socket.on('book_changed', (data) {
      if (data is Map && data['slug'] == slug) onChange();
    });
    _socket.connect();
  }

  final String slug;
  final void Function() onChange;
  late final io.Socket _socket;

  void dispose() => _socket.dispose();
}
