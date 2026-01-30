import 'package:flutter/material.dart';
import 'package:ticket_app/models/ticket.dart';
import 'package:ticket_app/models/user.dart';
import 'package:ticket_app/services/ticket_service.dart';
import 'package:ticket_app/services/user_service.dart';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  Prioridad _prioridadSeleccionada = Prioridad.media;
  Estado _estadoSeleccionado = Estado.abierto;
  User? _usuarioSeleccionado;
  List<User> _usuarios = [];
  bool _isLoading = false;
  bool _isLoadingUsers = true;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    try {
      final usuarios = await UserService.fetchUsers();
      setState(() {
        _usuarios = usuarios;
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUsers = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar usuarios: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _guardarTicket() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final nuevoTicket = Ticket(
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      prioridad: _prioridadSeleccionada,
      estado: _estadoSeleccionado,
      usuario: _usuarioSeleccionado,
    );

    try {
      await TicketService.createTicket(nuevoTicket);
      
      if (mounted) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Ticket creado exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Regresar a la pantalla anterior
        Navigator.of(context).pop(true); // true indica que se creó un ticket
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al crear ticket: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Ticket'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Campo de Título
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Ingresa el título del ticket',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              maxLength: 200,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El título es obligatorio';
                }
                if (value.trim().length < 3) {
                  return 'El título debe tener al menos 3 caracteres';
                }
                return null;
              },
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Campo de Descripción
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Describe el problema o tarea',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              maxLength: 500,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La descripción es obligatoria';
                }
                if (value.trim().length < 10) {
                  return 'La descripción debe tener al menos 10 caracteres';
                }
                return null;
              },
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Selector de Prioridad
            DropdownButtonFormField<Prioridad>(
              value: _prioridadSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Prioridad',
                prefixIcon: Icon(Icons.flag),
                border: OutlineInputBorder(),
              ),
              items: Prioridad.values.map((prioridad) {
                return DropdownMenuItem(
                  value: prioridad,
                  child: Row(
                    children: [
                      Icon(
                        _getPriorityIcon(prioridad),
                        color: _getPriorityColor(prioridad),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(prioridad.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: _isLoading
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _prioridadSeleccionada = value;
                        });
                      }
                    },
            ),
            const SizedBox(height: 16),

            // Selector de Estado
            DropdownButtonFormField<Estado>(
              value: _estadoSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Estado',
                prefixIcon: Icon(Icons.info),
                border: OutlineInputBorder(),
              ),
              items: Estado.values.map((estado) {
                return DropdownMenuItem(
                  value: estado,
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        color: _getEstadoColor(estado),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(estado.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: _isLoading
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _estadoSeleccionado = value;
                        });
                      }
                    },
            ),
            const SizedBox(height: 16),

            // Selector de Usuario
            _isLoadingUsers
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : DropdownButtonFormField<User>(
                    value: _usuarioSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Usuario (Opcional)',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                      hintText: 'Selecciona un usuario',
                    ),
                    items: [
                      const DropdownMenuItem<User>(
                        value: null,
                        child: Text('Sin asignar'),
                      ),
                      ..._usuarios.map((usuario) {
                        return DropdownMenuItem<User>(
                          value: usuario,
                          child: Row(
                            children: [
                              Icon(
                                usuario.rol == Rol.tecnico
                                    ? Icons.engineering
                                    : Icons.person,
                                color: usuario.rol == Rol.tecnico
                                    ? Colors.blue
                                    : Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${usuario.nombre} (${usuario.rol.displayName})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _usuarioSeleccionado = value;
                            });
                          },
                  ),
            const SizedBox(height: 32),

            // Botón Guardar
            ElevatedButton(
              onPressed: _isLoading ? null : _guardarTicket,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save),
                        SizedBox(width: 8),
                        Text(
                          'Guardar Ticket',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),

            // Botón Cancelar
            OutlinedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.of(context).pop();
                    },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Obtiene el color según la prioridad
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

  /// Obtiene el icono según la prioridad
  IconData _getPriorityIcon(Prioridad prioridad) {
    switch (prioridad) {
      case Prioridad.alta:
        return Icons.priority_high;
      case Prioridad.media:
        return Icons.remove;
      case Prioridad.baja:
        return Icons.arrow_downward;
    }
  }

  /// Obtiene el color según el estado
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
}
