String getFriendlyErrorMessage(String? error) {
  if (error == null || error.isEmpty) {
    return 'Noma\'lum xatolik yuz berdi';
  }
  if (error.contains('401')) {
    return 'Sessiya vaqti tugadi yoki xatolik yuz berdi. Iltimos, qaytadan kiring.';
  }
  if (error.contains('403')) {
    return 'Sizga bu amalni bajarishga ruxsat berilmagan.';
  }
  if (error.contains('404')) {
    return 'Ma\'lumot topilmadi.';
  }
  if (error.contains('500') || error.contains('502')) {
    return 'Serverda xatolik. Birozdan so\'ng urinib ko\'ring.';
  }
  if (error.contains('SocketException') ||
      error.contains('Connection refused')) {
    return 'Internet aloqasi yo\'q. Iltimos, tekshiring.';
  }

  // Clean up common prefixes
  return error.replaceAll('Exception: ', '').replaceAll('Failure: ', '');
}
