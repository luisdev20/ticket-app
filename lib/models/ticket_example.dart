import 'package:flutter/material.dart';
import 'package:ticket_app/models/ticket.dart';

void main() {
  runApp(const TicketExampleApp());
}

class TicketExampleApp extends StatelessWidget {
  const TicketExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ticket Model Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TicketExampleScreen(),
    );
  }
}

class TicketExampleScreen extends StatelessWidget {
  const TicketExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ============================================
    // 1. CREAR UN TICKET NUEVO
    // ============================================
    final nuevoTicket = Ticket(
      titulo: 'Error en el login',
      descripcion: 'El botón de inicio de sesión no responde',
      prioridad: Prioridad.alta,
      estado: Estado.abierto,
    );

    // ============================================
    // 2. PARSEAR UN TICKET DESDE LA API
    // ============================================
    final jsonDesdeApi = {
      'id': 1,
      'titulo': 'Bug en Flutter',
      'descripcion': 'Error al renderizar widget',
      'prioridad': 'MEDIA',
      'estado': 'EN_PROCESO',
      'fechaCreacion': '2026-01-30T02:27:51.471793',
    };

    final ticketDesdeApi = Ticket.fromJson(jsonDesdeApi);

    // ============================================
    // 3. LISTA DE TICKETS
    // ============================================
    final listaJson = [
      {
        'id': 1,
        'titulo': 'Implementar login',
        'descripcion': 'Crear pantalla de autenticación',
        'prioridad': 'ALTA',
        'estado': 'ABIERTO',
        'fechaCreacion': '2026-01-30T01:00:00',
      },
      {
        'id': 2,
        'titulo': 'Diseñar dashboard',
        'descripcion': 'Crear interfaz principal',
        'prioridad': 'MEDIA',
        'estado': 'EN_PROCESO',
        'fechaCreacion': '2026-01-30T02:00:00',
      },
      {
        'id': 3,
        'titulo': 'Configurar base de datos',
        'descripcion': 'Setup PostgreSQL',
        'prioridad': 'BAJA',
        'estado': 'CERRADO',
        'fechaCreacion': '2026-01-30T03:00:00',
      },
    ];

    final tickets = listaJson.map((json) => Ticket.fromJson(json)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Model - Ejemplos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección 1: Ticket Nuevo
          _buildSection(
            context,
            title: '1. Ticket Nuevo (para enviar a API)',
            child: _buildTicketCard(nuevoTicket, showJson: true),
          ),
          const SizedBox(height: 24),

          // Sección 2: Ticket desde API
          _buildSection(
            context,
            title: '2. Ticket Parseado desde API',
            child: _buildTicketCard(ticketDesdeApi),
          ),
          const SizedBox(height: 24),

          // Sección 3: Lista de Tickets
          _buildSection(
            context,
            title: '3. Lista de Tickets',
            child: Column(
              children: tickets
                  .map((ticket) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildTicketCard(ticket, compact: true),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Sección 4: Enums
          _buildSection(
            context,
            title: '4. Valores de Enums',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Prioridades:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...Prioridad.values.map((p) => Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 4),
                      child: Row(
                        children: [
                          _getPrioridadIcon(p),
                          const SizedBox(width: 8),
                          Text('${p.displayName} (${p.value})'),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
                const Text(
                  'Estados:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...Estado.values.map((e) => Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 4),
                      child: Row(
                        children: [
                          _getEstadoIcon(e),
                          const SizedBox(width: 8),
                          Text('${e.displayName} (${e.value})'),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title, required Widget child}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(Ticket ticket,
      {bool compact = false, bool showJson = false}) {
    return Card(
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (ticket.id != null) ...[
                  Chip(
                    label: Text('ID: ${ticket.id}'),
                    backgroundColor: Colors.blue[100],
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    ticket.titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            if (!compact) ...[
              const SizedBox(height: 8),
              Text(ticket.descripcion),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                _getPrioridadIcon(ticket.prioridad),
                const SizedBox(width: 4),
                Text(ticket.prioridad.displayName),
                const SizedBox(width: 16),
                _getEstadoIcon(ticket.estado),
                const SizedBox(width: 4),
                Text(ticket.estado.displayName),
              ],
            ),
            if (ticket.fechaCreacion != null) ...[
              const SizedBox(height: 4),
              Text(
                'Creado: ${ticket.fechaCreacion!.toString().substring(0, 19)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
            if (showJson) ...[
              const SizedBox(height: 8),
              const Divider(),
              const Text(
                'JSON:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  ticket.toJson().toString(),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _getPrioridadIcon(Prioridad prioridad) {
    switch (prioridad) {
      case Prioridad.alta:
        return const Icon(Icons.arrow_upward, color: Colors.red, size: 20);
      case Prioridad.media:
        return const Icon(Icons.remove, color: Colors.orange, size: 20);
      case Prioridad.baja:
        return const Icon(Icons.arrow_downward, color: Colors.green, size: 20);
    }
  }

  Widget _getEstadoIcon(Estado estado) {
    switch (estado) {
      case Estado.abierto:
        return const Icon(Icons.radio_button_unchecked,
            color: Colors.blue, size: 20);
      case Estado.enProceso:
        return const Icon(Icons.pending, color: Colors.orange, size: 20);
      case Estado.cerrado:
        return const Icon(Icons.check_circle, color: Colors.green, size: 20);
    }
  }
}
