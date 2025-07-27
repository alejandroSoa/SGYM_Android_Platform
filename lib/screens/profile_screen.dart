import 'package:flutter/material.dart';
import '../interfaces/user/profile_interface.dart';
import '../interfaces/user/qr_interface.dart';
import '../services/ProfileService.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Profile? profile;
  bool loading = true;
  bool isUpdating = false;
  bool isLoadingQr = false;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final fetchedProfile = await ProfileService.fetchProfile();

    setState(() {
      profile = fetchedProfile;
      loading = false;
    });
  }

  Future<void> _showEditDialog(
    String fieldName,
    String currentValue,
    String fieldKey,
  ) async {
    if (fieldKey == 'gender') {
      _showGenderDialog(currentValue);
      return;
    }

    if (fieldKey == 'birthDate') {
      _showDateDialog(currentValue);
      return;
    }

    if (fieldKey == 'password') {
      _showPasswordDialog();
      return;
    }

    final TextEditingController controller = TextEditingController(
      text: currentValue,
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.black.withOpacity(0.5),
          body: SafeArea(
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Editar $fieldName',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: fieldName,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF2F2FF),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: isUpdating
                              ? null
                              : () async {
                                  final newValue = controller.text.trim();
                                  if (newValue.isNotEmpty &&
                                      newValue != currentValue) {
                                    Navigator.of(context).pop();
                                    await _updateField(fieldKey, newValue);
                                  } else {
                                    Navigator.of(context).pop();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7012DA),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Aceptar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showPasswordDialog() async {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.black.withOpacity(0.5),
          body: SafeArea(
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cambiar Contraseña',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: currentPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Contraseña Actual',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF2F2FF),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Nueva Contraseña',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF2F2FF),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirmar Nueva Contraseña',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF2F2FF),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: isUpdating
                              ? null
                              : () async {
                                  final currentPassword =
                                      currentPasswordController.text.trim();
                                  final newPassword = newPasswordController.text
                                      .trim();
                                  final confirmPassword =
                                      confirmPasswordController.text.trim();

                                  if (currentPassword.isEmpty ||
                                      newPassword.isEmpty ||
                                      confirmPassword.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Todos los campos son obligatorios',
                                        ),
                                        backgroundColor: Color.fromARGB(
                                          152,
                                          244,
                                          67,
                                          54,
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  if (newPassword != confirmPassword) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Las contraseñas no coinciden',
                                        ),
                                        backgroundColor: Color.fromARGB(
                                          152,
                                          244,
                                          67,
                                          54,
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  Navigator.of(context).pop();
                                  await _updatePassword(
                                    currentPassword,
                                    newPassword,
                                    confirmPassword,
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7012DA),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Actualizar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showGenderDialog(String currentGender) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.black.withOpacity(0.5),
          body: SafeArea(
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 40,
                ),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Seleccionar Género',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: isUpdating
                                ? null
                                : () {
                                    Navigator.of(context).pop();
                                    _updateField('gender', 'M');
                                  },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: currentGender == 'M'
                                    ? const Color(0xFF7012DA)
                                    : const Color(0xFFF2F2FF),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: currentGender == 'M'
                                      ? const Color(0xFF7012DA)
                                      : Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.male,
                                    size: 24,
                                    color: currentGender == 'M'
                                        ? Colors.white
                                        : const Color(0xFF7012DA),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Masculino',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: currentGender == 'M'
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: isUpdating
                                ? null
                                : () {
                                    Navigator.of(context).pop();
                                    _updateField('gender', 'F');
                                  },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: currentGender == 'F'
                                    ? const Color(0xFF7012DA)
                                    : const Color(0xFFF2F2FF),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: currentGender == 'F'
                                      ? const Color(0xFF7012DA)
                                      : Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.female,
                                    size: 24,
                                    color: currentGender == 'F'
                                        ? Colors.white
                                        : const Color(0xFF7012DA),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Femenino',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: currentGender == 'F'
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDateDialog(String currentDate) async {
    DateTime? selectedDate;

    if (currentDate.isNotEmpty) {
      try {
        selectedDate = DateTime.parse(currentDate);
      } catch (e) {
        selectedDate = DateTime.now();
      }
    } else {
      selectedDate = DateTime.now();
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7012DA),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final formattedDate =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      await _updateField('birthDate', formattedDate);
    }
  }

  Future<void> _updateField(String fieldKey, String newValue) async {
    if (profile == null || isUpdating) return;

    setState(() {
      isUpdating = true;
    });

    try {
      Profile? updatedProfile;

      switch (fieldKey) {
        case 'fullName':
          updatedProfile = await ProfileService.updateProfile(
            profile!,
            fullName: newValue,
          );
          break;
        case 'phone':
          updatedProfile = await ProfileService.updateProfile(
            profile!,
            phone: newValue,
          );
          break;
        case 'birthDate':
          updatedProfile = await ProfileService.updateProfile(
            profile!,
            birthDate: newValue,
          );
          break;
        case 'gender':
          updatedProfile = await ProfileService.updateProfile(
            profile!,
            gender: newValue,
          );
          break;
        case 'photoUrl':
          updatedProfile = await ProfileService.updateProfile(
            profile!,
            photoUrl: newValue,
          );
          break;
      }

      if (updatedProfile != null) {
        setState(() {
          profile = updatedProfile;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Campo actualizado correctamente'),
              duration: Duration(seconds: 2),
              backgroundColor: Color(0xFF019E83),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al actualizar el campo'),
              duration: Duration(seconds: 2),
              backgroundColor: Color.fromARGB(152, 244, 67, 54),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error de conexión';

        try {
          final errorString = e.toString();
          if (errorString.contains('Exception: ')) {
            final jsonString = errorString.substring(errorString.indexOf('{'));
            final errorData = json.decode(jsonString);

            if (errorData['data'] != null) {
              final fieldErrors = errorData['data'] as Map<String, dynamic>;

              String apiFieldKey;
              switch (fieldKey) {
                case 'fullName':
                  apiFieldKey = 'full_name';
                  break;
                case 'phone':
                  apiFieldKey = 'phone';
                  break;
                case 'birthDate':
                  apiFieldKey = 'birth_date';
                  break;
                case 'gender':
                  apiFieldKey = 'gender';
                  break;
                case 'photoUrl':
                  apiFieldKey = 'photo_url';
                  break;
                default:
                  apiFieldKey = fieldKey;
              }

              if (fieldErrors[apiFieldKey] != null) {
                errorMessage = fieldErrors[apiFieldKey].toString();
              } else if (errorData['msg'] != null) {
                errorMessage = errorData['msg'].toString();
              }
            }
          }
        } catch (parseError) {
          errorMessage = 'Error al actualizar el campo';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 3),
            backgroundColor: const Color.fromARGB(152, 244, 67, 54),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isUpdating = false;
        });
      }
    }
  }

  Future<void> _updatePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    if (isUpdating) return;

    setState(() {
      isUpdating = true;
    });

    try {
      await ProfileService.updatePassword(
        currentPassword,
        newPassword,
        confirmPassword,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contraseña actualizada correctamente'),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFF019E83),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error de conexión';

        try {
          final errorString = e.toString();
          if (errorString.contains('Exception: ')) {
            final jsonString = errorString.substring(errorString.indexOf('{'));
            final errorData = json.decode(jsonString);

            if (errorData['msg'] != null) {
              errorMessage = errorData['msg'].toString();
            }
          }
        } catch (parseError) {
          errorMessage = 'Error al actualizar la contraseña';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 3),
            backgroundColor: const Color.fromARGB(152, 244, 67, 54),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isUpdating = false;
        });
      }
    }
  }

  String _getGenderDisplay(String gender) {
    switch (gender) {
      case 'M':
        return 'Masculino';
      case 'F':
        return 'Femenino';
      default:
        return gender;
    }
  }

  Future<void> _showQrCode() async {
    print('=== INICIANDO _showQrCode ==='); // Debug log
    setState(() {
      isLoadingQr = true;
    });

    try {
      print('Llamando a ProfileService.fetchQrCode()...'); // Debug log
      final qrData = await ProfileService.fetchQrCode();
      print('Respuesta de ProfileService recibida exitosamente'); // Debug log

      if (qrData != null) {
        print('QR Base64 length: ${qrData.qrImageBase64.length}'); // Debug log
        print(
          'userId: ${qrData.userId}, qrToken: ${qrData.qrToken}',
        ); // Debug log

        // Limpiar el string base64 removiendo el prefijo si existe
        String cleanBase64 = qrData.qrImageBase64;
        if (cleanBase64.startsWith('data:image/')) {
          final commaIndex = cleanBase64.indexOf(',');
          if (commaIndex != -1) {
            cleanBase64 = cleanBase64.substring(commaIndex + 1);
          }
        }
        print('Base64 limpio length: ${cleanBase64.length}'); // Debug log

        if (mounted) {
          print('Widget está mounted, mostrando dialog...'); // Debug log
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              print('Construyendo dialog...'); // Debug log
              return Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Tu Código QR',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              base64Decode(cleanBase64),
                              width: 250,
                              height: 250,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                print(
                                  'Error al mostrar imagen QR: $error',
                                ); // Debug log
                                return Container(
                                  width: 250,
                                  height: 250,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        size: 48,
                                        color: Colors.red,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Error al cargar QR',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          print('Cerrando dialog...'); // Debug log
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7012DA),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
          print('Dialog mostrado exitosamente'); // Debug log
        } else {
          print('Widget NO está mounted'); // Debug log
        }
      } else {
        print('QR Data es null - mostrando SnackBar de error'); // Debug log
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Error al generar el código QR - No se recibieron datos',
              ),
              backgroundColor: Color.fromARGB(152, 244, 67, 54),
            ),
          );
        }
      }
    } catch (e) {
      print('ERROR CAPTURADO en _showQrCode: $e'); // Debug log
      print('Tipo de error: ${e.runtimeType}'); // Debug log

      if (mounted) {
        // Verificar si es realmente un error o una respuesta exitosa mal manejada
        final errorString = e.toString();
        if (errorString.contains('"status":"success"')) {
          print(
            'Detectada respuesta exitosa mal interpretada como error',
          ); // Debug log

          try {
            // Intentar parsear los datos directamente desde la excepción
            final jsonString = errorString.substring(errorString.indexOf('{'));
            final errorData = json.decode(jsonString);

            if (errorData['status'] == 'success' && errorData['data'] != null) {
              print(
                'Parseando datos exitosos desde la excepción...',
              ); // Debug log
              final qrData = QrCode.fromJson(errorData['data']);

              // Limpiar el string base64
              String cleanBase64 = qrData.qrImageBase64;
              if (cleanBase64.startsWith('data:image/')) {
                final commaIndex = cleanBase64.indexOf(',');
                if (commaIndex != -1) {
                  cleanBase64 = cleanBase64.substring(commaIndex + 1);
                }
              }

              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Tu Código QR',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Container(
                              width: 250,
                              height: 250,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  base64Decode(cleanBase64),
                                  width: 250,
                                  height: 250,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 250,
                                      height: 250,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            size: 48,
                                            color: Colors.red,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Error al cargar QR',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7012DA),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Cerrar'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
              return; // Salir después de mostrar el QR exitosamente
            }
          } catch (parseError) {
            print(
              'Error al parsear datos de la excepción: $parseError',
            ); // Debug log
          }
        }

        // Si llegamos aquí, es un error real
        String errorMessage = 'Error al generar el código QR';

        try {
          if (errorString.contains('Exception: ')) {
            final jsonString = errorString.substring(errorString.indexOf('{'));
            final errorData = json.decode(jsonString);

            if (errorData['msg'] != null) {
              errorMessage = errorData['msg'].toString();
            }
          }
        } catch (parseError) {
          errorMessage = 'Error de conexión';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 3),
            backgroundColor: const Color.fromARGB(152, 244, 67, 54),
          ),
        );
      }
    } finally {
      print('=== FINALIZANDO _showQrCode ==='); // Debug log
      if (mounted) {
        setState(() {
          isLoadingQr = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (profile == null) {
      return const Scaffold(body: Center(child: Text('Error cargando perfil')));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: isUpdating
                        ? null
                        : () => _showEditDialog(
                            'URL de foto de perfil',
                            profile!.photoUrl ?? '',
                            'photoUrl',
                          ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: profile!.photoUrl != null
                          ? NetworkImage(profile!.photoUrl!)
                          : null,
                      backgroundColor: Colors.grey[400],
                      child: profile!.photoUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile!.fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile!.phone != null && profile!.phone!.isNotEmpty
                        ? '+52 ${profile!.phone}'
                        : '',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: isUpdating
                              ? null
                              : () => _showEditDialog(
                                  'Género',
                                  _getGenderDisplay(profile!.gender),
                                  'gender',
                                ),
                          child: _InfoBox(
                            icon: Icons.male,
                            label: 'Género',
                            value: _getGenderDisplay(profile!.gender),
                          ),
                        ),
                        GestureDetector(
                          onTap: isUpdating
                              ? null
                              : () => _showEditDialog(
                                  'Fecha de nacimiento',
                                  profile!.birthDate,
                                  'birthDate',
                                ),
                          child: _InfoBox(
                            icon: Icons.calendar_month,
                            label: 'Nacimiento',
                            value: profile!.birthDate,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _OptionItem(
                    title: 'Subscripción',
                    icon: Icons.credit_card,
                    iconColor: Color(0xFF7012DA),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: isUpdating || isLoadingQr ? null : _showQrCode,
                    child: Stack(
                      children: [
                        const _OptionItem(
                          title: 'QR',
                          icon: Icons.qr_code_2_rounded,
                          iconColor: Color(0xFF7012DA),
                        ),
                        if (isLoadingQr)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF7012DA),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: isUpdating
                              ? null
                              : () => _showEditDialog(
                                  'Nombre completo',
                                  profile!.fullName,
                                  'fullName',
                                ),
                          child: _EditableField(
                            label: 'Nombre completo',
                            value: profile!.fullName,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: isUpdating
                              ? null
                              : () => _showEditDialog(
                                  'Contraseña',
                                  '',
                                  'password',
                                ),
                          child: const _EditableField(
                            label: 'Contraseña',
                            value: '********',
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: isUpdating
                              ? null
                              : () => _showEditDialog(
                                  'Teléfono',
                                  profile!.phone ?? '',
                                  'phone',
                                ),
                          child: _EditableField(
                            label: 'Teléfono',
                            value:
                                profile!.phone != null &&
                                    profile!.phone!.isNotEmpty
                                ? '+52 ${profile!.phone}'
                                : '',
                          ),
                        ),
                        const SizedBox(height: 150),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isUpdating)
              Container(
                color: const Color.fromRGBO(0, 0, 0, 1).withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF7012DA),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color.fromRGBO(103, 58, 183, 1), size: 24),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? iconColor;

  const _OptionItem({required this.title, this.icon, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              icon != null
                  ? Icon(icon, size: 24, color: iconColor ?? Colors.grey[600])
                  : Container(width: 24, height: 24, color: Colors.grey[300]),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 16)),
            ],
          ),
          const Icon(Icons.chevron_right, color: Colors.black54),
        ],
      ),
    );
  }
}

class _EditableField extends StatelessWidget {
  final String label;
  final String value;

  const _EditableField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.edit_note_rounded,
            color: Color.fromRGBO(122, 90, 249, 1),
          ),
        ],
      ),
    );
  }
}
