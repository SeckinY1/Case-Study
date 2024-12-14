import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:task/models/user_model.dart';

class ApiService extends ChangeNotifier {
  final Dio _dio = Dio();
  List<User> users = [];

  // API URL'ler
  final String uploadImageUrl = "http://146.59.52.68:11235/api/User/UploadImage";
  final String userUrl = "http://146.59.52.68:11235/api/User";

  // Görsel Yükleme Fonksiyonu
  Future<String?> uploadImage(File imageFile) async {
    try {
      // Multipart form-data oluştur
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      // API çağrısı
      Response response = await _dio.post(
        uploadImageUrl,
        data: formData,
        options: Options(headers: {
          'accept': 'application/json',
          'ApiKey': 'ef7206fd-0639-4371-ac87-c7939fc841d8',
          'Content-Type': 'multipart/form-data',
        }),
      );

      // Yanıttan imageUrl'i al
      if (response.statusCode == 200 && response.data['success'] == true) {
        final String imageUrl = response.data['data']['imageUrl'];
        print('Yüklenen görsel URL: $imageUrl');
        return imageUrl;
      } else {
        print('Görsel yükleme başarısız: ${response.data['messages']}');
        return null;
      }
    } catch (e) {
      print('Görsel yüklenirken hata: $e');
      return null;
    }
  }

  // Kullanıcı Oluşturma Fonksiyonu
  Future<void> createUser({required String firstName, required String lastName, required String phoneNumber, required String profileImageUrl}) async {
    try {
      // Kullanıcı verisi
      final Map<String, dynamic> userData = {
        "firstName": firstName,
        "lastName": lastName,
        "phoneNumber": phoneNumber,
        "profileImageUrl": profileImageUrl,
      };

      // API çağrısı
      Response response = await _dio.post(
        userUrl,
        data: userData,
        options: Options(headers: {
          'accept': 'application/json',
          'ApiKey': 'ef7206fd-0639-4371-ac87-c7939fc841d8',
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200) {
        print('Kullanıcı oluşturma başarılı: ${response.data}');
      } else {
        print('Kullanıcı oluşturma başarısız: ${response.data}');
      }
    } catch (e) {
      print('Kullanıcı oluşturulurken hata: $e');
    }
  }

  Future<void> getUsers({String? search, int skip = 0, int take = 10}) async {
    try {
      // Parametreler
      final Map<String, dynamic> queryParams = {
        'search': search ?? '',
        'skip': skip,
        'take': take,
      };

      // API Çağrısı
      Response response = await _dio.get(
        userUrl,
        queryParameters: queryParams,
        options: Options(headers: {
          'accept': 'text/plain',
          'ApiKey': 'ef7206fd-0639-4371-ac87-c7939fc841d8',
        }),
      );

      if (response.statusCode == 200) {
        // Gelen veriyi güvenli bir şekilde işleyelim
        var usersData = response.data['data']['users'];

        // Eğer 'users' null ise boş bir listeye döneriz
        if (usersData != null) {
          users = usersData.map<User>((userJson) {
            return User.fromJson(userJson);
          }).toList();
          print('Kullanıcılar başarıyla getirildi:');
          print(users);
        } else {
          print('Kullanıcı verisi boş.');
        }
      } else {
        print('Kullanıcı getirme başarısız: ${response.data}');
      }
    } catch (e) {
      print('Kullanıcı getirilirken hata: $e');
    }

    notifyListeners();
  }

  // Tüm İşlemi Tek Fonksiyonda Birleştirme
  Future<void> uploadImageAndCreateUser({required File imageFile, required String firstName, required String lastName, required String phoneNumber}) async {
    // 1. Görseli Yükle
    final String? imageUrl = await uploadImage(imageFile);

    if (imageUrl != null) {
      // 2. Görsel URL'sini Kullanıcıya Ekle
      await createUser(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        profileImageUrl: imageUrl,
      );
    } else {
      print('Görsel yüklenemedi, kullanıcı oluşturma işlemi iptal edildi.');
    }
  }
}
