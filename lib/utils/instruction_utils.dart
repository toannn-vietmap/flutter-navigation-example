import 'package:vietmap_flutter_navigation/models/direction_route.dart';

class InstructionUtils {
  /// Hàm lấy đường dẫn icon từ thư mục assets
  /// Input: Maneuver object
  /// Output: String path (ví dụ: 'assets/navigation_symbol/turn_left.svg')
  static String getManeuverIconPath(Maneuver maneuver) {
    const String basePath = 'assets/navigation_symbol';
    const String defaultIcon =
        '$basePath/progress_arrow.svg'; // Icon mặc định nếu lỗi

    // 1. Chuẩn hóa dữ liệu đầu vào
    final String type = maneuver.type?.toLowerCase().trim() ?? '';
    // Mapbox modifier có thể chứa khoảng trắng (ví dụ "sharp right"),
    // nhưng tên file của bạn dùng gạch dưới ("sharp_right").
    final String modifier =
        maneuver.modifier?.toLowerCase().replaceAll(' ', '_') ?? '';

    // Helper để ghép chuỗi cho gọn
    String buildPath(String prefix, [String? suffix]) {
      final mod = (suffix != null && suffix.isNotEmpty) ? suffix : modifier;
      // Nếu không có modifier, trả về file gốc (ví dụ "fork.svg")
      if (mod.isEmpty) return '$basePath/$prefix.svg';
      return '$basePath/${prefix}_$mod.svg';
    }

    // 2. Logic Mapping
    switch (type) {
      case 'arrive':
        // File có sẵn: arrive_left, arrive_right, arrive_straight
        return buildPath('arrive');

      case 'depart':
        // File có sẵn: depart_left, depart_right, depart_straight
        return buildPath('depart');

      case 'turn':
        // File có sẵn: turn_left, turn_sharp_right, turn_straight...
        // Đặc biệt: Nếu modifier là 'uturn' -> map sang bộ icon uturn
        if (modifier.contains('uturn')) {
          return '$basePath/uturn.svg'; // Hoặc uturn_left/right nếu logic API trả về cụ thể
        }
        return buildPath('turn');

      case 'continue':
      case 'new name': // "New name" bản chất là đi tiếp
      case 'straight':
        // Nếu modifier là uturn (trường hợp hiếm)
        if (modifier.contains('uturn')) return '$basePath/continue_uturn.svg';
        // Mặc định map về continue_straight nếu không có modifier
        if (modifier.isEmpty) return '$basePath/continue_straight.svg';
        return buildPath('continue');

      case 'merge':
        // File có sẵn: merge_left, merge_slight_left...
        return buildPath('merge');

      case 'on ramp':
        // [XỬ LÝ CASE THIẾU]: On ramp (vào cao tốc) bản chất là nhập làn (merge)
        // Mapbox on ramp thường đi kèm modifier left/right/slight...
        // Map sang icon "merge"
        return buildPath('merge');

      case 'off ramp':
        // [XỬ LÝ CASE THIẾU]: Off ramp (ra cao tốc)
        // Có thể dùng icon "exit" hoặc "fork".
        // Tôi ưu tiên dùng "exit" vì bạn có bộ icon exit_left, exit_right...
        return buildPath('exit');

      case 'fork':
        // File có sẵn: fork_left, fork_straight...
        return buildPath('fork');

      case 'end of road':
        // File có sẵn: end_of_road_left, end_of_road_right
        return buildPath('end_of_road');

      case 'roundabout':
        // File có sẵn: roundabout_left, roundabout_sharp_left...
        // Logic: Lấy roundabout + modifier
        return buildPath('roundabout');

      case 'rotary':
        // File có sẵn: rotary_left, rotary_sharp_right...
        return buildPath('rotary');

      case 'exit roundabout':
      case 'exit rotary':
        // [XỬ LÝ CASE KHÁC TÊN]: Ra khỏi vòng xuyến
        // Dùng bộ icon "exit"
        return buildPath('exit');

      case 'roundabout turn':
        // Vòng xuyến nhỏ, coi như là turn bình thường hoặc roundabout
        return buildPath('roundabout');

      case 'notification':
        return '$basePath/flag.svg';

      default:
        // Các trường hợp không xác định
        if (modifier.isNotEmpty) {
          // Cố gắng tìm file theo modifier (ví dụ type lạ nhưng modifier là 'left' -> turn_left)
          return '$basePath/turn_$modifier.svg';
        }
        return defaultIcon;
    }
  }

