class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - change this for production
  // static const String baseUrl = 'http://192.168.:3000/api/v1';
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  //static const String baseUrl = 'http://localhost:3000/api/v1';ip halna pardaina?
  // For Android Emulator use: 'http://10.0.2.2:3000/api/v1'
  // For iOS Simulator use: 'http://localhost:5000/api/v1'
  // For Physical Device use your computer's IP: 'http://192.168.x.x:
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

// ========================= Auth Endpoints =========================
  static const String login = "/auth/login";
  static const String signup = "/auth/register";
   
  // ========================= PHOTO (IMAGE) ENDPOINTS =========================

  static const String uploadPhoto = "/media/photo/upload";
  static const String uploadPhotos = "/media/photos/upload";
  static const String getPhoto = "/media/photo";

  // ========================= BOOKING ENDPOINTS =========================

  static const String services = "/bookings/services";
  static const String createBooking = "/bookings";
  static const String allBookings = "/bookings";
  static const String availableBookings = "/bookings/available";
  static const String openBookings = "/bookings/open";
  static const String unassignedBookings = "/bookings/unassigned";
  static const String myBookings = "/bookings/me";
  static String deleteBooking(String id) => "/bookings/$id";
  static String acceptBooking(String id) => "/bookings/$id/accept";
  static String assignSelfBooking(String id) => "/bookings/$id/assign-self";
  static String claimBooking(String id) => "/bookings/$id/claim";
  static String assignBooking(String id) => "/bookings/$id/assign";
  static String assignBookingToWorker(String id, String workerId) =>
      "/bookings/$id/assign/$workerId";
  static String assignWorkerBooking(String id) => "/bookings/$id/assign-worker";
  static const String assignBookingRoot = "/bookings/assign";
  static String bookingById(String id) => "/bookings/$id";
  static String completeBooking(String id) => "/bookings/$id/complete";
  static String markBookingComplete(String id) => "/bookings/$id/mark-complete";
  static String finishBooking(String id) => "/bookings/$id/finish";

  // ========================= PHOTO URL HELPER =========================

  static String photoUrl(String fileName) {
    return "$baseUrl$getPhoto/$fileName";
  }
}
