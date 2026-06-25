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
