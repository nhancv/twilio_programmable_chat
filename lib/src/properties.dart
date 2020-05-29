part of twilio_programmable_chat;

/// Represents options when connecting to a [ChatClient].
class Properties {
  //#region Private API properties
  String _region;

  /// Defer certificate trust decisions to Android OS, overriding the default of certificate pinning for Twilio back-end connections.
  ///
  /// Twilio client SDKs utilize certificate pinning to prevent man-in-the-middle attacks against your connections to our services. Customers in certain very specific environments may need to opt-out of this if custom certificate authorities must be allowed to intentionally intercept communications for security or policy reasons.
  /// Setting this property to true for a Chat Client instance will defer to Android to establish whether or not a given connection is providing valid and trusted TLS certificates.
  /// Keeping this property at its default value of false allows the Twilio client SDK to determine trust when communicating with our servers.
  /// The default value is false.
  bool _deferCA;
  //#endregion

  //#region Public API properties
  /// Twilio server region to connect to.
  ///
  /// Instances exist in specific regions, so this should only be changed if needed.
  String get region {
    return _region;
  }
  //#endregion

  Properties({
    String region,
    bool deferCertificateTrustToPlatform,
  }) {
    _region = region ?? 'us1';
    _deferCA = deferCertificateTrustToPlatform ?? false;
  }

  /// Construct from a map.
  factory Properties._fromMap(Map<String, dynamic> map) {
    var properties = Properties();
    properties._updateFromMap(map);
    return properties;
  }

  /// Update properties from a map.
  void _updateFromMap(Map<String, dynamic> map) {
    _region = map['region'];
    _deferCA = map['deferCA'];
  }

  /// Create map from properties.
  Map<String, Object> _toMap() {
    return {
      'region': _region,
      'deferCA': _deferCA,
    };
  }
}
