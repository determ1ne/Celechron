import 'package:hive/hive.dart';
import '../utils/utils.dart';

class DurationAdapter extends TypeAdapter<Duration> {
  @override
  final typeId = 4;

  @override
  void write(BinaryWriter writer, Duration obj) =>
      writer.writeInt(obj.inMicroseconds);

  @override
  Duration read(BinaryReader reader) =>
      Duration(microseconds: reader.readInt());
}

class Options {
  late final Box optionsBox;

  final String dbOptions = 'dbOptions';
  final String kWorkTime = 'workTime';
  final String kRestTime = 'restTime';

  Future<void> init() async {
    Hive.registerAdapter(DurationAdapter());
    optionsBox = await Hive.openBox(dbOptions);
  }

  Duration getWorkTime() {
    if (optionsBox.get(kWorkTime) == null) {
      optionsBox.put(kWorkTime, const Duration(minutes: 45));
    }
    return optionsBox.get(kWorkTime);
  }

  void setWorkTime(Duration workTime) {
    optionsBox.put(kWorkTime, workTime);
  }

  Duration getRestTime() {
    if (optionsBox.get(kRestTime) == null) {
      optionsBox.put(kRestTime, const Duration(minutes: 15));
    }
    return optionsBox.get(kRestTime);
  }

  void setRestTime(Duration restTime) {
    optionsBox.put(kRestTime, restTime);
  }
}

late Options options;