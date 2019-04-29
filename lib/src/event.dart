import 'package:uuid/uuid.dart';
import 'constants.dart';

class Event {
  Event(this.name,
      {this.sessionId, this.timestamp, this.id, Map<String, dynamic> props}) {
    addProps(props);
    uuid = Uuid().v4();
  }

  int id;
  String sessionId;
  int timestamp;
  String name;
  Map<String, dynamic> props = <String, dynamic>{};
  String uuid;

  void addProps(Map<String, dynamic> props) {
    if (props != null) {
      this.props.addAll(props);
    }
  }

  Map<String, dynamic> toPayload() {
    return <String, dynamic>{
      'event_type': name,
      'session_id': sessionId,
      'timestamp': timestamp,
      'uuid': uuid,
      'library': {
        'name': Constants.packageName,
        'version': Constants.packageVersion
      }
    }..addAll(props);
  }
}
