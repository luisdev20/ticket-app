import 'package:flutter/material.dart';
import 'package:ticket_app/models/ticket.dart';
import 'package:ticket_app/services/ticket_service.dart';

void main() {
  runApp(const TicketServiceExampleApp());
}

class TicketServiceExampleApp extends StatelessWidget {
  const TicketServiceExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ticket Service - Prueba de API',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TicketServiceScreen(),
    );
  }
}

class TicketServiceScreen extends StatefulWidget {
  const TicketServiceScreen({super.key});

  @override
  State<TicketServiceScreen> createState() => _TicketServiceScreenState();
}

class _TicketServiceScreenState extends State<TicketServiceScreen> {
  List<Ticket> _tickets = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  /// Carga todos los tickets desde el backend
  Future<void> _loadTickets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _statusMessage = 'Cargando tickets...';
    });

    try {
      final tickets = await TicketService.fetchTickets();
      setState(() {
        _tickets = tickets;
        _isLoading = false;
        _statusMessage = 'Se cargaron ${tickets.length} tickets';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
        _statusMessage = 'Error al cargar tickets';
      });
    }
  }

  /// Crea un nuevo ticket de prueba
  Future<void> _createTestTicket() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _statusMessage = 'Creando ticket...';
    });

    final nuevoTicket = Ticket(
      titulo: 'Ticket de prueba ${DateTime.now().millisecondsSinceEpoch}',
      descripcion: 'Este es un ticket creado desde Flutter',
      prioridad: Prioridad.media,
      estado: Estado.abierto,
    );

    try {
      final ticketCreado = await TicketService.createTicket(nuevoTicket);
      setState(() {
        _isLoading = false;
        _statusMessage = 'Ticket creado con ID: ${ticketCreado.id}';
      });
      
      // Recargar la lista de tickets
      await _loadTickets();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Ticket creado: ${ticketCreado.titulo}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
        _statusMessage = 'Error al crear ticket';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba de API - Ticket Service'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadTickets,
            tooltip: 'Recargar tickets',
          ),
        ],
      ),
      body: Column(
        children: [
          // Panel de información
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'URL de la API:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  TicketService.baseUrl,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _errorMessage != null ? Colors.red : Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Mensaje de error si existe
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.red[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      const Text(
                        'Error:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

          // Lista de tickets
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Cargando...'),
                      ],
                    ),
                  )
                : _tickets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay tickets',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Crea uno usando el botón +',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadTickets,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _tickets.length,
                          itemBuilder: (context, index) {
                            final ticket = _tickets[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getPrioridadColor(ticket.prioridad),
                                  child: Text(
                                    '${ticket.id}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  ticket.titulo,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      ticket.descripcion,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        _buildChip(
                                          ticket.prioridad.displayName,
                                          _getPrioridadColor(ticket.prioridad),
                                        ),
                                        const SizedBox(width: 8),
                                        _buildChip(
                                          ticket.estado.displayName,
                                          _getEstadoColor(ticket.estado),
                                        ),
                                      ],
                                    ),
                                    if (ticket.fechaCreacion != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Creado: ${_formatDate(ticket.fechaCreacion!)}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _createTestTicket,
        icon: const Icon(Icons.add),
        label: const Text('Crear Ticket'),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color.withOpacity(0.9),
        ),
      ),
    );
  }

  Color _getPrioridadColor(Prioridad prioridad) {
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
        return Colors.purple;
      case Estado.cerrado:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
