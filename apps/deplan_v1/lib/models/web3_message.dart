const Web3MessageChannelRequest = 'channel-secure-ui-background-request';

class Web3Message {
  String? channel;
  Web3MessageData? data;

  Web3Message.fromJson(Map json)
      : channel = json['channel'],
        data = Web3MessageData.fromJson(json['data']);

  toJson() {
    return {
      'channel': channel,
      'data': data?.toJson(),
    };
  }
}

class Web3MessageData {
  String? id;
  String? name;
  Map? request;
  Web3MessageOrigin? origin;
  Map? response;

  Web3MessageData.fromJson(Map json)
      : name = json['name'],
        id = json['id'],
        request = json['request'],
        origin = Web3MessageOrigin.fromJson(json['origin']);

  toJson() {
    return {
      'id': id,
      'name': name,
      'response': response,
      'origin': origin?.toJson(),
    };
  }
}

class Web3MessageOrigin {
  String? context;
  String? name;
  String? address;

  Web3MessageOrigin.fromJson(Map json)
      : context = json['context'],
        name = json['name'],
        address = json['address'];

  toJson() {
    return {
      'context': context,
      'name': name,
      'address': address,
    };
  }
}
