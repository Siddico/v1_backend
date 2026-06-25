import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grad_imp_1/core/localization/app_localizations.dart';

import 'patient_search_view_content.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/constants/app_constants.dart';
import 'doctor_card.dart';
import 'search_not_found_state.dart';
import 'speciality_chip.dart';
import '../../../../../core/networking/dio_factory.dart';
import '../../../../../core/networking/api_constants.dart';

class PatientSearchViewContentState extends State<PatientSearchViewContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSpecialty = 'All';

  List<Map<String, dynamic>> _doctors = [];
  List<String> _specialties = ['All'];
  bool _isLoading = true;
  String? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    
    _fetchDoctors();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      _fetchDoctors();
    });
  }
  
  Future<void> _fetchDoctors() async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get('${ApiConstants.baseUrl}/doctors');
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        final List<dynamic> data = response.data['data'] ?? [];
        
        final newDocs = <Map<String, dynamic>>[];
        final specs = <String>{'All'};
        
        for (var doc in data) {
          final docMap = doc as Map<String, dynamic>;
          newDocs.add({
             'id': docMap['id'].toString(),
             'name': docMap['name']?.toString() ?? docMap['fullName']?.toString() ?? 'Doctor',
             'specialization': docMap['specialization']?.toString() ?? 'General Neurology',
             'photo_url': docMap['photo_url']?.toString() ?? '',
          });
          
          final spec = docMap['specialization']?.toString().trim();
          if (spec != null && spec.isNotEmpty) {
            specs.add(spec);
          }
        }
        
        if (mounted) {
           setState(() {
             _doctors = newDocs;
             _specialties = specs.toList()..sort();
             _isLoading = false;
             _error = null;
           });
        }
      }
    } catch (e) {
      if (mounted && _doctors.isEmpty) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search doctor, specialty...'.tr(context),
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                      fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.tealP,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.search, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),

        // Horizontal list of specialties
        Container(
          height: 38,
          margin: const EdgeInsetsDirectional.only(bottom: 16),
          child: ListView.separated(
             scrollDirection: Axis.horizontal,
             padding: const EdgeInsets.symmetric(horizontal: 16),
             itemCount: _specialties.length,
             // ignore: unnecessary_underscores
             separatorBuilder: (_, __) => const SizedBox(width: 8),
             itemBuilder: (context, index) {
               final spec = _specialties[index];
               final isSelected = _selectedSpecialty == spec;
               return SpecialtyChip(
                 label: spec,
                 isSelected: isSelected,
                 onTap: () {
                   setState(() {
                     _selectedSpecialty = spec;
                   });
                 },
               );
             },
          ),
        ),

        Expanded(
          child: _isLoading
             ? const Center(child: CircularProgressIndicator(color: AppColors.tealP))
             : _error != null
                 ? Center(child: Text('Error: $_error'))
                 : Builder(
                     builder: (context) {
                       // Filter doctors client-side by query and selected specialty
                       final filteredUsers = _doctors.where((uDoc) {
                         final name = (uDoc['name']?.toString() ?? '').toLowerCase();
                         if (!name.contains(_searchQuery)) return false;

                         if (_selectedSpecialty != 'All') {
                           final docSpec = uDoc['specialization'] ?? 'General Neurology';
                           if (docSpec != _selectedSpecialty) return false;
                         }
                         return true;
                       }).toList();

                       if (filteredUsers.isEmpty) {
                         return const SearchNotFoundState();
                       }

                       return ListView.separated(
                         padding: const EdgeInsets.symmetric(
                           horizontal: 16,
                           vertical: 8,
                         ),
                         itemCount: filteredUsers.length,
                         // ignore: unnecessary_underscores
                         separatorBuilder: (_, __) => const SizedBox(height: 12),
                         itemBuilder: (context, index) {
                           final data = filteredUsers[index];
                           return DoctorCard(
                             name: data['name'] ?? 'Doctor',
                             specialty: data['specialization'] ?? 'General Neurology',
                             photoUrl: data['photo_url'] ?? '',
                             onTap: () {
                               context.push(AppConstants.routeDoctorScanQr);
                             },
                           );
                         },
                       );
                     },
                   ),
        ),
      ],
    );
  }
}
