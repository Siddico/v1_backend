class ApiResponseParser {
  /// Extracts a list of dynamic items from a JSON response payload safely.
  /// Handles cases where the backend wraps the list in `{"data": {"predictions": []}}`,
  /// `{"data": []}`, or similar nested structures.
  static List<dynamic> extractList(dynamic rawData) {
    if (rawData == null) return [];
    if (rawData is List) return rawData;
    
    if (rawData is Map) {
      if (rawData.containsKey('data') && rawData['data'] is List) {
        return rawData['data'];
      }
      if (rawData.containsKey('health_data') && rawData['health_data'] is List) {
        return rawData['health_data'];
      }
      if (rawData.containsKey('predictions') && rawData['predictions'] is List) {
        return rawData['predictions'];
      }
      if (rawData.containsKey('appointments') && rawData['appointments'] is List) {
        return rawData['appointments'];
      }
      if (rawData.containsKey('medications') && rawData['medications'] is List) {
        return rawData['medications'];
      }
      if (rawData.containsKey('chats') && rawData['chats'] is List) {
        return rawData['chats'];
      }
      if (rawData.containsKey('sessions') && rawData['sessions'] is List) {
        return rawData['sessions'];
      }
      if (rawData.containsKey('messages') && rawData['messages'] is List) {
        return rawData['messages'];
      }
      if (rawData.containsKey('notifications') && rawData['notifications'] is List) {
        return rawData['notifications'];
      }
      if (rawData.containsKey('reports') && rawData['reports'] is List) {
        return rawData['reports'];
      }
      if (rawData.containsKey('emergency_recommendations') && rawData['emergency_recommendations'] is List) {
        return rawData['emergency_recommendations'];
      }
      if (rawData.containsKey('relationship_requests') && rawData['relationship_requests'] is List) {
        return rawData['relationship_requests'];
      }
      
      // Look for known nested array keys or any array
      for (var value in rawData.values) {
        if (value is List) {
          return value;
        }
      }
    }
    
    return [];
  }
}
