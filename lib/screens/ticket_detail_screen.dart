import 'package:flutter/material.dart';
import 'package:ticket_app/models/ticket.dart';
import 'package:ticket_app/models/comment_model.dart';
import 'package:ticket_app/services/comment_service.dart';
import 'package:intl/intl.dart';

class TicketDetailScreen extends StatefulWidget {
  final Ticket ticket;

  const TicketDetailScreen({super.key, required this.ticket});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  late Future<List<Comment>> _commentsFuture;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _loadComments() {
    setState(() {
      _commentsFuture = CommentService.fetchCommentsByTicket(widget.ticket.id!);
    });
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El comentario no puede estar vacío')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await CommentService.createComment(
        widget.ticket.id!,
        _commentController.text.trim(),
      );

      _commentController.clear();
      _loadComments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Comentario agregado'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agregar comentario: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Ticket'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del ticket
            _buildTicketInfo(),

            const Divider(height: 32, thickness: 2),

            // Sección de comentarios
            _buildCommentsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketInfo() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              widget.ticket.titulo,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Descripción
            Text(
              widget.ticket.descripcion,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Prioridad
            _buildInfoRow(
              Icons.flag,
              'Prioridad',
              widget.ticket.prioridad.displayName,
              _getPriorityColor(widget.ticket.prioridad),
            ),
            const SizedBox(height: 12),

            // Estado
            _buildInfoRow(
              Icons.info,
              'Estado',
              widget.ticket.estado.displayName,
              _getEstadoColor(widget.ticket.estado),
            ),
            const SizedBox(height: 12),

            // Categoría
            if (widget.ticket.categoria != null)
              _buildInfoRow(
                Icons.category,
                'Categoría',
                widget.ticket.categoria!.nombre,
                Colors.blue,
              ),
            if (widget.ticket.categoria != null) const SizedBox(height: 12),

            // Usuario asignado
            if (widget.ticket.usuario != null)
              _buildInfoRow(
                Icons.person,
                'Asignado a',
                widget.ticket.usuario!.nombre,
                Colors.green,
              ),
            if (widget.ticket.usuario != null) const SizedBox(height: 12),

            // Fecha de creación
            if (widget.ticket.fechaCreacion != null)
              _buildInfoRow(
                Icons.calendar_today,
                'Creado',
                DateFormat('dd/MM/yyyy HH:mm')
                    .format(widget.ticket.fechaCreacion!),
                Colors.grey,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comentarios',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Lista de comentarios
          FutureBuilder<List<Comment>>(
            future: _commentsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error al cargar comentarios: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final comments = snapshot.data ?? [];

              if (comments.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No hay comentarios aún',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  return _buildCommentCard(comments[index]);
                },
              );
            },
          ),

          const SizedBox(height: 20),

          // Campo para agregar comentario
          _buildAddCommentField(),
        ],
      ),
    );
  }

  Widget _buildCommentCard(Comment comment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    comment.usuarioNombre?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.usuarioNombre ?? 'Usuario',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(comment.fecha),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              comment.texto,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCommentField() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agregar comentario',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Escribe tu comentario aquí...',
                border: OutlineInputBorder(),
              ),
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitComment,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(_isSubmitting ? 'Enviando...' : 'Enviar comentario'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(Prioridad prioridad) {
    switch (prioridad) {
      case Prioridad.alta:
        return Colors.red;
      case Prioridad.media:
        return Colors.orange;
      case Prioridad.baja:
        return Colors.green;
    }
  }

  Color _getEstadoColor(Estado estado) {
    switch (estado) {
      case Estado.abierto:
        return Colors.blue;
      case Estado.enProceso:
        return Colors.orange;
      case Estado.cerrado:
        return Colors.green;
    }
  }
}
