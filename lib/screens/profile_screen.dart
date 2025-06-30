import 'package:flutter/material.dart';
import '../interfaces/user/profile_interface.dart';
import '../services/ProfileService.dart';
import '../services/QrService.dart';
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

  Future<void> _showEditDialog(String fieldName, String currentValue, String fieldKey) async {
    if (fieldKey == 'gender') {
      _showGenderDialog(currentValue);
      return;
    }
    
    if (fieldKey == 'birthDate') {
      _showDateDialog(currentValue);
      return;
    }

    final TextEditingController controller = TextEditingController(text: currentValue);
    
    showDialog(
      context: context,
      barrierDismissible: false,
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
                          onPressed: isUpdating ? null : () async {
                            final newValue = controller.text.trim();
                            if (newValue.isNotEmpty && newValue != currentValue) {
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

  Future<void> _showGenderDialog(String currentGender) async {
    showDialog(
      context: context,
      barrierDismissible: false,
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
                      'Seleccionar Género',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: isUpdating ? null : () {
                              Navigator.of(context).pop();
                              _updateField('gender', 'M');
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: currentGender == 'M' 
                                    ? const Color(0xFF7012DA)
                                    : const Color(0xFFF2F2FF),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: currentGender == 'M' 
                                      ? const Color(0xFF7012DA)
                                      : Colors.grey[300]!,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.male,
                                    size: 40,
                                    color: currentGender == 'M' 
                                        ? Colors.white 
                                        : const Color(0xFF7012DA),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Masculino',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: currentGender == 'M' 
                                          ? Colors.white 
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: isUpdating ? null : () {
                              Navigator.of(context).pop();
                              _updateField('gender', 'F');
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: currentGender == 'F' 
                                    ? const Color(0xFF7012DA)
                                    : const Color(0xFFF2F2FF),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: currentGender == 'F' 
                                      ? const Color(0xFF7012DA)
                                      : Colors.grey[300]!,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.female,
                                    size: 40,
                                    color: currentGender == 'F' 
                                        ? Colors.white 
                                        : const Color(0xFF7012DA),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Femenino',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: currentGender == 'F' 
                                          ? Colors.white 
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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
    
    // Parsear la fecha actual si existe
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
      final formattedDate = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
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
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al actualizar el campo'),
            duration: Duration(seconds: 2),
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

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (profile == null) {
      return const Scaffold(
        body: Center(child: Text('Error cargando perfil')),
      );
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
                    onTap: isUpdating ? null : () => _showEditDialog(
                      'URL de foto de perfil', 
                      profile!.photoUrl ?? '', 
                      'photoUrl'
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: profile!.photoUrl != null
                          ? NetworkImage(profile!.photoUrl!)
                          : null,
                      backgroundColor: Colors.grey[400],
                      child: profile!.photoUrl == null
                          ? const Icon(Icons.person, size: 60, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile!.fullName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile!.phone != null && profile!.phone!.isNotEmpty 
                        ? '+52 ${profile!.phone}' 
                        : '',                    style: const TextStyle(color: Colors.black54),
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
                          onTap: isUpdating ? null : () => _showEditDialog(
                            'Género', 
                            _getGenderDisplay(profile!.gender), 
                            'gender'
                          ),
                          child: _InfoBox(
                            icon: Icons.male,
                            label: 'Género',
                            value: _getGenderDisplay(profile!.gender),
                          ),
                        ),
                        GestureDetector(
                          onTap: isUpdating ? null : () => _showEditDialog(
                            'Fecha de nacimiento', 
                            profile!.birthDate, 
                            'birthDate'
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
                    onTap: () async {
                      if (profile == null) return;
                      final qrData = await QrService.generateQr(profile!.userId);
                      if (qrData != null && qrData['qr_image_base64'] != null && mounted) {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Tu código QR'),
                            content: Image.memory(
                              base64Decode(
                                qrData['qr_image_base64'].split(',').last,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cerrar'),
                              ),
                            ],
                          ),
                        );
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No se pudo generar el QR')),
                        );
                      }
                    },
                    child: const _OptionItem(
                      title: 'QR',
                      icon: Icons.qr_code_2_rounded,
                      iconColor: Color(0xFF7012DA),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: isUpdating ? null : () => _showEditDialog(
                            'Nombre completo', 
                            profile!.fullName, 
                            'fullName'
                          ),
                          child: _EditableField(
                            label: 'Nombre completo', 
                            value: profile!.fullName
                          ),
                        ),
                        const SizedBox(height: 12),
                        const _EditableField(label: 'Contraseña', value: '********'),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: isUpdating ? null : () => _showEditDialog(
                            'Teléfono', 
                            profile!.phone ?? '', 
                            'phone'
                          ),
                          child: _EditableField(
                            label: 'Teléfono', 
                            value: profile!.phone != null && profile!.phone!.isNotEmpty 
                                ? '+52 ${profile!.phone}' 
                                : ''
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
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7012DA)),
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
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  )
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  )
                ),
              ],
            ),
          ),
          const Icon(
            Icons.edit_note_rounded, 
            color: Color.fromRGBO(122, 90, 249, 1)
          ),
        ],
      ),
    );
  }
}