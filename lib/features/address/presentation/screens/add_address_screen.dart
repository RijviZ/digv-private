import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/features/address/domain/entities/address.dart';
import 'package:digv/features/address/presentation/providers/address_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

class AddEditAddressScreen extends ConsumerStatefulWidget {
  final Address? initialAddress;
  const AddEditAddressScreen({super.key, this.initialAddress});

  @override
  ConsumerState<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends ConsumerState<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelCtrl;
  late final TextEditingController _addressLineCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _postalCodeCtrl;
  
  double? _lat;
  double? _lng;
  late bool _isDefault;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;

  bool get _isEditing => widget.initialAddress != null;

  @override
  void initState() {
    super.initState();
    _labelCtrl = TextEditingController(text: widget.initialAddress?.label);
    _addressLineCtrl = TextEditingController(text: widget.initialAddress?.addressLine);
    _cityCtrl = TextEditingController(text: widget.initialAddress?.city);
    _stateCtrl = TextEditingController(text: widget.initialAddress?.state);
    _postalCodeCtrl = TextEditingController(text: widget.initialAddress?.postalCode);
    _lat = widget.initialAddress?.lat;
    _lng = widget.initialAddress?.lng;
    _isDefault = widget.initialAddress?.isDefault ?? false;

    if (!_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getCurrentLocation();
      });
    }
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _addressLineCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _postalCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied';
      }

      final Position position = await Geolocator.getCurrentPosition();
      _lat = position.latitude;
      _lng = position.longitude;

      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        setState(() {
          _addressLineCtrl.text = [
            place.name,
            place.street,
            place.subLocality,
          ].where((e) => e != null && e.isNotEmpty).join(', ');
          _cityCtrl.text = place.locality ?? '';
          _stateCtrl.text = place.administrativeArea ?? '';
          _postalCodeCtrl.text = place.postalCode ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_lat == null || _lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please get location first')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final data = {
        'label': _labelCtrl.text,
        'addressLine': _addressLineCtrl.text,
        'city': _cityCtrl.text,
        'state': _stateCtrl.text,
        'postalCode': _postalCodeCtrl.text,
        'lat': _lat,
        'lng': _lng,
        'isDefault': _isDefault,
      };

      if (_isEditing) {
        await ref.read(addressListProvider.notifier).updateAddress(
          widget.initialAddress!.userLocationId,
          data,
        );
      } else {
        await ref.read(addressListProvider.notifier).addAddress(data);
      }
      
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: SvgPicture.asset(
              'assets/images/CaretLeft.svg',
              colorFilter: ColorFilter.mode(
                theme.colorScheme.secondary,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: Text(
            _isEditing ? 'Edit Address' : 'Add New Address',
            style: AppTextStyles.titleLight.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w400,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      
                      Text(
                        'Location Details',
                        style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      
                      _AddressFormField(
                        controller: _labelCtrl,
                        label: 'Label (e.g. Home, Office)',
                        hint: 'Home',
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      
                      _AddressFormField(
                        controller: _addressLineCtrl,
                        label: 'Address Line',
                        hint: 'Road 5, House 12',
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _AddressFormField(
                              controller: _cityCtrl,
                              label: 'City',
                              hint: 'New Delhi',
                              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _AddressFormField(
                              controller: _stateCtrl,
                              label: 'State',
                              hint: 'Delhi',
                              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      _AddressFormField(
                        controller: _postalCodeCtrl,
                        label: 'Postal Code',
                        hint: '110001',
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),

                      TextButton.icon(
                        onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                        icon: _isLoadingLocation 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : SvgPicture.asset('assets/images/MapPin.svg', width: 18, colorFilter: ColorFilter.mode(theme.colorScheme.primary, BlendMode.srcIn)),
                        label: Text('Get Current Location', style: TextStyle(color: theme.colorScheme.primary)),
                      ),

                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Switch(
                            value: _isDefault,
                            onChanged: (v) => setState(() => _isDefault = v),
                            activeColor: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          const Text('Set as default address', style: AppTextStyles.bodyMedium),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).padding.bottom + 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    elevation: 0,
                  ),
                  child: _isSubmitting 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_isEditing ? 'Update Address' : 'Save Address', style: AppTextStyles.button),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;

  const _AddressFormField({
    required this.controller,
    required this.label,
    required this.hint,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium.copyWith(color: theme.colorScheme.secondary)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.dividerColor),
          ),
          child: TextFormField(
            controller: controller,
            validator: validator,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(color: theme.colorScheme.secondary.withOpacity(0.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
