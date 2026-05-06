import 'package:get/get.dart';
import 'package:syriatravel/bot/bot_api_service.dart';
import 'package:syriatravel/bot/bot_booking_model.dart';
import 'package:syriatravel/bot/bot_firestore_service.dart';

class BotRequestsController extends GetxController {
  final BotApiService apiService;
  final BotFirestoreService firestoreService;

  BotRequestsController({
    required this.apiService,
    required this.firestoreService,
  });

  bool isLoading = false;
  String? savingBookingId;
  String? errorMessage;
  List<BotBookingModel> bookings = [];

  @override
  void onInit() {
    super.onInit();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    isLoading = true;
    errorMessage = null;
    update();

    try {
      bookings = await apiService.fetchBookings();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> approveBooking(BotBookingModel booking) async {
    savingBookingId = booking.externalId;
    update();

    try {
      await firestoreService.saveRequest(booking);
      Get.snackbar('تم', 'تم حفظ الطلب في Firestore');
    } catch (e) {
      Get.snackbar('خطأ', e.toString());
    } finally {
      savingBookingId = null;
      update();
    }
  }

  bool isBookingSaving(BotBookingModel booking) {
    return savingBookingId == booking.externalId;
  }
}
