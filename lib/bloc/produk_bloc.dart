import 'dart:convert';
import 'package:tokokita/helpers/api.dart';
import 'package:tokokita/helpers/api_url.dart';
import 'package:tokokita/model/produk.dart';

class ProdukBloc {
  static Future<List<Produk>> getProduks() async {
    try {
      String apiUrl = ApiUrl.listProduk;
      print('Fetching products from: $apiUrl');
      
      var response = await Api().get(apiUrl);
      print('Response body: ${response.body}');
      
      var jsonObj = json.decode(response.body);
      print('Decoded JSON: $jsonObj');
      
      // Handle both direct array and nested data structure
      List<dynamic> listProduk;
      if (jsonObj is List) {
        listProduk = jsonObj;
      } else if (jsonObj is Map && jsonObj.containsKey('data')) {
        listProduk = jsonObj['data'] ?? [];
      } else {
        print('Unexpected response format');
        return [];
      }
      
      print('Total products: ${listProduk.length}');
      
      List<Produk> produks = [];
      for (int i = 0; i < listProduk.length; i++) {
        try {
          produks.add(Produk.fromJson(listProduk[i]));
        } catch (e) {
          print('Error parsing product at index $i: $e');
        }
      }
      return produks;
    } catch (e) {
      print('Error in getProduks: $e');
      rethrow;
    }
  }

  static Future addProduk({Produk? produk}) async {
    try {
      String apiUrl = ApiUrl.createProduk;
      print('Adding product to: $apiUrl');
      
      var body = {
        "kode_produk": produk!.kodeProduk,
        "nama_produk": produk.namaProduk,
        "harga": produk.hargaProduk.toString()
      };
      
      var response = await Api().post(apiUrl, body);
      print('Add response: ${response.body}');
      
      var jsonObj = json.decode(response.body);
      
      // Safe code checking
      int code = int.tryParse(jsonObj['code']?.toString() ?? '0') ?? 0;
      bool status = jsonObj['status'] == true || jsonObj['status'] == 'true' || jsonObj['status'] == 1 || jsonObj['status'] == '1';
      
      print('Response code: $code, status: $status');
      
      if (code == 200 || code == 201) {
        return status;
      } else {
        throw Exception('Failed to add product: code $code');
      }
    } catch (e) {
      print('Error in addProduk: $e');
      rethrow;
    }
  }

  static Future updateProduk({required Produk produk}) async {
    try {
      String apiUrl = ApiUrl.updateProduk(int.parse(produk.id!));
      print('=== UPDATE PRODUK DEBUG ===');
      print('URL: $apiUrl');
      print('Product ID: ${produk.id}');
      print('Kode: ${produk.kodeProduk}');
      print('Nama: ${produk.namaProduk}');
      print('Harga: ${produk.hargaProduk}');
      
      var body = {
        "kode_produk": produk.kodeProduk,
        "nama_produk": produk.namaProduk,
        "harga": produk.hargaProduk.toString()
      };
      
      print('Request body: $body');
      
      var response = await Api().put(apiUrl, body);
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      var jsonObj = json.decode(response.body);
      print('Decoded JSON: $jsonObj');
      print('JSON type: ${jsonObj.runtimeType}');
      
      // Safe code checking - backend returns String "200" or "201"
      var codeValue = jsonObj['code'];
      var statusValue = jsonObj['status'];
      print('Raw code value: $codeValue (${codeValue.runtimeType})');
      print('Raw status value: $statusValue (${statusValue.runtimeType})');
      
      int code = int.tryParse(codeValue?.toString() ?? '0') ?? 0;
      bool status = statusValue == true || statusValue == 'true' || statusValue == 1 || statusValue == '1';
      
      print('Parsed code: $code');
      print('Parsed status: $status');
      print('=== END DEBUG ===');
      
      if (code == 200 || code == 201) {
        return status;
      } else {
        throw Exception('Failed to update product: code $code');
      }
    } catch (e) {
      print('!!! ERROR in updateProduk: $e');
      print('Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  static Future<bool> deleteProduk({int? id}) async {
    try {
      String apiUrl = ApiUrl.deleteProduk(id!);
      print('Deleting product at: $apiUrl');
      
      var response = await Api().delete(apiUrl);
      print('Delete response: ${response.body}');
      
      var jsonObj = json.decode(response.body);
      
      // Safe code checking
      int code = int.tryParse(jsonObj['code']?.toString() ?? '0') ?? 0;
      bool status = jsonObj['status'] == true || jsonObj['status'] == 'true' || jsonObj['status'] == 1 || jsonObj['status'] == '1';
      
      print('Response code: $code, status: $status');
      
      if (code == 200 || code == 204) {
        return status;
      } else {
        throw Exception('Failed to delete product: code $code');
      }
    } catch (e) {
      print('Error in deleteProduk: $e');
      rethrow;
    }
  }
}