  /// Hàm chính để tạo câu hướng dẫn điều hướng
  static String generateInstruction(Maneuver maneuver, {String? roadName}) {
    // 1. Xử lý các trường hợp đặc biệt không cần modifier hoặc logic riêng
    if (maneuver.type == null) return "Đi tiếp";

    final String roadInfo =
        (roadName != null && roadName.isNotEmpty) ? " vào $roadName" : "";

    switch (maneuver.type) {
      case 'arrive':
        // Arrive: Đã đến nơi
        if (maneuver.modifier != null) {
          String side = _translateSide(maneuver.modifier);
          return "Đến điểm đến nằm ở phía $side";
        }
        return "Bạn đã đến nơi";

      case 'depart':
        // Depart: Xuất phát
        String direction = _translateModifier(maneuver.modifier) ?? "hướng đi";
        // return "Xuất phát về $direction";
        return direction;

      case 'roundabout':
      case 'rotary':
        // Roundabout/Rotary: Vòng xuyến
        String exitStr =
            (maneuver.exit != null) ? "lối ra thứ ${maneuver.exit}" : "lối ra";
        return "Vào vòng xuyến, đi theo $exitStr$roadInfo";

      case 'roundabout turn':
        return "Rẽ tại vòng xuyến$roadInfo";

      case 'exit roundabout':
      case 'exit rotary':
        return "Ra khỏi vòng xuyến$roadInfo";

      case 'merge':
        // Merge: Nhập làn
        String side = _translateSide(maneuver.modifier); // Thường là left/right
        return "Nhập làn sang $side$roadInfo";

      case 'on ramp':
        return "Đi vào đường dẫn cao tốc$roadInfo";

      case 'off ramp':
        return "Ra khỏi đường cao tốc$roadInfo";

      case 'fork':
        // Fork: Ngã ba/tách làn, thường dùng Keep left/right
        String side = _translateSide(maneuver.modifier);
        return "Giữ bên $side tại ngã rẽ$roadInfo";

      case 'end of road':
        // End of road: Hết đường (T-intersection)
        String turnDir = _translateModifier(maneuver.modifier) ?? "hướng đi";
        return "Đi hết đường, rẽ $turnDir$roadInfo";

      case 'continue':
      case 'new name':
      case 'straight':
        // Straight: Đi thẳng
        // New name: Đổi tên đường nhưng vẫn đi thẳng
        // Continue: Tiếp tục đi
        if (roadName != null && roadName.isNotEmpty) {
          return "Tiếp tục đi thẳng trên $roadName";
        }
        return "Tiếp tục đi thẳng";

      case 'notification':
        return "Có thay đổi về điều kiện giao thông";

      case 'turn':
      default:
        // Xử lý các loại rẽ thông thường (Turn)
        // Kết hợp với modifier: left, right, sharp, slight...
        String action = _translateModifier(maneuver.modifier) ?? "Rẽ";
        return "$action$roadInfo";
    }
  }

  /// Helper: Dịch modifier sang hành động cụ thể (cho case Turn)
  /// Dựa trên Image modifier
  static String? _translateModifier(String? modifier) {
    if (modifier == null) return null;
    switch (modifier) {
      case 'uturn':
        return "Quay đầu";
      case 'sharp right':
        return "Ngoặt gấp sang phải";
      case 'right':
        return "Rẽ phải";
      case 'slight right':
        return "Chếch sang phải";
      case 'sharp left':
        return "Ngoặt gấp sang trái";
      case 'left':
        return "Rẽ trái";
      case 'slight left':
        return "Chếch sang trái";
      case 'straight':
        return "Đi thẳng";
      default:
        return "Rẽ";
    }
  }

  /// Helper: Dịch modifier sang phía (cho case Fork, Merge, Arrive)
  static String _translateSide(String? modifier) {
    if (modifier == null) return "này";
    if (modifier.contains("left")) return "trái";
    if (modifier.contains("right")) return "phải";
    return "này";
  }
}
