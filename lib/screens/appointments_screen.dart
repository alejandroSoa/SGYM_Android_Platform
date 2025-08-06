import 'package:flutter/material.dart';
import '../services/AppointmentService.dart';
import '../services/UserService.dart';
import '../services/ProfileService.dart';
import '../interfaces/bussiness/appointment_interface.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<dynamic> appointments = [];
  bool isLoadingAppointments = false;
  String appointmentType = '';
  String? errorMessage;
  int? userRoleId;
  String selectedDate = '';

  // Caché para nombres de usuarios
  Map<int, String> _userNamesCache = {};

  @override
  void initState() {
    super.initState();
    // Inicializar con la fecha de hoy
    final today = DateTime.now();
    selectedDate =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      isLoadingAppointments = true;
      errorMessage = null;
    });

    // Limpiar caché de nombres cuando se recargan las citas
    _userNamesCache.clear();

    try {
      // Obtener el usuario actual
      final user = await UserService.getUser();
      if (user == null || user['role_id'] == null) {
        setState(() {
          errorMessage = 'No se pudo obtener el rol del usuario actual';
          isLoadingAppointments = false;
        });
        return;
      }

      final roleId = user['role_id'];
      userRoleId = roleId; // Guardar el role_id en la variable de estado
      print('=== DEBUG APPOINTMENTS: Usuario Role ID: $roleId ===');

      // Determinar qué método llamar según el role_id del usuario
      if (roleId == 3) {
        print('Usuario es entrenador - llamando fetchTrainerAppointments');
        appointmentType = 'Entrenador';
        final trainerAppointments =
            await AppointmentService.fetchTrainerAppointments();
        setState(() {
          appointments = trainerAppointments ?? [];
          isLoadingAppointments = false;
        });
      } else if (roleId == 5) {
        print('Usuario es cliente - llamando fetchUserAppointments');
        appointmentType = 'Cliente';
        final userAppointments =
            await AppointmentService.fetchUserAppointments();
        setState(() {
          appointments = userAppointments ?? [];
          isLoadingAppointments = false;
        });
      } else if (roleId == 6) {
        print('Usuario es nutriólogo - llamando fetchNutritionistAppointments');
        appointmentType = 'Nutriólogo';
        final nutritionistAppointments =
            await AppointmentService.fetchNutritionistAppointments();
        setState(() {
          appointments = nutritionistAppointments ?? [];
          isLoadingAppointments = false;
        });
      } else {
        print('Usuario role_id $roleId no corresponde a ningún tipo de citas');
        setState(() {
          appointmentType = 'Desconocido';
          appointments = [];
          errorMessage =
              'Tipo de usuario no válido para citas (Role ID: $roleId)';
          isLoadingAppointments = false;
        });
      }

      print('Total de citas cargadas: ${appointments.length}');

      // Precargar nombres de usuarios para evitar "Cargando..." en el futuro
      _preloadUserNames();
    } catch (e) {
      print('Error al cargar citas: $e');
      setState(() {
        errorMessage = 'Error al cargar citas: $e';
        isLoadingAppointments = false;
      });
    }
  }

  // Método para precargar nombres de usuarios en segundo plano
  Future<void> _preloadUserNames() async {
    Set<int> userIds = {};

    // Extraer todos los IDs de usuarios de las citas
    for (final appointment in appointments) {
      if (appointment is TrainerAppointment) {
        userIds.add(appointment.userId);
      } else if (appointment is NutritionistAppointment) {
        userIds.add(appointment.userId);
      } else if (appointment is UserTrainerAppointment) {
        userIds.add(appointment.trainerId);
      } else if (appointment is UserAppointment) {
        if (appointment.trainerId != null) {
          userIds.add(appointment.trainerId!);
        }
        if (appointment.nutritionistId != null) {
          userIds.add(appointment.nutritionistId!);
        }
      }
    }

    // Precargar nombres en segundo plano (sin await para no bloquear la UI)
    for (final userId in userIds) {
      if (!_userNamesCache.containsKey(userId)) {
        _getUserName(userId).catchError((error) {
          // Ignorar errores en precarga, se manejarán cuando se muestre la UI
          print('Error precargando nombre del usuario $userId: $error');
          return 'Usuario $userId'; // Valor por defecto en caso de error
        });
      }
    }
  }

  void _showCreateAppointmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Crear Nueva Cita'),
          content: const Text('Selecciona el tipo de cita que deseas crear:'),
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showCreateTrainerAppointmentForm(context);
                  },
                  child: const Text('Entrenador'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showCreateNutritionistAppointmentForm(context);
                  },
                  child: const Text('Nutriólogo'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showCreateTrainerAppointmentForm(BuildContext context) {
    DateTime? selectedDate;
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    String? errorMessage; // Variable para almacenar mensajes de error

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Cita con Entrenador'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Selector de fecha
                    InkWell(
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 60),
                          ), // 2 meses
                        );
                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                            errorMessage =
                                null; // Limpiar error al seleccionar fecha
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 12),
                            Text(
                              selectedDate != null
                                  ? '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}'
                                  : 'Seleccionar fecha',
                              style: TextStyle(
                                color: selectedDate != null
                                    ? Colors.black
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Selector de hora de inicio
                    InkWell(
                      onTap: () async {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            startTime = pickedTime;
                            errorMessage =
                                null; // Limpiar error al seleccionar hora
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time),
                            const SizedBox(width: 12),
                            Text(
                              startTime != null
                                  ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}'
                                  : 'Hora de inicio',
                              style: TextStyle(
                                color: startTime != null
                                    ? Colors.black
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Selector de hora de fin
                    InkWell(
                      onTap: () async {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            endTime = pickedTime;
                            errorMessage =
                                null; // Limpiar error al seleccionar hora
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time),
                            const SizedBox(width: 12),
                            Text(
                              endTime != null
                                  ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}'
                                  : 'Hora de fin',
                              style: TextStyle(
                                color: endTime != null
                                    ? Colors.black
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Mostrar mensaje de error si existe
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red[700],
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () async {
                    // Validar que todos los campos estén completos
                    if (selectedDate == null ||
                        startTime == null ||
                        endTime == null) {
                      setState(() {
                        errorMessage = 'Por favor completa todos los campos';
                      });
                      return;
                    }

                    // Validar duración máxima de 2 horas 30 minutos
                    final startDateTime = DateTime(
                      2023,
                      1,
                      1,
                      startTime!.hour,
                      startTime!.minute,
                    );
                    final endDateTime = DateTime(
                      2023,
                      1,
                      1,
                      endTime!.hour,
                      endTime!.minute,
                    );
                    final duration = endDateTime.difference(startDateTime);

                    if (duration.isNegative) {
                      setState(() {
                        errorMessage =
                            'La hora de fin debe ser posterior a la hora de inicio';
                      });
                      return;
                    }

                    if (duration.inMinutes > 150) {
                      // 2 horas 30 minutos = 150 minutos
                      setState(() {
                        errorMessage =
                            'La cita no puede durar más de 2 horas y 30 minutos';
                      });
                      return;
                    }

                    // Limpiar mensaje de error si todo está bien
                    setState(() {
                      errorMessage = null;
                    });

                    final dateString =
                        '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}';
                    final startTimeString =
                        '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}';
                    final endTimeString =
                        '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}';

                    // Cerrar el diálogo actual
                    Navigator.of(context).pop();
                    
                    // Buscar entrenadores disponibles
                    await _searchAvailableStaff(
                      context,
                      'trainer',
                      dateString,
                      startTimeString,
                      endTimeString,
                    );
                  },
                  child: const Text('Buscar Disponibles'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCreateNutritionistAppointmentForm(BuildContext context) {
    DateTime? selectedDate;
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    String? errorMessage; // Variable para almacenar mensajes de error

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Cita con Nutriólogo'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Selector de fecha
                    InkWell(
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 60),
                          ), // 2 meses
                        );
                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                            errorMessage =
                                null; // Limpiar error al seleccionar fecha
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 12),
                            Text(
                              selectedDate != null
                                  ? '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}'
                                  : 'Seleccionar fecha',
                              style: TextStyle(
                                color: selectedDate != null
                                    ? Colors.black
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Selector de hora de inicio
                    InkWell(
                      onTap: () async {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            startTime = pickedTime;
                            errorMessage =
                                null; // Limpiar error al seleccionar hora
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time),
                            const SizedBox(width: 12),
                            Text(
                              startTime != null
                                  ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}'
                                  : 'Hora de inicio',
                              style: TextStyle(
                                color: startTime != null
                                    ? Colors.black
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Selector de hora de fin
                    InkWell(
                      onTap: () async {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            endTime = pickedTime;
                            errorMessage =
                                null; // Limpiar error al seleccionar hora
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time),
                            const SizedBox(width: 12),
                            Text(
                              endTime != null
                                  ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}'
                                  : 'Hora de fin',
                              style: TextStyle(
                                color: endTime != null
                                    ? Colors.black
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Mostrar mensaje de error si existe
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red[700],
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () async {
                    // Validar que todos los campos estén completos
                    if (selectedDate == null ||
                        startTime == null ||
                        endTime == null) {
                      setState(() {
                        errorMessage = 'Por favor completa todos los campos';
                      });
                      return;
                    }

                    // Validar duración máxima de 2 horas 30 minutos
                    final startDateTime = DateTime(
                      2023,
                      1,
                      1,
                      startTime!.hour,
                      startTime!.minute,
                    );
                    final endDateTime = DateTime(
                      2023,
                      1,
                      1,
                      endTime!.hour,
                      endTime!.minute,
                    );
                    final duration = endDateTime.difference(startDateTime);

                    if (duration.isNegative) {
                      setState(() {
                        errorMessage =
                            'La hora de fin debe ser posterior a la hora de inicio';
                      });
                      return;
                    }

                    if (duration.inMinutes > 150) {
                      // 2 horas 30 minutos = 150 minutos
                      setState(() {
                        errorMessage =
                            'La cita no puede durar más de 2 horas y 30 minutos';
                      });
                      return;
                    }

                    // Limpiar mensaje de error si todo está bien
                    setState(() {
                      errorMessage = null;
                    });

                    final dateString =
                        '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}';
                    final startTimeString =
                        '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}';
                    final endTimeString =
                        '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}';

                    // Cerrar el diálogo actual
                    Navigator.of(context).pop();
                    
                    // Buscar nutriólogos disponibles
                    await _searchAvailableStaff(
                      context,
                      'nutritionist',
                      dateString,
                      startTimeString,
                      endTimeString,
                    );
                  },
                  child: const Text('Buscar Disponibles'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Método para buscar personal disponible y mostrar diálogo de selección
  Future<void> _searchAvailableStaff(
    BuildContext context,
    String role,
    String date,
    String startTime,
    String endTime,
  ) async {
    try {
      print('=== BÚSQUEDA DE PERSONAL DISPONIBLE ===');
      print('Role: $role');
      print('Date: $date');
      print('Start time: $startTime');
      print('End time: $endTime');

      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Hacer la petición a la API
      final availableStaff = await AppointmentService.getAvailableStaff(
        role: role,
        date: date,
        startTime: startTime,
        endTime: endTime,
      );

      // Cerrar loading
      Navigator.of(context).pop();

      if (availableStaff == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al buscar personal disponible'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (availableStaff.isEmpty) {
        // No hay personal disponible
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('No hay ${role == 'trainer' ? 'entrenadores' : 'nutriólogos'} disponibles'),
            content: Text(
              'No se encontraron ${role == 'trainer' ? 'entrenadores' : 'nutriólogos'} disponibles para el horario seleccionado. '
              'Por favor intenta con otro horario.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
        return;
      }

      // Mostrar lista de personal disponible
      _showAvailableStaffDialog(
        context,
        role,
        availableStaff,
        date,
        startTime,
        endTime,
      );
    } catch (e) {
      // Cerrar loading si está abierto
      Navigator.of(context).pop();
      
      print('Error buscando personal disponible: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Método para mostrar diálogo con personal disponible
  void _showAvailableStaffDialog(
    BuildContext context,
    String role,
    List<Map<String, dynamic>> availableStaff,
    String date,
    String startTime,
    String endTime,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${role == 'trainer' ? 'Entrenadores' : 'Nutriólogos'} Disponibles'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableStaff.length,
            itemBuilder: (context, index) {
              final staff = availableStaff[index];
              final staffId = staff['id'];

              return FutureBuilder<String>(
                future: _getStaffName(staffId),
                builder: (context, snapshot) {
                  String staffName = 'Cargando...';
                  
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      staffName = snapshot.data!;
                    } else {
                      staffName = 'Usuario ID: $staffId';
                    }
                  }

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: role == 'trainer' ? Colors.orange : Colors.green,
                      child: Icon(
                        role == 'trainer' ? Icons.fitness_center : Icons.restaurant,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(staffName),
                    onTap: snapshot.connectionState == ConnectionState.done ? () {
                      Navigator.of(context).pop();
                      _confirmAppointmentCreation(
                        context,
                        role,
                        staffId,
                        staffName,
                        date,
                        startTime,
                        endTime,
                      );
                    } : null, // Deshabilitar tap mientras carga
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  // Método para obtener el nombre del personal usando ProfileService
  Future<String> _getStaffName(int staffId) async {
    try {
      final profile = await ProfileService.fetchProfileById(staffId);
      return profile?.fullName ?? 'Usuario ID: $staffId';
    } catch (e) {
      print('Error obteniendo nombre del personal $staffId: $e');
      return 'Usuario ID: $staffId';
    }
  }

  // Método para confirmar creación de cita
  void _confirmAppointmentCreation(
    BuildContext context,
    String role,
    int staffId,
    String staffName,
    String date,
    String startTime,
    String endTime,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Cita'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Confirmas la creación de la cita?'),
            const SizedBox(height: 16),
            Text('${role == 'trainer' ? 'Entrenador' : 'Nutriólogo'}: $staffName'),
            Text('Fecha: $date'),
            Text('Hora: $startTime - $endTime'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _createAppointmentWithStaff(
                context,
                role,
                staffId,
                date,
                startTime,
                endTime,
              );
            },
            child: const Text('Crear Cita'),
          ),
        ],
      ),
    );
  }

  // Método para crear la cita con el personal seleccionado
  Future<void> _createAppointmentWithStaff(
    BuildContext context,
    String role,
    int staffId,
    String date,
    String startTime,
    String endTime,
  ) async {
    try {
      // Obtener el usuario actual
      final user = await UserService.getUser();
      if (user == null || user['id'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No se pudo obtener el usuario actual'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final userId = user['id'];

      print('=== CREANDO CITA ===');
      print('Usuario ID: $userId');
      print('${role == 'trainer' ? 'Entrenador' : 'Nutriólogo'} ID: $staffId');
      print('Fecha: $date');
      
      // Asegurar formato correcto de horas HH:MM:SS
      final formattedStartTime = _formatTimeForAPI(startTime);
      final formattedEndTime = _formatTimeForAPI(endTime);
      
      print('Hora inicio: $formattedStartTime');
      print('Hora fin: $formattedEndTime');

      dynamic result;
      if (role == 'trainer') {
        result = await AppointmentService.createTrainerAppointment(
          userId: userId,
          trainerId: staffId,
          date: date,
          startTime: formattedStartTime,
          endTime: formattedEndTime,
        );
      } else {
        result = await AppointmentService.createNutritionistAppointment(
          userId: userId,
          nutritionistId: staffId,
          date: date,
          startTime: formattedStartTime,
          endTime: formattedEndTime,
        );
      }

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cita con ${role == 'trainer' ? 'entrenador' : 'nutriólogo'} creada exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Recargar las citas
        _loadAppointments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al crear la cita con ${role == 'trainer' ? 'entrenador' : 'nutriólogo'}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error al crear cita: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Método para formatear hora en formato API (HH:MM)
  String _formatTimeForAPI(String time) {
    // Si ya está en formato HH:MM, devolverlo tal como está
    if (time.split(':').length == 2) {
      return time;
    }
    
    // Si tiene segundos (HH:MM:SS), eliminar los segundos
    if (time.split(':').length == 3) {
      final timeParts = time.split(':');
      return '${timeParts[0]}:${timeParts[1]}';
    }
    
    // Fallback: intentar parsear y formatear sin segundos
    try {
      final timeParts = time.split(':');
      if (timeParts.length >= 2) {
        final hour = timeParts[0].padLeft(2, '0');
        final minute = timeParts[1].padLeft(2, '0');
        return '$hour:$minute';
      }
    } catch (e) {
      print('Error formateando hora $time: $e');
    }
    
    // Si todo falla, devolver la hora original
    return time;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WeeklyCalendar(
            userRoleId: userRoleId,
            onCreateAppointment: () => _showCreateAppointmentDialog(context),
            appointments: appointments,
            onDateSelected: (date) {
              setState(() {
                selectedDate = date;
              });
            },
          ),
          const SizedBox(height: 24),

          // Sección de citas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isToday() ? 'Citas de hoy' : 'Citas del día seleccionado',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!isLoadingAppointments && errorMessage == null)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadAppointments,
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Lista de citas o mensaje de estado
          if (isLoadingAppointments)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (errorMessage != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
            )
          else
            Builder(
              builder: (context) {
                final selectedDayAppointments = _getSelectedDayAppointments();

                if (selectedDayAppointments.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _isToday()
                            ? 'Hoy no tienes citas agendadas!'
                            : 'No hay citas agendadas para este día',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: selectedDayAppointments
                      .map(
                        (appointment) =>
                            _AppointmentCard(appointment: appointment),
                      )
                      .toList(),
                );
              },
            ),

          const SizedBox(height: 24),
          const Text(
            'Recordatorios',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          _ReminderCard(),
        ],
      ),
    );
  }

  Widget _AppointmentCard({required dynamic appointment}) {
    String title = '';
    String time = '';
    IconData icon = Icons.event;
    Color iconColor = Colors.blue;
    int? userId;

    // Determinar el contenido basado en el tipo de cita
    if (appointment is TrainerAppointment) {
      title = 'Sesión de Entrenamiento';
      userId = appointment.userId;
      time =
          '${_formatTime(appointment.startTime)} a ${_formatTime(appointment.endTime)}';
      icon = Icons.fitness_center;
      iconColor = Colors.orange;
    } else if (appointment is NutritionistAppointment) {
      title = 'Consulta Nutricional';
      userId = appointment.userId;
      time =
          '${_formatTime(appointment.startTime)} a ${_formatTime(appointment.endTime)}';
      icon = Icons.restaurant;
      iconColor = Colors.green;
    } else if (appointment is UserTrainerAppointment) {
      title = 'Sesión con Entrenador';
      userId = appointment.trainerId; // En este caso obtenemos el entrenador
      time =
          '${_formatTime(appointment.startTime)} a ${_formatTime(appointment.endTime)}';
      icon = Icons.person;
      iconColor = Colors.blue;
    } else if (appointment is UserAppointment) {
      // Nuevo tipo unificado para usuarios
      if (appointment.type == 'trainer') {
        title = 'Sesión con Entrenador';
        userId = appointment.trainerId;
        icon = Icons.fitness_center;
        iconColor = Colors.orange;
      } else if (appointment.type == 'nutritionist') {
        title = 'Consulta con Nutriólogo';
        userId = appointment.nutritionistId;
        icon = Icons.restaurant;
        iconColor = Colors.green;
      }
      time =
          '${_formatTime(appointment.startTime)} a ${_formatTime(appointment.endTime)}';
    } else {
      // Fallback para tipo dinámico
      title = 'Cita';
      time = 'Sin horario';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                // Usar el widget optimizado para nombres de usuario
                if (userId != null)
                  _buildUserNameWidget(
                    userId,
                    appointment is UserTrainerAppointment ||
                        (appointment is UserAppointment &&
                            appointment.type == 'trainer'),
                  )
                else
                  const Text(
                    'Ver detalles',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Programada',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Método auxiliar para obtener el nombre del usuario con caché
  Future<String> _getUserName(int userId) async {
    // Verificar si ya tenemos el nombre en caché
    if (_userNamesCache.containsKey(userId)) {
      return _userNamesCache[userId]!;
    }

    try {
      final profile = await ProfileService.fetchProfileById(userId);
      final userName = profile?.fullName ?? 'Usuario $userId';

      // Guardar en caché
      _userNamesCache[userId] = userName;

      return userName;
    } catch (e) {
      print('Error obteniendo nombre del usuario $userId: $e');
      final fallbackName = 'Usuario $userId';

      // Guardar también el fallback en caché para evitar repetir errores
      _userNamesCache[userId] = fallbackName;

      return fallbackName;
    }
  }

  // Método para obtener el nombre de forma síncrona si está en caché
  String? _getCachedUserName(int userId) {
    return _userNamesCache[userId];
  }

  // Widget para mostrar el nombre del usuario con manejo de caché
  Widget _buildUserNameWidget(int userId, bool isTrainer) {
    final cachedName = _getCachedUserName(userId);

    if (cachedName != null) {
      // Si tenemos el nombre en caché, mostrarlo inmediatamente
      final prefix = isTrainer ? 'Entrenador: ' : 'Cliente: ';
      return Text(
        '$prefix$cachedName',
        style: const TextStyle(color: Colors.black54, fontSize: 14),
      );
    } else {
      // Si no está en caché, usar FutureBuilder
      return FutureBuilder<String>(
        future: _getUserName(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text(
              'Cargando...',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            );
          } else if (snapshot.hasError) {
            final prefix = isTrainer ? 'Entrenador' : 'Cliente';
            return Text(
              '$prefix ID: $userId',
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            );
          } else {
            final userName = snapshot.data ?? '';
            final prefix = isTrainer ? 'Entrenador: ' : 'Cliente: ';
            return Text(
              '$prefix$userName',
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            );
          }
        },
      );
    }
  }

  // Método auxiliar para formatear las horas en formato 12 horas
  String _formatTime(String timeString) {
    try {
      // Parsear el tiempo en formato HH:mm:ss
      final timeParts = timeString.split(':');
      if (timeParts.length < 2) return timeString;

      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      // Convertir a formato 12 horas
      String period = hour >= 12 ? 'pm' : 'am';
      if (hour == 0) {
        hour = 12; // Medianoche
      } else if (hour > 12) {
        hour = hour - 12; // PM
      }

      // Formatear sin ceros a la izquierda en la hora
      String formattedMinute = minute.toString().padLeft(2, '0');
      return '$hour:$formattedMinute $period';
    } catch (e) {
      return timeString; // Retornar el original si hay error
    }
  }

  // Método auxiliar para normalizar fechas y manejar diferentes formatos
  String _normalizeDate(String dateString) {
    try {
      // Si la fecha ya está en formato YYYY-MM-DD, devolverla tal como está
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateString)) {
        return dateString;
      }

      // Si la fecha está en formato YYYY/MM/DD, convertir a YYYY-MM-DD
      if (RegExp(r'^\d{4}/\d{2}/\d{2}$').hasMatch(dateString)) {
        return dateString.replaceAll('/', '-');
      }

      // Si la fecha está en formato ISO (2025-08-04T00:00:00.000Z), extraer solo la parte de la fecha
      if (dateString.contains('T')) {
        return dateString.split('T')[0];
      }

      // Si no coincide con ningún formato conocido, intentar parsear como DateTime
      final parsedDate = DateTime.parse(dateString);
      return '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}';
    } catch (e) {
      print('Error normalizando fecha $dateString: $e');
      return dateString; // Devolver la fecha original si hay error
    }
  }

  // Método para verificar si la fecha seleccionada es hoy
  bool _isToday() {
    final today = DateTime.now();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return selectedDate == todayString;
  }

  // Método para filtrar las citas del día seleccionado
  List<dynamic> _getSelectedDayAppointments() {
    print('=== DEBUG FILTERING APPOINTMENTS ===');
    print('Selected date: $selectedDate');
    print('Total appointments: ${appointments.length}');

    final filtered = appointments.where((appointment) {
      String appointmentDate = '';

      if (appointment is TrainerAppointment) {
        appointmentDate = _normalizeDate(appointment.date);
        print(
          'TrainerAppointment - Original: ${appointment.date}, Normalized: $appointmentDate',
        );
      } else if (appointment is NutritionistAppointment) {
        appointmentDate = _normalizeDate(appointment.date);
        print(
          'NutritionistAppointment - Original: ${appointment.date}, Normalized: $appointmentDate',
        );
      } else if (appointment is UserTrainerAppointment) {
        appointmentDate = _normalizeDate(appointment.date);
        print(
          'UserTrainerAppointment - Original: ${appointment.date}, Normalized: $appointmentDate',
        );
      } else if (appointment is UserAppointment) {
        appointmentDate = _normalizeDate(appointment.date);
        print(
          'UserAppointment (${appointment.type}) - Original: ${appointment.date}, Normalized: $appointmentDate',
        );
      }

      final matches = appointmentDate == selectedDate;
      print('Date match: $appointmentDate == $selectedDate = $matches');
      return matches;
    }).toList();

    print('Filtered appointments count: ${filtered.length}');
    return filtered;
  }
}

class _WeeklyCalendar extends StatefulWidget {
  final int? userRoleId;
  final VoidCallback? onCreateAppointment;
  final List<dynamic> appointments;
  final Function(String) onDateSelected;

  const _WeeklyCalendar({
    this.userRoleId,
    this.onCreateAppointment,
    required this.appointments,
    required this.onDateSelected,
  });

  @override
  State<_WeeklyCalendar> createState() => _WeeklyCalendarState();
}

class _WeeklyCalendarState extends State<_WeeklyCalendar> {
  int selectedDayIndex = -1;

  @override
  void initState() {
    super.initState();
    // Inicializar con el día de hoy seleccionado
    selectedDayIndex = _getTodayIndex();
  }

  List<String> _getWeekDays() {
    return ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  }

  List<DateTime> _getCurrentWeekDates() {
    final today = DateTime.now();
    // Calcular el lunes de la semana actual
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    return List.generate(7, (index) {
      return startOfWeek.add(Duration(days: index));
    });
  }

  List<int> _getCurrentWeekDays() {
    return _getCurrentWeekDates().map((date) => date.day).toList();
  }

  int _getTodayIndex() {
    final today = DateTime.now();
    // Lunes = 1, Martes = 2, ..., Domingo = 7
    // Convertir a índice 0-6 donde Lunes = 0, Domingo = 6
    return today.weekday - 1;
  }

  String _getSelectedDateString() {
    final weekDates = _getCurrentWeekDates();
    if (selectedDayIndex >= 0 && selectedDayIndex < weekDates.length) {
      final selectedDate = weekDates[selectedDayIndex];
      return '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
    }
    return '';
  }

  void _onDaySelected(int index) {
    setState(() {
      selectedDayIndex = index;
    });
    widget.onDateSelected(_getSelectedDateString());
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _getWeekDays();
    final weekNumbers = _getCurrentWeekDays();
    final todayIndex = _getTodayIndex();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF2F2FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((day) => Text(day)).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekNumbers.asMap().entries.map((entry) {
              int index = entry.key;
              int dayNumber = entry.value;
              return GestureDetector(
                onTap: () => _onDaySelected(index),
                child: _DayCircle(
                  text: dayNumber.toString(),
                  selected: index == selectedDayIndex,
                  isToday: index == todayIndex,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: widget.userRoleId == 5
                ? Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.black),
                      onPressed: widget.onCreateAppointment,
                    ),
                  )
                : const SizedBox.shrink(), // No mostrar nada si no es cliente
          ),
        ],
      ),
    );
  }
}

class _DayCircle extends StatelessWidget {
  final String text;
  final bool selected;
  final bool isToday;

  const _DayCircle({
    required this.text,
    this.selected = false,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    if (selected) {
      backgroundColor = Colors.deepPurple;
      textColor = Colors.white;
    } else if (isToday) {
      backgroundColor = Colors.deepPurple.withOpacity(0.3);
      textColor = Colors.deepPurple;
    } else {
      backgroundColor = Colors.white;
      textColor = Colors.black;
    }

    return CircleAvatar(
      radius: 16,
      backgroundColor: backgroundColor,
      child: Text(
        text,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Color(0xFFF2F2FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text('Recordatorio del día'),
          CircleAvatar(
            radius: 12,
            backgroundColor: Color.fromRGBO(127, 17, 224, 1),
            child: Icon(Icons.info_outline, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }
}
