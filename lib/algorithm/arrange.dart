import 'package:celechron/utils/utils.dart';
import '../model/deadline.dart';
import '../model/period.dart';
import 'package:uuid/uuid.dart';

class TimeAssignSet {
  bool isValid;
  Duration restTime;
  List<Period> assignSet;

  TimeAssignSet({
    this.isValid = false,
    this.restTime = const Duration(minutes: 15),
    this.assignSet = const [],
  });
}

TimeAssignSet findSolution(Duration workTime, Duration targetRestTime,
    List<Deadline> _deadlineList, List<Period> _ableList) {
  print('findSolution: ');
  print('$workTime $targetRestTime');
  print('deadlineList: ');
  for (var x in _deadlineList) {
    print(x.endTime.toString());
    print(x.endTime.timeZoneOffset);
  }
  print('ableList: ');
  for (var x in _ableList) {
    print('${x.startTime} ${x.endTime}');
    print(x.startTime.timeZoneOffset);
  }

  List<Deadline> deadlineList = [];
  List<Period> ableList = [];

  for (var x in _deadlineList) {
    deadlineList.add(x.copyWith());
  }
  for (var x in _ableList) {
    ableList.add(x.copyWith());
  }

  deadlineList.sort(compareDeadline);
  ableList.sort(comparePeriod);
  ableList = List.from(ableList.reversed);

  Map<String, bool> isFresh = {};
  for (Period period in ableList) {
    isFresh[period.uid] = true;
  }

  TimeAssignSet ans = TimeAssignSet(
    isValid: true,
    restTime: targetRestTime,
    assignSet: [],
  );

  for (Deadline cur in deadlineList) {
    print(
        'deadlineList ${cur.endTime.toString()}, ${cur.timeSpent} / ${cur.timeNeeded}, ${ans.assignSet.length}');
    if (targetRestTime <= Duration.zero) cur.isBreakable = false;
    bool isStarting = cur.isBreakable;

    while (cur.timeSpent < cur.timeNeeded) {
      if (ableList.isEmpty) {
        ans.isValid = false;
        return ans;
      }

      Period now = ableList.removeLast();

      if (isStarting) {
        if (!isFresh[now.uid]!) {
          now.startTime = now.startTime.add(targetRestTime);
        }
        isStarting = false;
      }

      Duration curLength = cur.timeNeeded - cur.timeSpent;
      Duration nowLength = now.endTime.difference(now.startTime);
      Duration thisCut = curLength < nowLength ? curLength : nowLength;
      if (cur.isBreakable) {
        thisCut = thisCut < workTime ? thisCut : workTime;
      }
      print(cur.isBreakable);
      print(thisCut);
      print(workTime);
      if (now.startTime.add(thisCut).isAfter(now.endTime)) {
        ans.isValid = false;
        return ans;
      }

      Period period = Period(
        fromUid: cur.uid,
        periodType: PeriodType.flow,
        description: cur.description,
        startTime: now.startTime,
        endTime: now.startTime.add(thisCut),
        location: cur.location,
        summary: cur.summary,
      );
      period.genUid();
      ans.assignSet.add(period);
      cur.timeSpent += thisCut;
      now.startTime = now.startTime.add(thisCut);
      if (cur.isBreakable) {
        now.startTime = now.startTime.add(targetRestTime);
      }

      isFresh[now.uid] = cur.isBreakable && (cur.timeSpent >= cur.timeNeeded);
      if (now.startTime.isBefore(now.endTime)) {
        ableList.add(now);
      }
    }
  }

  return ans;
}

TimeAssignSet getTimeAssignSet(Duration workTime, Duration restTime,
    List<Deadline> deadlineList, List<Period> ableList) {
  TimeAssignSet ans = findSolution(workTime, restTime, deadlineList, ableList);
  if (ans.isValid) return ans;

  int l = 0, r = restTime.inMinutes - 1;
  while (r > l) {
    int mid = (l + r + 1) ~/ 2;
    TimeAssignSet res =
        findSolution(workTime, Duration(minutes: mid), deadlineList, ableList);
    if (res.isValid) {
      l = mid;
      ans = res;
    } else {
      r = mid - 1;
    }
  }

  if (!ans.isValid) ans.assignSet = [];
  return ans;
}
