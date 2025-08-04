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

  @override
  void initState() {
    super.initState();
    // Inicializar con la fecha de hoy
    final today = DateTime.now();
    selectedDate = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      isLoadingAppointments = true;
      errorMessage = null;
    });

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
    } catch (e) {
      print('Error al cargar citas: $e');
      setState(() {
        errorMessage = 'Error al cargar citas: $e';
        isLoadingAppointments = false;
      });
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
    final TextEditingController trainerIdController = TextEditingController();
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
                    TextField(
                      controller: trainerIdController,
                      decoration: const InputDecoration(
                        labelText: 'ID del Entrenador',
                        hintText: 'Ejemplo: 1',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

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
                                  ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}:00'
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
                                  ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}:00'
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
                    if (trainerIdController.text.isEmpty ||
                        selectedDate == null ||
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
                        '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}:00';
                    final endTimeString =
                        '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}:00';

                    await _createTrainerAppointment(
                      trainerIdController.text,
                      dateString,
                      startTimeString,
                      endTimeString,
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCreateNutritionistAppointmentForm(BuildContext context) {
    final TextEditingController nutritionistIdController =
        TextEditingController();
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
                    TextField(
                      controller: nutritionistIdController,
                      decoration: const InputDecoration(
                        labelText: 'ID del Nutriólogo',
                        hintText: 'Ejemplo: 1',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

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
                                  ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}:00'
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
                                  ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}:00'
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
                    if (nutritionistIdController.text.isEmpty ||
                        selectedDate == null ||
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
                        '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}:00';
                    final endTimeString =
                        '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}:00';

                    await _createNutritionistAppointment(
                      nutritionistIdController.text,
                      dateString,
                      startTimeString,
                      endTimeString,
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _createTrainerAppointment(
    String trainerId,
    String date,
    String startTime,
    String endTime,
  ) async {
    try {
      // Obtener el usuario actual para el userId
      final user = await UserService.getUser();
      if (user == null || user['id'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No se pudo obtener el usuario actual'),
          ),
        );
        return;
      }

      final userId = user['id'];
      final trainerIdInt = int.tryParse(trainerId);

      if (trainerIdInt == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: ID del entrenador inválido')),
        );
        return;
      }

      print('=== CREANDO CITA CON ENTRENADOR ===');
      print('Usuario ID: $userId');
      print('Entrenador ID: $trainerIdInt');
      print('Fecha: $date');
      print('Hora inicio: $startTime');
      print('Hora fin: $endTime');

      final result = await AppointmentService.createTrainerAppointment(
        userId: userId,
        trainerId: trainerIdInt,
        date: date,
        startTime: startTime,
        endTime: endTime,
      );

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cita con entrenador creada exitosamente'),
          ),
        );
        // Recargar las citas
        _loadAppointments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al crear la cita con entrenador'),
          ),
        );
      }
    } catch (e) {
      print('Error al crear cita con entrenador: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _createNutritionistAppointment(
    String nutritionistId,
    String date,
    String startTime,
    String endTime,
  ) async {
    try {
      // Obtener el usuario actual para el userId
      final user = await UserService.getUser();
      if (user == null || user['id'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No se pudo obtener el usuario actual'),
          ),
        );
        return;
      }

      final userId = user['id'];
      final nutritionistIdInt = int.tryParse(nutritionistId);

      if (nutritionistIdInt == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: ID del nutriólogo inválido')),
        );
        return;
      }

      print('=== CREANDO CITA CON NUTRIÓLOGO ===');
      print('Usuario ID: $userId');
      print('Nutriólogo ID: $nutritionistIdInt');
      print('Fecha: $date');
      print('Hora inicio: $startTime');
      print('Hora fin: $endTime');

      final result = await AppointmentService.createNutritionistAppointment(
        userId: userId,
        nutritionistId: nutritionistIdInt,
        date: date,
        startTime: startTime,
        endTime: endTime,
      );

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cita con nutriólogo creada exitosamente'),
          ),
        );
        // Recargar las citas
        _loadAppointments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al crear la cita con nutriólogo'),
          ),
        );
      }
    } catch (e) {
      print('Error al crear cita con nutriólogo: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
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
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        style: const TextStyle(color: Colors.black54, fontSize: 16),
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
                // Usar FutureBuilder para obtener el nombre del usuario
                if (userId != null)
                  FutureBuilder<String>(
                    future: _getUserName(userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text(
                          'Cargando...',
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        );
                      } else if (snapshot.hasError) {
                        return Text(
                          appointment is UserTrainerAppointment
                              ? 'Entrenador ID: $userId'
                              : 'Cliente ID: $userId',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        );
                      } else {
                        final userName = snapshot.data ?? '';
                        final prefix = appointment is UserTrainerAppointment
                            ? 'Entrenador: '
                            : 'Cliente: ';
                        return Text(
                          '$prefix$userName',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        );
                      }
                    },
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

  // Método auxiliar para obtener el nombre del usuario
  Future<String> _getUserName(int userId) async {
    try {
      final profile = await ProfileService.fetchProfileById(userId);
      return profile?.fullName ?? 'Usuario $userId';
    } catch (e) {
      print('Error obteniendo nombre del usuario $userId: $e');
      return 'Usuario $userId';
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

  // Método para verificar si la fecha seleccionada es hoy
  bool _isToday() {
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return selectedDate == todayString;
  }

  // Método para filtrar las citas del día seleccionado
  List<dynamic> _getSelectedDayAppointments() {
    return appointments.where((appointment) {
      String appointmentDate = '';

      if (appointment is TrainerAppointment) {
        appointmentDate = appointment.date;
      } else if (appointment is NutritionistAppointment) {
        appointmentDate = appointment.date;
      } else if (appointment is UserTrainerAppointment) {
        appointmentDate = appointment.date;
      }

      return appointmentDate == selectedDate;
    }).toList();
  }

  // Método para filtrar las citas de hoy (mantenido para compatibilidad)
  List<dynamic> _getTodayAppointments() {
    final today = DateTime.now();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return appointments.where((appointment) {
      String appointmentDate = '';

      if (appointment is TrainerAppointment) {
        appointmentDate = appointment.date;
      } else if (appointment is NutritionistAppointment) {
        appointmentDate = appointment.date;
      } else if (appointment is UserTrainerAppointment) {
        appointmentDate = appointment.date;
      }

      return appointmentDate == todayString;
    }).toList();
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

  List<dynamic> _getAppointmentsForSelectedDay() {
    final selectedDateString = _getSelectedDateString();
    return widget.appointments.where((appointment) {
      String appointmentDate = '';
      
      if (appointment is TrainerAppointment) {
        appointmentDate = appointment.date;
      } else if (appointment is NutritionistAppointment) {
        appointmentDate = appointment.date;
      } else if (appointment is UserTrainerAppointment) {
        appointmentDate = appointment.date;
      }
      
      return appointmentDate == selectedDateString;
    }).toList();
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
    final selectedAppointments = _getAppointmentsForSelectedDay();

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
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Día seleccionado:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: selectedAppointments.isEmpty
                ? const Text(
                    'No hay citas programadas para este día',
                    style: TextStyle(color: Colors.black54),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: selectedAppointments.map((appointment) {
                      String title = '';
                      String time = '';
                      
                      if (appointment is TrainerAppointment) {
                        title = 'Sesión de Entrenamiento';
                        time = '${appointment.startTime} - ${appointment.endTime}';
                      } else if (appointment is NutritionistAppointment) {
                        title = 'Consulta Nutricional';
                        time = '${appointment.startTime} - ${appointment.endTime}';
                      } else if (appointment is UserTrainerAppointment) {
                        title = 'Sesión con Entrenador';
                        time = '${appointment.startTime} - ${appointment.endTime}';
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '$title - $time',
                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      );
                    }).toList(),
                  ),
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
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
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
