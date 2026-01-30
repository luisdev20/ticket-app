# Ticket Service - Servicio de API

Este servicio proporciona métodos para interactuar con la API REST de tickets del backend.

## 📋 Características

- ✅ **fetchTickets()** - Obtiene todos los tickets
- ✅ **createTicket()** - Crea un nuevo ticket
- ✅ **getTicketById()** - Obtiene un ticket por ID
- ✅ **updateTicket()** - Actualiza un ticket existente
- ✅ **deleteTicket()** - Elimina un ticket
- ✅ **Soporte para Android Emulator** - Usa automáticamente `10.0.2.2` en lugar de `localhost`
- ✅ **Manejo de errores** - Excepciones personalizadas con información detallada

## 🚀 Uso Básico

### Obtener todos los tickets

```dart
import 'package:ticket_app/services/ticket_service.dart';

try {
  final tickets = await TicketService.fetchTickets();
  print('Se obtuvieron ${tickets.length} tickets');
  for (var ticket in tickets) {
    print('- ${ticket.titulo}');
  }
} catch (e) {
  print('Error: $e');
}
```

### Crear un nuevo ticket

```dart
import 'package:ticket_app/models/ticket.dart';
import 'package:ticket_app/services/ticket_service.dart';

final nuevoTicket = Ticket(
  titulo: 'Bug en el login',
  descripcion: 'El botón de inicio de sesión no responde',
  prioridad: Prioridad.alta,
  estado: Estado.abierto,
);

try {
  final ticketCreado = await TicketService.createTicket(nuevoTicket);
  print('Ticket creado con ID: ${ticketCreado.id}');
} catch (e) {
  print('Error al crear ticket: $e');
}
```

### Obtener un ticket por ID

```dart
try {
  final ticket = await TicketService.getTicketById(1);
  print('Ticket encontrado: ${ticket.titulo}');
} catch (e) {
  print('Error: $e');
}
```

### Actualizar un ticket

```dart
final ticketActualizado = ticket.copyWith(
  estado: Estado.enProceso,
  descripcion: 'Descripción actualizada',
);

try {
  final resultado = await TicketService.updateTicket(ticket.id!, ticketActualizado);
  print('Ticket actualizado: ${resultado.estado.displayName}');
} catch (e) {
  print('Error: $e');
}
```

### Eliminar un ticket

```dart
try {
  await TicketService.deleteTicket(1);
  print('Ticket eliminado exitosamente');
} catch (e) {
  print('Error: $e');
}
```

## 🔧 Configuración de URL

El servicio detecta automáticamente la plataforma y usa la URL correcta:

- **Android Emulator**: `http://10.0.2.2:8081/api/tickets`
- **Otras plataformas**: `http://localhost:8081/api/tickets`

### ¿Por qué 10.0.2.2 en Android?

En el emulador de Android, `localhost` se refiere al propio emulador, no a tu máquina host. La IP especial `10.0.2.2` es un alias que el emulador usa para acceder al `localhost` de tu computadora.

## 🧪 Probar el Servicio

Ejecuta el ejemplo interactivo:

```bash
flutter run -d emulator-5554 lib/services/ticket_service_example.dart
```

Este ejemplo te permite:
- Ver todos los tickets del backend
- Crear tickets de prueba con un botón
- Refrescar la lista
- Ver errores de conexión si el backend no está corriendo

## ⚠️ Requisitos

1. **Backend corriendo**: Asegúrate de que el backend Spring Boot esté corriendo en el puerto 8081
2. **Paquete http**: Ya está incluido en `pubspec.yaml`

### Verificar que el backend esté corriendo

```bash
# En Windows PowerShell
Invoke-WebRequest -Uri http://localhost:8081/api/tickets

# En terminal Unix/Mac
curl http://localhost:8081/api/tickets
```

## 🐛 Manejo de Errores

El servicio lanza `TicketServiceException` con información detallada:

```dart
try {
  final tickets = await TicketService.fetchTickets();
} on TicketServiceException catch (e) {
  print('Error del servicio: ${e.message}');
  print('Código de estado: ${e.statusCode}');
  print('Respuesta: ${e.responseBody}');
} catch (e) {
  print('Error inesperado: $e');
}
```

### Tipos de errores comunes

- **SocketException**: El backend no está corriendo o no es accesible
- **Status 404**: Recurso no encontrado
- **Status 500**: Error interno del servidor
- **Status 400**: Datos inválidos enviados al servidor

## 📱 Probar en Diferentes Plataformas

### Android Emulator
```bash
flutter run -d emulator-5554
```

### Windows Desktop
```bash
flutter run -d windows
```

### Chrome
```bash
flutter run -d chrome
```

## 🔗 Endpoints de la API

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/tickets` | Obtener todos los tickets |
| POST | `/api/tickets` | Crear un nuevo ticket |
| GET | `/api/tickets/{id}` | Obtener un ticket por ID |
| PUT | `/api/tickets/{id}` | Actualizar un ticket |
| DELETE | `/api/tickets/{id}` | Eliminar un ticket |

## 📝 Notas

- Todos los métodos son asíncronos y retornan `Future`
- Los métodos usan `utf8.decode()` para manejar correctamente caracteres especiales en español
- Los headers incluyen `charset=UTF-8` para asegurar la correcta codificación
