import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class AuthUtils {
  static Future<UserType> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    final userRole = prefs.getString('userRole')?.toLowerCase() ?? 'resident';
    switch (userRole) {
      case 'manager':
        return UserType.manager;
      case 'serviceprovider':
        return UserType.serviceProvider;
      case 'resident':
      default:
        return UserType.resident;
    }
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('userRole');
    await prefs.remove('userPhone');
    await prefs.remove('userApartment');
    await prefs.remove('userAddress');
  }

  static Future<Map<String, String>> getUserProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final userType = await getUserType();
    final profileData = {
      'name': prefs.getString('userName') ?? '',
      'email': prefs.getString('userEmail') ?? '',
      'phone': prefs.getString('userPhone') ?? '', // Re-added
      'apartmentComplexName': prefs.getString('userApartment') ?? '',
    };
    switch (userType) {
      case UserType.resident:
        profileData['apartmentComplexName'] = prefs.getString('userApartment') ?? '';
        break;
      case UserType.manager:
        profileData['apartmentComplexName'] = prefs.getString('userApartment') ?? '';
        profileData['designation'] = prefs.getString('designation') ?? '';
        break;
      case UserType.serviceProvider:
        profileData['address'] = prefs.getString('userAddress') ?? '';
        break;
    }
    return profileData;
  }

  static Future<void> saveUserProfileData({
    required String name,
    required String email,
    required String phone, // Re-added
    String? apartmentComplexName,
    String? address,
    String? serviceType,
    String? designation,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);
    await prefs.setString('userPhone', phone); // Re-added
    if (apartmentComplexName != null) await prefs.setString('userApartment', apartmentComplexName);
    if (address != null) await prefs.setString('userAddress', address);
    if (serviceType != null) await prefs.setString('serviceType', serviceType);
    if (designation != null) await prefs.setString('designation', designation);
  }

  static Future<void> saveProfileImagePath(String imagePath, UserType userType) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getProfileImageKey(userType);
    await prefs.setString(key, imagePath);
  }

  static Future<String?> getProfileImagePath(UserType userType) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getProfileImageKey(userType);
    return prefs.getString(key);
  }

  static String _getProfileImageKey(UserType userType) {
    switch (userType) {
      case UserType.resident:
        return 'resident_profile_image';
      case UserType.manager:
        return 'manager_profile_image';
      case UserType.serviceProvider:
        return 'provider_profile_image';
    }
  }

  static Future<void> updateUserDataOnLogin(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', userData['token'] ?? '');
    await prefs.setString('userId', userData['user']['id'] ?? '');
    await prefs.setString('userName', userData['user']['name'] ?? '');
    await prefs.setString('userEmail', userData['user']['email'] ?? '');
    await prefs.setString('userRole', userData['user']['role'].toLowerCase() ?? 'resident');
    await prefs.setString('userPhone', userData['user']['phone'] ?? ''); // Re-added

    final role = userData['user']['role'].toLowerCase();
    if (role == 'resident' || role == 'manager') {
      await prefs.setString('userApartment', userData['user']['apartmentComplexName'] ?? '');
    }
    if (role == 'serviceprovider') {
      await prefs.setString('userAddress', userData['user']['address'] ?? ''); // Optional
    }
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }
}