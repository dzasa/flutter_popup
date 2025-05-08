part of flutter_popup;

/// A controller that manages CustomPopup instances and allows closing popups programmatically.
class PopupController {
  /// Map of active popup routes using a unique identifier
  static final Map<String, _PopupRoute> _activePopups = {};

  /// Register a popup route with the controller
  static void _registerPopup(String id, _PopupRoute route) {
    _activePopups[id] = route;
  }

  /// Unregister a popup route from the controller
  static void _unregisterPopup(String id) {
    _activePopups.remove(id);
  }

  /// Close a specific popup by ID
  /// Returns true if a popup was found and closed, false otherwise
  static bool closePopupById(String id) {
    final popup = _activePopups[id];
    if (popup != null) {
      popup.navigator?.pop();
      return true;
    }
    return false;
  }

  /// Close all active popups
  static void closeAllPopups() {
    final popups = List<_PopupRoute>.from(_activePopups.values);
    for (final popup in popups) {
      popup.navigator?.pop();
    }
  }

  /// Get the count of currently active popups
  static int get activePopupsCount => _activePopups.length;

  /// Check if a popup with the given ID is active
  static bool isPopupActive(String id) => _activePopups.containsKey(id);
}
