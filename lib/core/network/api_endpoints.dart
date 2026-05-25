// lib/core/network/api_endpoints.dart
class ApiEndpoints {
  // Auth
  static const String register = '/api/v1/auth/register';
  static const String login = '/api/v1/auth/login';
  static const String logout = '/api/v1/auth/logout';

  // Pelanggan
  static String pelanggan(String id) => '/api/v1/pelanggan/$id';

  // Barber
  static const String barber = '/api/v1/barber';
  static const String barberAvailable = '/api/v1/barber/available'; // includes kursi info
  static String barberById(String id) => '/api/v1/barber/$id';

  // Layanan
  static const String layanan = '/api/v1/layanan';
  static String layananById(String id) => '/api/v1/layanan/$id';

  // Kursi
  static const String kursi = '/api/v1/kursi';
  static String kursiStatus(String id) => '/api/v1/kursi/$id/status';

  // Booking
  static const String booking = '/api/v1/booking';
  static String bookingById(String id) => '/api/v1/booking/$id';
  static String bookingStatus(String id) => '/api/v1/booking/$id/status';

  // Pembayaran
  static const String pembayaran = '/api/v1/pembayaran';
  static String pembayaranById(String id) => '/api/v1/pembayaran/$id';

  // Antrean
  static const String antrean = '/api/v1/antrean';
  static String antreanByBooking(String id) => '/api/v1/antrean/$id';

  // Notifikasi
  static const String notifikasiMe = '/api/v1/notifikasi/me';
  static const String notifikasiSemuaDibaca = '/api/v1/notifikasi/me/baca-semua';
  static String notifikasi(String id) => '/api/v1/notifikasi/$id';
  static String notifikasiDibaca(String id) => '/api/v1/notifikasi/$id/baca';
  static String notifikasiDelete(String id) => '/api/v1/notifikasi/$id';
}
